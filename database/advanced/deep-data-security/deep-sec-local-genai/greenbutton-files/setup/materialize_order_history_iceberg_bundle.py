#!/usr/bin/env python3
"""Publish the checked-in Iceberg table into the configured destination.

The bundle contains the complete small sample table. Its metadata is portable
and may contain local ``file://`` locations, so this script rewrites JSON and
Avro manifest locations to the ``oci://bucket@namespace/...`` form before
uploading every object in the table graph.

The Stack uploads the extracted objects through Stack-created PARs. The script
does not generate a new table with Spark or PyIceberg.
"""

import io
import hashlib
import json
import os
import shutil
import tempfile
import urllib.request
import zipfile
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple
from urllib.parse import quote

from fastavro import reader as avro_reader
from fastavro import writer as avro_writer


TABLE_ROOT = "order_history"
NAMESPACE = "default"
TABLE_NAME = "order_history"
BUNDLE_OBJECT = ".delivery-bundle.zip"
METADATA_URL_FILE = Path("/home/opc/.deep-sec-order-history-metadata-url")


def native_url(bucket: str, namespace: str, region: str, object_name: str) -> str:
    return (
        f"https://objectstorage.{region}.oraclecloud.com/"
        f"n/{namespace}/b/{bucket}/o/{quote(object_name, safe='/')}"
    )


def native_graph_url(bucket: str, namespace: str, object_name: str) -> str:
    """Return the OCI location form stored in the Iceberg metadata graph."""
    return f"oci://{bucket}@{namespace}/{object_name}"


def object_name_from_location(value: str) -> Optional[str]:
    if value.startswith("oci://"):
        bucket_and_namespace, separator, object_name = value[6:].partition("/")
        if separator and "@" in bucket_and_namespace and object_name:
            return object_name
    if "/o/" in value:
        return value.rsplit("/o/", 1)[1].replace("%2F", "/")
    return None


def target_key(source_key: str, target_prefix: str) -> str:
    prefix = f"{TABLE_ROOT}/"
    if not source_key.startswith(prefix):
        raise ValueError(f"Bundle object is outside {TABLE_ROOT}/: {source_key}")
    return f"{target_prefix}/default/{TABLE_NAME}/{source_key[len(prefix):]}"


def target_key_from_location(value: str, target_prefix: str) -> Optional[str]:
    marker = f"/{TABLE_ROOT}"
    position = value.rfind(marker)
    if position < 0:
        return None
    suffix = value[position + len(marker) :].lstrip("/")
    return f"{target_prefix}/default/{TABLE_NAME}" + (f"/{suffix}" if suffix else "")


def rewrite_location(value: str, bucket: str, namespace: str, region: str, target_prefix: str) -> str:
    if not value.startswith(("file://", "s3://", "http://", "https://")):
        return value
    object_name = target_key_from_location(value, target_prefix)
    if object_name is None:
        return value
    return native_graph_url(bucket, namespace, object_name)


def rewrite_value(value: Any, bucket: str, namespace: str, region: str, target_prefix: str) -> Any:
    if isinstance(value, str):
        return rewrite_location(value, bucket, namespace, region, target_prefix)
    if isinstance(value, list):
        return [rewrite_value(item, bucket, namespace, region, target_prefix) for item in value]
    if isinstance(value, dict):
        return {
            key: rewrite_value(child, bucket, namespace, region, target_prefix)
            for key, child in value.items()
        }
    return value


def avro_header_metadata(raw_metadata: Dict[Any, Any]) -> Dict[str, Any]:
    result: Dict[str, Any] = {}
    for key, value in raw_metadata.items():
        text_key = key.decode("utf-8") if isinstance(key, bytes) else key
        if text_key in {"avro.schema", "avro.codec"}:
            continue
        result[text_key] = value.decode("utf-8") if isinstance(value, bytes) else value
    return result


def read_avro(payload: bytes) -> Tuple[Any, Dict[str, Any], str, List[Dict[str, Any]]]:
    with io.BytesIO(payload) as source:
        avro = avro_reader(source)
        return avro.writer_schema, avro_header_metadata(avro.metadata), avro.codec, list(avro)


def write_avro(
    schema: Any,
    metadata: Dict[str, Any],
    codec: str,
    records: Iterable[Dict[str, Any]],
) -> bytes:
    output = io.BytesIO()
    avro_writer(output, schema, records, codec=codec, metadata=metadata)
    return output.getvalue()


def put_object(par_url: str, relative_name: str, payload: bytes, content_type: str) -> None:
    url = par_url.rstrip("/")
    if relative_name:
        url = f"{url}/{quote(relative_name, safe='/')}"
    request = urllib.request.Request(
        url,
        data=payload,
        method="PUT",
        headers={"Content-Type": content_type},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        if response.status not in (200, 201):
            raise RuntimeError(f"Object Storage returned HTTP {response.status} for {relative_name}")


def safe_extract(archive: zipfile.ZipFile, destination: Path) -> None:
    destination_resolved = destination.resolve()
    for member in archive.infolist():
        member_path = (destination / member.filename).resolve()
        if destination_resolved != member_path and destination_resolved not in member_path.parents:
            raise RuntimeError(f"Unsafe bundle member: {member.filename}")
        if member.is_dir():
            member_path.mkdir(parents=True, exist_ok=True)
            continue
        member_path.parent.mkdir(parents=True, exist_ok=True)
        with archive.open(member) as source, member_path.open("wb") as target:
            shutil.copyfileobj(source, target)


def main() -> None:
    bucket = os.environ["ORDER_HISTORY_BUCKET"]
    namespace = os.environ["ORDER_HISTORY_NAMESPACE"]
    region = os.environ["OCI_REGION"]
    target_prefix = os.environ.get("ORDER_HISTORY_OCI_EXPORT_PREFIX", "order_history_iceberg").strip("/")
    par_url = os.environ.get("ORDER_HISTORY_BUNDLE_PAR_URL", "").strip()
    archive_url = os.environ.get("ORDER_HISTORY_BUNDLE_ARCHIVE_URL", "").strip()
    if not archive_url:
        if not par_url:
            raise RuntimeError("No Iceberg bundle archive URL was supplied.")
        archive_url = f"{par_url.rstrip('/')}/{BUNDLE_OBJECT}"
    try:
        write_par_urls = json.loads(os.environ["ORDER_HISTORY_BUNDLE_WRITE_PAR_URLS"])
    except (KeyError, json.JSONDecodeError) as exc:
        raise RuntimeError("Missing or invalid Iceberg object-write PAR map.") from exc
    if not isinstance(write_par_urls, dict):
        raise RuntimeError("The Iceberg object-write PAR map must be a JSON object.")
    archive_path = Path(tempfile.mkstemp(prefix="deep-sec-order-history-", suffix=".zip")[1])

    try:
        with urllib.request.urlopen(archive_url, timeout=60) as source:
            archive_path.write_bytes(source.read())
        expected_hash = os.environ.get("ORDER_HISTORY_BUNDLE_ARCHIVE_SHA256", "").strip()
        if expected_hash:
            actual_hash = hashlib.sha256(archive_path.read_bytes()).hexdigest()
            if actual_hash != expected_hash:
                raise RuntimeError(
                    "The downloaded Iceberg bundle checksum does not match the Terraform artifact."
                )

        with tempfile.TemporaryDirectory(prefix="deep-sec-order-history-bundle-") as temp_dir:
            extracted = Path(temp_dir)
            with zipfile.ZipFile(archive_path) as archive:
                safe_extract(archive, extracted)

            source_root = extracted / TABLE_ROOT
            source_paths = sorted(path for path in source_root.rglob("*") if path.is_file())
            if not source_paths:
                raise RuntimeError("The Order History bundle contains no table files.")

            source_payloads = {
                path.relative_to(extracted).as_posix(): path.read_bytes() for path in source_paths
            }
            metadata_keys = sorted(
                key for key in source_payloads if f"/{TABLE_ROOT}/metadata/" in f"/{key}" and key.endswith(".metadata.json")
            )
            if not metadata_keys:
                raise RuntimeError("The Order History bundle contains no metadata JSON.")

            output_payloads: Dict[str, bytes] = {}
            manifest_lists: List[Tuple[str, Any, Dict[str, Any], str, List[Dict[str, Any]]]] = []
            for source_key, payload in source_payloads.items():
                output_key = target_key(source_key, target_prefix)
                if source_key.endswith(".metadata.json"):
                    document = json.loads(payload.decode("utf-8"))
                    rewritten = rewrite_value(document, bucket, namespace, region, target_prefix)
                    output_payloads[output_key] = (
                        json.dumps(rewritten, separators=(",", ":"), sort_keys=False).encode("utf-8") + b"\n"
                    )
                elif source_key.endswith(".avro"):
                    schema, metadata, codec, records = read_avro(payload)
                    if records and "manifest_path" in records[0]:
                        manifest_lists.append((output_key, schema, metadata, codec, records))
                    else:
                        rewritten_records = [
                            rewrite_value(record, bucket, namespace, region, target_prefix)
                            for record in records
                        ]
                        output_payloads[output_key] = write_avro(schema, metadata, codec, rewritten_records)
                else:
                    output_payloads[output_key] = payload

            for output_key, schema, metadata, codec, records in manifest_lists:
                rewritten_records = []
                for record in records:
                    rewritten = rewrite_value(record, bucket, namespace, region, target_prefix)
                    manifest_path = rewritten.get("manifest_path")
                    if not isinstance(manifest_path, str):
                        raise RuntimeError("Iceberg manifest list record has no manifest_path.")
                    manifest_name = object_name_from_location(manifest_path)
                    if manifest_name is None:
                        raise RuntimeError(f"Iceberg manifest list has an unrecognized manifest_path: {manifest_path!r}.")
                    manifest_payload = output_payloads.get(manifest_name)
                    if manifest_payload is None:
                        raise RuntimeError(f"Manifest list points to missing object {manifest_name!r}.")
                    rewritten["manifest_length"] = len(manifest_payload)
                    rewritten_records.append(rewritten)
                output_payloads[output_key] = write_avro(schema, metadata, codec, rewritten_records)

            latest_metadata = target_key(metadata_keys[-1], target_prefix)
            latest_metadata_payload = output_payloads.get(latest_metadata)
            if latest_metadata_payload is None:
                raise RuntimeError(f"Latest metadata object was not materialized: {latest_metadata!r}.")

            for object_name, payload in sorted(output_payloads.items()):
                object_par_url = write_par_urls.get(object_name)
                if not isinstance(object_par_url, str) or not object_par_url:
                    raise RuntimeError(f"No object-write PAR was supplied for {object_name!r}.")
                put_object(object_par_url, "", payload, "application/octet-stream")

            metadata_url = native_url(bucket, namespace, region, latest_metadata)
            METADATA_URL_FILE.write_text(metadata_url + "\n", encoding="utf-8")
            os.chmod(METADATA_URL_FILE, 0o600)
            print(f"Published {len(output_payloads)} pre-created Apache Iceberg objects.")
            print(f"Wrote Oracle metadata URL to {METADATA_URL_FILE}")
    finally:
        archive_path.unlink(missing_ok=True)


if __name__ == "__main__":
    main()
