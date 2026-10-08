output "shared_iceberg" {
  description = "Provide these non-secret values to GreenButton after the one-time writer run succeeds and ADB validates the table."
  value = {
    bucket_name            = local.bucket_name
    namespace              = data.oci_objectstorage_namespace.current.namespace
    warehouse_uri          = local.warehouse_uri
    metadata_url           = local.metadata_url
    raw_files_read_par_url = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.raw_files_read.access_uri}"
    metadata_read_par_url  = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.metadata_read.access_uri}"
    application_id         = oci_dataflow_application.shared_order_history_writer.id
    submit_command         = "oci data-flow run create --application-id ${oci_dataflow_application.shared_order_history_writer.id} --compartment-id ${var.compartment_ocid} --display-name 'Deep Sec shared Order History Iceberg publisher'"
  }
}
