#!/usr/bin/env python3
"""Create a disposable format-v1 Iceberg compatibility test table.

This is an investigation aid, not part of the lab bootstrap.  It reads the
one Parquet file written by the normal Order History generator and writes the
same rows to a separate, unpartitioned Iceberg v1 table.  The V1 table can
then be passed through ``publish_order_history_iceberg_oci.py`` so Oracle
is tested against OCI-native metadata URLs without modifying production data.
"""

import os
from pathlib import Path

import pyarrow as pa
import pyarrow.parquet as pq
from pyiceberg.catalog import load_catalog
from pyiceberg.io.pyarrow import PyArrowFileIO


SOURCE_PREFIX = os.environ.get("ORDER_HISTORY_SOURCE_PREFIX", "order_history_iceberg")
TEST_PREFIX = os.environ.get("ORDER_HISTORY_V1_TEST_PREFIX", "order_history_iceberg_v1_test")
NAMESPACE = "default"
TABLE_NAME = "order_history"
CATALOG_DIRECTORY = Path(f"/tmp/deep-sec-{TEST_PREFIX}-catalog")


def main() -> None:
    bucket = os.environ["ORDER_HISTORY_BUCKET"]
    namespace = os.environ["ORDER_HISTORY_NAMESPACE"]
    region = os.environ["OCI_REGION"]
    s3_properties = {
        "s3.endpoint": f"https://{namespace}.compat.objectstorage.{region}.oraclecloud.com",
        "s3.access-key-id": os.environ["ORDER_HISTORY_ACCESS_KEY"],
        "s3.secret-access-key": os.environ["ORDER_HISTORY_SECRET_KEY"],
        "s3.region": region,
    }
    file_io = PyArrowFileIO(s3_properties)
    filesystem = file_io.fs_by_scheme("s3", bucket)

    target_files = filesystem.get_file_info(
        pa.fs.FileSelector(f"{bucket}/{TEST_PREFIX}", recursive=True, allow_not_found=True)
    )
    if target_files:
        raise RuntimeError(
            f"Test prefix {TEST_PREFIX!r} already contains objects. Delete only that disposable "
            "test prefix before rerunning, or choose a new prefix."
        )
    if CATALOG_DIRECTORY.exists():
        raise RuntimeError(
            f"Local V1 test catalog {CATALOG_DIRECTORY} already exists. Remove that disposable "
            "directory before rerunning, after confirming it contains no needed data."
        )

    source_files = filesystem.get_file_info(
        pa.fs.FileSelector(
            f"{bucket}/{SOURCE_PREFIX}/{NAMESPACE}/{TABLE_NAME}/data",
            recursive=True,
            allow_not_found=False,
        )
    )
    parquet_files = [info.path for info in source_files if info.type == pa.fs.FileType.File and info.path.endswith(".parquet")]
    if len(parquet_files) != 1:
        raise RuntimeError(f"Expected exactly one source Parquet file, found {len(parquet_files)}: {parquet_files}")

    source_path = parquet_files[0]
    table_data = pq.read_table(source_path, filesystem=filesystem)
    if table_data.num_rows != 1500:
        raise RuntimeError(f"Expected 1500 source rows, found {table_data.num_rows}.")

    CATALOG_DIRECTORY.mkdir(mode=0o700)
    catalog = load_catalog(
        "oci_sql_v1_test",
        type="sql",
        uri=f"sqlite:///{CATALOG_DIRECTORY}/catalog.db",
        warehouse=f"s3://{bucket}/{TEST_PREFIX}",
        **s3_properties,
    )
    catalog.create_namespace_if_not_exists(NAMESPACE)
    table = catalog.create_table(
        f"{NAMESPACE}.{TABLE_NAME}",
        schema=table_data.schema,
        properties={"format-version": "1"},
    )
    table.append(table_data)
    table.refresh()

    if table.format_version != 1:
        raise RuntimeError(f"Expected Iceberg format version 1, got {table.format_version}.")
    if table.scan().to_arrow().num_rows != 1500:
        raise RuntimeError("V1 Iceberg table did not return 1500 rows after append.")

    metadata_location = table.metadata_location
    print("Created disposable Iceberg format-v1 test table.")
    print("Rows:", table.scan().to_arrow().num_rows)
    print("Format version:", table.format_version)
    print("S3 metadata location:", metadata_location)
    print("Next, run the OCI-native metadata export with:")
    print(f"  ORDER_HISTORY_SOURCE_PREFIX={TEST_PREFIX} ORDER_HISTORY_OCI_TEST_PREFIX=order_history_iceberg_v1_native_test \\")
    print("    /opt/deep-sec-order-history/.venv/bin/python /tmp/publish_order_history_iceberg_oci.py")


if __name__ == "__main__":
    main()
