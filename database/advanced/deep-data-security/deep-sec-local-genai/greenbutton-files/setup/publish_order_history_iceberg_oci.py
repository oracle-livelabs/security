"""Copy and publish an OCI-native view of the Order History Iceberg table.

PyIceberg writes through OCI's S3-compatible API and consequently records
``s3://`` locations throughout the Iceberg metadata graph. Autonomous Database
needs OCI-native Object Storage URLs when it follows those metadata and data
references. This publisher copies the complete table file graph into a
separate prefix, rewrites metadata and manifest references to the copied
objects, then records the rewritten root metadata URL for database bootstrap.
"""

import io
import json
import os
from pathlib import Path
from typing import Any, Dict, Iterable, List, Tuple

import pyarrow as pa
from fastavro import reader as avro_reader
from fastavro import writer as avro_writer
from pyiceberg.io.pyarrow import PyArrowFileIO


SOURCE_PREFIX = os.environ.get("ORDER_HISTORY_SOURCE_PREFIX", "order_history_iceberg").strip("/")
TARGET_PREFIX = os.environ.get(
    "ORDER_HISTORY_OCI_EXPORT_PREFIX",
    os.environ.get("ORDER_HISTORY_OCI_TEST_PREFIX", "order_history_iceberg_oci"),
).strip("/")
URI_STYLE = os.environ.get("ORDER_HISTORY_EXPORT_URI_STYLE", "native")
NAMESPACE = "default"
TABLE_NAME = "order_history"
METADATA_URL_FILE = Path("/home/opc/.deep-sec-order-history-metadata-url")


def native_url(bucket: str, namespace: str, region: str, object_name: str) -> str:
    """Return an OCI URI form accepted by Autonomous Database."""
    if URI_STYLE == "native":
        return (
            f"https://objectstorage.{region}.oraclecloud.com/"
            f"n/{namespace}/b/{bucket}/o/{object_name}"
        )
    if URI_STYLE == "native_dedicated":
        return (
            f"https://{namespace}.objectstorage.{region}.oci.customer-oci.com/"
            f"n/{namespace}/b/{bucket}/o/{object_name}"
        )
    if URI_STYLE == "s3_compat":
        return (
            f"https://{namespace}.compat.objectstorage.{region}.oci.customer-oci.com/"
            f"{bucket}/{object_name}"
        )
    if URI_STYLE == "s3_compat_scheme":
        return (
            f"s3://{namespace}.compat.objectstorage.{region}.oraclecloud.com/"
            f"{bucket}/{object_name}"
        )
    raise ValueError(
        "ORDER_HISTORY_EXPORT_URI_STYLE must be 'native', 'native_dedicated', 's3_compat', or "
        "'s3_compat_scheme', "
        f"not {URI_STYLE!r}."
    )


def s3_key(value: str, bucket: str) -> str:
    prefix = f"s3://{bucket}/"
    if not value.startswith(prefix):
        raise ValueError(f"Expected an OCI S3-compatible location, got: {value}")
    return value[len(prefix) :]


def target_key(source_key: str) -> str:
    prefix = f"{SOURCE_PREFIX}/"
    if not source_key.startswith(prefix):
        raise ValueError(f"Object is outside the source warehouse: {source_key}")
    return f"{TARGET_PREFIX}/{source_key[len(prefix):]}"


def avro_header_metadata(raw_metadata: Dict[Any, Any]) -> Dict[str, Any]:
    """Preserve Iceberg's Avro header metadata, excluding Avro-owned keys."""
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
        records = list(avro)
        return avro.writer_schema, avro_header_metadata(avro.metadata), avro.codec, records


def write_avro(schema: Any, metadata: Dict[str, Any], codec: str, records: Iterable[Dict[str, Any]]) -> bytes:
    output = io.BytesIO()
    avro_writer(output, schema, records, codec=codec, metadata=metadata)
    return output.getvalue()


def rewrite_manifest_record(value: Any, bucket: str, namespace: str, region: str) -> Any:
    """Rewrite data/delete-file paths to the copied native Object Storage URL."""
    if isinstance(value, list):
        return [rewrite_manifest_record(item, bucket, namespace, region) for item in value]
    if not isinstance(value, dict):
        return value

    rewritten = {}
    for key, child in value.items():
        if key == "file_path" and isinstance(child, str) and child.startswith(f"s3://{bucket}/"):
            source_key = s3_key(child, bucket)
            rewritten[key] = native_url(bucket, namespace, region, target_key(source_key))
        else:
            rewritten[key] = rewrite_manifest_record(child, bucket, namespace, region)
    return rewritten


def rewrite_json(value: Any, bucket: str, namespace: str, region: str) -> Any:
    """Point copied metadata at copied metadata and data files."""
    if isinstance(value, list):
        return [rewrite_json(item, bucket, namespace, region) for item in value]
    if not isinstance(value, dict):
        return value

    rewritten = {}
    for key, child in value.items():
        if key == "location" and isinstance(child, str) and child == f"s3://{bucket}/{SOURCE_PREFIX}/{NAMESPACE}/{TABLE_NAME}":
            rewritten[key] = native_url(
                bucket, namespace, region, f"{TARGET_PREFIX}/{NAMESPACE}/{TABLE_NAME}"
            )
        elif isinstance(child, str) and child.startswith(f"s3://{bucket}/"):
            object_name = s3_key(child, bucket)
            if object_name.startswith(f"{SOURCE_PREFIX}/"):
                object_name = target_key(object_name)
            rewritten[key] = native_url(bucket, namespace, region, object_name)
        else:
            rewritten[key] = rewrite_json(child, bucket, namespace, region)
    return rewritten


def assert_no_legacy_s3_locations(value: Any, bucket: str) -> None:
    """Reject bare bucket S3 URIs; allow the explicit endpoint test form."""
    if isinstance(value, str) and value.startswith("s3://"):
        if URI_STYLE != "s3_compat_scheme" or value.startswith(f"s3://{bucket}/"):
            raise RuntimeError(f"Compatibility export still contains an unsupported S3 location: {value}")
    if isinstance(value, dict):
        for child in value.values():
            assert_no_legacy_s3_locations(child, bucket)
    elif isinstance(value, list):
        for child in value:
            assert_no_legacy_s3_locations(child, bucket)


def main() -> None:
    bucket = os.environ["ORDER_HISTORY_BUCKET"]
    namespace = os.environ["ORDER_HISTORY_NAMESPACE"]
    region = os.environ["OCI_REGION"]
    properties = {
        "s3.endpoint": f"https://{namespace}.compat.objectstorage.{region}.oraclecloud.com",
        "s3.access-key-id": os.environ["ORDER_HISTORY_ACCESS_KEY"],
        "s3.secret-access-key": os.environ["ORDER_HISTORY_SECRET_KEY"],
        "s3.region": region,
    }
    filesystem = PyArrowFileIO(properties).fs_by_scheme("s3", bucket)

    target_info = filesystem.get_file_info(
        pa.fs.FileSelector(f"{bucket}/{TARGET_PREFIX}", recursive=True, allow_not_found=True)
    )
    if target_info:
        raise RuntimeError(
            f"OCI-native metadata prefix {TARGET_PREFIX!r} already contains objects; "
            "use a new empty destination prefix. The publisher never deletes a user bucket or prefix."
        )

    table_selector = pa.fs.FileSelector(
        f"{bucket}/{SOURCE_PREFIX}/{NAMESPACE}/{TABLE_NAME}",
        recursive=True,
        allow_not_found=False,
    )
    source_keys = []
    for info in filesystem.get_file_info(table_selector):
        if info.type != pa.fs.FileType.File:
            continue
        source_keys.append(info.path.removeprefix(f"{bucket}/"))
    if not source_keys:
        raise RuntimeError("The source Iceberg table directory is empty.")

    payloads: Dict[str, bytes] = {}
    for source_key in source_keys:
        with filesystem.open_input_file(f"{bucket}/{source_key}") as source:
            payloads[source_key] = source.read()

    metadata_keys = sorted(
        key for key in source_keys if f"/{NAMESPACE}/{TABLE_NAME}/metadata/" in f"/{key}"
    )
    if not metadata_keys:
        raise RuntimeError("The source Iceberg metadata directory is empty.")

    # Copy non-metadata files first. This includes Parquet data files and any
    # catalog marker files under the table root. The old publisher omitted the
    # Parquet file, which made a metadata-only export appear valid but fail on
    # the first SELECT COUNT(*).
    output_payloads: Dict[str, bytes] = {
        target_key(source_key): payload
        for source_key, payload in payloads.items()
        if source_key not in metadata_keys
    }

    manifest_payloads: Dict[str, bytes] = {}
    manifest_lists: List[Tuple[str, Any, Dict[str, Any], str, List[Dict[str, Any]]]] = []
    for source_key in metadata_keys:
        payload = payloads[source_key]
        if not source_key.endswith(".avro"):
            continue
        schema, metadata, codec, records = read_avro(payload)
        if records and "manifest_path" in records[0]:
            manifest_lists.append((source_key, schema, metadata, codec, records))
            continue
        rewritten_records = [rewrite_manifest_record(record, bucket, namespace, region) for record in records]
        assert_no_legacy_s3_locations(rewritten_records, bucket)
        manifest_payloads[source_key] = write_avro(schema, metadata, codec, rewritten_records)

    for source_key, payload in manifest_payloads.items():
        output_payloads[target_key(source_key)] = payload

    for source_key, schema, metadata, codec, records in manifest_lists:
        rewritten_records = []
        for record in records:
            rewritten = dict(record)
            source_manifest_key = s3_key(rewritten["manifest_path"], bucket)
            rewritten_manifest_key = target_key(source_manifest_key)
            rewritten["manifest_path"] = native_url(bucket, namespace, region, rewritten_manifest_key)
            rewritten["manifest_length"] = len(output_payloads[rewritten_manifest_key])
            rewritten_records.append(rewritten)
        assert_no_legacy_s3_locations(rewritten_records, bucket)
        output_payloads[target_key(source_key)] = write_avro(schema, metadata, codec, rewritten_records)

    json_keys = sorted(key for key in metadata_keys if key.endswith(".metadata.json"))
    if not json_keys:
        raise RuntimeError("No Iceberg metadata JSON file was found.")
    for source_key in json_keys:
        document = json.loads(payloads[source_key].decode("utf-8"))
        rewritten = rewrite_json(document, bucket, namespace, region)
        assert_no_legacy_s3_locations(rewritten, bucket)
        output_payloads[target_key(source_key)] = (
            json.dumps(rewritten, separators=(",", ":"), sort_keys=False).encode("utf-8") + b"\n"
        )

    latest_metadata = target_key(json_keys[-1])
    # The database receives the root metadata URL only after every referenced
    # metadata object has been written.
    for object_name, payload in sorted(output_payloads.items()):
        if object_name == latest_metadata:
            continue
        with filesystem.open_output_stream(f"{bucket}/{object_name}") as target:
            target.write(payload)
    with filesystem.open_output_stream(f"{bucket}/{latest_metadata}") as target:
        target.write(output_payloads[latest_metadata])

    metadata_url = native_url(bucket, namespace, region, latest_metadata)
    METADATA_URL_FILE.write_text(metadata_url + "\n", encoding="utf-8")
    os.chmod(METADATA_URL_FILE, 0o600)
    print(f"Published OCI-native Iceberg metadata using URI style: {URI_STYLE}")
    print(f"Objects written: {len(output_payloads)}")
    print(f"Wrote Oracle metadata URL to {METADATA_URL_FILE}")


if __name__ == "__main__":
    main()
