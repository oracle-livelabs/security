"""Write the lab's one-time Iceberg data via PyIceberg's standard S3FileIO.
No JVM, no Spark, no Maven dependency resolution at runtime. Writes go
through OCI's S3-compatible API. The following publisher step rewrites the
complete metadata graph to OCI-native URLs before Autonomous Database reads it.
"""

import os
import random
from datetime import date, timedelta
from pathlib import Path

import pyarrow as pa
from pyiceberg.catalog import load_catalog
from pyiceberg.io.pyarrow import PyArrowFileIO

CUSTOMER_IDS = list(range(1, 23))
SALES_REPS = ["MARVIN", "EMMA", "PRIYA"]
PRODUCT_CATEGORIES = ["Software", "Hardware", "Services", "Support"]
NAMESPACE = "default"
TABLE_NAME = "order_history"
# Must remain aligned with terraform/object_storage.tf and the Admin
# Console's prefix-scoped read/list PAR.
WAREHOUSE_PREFIX = "order_history_iceberg"
CATALOG_DIRECTORY = Path("/home/opc/.deep-sec-order-history")


def generate_orders(n=1500, start=date(2025, 1, 1), end=date(2026, 12, 31)):
    random.seed(20260820)
    span = (end - start).days
    return [
        {
            "order_id": order_id,
            "customer_id": random.choice(CUSTOMER_IDS),
            "order_date": start + timedelta(days=random.randint(0, span)),
            "sales_rep": random.choice(SALES_REPS),
            "product_category": random.choice(PRODUCT_CATEGORIES),
            "amount": round(random.uniform(500, 25000), 2),
        }
        for order_id in range(1, n + 1)
    ]


def ensure_empty_warehouse(catalog_properties: dict[str, str], bucket: str) -> None:
    """Fail safely if this disposable Stack-owned warehouse was not destroyed.

    SqlCatalog persists its table bookkeeping on the VM. A replacement VM has
    a new local catalog, so it cannot safely adopt files left in the same
    Object Storage prefix by a prior VM.
    """
    file_io = PyArrowFileIO(catalog_properties)
    s3_filesystem = file_io.fs_by_scheme("s3", bucket)
    existing_files = s3_filesystem.get_file_info(
        pa.fs.FileSelector(f"{bucket}/{WAREHOUSE_PREFIX}", recursive=True, allow_not_found=True)
    )
    if existing_files:
        raise RuntimeError(
            "Order History warehouse already contains files. This Stack was not destroyed before "
            "redeploy; destroy it first or use a new bucket."
        )


def main():
    bucket = os.environ["ORDER_HISTORY_BUCKET"]
    namespace = os.environ["ORDER_HISTORY_NAMESPACE"]
    region = os.environ["OCI_REGION"]
    CATALOG_DIRECTORY.mkdir(mode=0o700, exist_ok=True)

    catalog_properties = {
        "type": "sql",
        "uri": f"sqlite:///{CATALOG_DIRECTORY}/catalog.db",
        "warehouse": f"s3://{bucket}/{WAREHOUSE_PREFIX}",
        "s3.endpoint": f"https://{namespace}.compat.objectstorage.{region}.oraclecloud.com",
        "s3.access-key-id": os.environ["ORDER_HISTORY_ACCESS_KEY"],
        "s3.secret-access-key": os.environ["ORDER_HISTORY_SECRET_KEY"],
        "s3.region": region,
    }
    ensure_empty_warehouse(catalog_properties, bucket)
    catalog = load_catalog("oci_sql", **catalog_properties)
    catalog.create_namespace_if_not_exists(NAMESPACE)

    table_identifier = f"{NAMESPACE}.{TABLE_NAME}"
    orders = generate_orders()
    table_data = pa.table({
        "order_id": [r["order_id"] for r in orders],
        "customer_id": [r["customer_id"] for r in orders],
        "order_date": [r["order_date"] for r in orders],
        "sales_rep": [r["sales_rep"] for r in orders],
        "product_category": [r["product_category"] for r in orders],
        "amount": [r["amount"] for r in orders],
    })

    # Keep the lab on the broadly compatible Iceberg v1 metadata layout.
    # The lab is append-only and unpartitioned, so it does not need v2-only
    # delete-file semantics; v1 avoids an unnecessary compatibility variable
    # for Autonomous Database's direct-metadata reader.
    table = catalog.create_table_if_not_exists(
        table_identifier,
        schema=table_data.schema,
        properties={"format-version": "1"},
    )
    if table.format_version != 1:
        raise RuntimeError(f"Expected Iceberg format version 1, got {table.format_version}.")
    existing_rows = table.scan().to_arrow().num_rows
    if existing_rows == 0:
        table.append(table_data)
        table.refresh()
        print(f"Wrote {table_data.num_rows} rows to Iceberg table {table_identifier}")
    else:
        print(f"Iceberg table {table_identifier} already contains {existing_rows} rows; leaving it unchanged.")

    print("Source Iceberg table is ready for OCI-native metadata publication.")


if __name__ == "__main__":
    main()
