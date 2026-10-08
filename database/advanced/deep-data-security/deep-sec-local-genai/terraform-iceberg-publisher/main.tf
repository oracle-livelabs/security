resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name      = trimspace(var.shared_bucket_name) != "" ? var.shared_bucket_name : "deep-sec-iceberg-shared-${random_id.bucket_suffix.hex}"
  writer_object    = "publisher/dataflow_order_history_hadoop.py"
  warehouse_prefix = "iceberg/order_history/warehouse"
  warehouse_uri    = "oci://${local.bucket_name}@${data.oci_objectstorage_namespace.current.namespace}/${local.warehouse_prefix}"
  metadata_object  = "${local.warehouse_prefix}/default/order_history/metadata/v1.metadata.json"
  metadata_url     = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.current.namespace}/b/${local.bucket_name}/o/${local.metadata_object}"
}

# This bucket contains only the reusable Iceberg lesson data, writer source,
# and Data Flow logs. Its objects are public-read by design; no credentials,
# wallets, or learner-specific artifacts may be placed here.
resource "oci_objectstorage_bucket" "shared_iceberg" {
  compartment_id        = var.compartment_ocid
  namespace             = data.oci_objectstorage_namespace.current.namespace
  name                  = local.bucket_name
  access_type           = "ObjectReadWithoutList"
  object_events_enabled = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "oci_objectstorage_object" "writer" {
  bucket       = oci_objectstorage_bucket.shared_iceberg.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  object       = local.writer_object
  source       = "${path.module}/artifacts/dataflow_order_history_hadoop.py"
  content_type = "text/x-python"
}

resource "oci_identity_policy" "dataflow_publisher" {
  compartment_id = var.compartment_ocid
  name           = "deep-sec-iceberg-publisher-${random_id.bucket_suffix.hex}"
  description    = "Allows the designated Deep Sec operator group to submit the one-time shared Iceberg writer."
  statements = [
    "Allow group '${var.dataflow_operator_identity_domain}'/'${var.dataflow_operator_group_name}' to manage dataflow-family in compartment id ${var.compartment_ocid}",
    "Allow any-user to manage objects in compartment id ${var.compartment_ocid} where all {request.principal.type = 'dataflowrun', request.resource.compartment.id = '${var.compartment_ocid}', target.bucket.name = '${local.bucket_name}'}",
  ]
}

resource "oci_dataflow_application" "shared_order_history_writer" {
  compartment_id = var.compartment_ocid
  display_name   = "Deep Sec shared Order History Iceberg publisher"
  description    = "One-time publisher for the shared Deep Sec Order History Iceberg table."
  language       = "PYTHON"
  spark_version  = var.spark_version
  file_uri       = "oci://${local.bucket_name}@${data.oci_objectstorage_namespace.current.namespace}/${local.writer_object}"
  arguments = [
    "--warehouse-uri", local.warehouse_uri,
    "--database", "default",
    "--table", "order_history",
  ]
  configuration = {
    "spark.jars.packages"  = var.iceberg_runtime_package
    "spark.sql.extensions" = "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions"
  }
  driver_shape   = "VM.Standard.E4.Flex"
  executor_shape = "VM.Standard.E4.Flex"
  num_executors  = 1
  driver_shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }
  executor_shape_config {
    ocpus         = 1
    memory_in_gbs = 16
  }
  logs_bucket_uri = "oci://${local.bucket_name}@${data.oci_objectstorage_namespace.current.namespace}/dataflow-logs"

  depends_on = [oci_objectstorage_object.writer, oci_identity_policy.dataflow_publisher]
}

resource "time_static" "par_anchor" {}

# The Admin Console needs a list-capable URL for the learner-facing raw-files
# page. The PAR is restricted to the table prefix and lasts two years.
resource "oci_objectstorage_preauthrequest" "raw_files_read" {
  bucket                = oci_objectstorage_bucket.shared_iceberg.name
  namespace             = data.oci_objectstorage_namespace.current.namespace
  name                  = "deep-sec-shared-iceberg-raw-files-read"
  access_type           = "AnyObjectRead"
  bucket_listing_action = "ListObjects"
  object_name           = "${local.warehouse_prefix}/"
  time_expires          = timeadd(time_static.par_anchor.rfc3339, "${var.raw_files_par_ttl_hours}h")
}

resource "oci_objectstorage_preauthrequest" "metadata_read" {
  bucket       = oci_objectstorage_bucket.shared_iceberg.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "deep-sec-shared-iceberg-metadata-read"
  access_type  = "ObjectRead"
  object_name  = local.metadata_object
  time_expires = timeadd(time_static.par_anchor.rfc3339, "${var.raw_files_par_ttl_hours}h")
}
