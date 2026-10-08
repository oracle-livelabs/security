resource "oci_database_autonomous_database" "lab" {
  compartment_id = var.compartment_ocid
  db_name        = local.adb_db_name
  display_name   = var.adb_display_name
  db_version     = "26ai"
  db_workload    = "OLTP"
  admin_password = random_password.lab_admin.result

  compute_model               = "ECPU"
  compute_count               = var.adb_compute_count
  data_storage_size_in_tbs    = var.adb_storage_tbs
  license_model               = var.adb_license_model
  is_auto_scaling_enabled     = true
  is_mtls_connection_required = true

  freeform_tags = local.common_tags

}

resource "random_id" "adb_name_suffix" {
  byte_length = 4
}

# The wallet is generated during the Stack apply, encrypted with the same
# disposable lab password used by ADB ADMIN, JupyterLab, and MARVIN. Its ZIP
# content is subsequently delivered through the Stack-owned private bucket.
resource "oci_database_autonomous_database_wallet" "lab" {
  autonomous_database_id = oci_database_autonomous_database.lab.id
  password               = random_password.lab_admin.result
  base64_encode_content  = true
  generate_type          = "SINGLE"
}
