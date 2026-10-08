locals {
  home_ip_cidr          = can(cidrhost(var.allowed_ingress_home_ip_address, 0)) ? var.allowed_ingress_home_ip_address : "${var.allowed_ingress_home_ip_address}/32"
  stack_suffix          = lower(random_id.adb_name_suffix.hex)
  stack_resource_prefix = "deep-sec-gb-${local.stack_suffix}"
  wallet_bucket_name    = var.wallet_bucket_name != "" ? var.wallet_bucket_name : "${local.stack_resource_prefix}-files"
  adb_db_name           = var.adb_db_name != "" ? var.adb_db_name : "DEEPSEC${upper(random_id.adb_name_suffix.hex)}"
  adb_low_profile_index = index(oci_database_autonomous_database.lab.connection_strings[0].profiles.*.consumer_group, "LOW")
  # ADB private endpoints use the TCPS listener on port 1522. Some provider
  # responses have returned the generic 1521 descriptor even though the
  # private endpoint only accepts 1522, so normalize that port for the VM.
  adb_tls_connection_string = replace(oci_database_autonomous_database.lab.connection_strings[0].profiles[local.adb_low_profile_index].value, "(port=1521)", "(port=1522)")
  # This small, checked-in Iceberg v1 sample is packaged as a complete bundle
  # and materialized into the Stack-created Order History bucket during VM
  # bootstrap.
  order_history_sample_root  = "${path.module}/artifacts/order_history_iceberg"
  order_history_sample_files = fileset(local.order_history_sample_root, "**")
  order_history_bundle_source_objects = {
    for source_key in local.order_history_sample_files :
    "${local.order_history_target_prefix}/default/order_history/${trimprefix(source_key, "order_history/")}" => source_key
  }
  order_history_bundle_metadata_sources = sort([
    for source_key in local.order_history_sample_files : source_key
    if startswith(source_key, "order_history/metadata/") && endswith(source_key, ".metadata.json")
  ])
  order_history_bundle_file                     = "${path.module}/artifacts/order_history_iceberg_bundle.zip"
  order_history_bundle_object                   = "${local.order_history_target_prefix}/.delivery-bundle.zip"
  order_history_bundle_data_object              = "${local.order_history_target_prefix}/default/order_history/data/00000-0-ccf6774e-15fa-4b3b-b7be-9724a1706ba0.parquet"
  order_history_bundle_metadata_object          = "${local.order_history_target_prefix}/default/order_history/${trimprefix(local.order_history_bundle_metadata_sources[length(local.order_history_bundle_metadata_sources) - 1], "order_history/")}"
  order_history_bundle_upload_objects           = local.order_history_bundle_source_objects
  order_history_target_prefix                   = trim(trimspace(var.order_history_bucket_prefix), "/")
  order_history_bundle_bucket_name              = "${local.stack_resource_prefix}-iceberg"
  order_history_target_bucket                   = local.order_history_bundle_bucket_name
  order_history_effective_bucket                = local.order_history_target_bucket
  order_history_effective_namespace             = data.oci_objectstorage_namespace.current.namespace
  order_history_effective_prefix                = "${local.order_history_target_prefix}/"
  order_history_effective_metadata_url          = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.current.namespace}/b/${local.order_history_target_bucket}/o/${local.order_history_bundle_metadata_object}"
  order_history_effective_read_par_url          = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_read.access_uri}"
  order_history_effective_metadata_read_par_url = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_metadata_read.access_uri}"
  order_history_bundle_archive_url              = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_bundle_archive_read[0].access_uri}"
  order_history_bundle_write_par_urls = {
    for object_name in keys(local.order_history_bundle_upload_objects) :
    object_name => "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_bundle_object_write[object_name].access_uri}"
  }
  order_history_bundle_read_par_urls = {
    for object_name in keys(local.order_history_bundle_upload_objects) :
    object_name => "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_bundle_object_read[object_name].access_uri}"
  }
  order_history_bundle_archive_sha256 = filesha256(local.order_history_bundle_file)

  common_tags = {
    lab        = "deep-sec"
    managed_by = "terraform"
    deployment = local.stack_suffix
  }
}
