resource "oci_database_autonomous_database" "lab" {
  compartment_id = var.compartment_ocid
  db_name        = local.adb_db_name
  display_name   = "${var.adb_display_name}-${local.stack_suffix}"
  db_version     = "26ai"
  db_workload    = "OLTP"
  admin_password = random_password.lab_admin.result

  compute_model            = "ECPU"
  compute_count            = var.adb_compute_count
  data_storage_size_in_tbs = var.adb_storage_tbs
  license_model            = var.adb_license_model
  is_auto_scaling_enabled  = true
  # Keep database traffic inside the Stack-created VCN. The VM reaches ADB
  # through this private endpoint. The application server is also private and
  # has no public Internet path.
  private_endpoint_label      = "deepsec${local.stack_suffix}"
  subnet_id                   = oci_core_subnet.public_app.id
  is_mtls_connection_required = false

  # OCI cannot delete a subnet while its private ADB endpoint is attached.
  # The public-IP migration changes prohibit_public_ip_on_vnic, which forces
  # subnet replacement; replace the ADB first so Terraform can tear down the
  # old endpoint and recreate it in the new subnet.
  lifecycle {
    replace_triggered_by = [oci_core_subnet.public_app.id]
  }

  freeform_tags = local.common_tags

}

resource "random_id" "adb_name_suffix" {
  byte_length = 4
}
