resource "oci_database_autonomous_database" "lab" {
  compartment_id = var.compartment_ocid
  db_name        = local.adb_db_name
  display_name   = var.adb_display_name
  db_workload    = "OLTP"
  admin_password = random_password.lab_admin.result

  # Always Free ADB fixes its own CPU and storage allocation.  Do not set the
  # paid deployment's compute model, count, storage, license, or DB version.
  is_free_tier                = true
  is_mtls_connection_required = true

  freeform_tags = local.common_tags
}

resource "random_id" "adb_name_suffix" {
  byte_length = 4
}

# The rest of the archive still exercises the wallet bucket, PARs, and ADB
# dynamic group.  This provides a real resource OCID for its IAM rule.
resource "oci_database_autonomous_database_wallet" "lab" {
  autonomous_database_id = oci_database_autonomous_database.lab.id
  password               = random_password.lab_admin.result
  base64_encode_content  = true
  generate_type          = "SINGLE"
}
