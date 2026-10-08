locals {
  home_ip_cidr          = can(cidrhost(var.allowed_ingress_home_ip_address, 0)) ? var.allowed_ingress_home_ip_address : "${var.allowed_ingress_home_ip_address}/32"
  stack_suffix          = lower(random_id.adb_name_suffix.hex)
  stack_resource_prefix = "deep-sec-ms-${local.stack_suffix}"
  wallet_bucket_name    = var.wallet_bucket_name != "" ? var.wallet_bucket_name : "${local.stack_resource_prefix}-files"
  adb_db_name           = var.adb_db_name != "" ? var.adb_db_name : "DEEPSEC${upper(random_id.adb_name_suffix.hex)}"
  adb_low_profile_index = index(oci_database_autonomous_database.lab.connection_strings[0].profiles.*.consumer_group, "LOW")
  # ADB private endpoints use the TCPS listener on port 1522. Some provider
  # responses have returned the generic 1521 descriptor even though the
  # private endpoint only accepts 1522, so normalize that port for the VM.
  adb_tls_connection_string = replace(oci_database_autonomous_database.lab.connection_strings[0].profiles[local.adb_low_profile_index].value, "(port=1521)", "(port=1522)")
  # The bundle is published separately from this Terraform archive. Keep only
  # its stable object graph here so the Stack can create exact-object write and
  # read PARs for the private destination bucket.
  order_history_bundle_object_names = [
    "${local.order_history_target_prefix}/default/order_history/data/00000-0-ccf6774e-15fa-4b3b-b7be-9724a1706ba0.parquet",
    "${local.order_history_target_prefix}/default/order_history/metadata/00000-bc1c3928-73a6-4f31-823a-6c1de5a23be7.metadata.json",
    "${local.order_history_target_prefix}/default/order_history/metadata/00001-bf556b46-af5f-4cd7-b899-d161e3a63361.metadata.json",
    "${local.order_history_target_prefix}/default/order_history/metadata/ccf6774e-15fa-4b3b-b7be-9724a1706ba0-m0.avro",
    "${local.order_history_target_prefix}/default/order_history/metadata/snap-720290762785620607-0-ccf6774e-15fa-4b3b-b7be-9724a1706ba0.avro",
  ]
  order_history_bundle_upload_objects = {
    for object_name in local.order_history_bundle_object_names : object_name => object_name
  }
  order_history_bundle_data_object              = "${local.order_history_target_prefix}/default/order_history/data/00000-0-ccf6774e-15fa-4b3b-b7be-9724a1706ba0.parquet"
  order_history_bundle_metadata_object          = "${local.order_history_target_prefix}/default/order_history/metadata/00001-bf556b46-af5f-4cd7-b899-d161e3a63361.metadata.json"
  order_history_target_prefix                   = trim(trimspace(var.order_history_bucket_prefix), "/")
  order_history_bundle_bucket_name              = "${local.stack_resource_prefix}-iceberg"
  order_history_target_bucket                   = local.order_history_bundle_bucket_name
  order_history_effective_bucket                = local.order_history_target_bucket
  order_history_effective_namespace             = data.oci_objectstorage_namespace.current.namespace
  order_history_effective_prefix                = "${local.order_history_target_prefix}/"
  order_history_effective_metadata_url          = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.current.namespace}/b/${local.order_history_target_bucket}/o/${local.order_history_bundle_metadata_object}"
  order_history_effective_read_par_url          = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_read.access_uri}"
  order_history_effective_metadata_read_par_url = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_metadata_read.access_uri}"
  order_history_bundle_archive_url              = var.order_history_bundle_par_url
  order_history_bundle_write_par_urls = {
    for object_name in keys(local.order_history_bundle_upload_objects) :
    object_name => "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_bundle_object_write[object_name].access_uri}"
  }
  order_history_bundle_read_par_urls = {
    for object_name in keys(local.order_history_bundle_upload_objects) :
    object_name => "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_bundle_object_read[object_name].access_uri}"
  }
  common_tags = {
    lab        = "deep-sec"
    managed_by = "terraform"
    deployment = local.stack_suffix
  }
}
