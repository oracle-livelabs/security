"""Produce the lab's queryable Iceberg table with OCI Data Flow.

This is the production-shaped writer: Data Flow owns the HadoopCatalog layout
in OCI Object Storage.  ADB can therefore read the warehouse directly without
rewriting Iceberg metadata or manifest URLs.
"""

import argparse
from datetime import date, timedelta
from decimal import Decimal

from pyspark.sql import SparkSession


def arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--warehouse-uri", required=True)
    parser.add_argument("--database", default="default")
    parser.add_argument("--table", default="order_history")
    return parser.parse_args()


def main():
    args = arguments()
    spark = SparkSession.builder.getOrCreate()
    catalog = "deepsec_hadoop"
    identifier = f"{catalog}.{args.database}.{args.table}"

    # Iceberg runtime and extensions are supplied by the Data Flow application
    # configuration before this script starts.
    spark.conf.set(f"spark.sql.catalog.{catalog}", "org.apache.iceberg.spark.SparkCatalog")
    spark.conf.set(f"spark.sql.catalog.{catalog}.type", "hadoop")
    spark.conf.set(f"spark.sql.catalog.{catalog}.warehouse", args.warehouse_uri)
    spark.sql(f"CREATE NAMESPACE IF NOT EXISTS {catalog}.{args.database}")
    spark.sql(f"DROP TABLE IF EXISTS {identifier}")

    start = date(2026, 1, 1)
    rows = [
        (
            number,
            ((number - 1) % 22) + 1,
            start + timedelta(days=number % 180),
            ("MARVIN", "EMMA", "PRIYA")[number % 3],
            ("Software", "Hardware", "Services")[number % 3],
            Decimal(f"{(number * 17) % 5000 + 100}.00"),
        )
        for number in range(1, 1501)
    ]
    dataframe = spark.createDataFrame(
        rows,
        "order_id LONG, customer_id LONG, order_date DATE, sales_rep STRING, "
        "product_category STRING, amount DECIMAL(12,2)",
    )
    dataframe.writeTo(identifier).using("iceberg").tableProperty("format-version", "1").create()

    count = spark.table(identifier).count()
    if count != 1500:
        raise RuntimeError(f"Expected 1500 Order History rows, found {count}.")
    print(f"Created {identifier} with {count} rows in {args.warehouse_uri}")


if __name__ == "__main__":
    main()
