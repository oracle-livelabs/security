resource "oci_core_instance" "flask" {
  # Keep the bucket cleanup resource alive while this VM can still write its
  # generated Iceberg files. Terraform destroys the VM before the cleanup.
  depends_on = [terraform_data.wallet_bucket_cleanup]

  availability_domain = data.oci_identity_availability_domains.available.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.compute_display_name
  shape               = var.compute_shape

  shape_config {
    ocpus         = var.compute_ocpus
    memory_in_gbs = var.compute_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_app.id
    assign_public_ip = var.assign_public_ip
    display_name     = var.compute_display_name
  }

  source_details {
    source_type = "image"
    source_id   = var.compute_image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64gzip(templatefile("${path.module}/templates/genai-defaults-cloud-init.yaml.tftpl", {
      genai_compartment_ocid         = local.genai_compartment_ocid
      genai_model_id                 = var.genai_model_id
      jupyter_password               = random_password.lab_admin.result
      region                         = var.region
      adb_service_alias              = local.adb_service_alias
      adb_actual_service_alias       = local.adb_actual_service_alias
      wallet_par_url                 = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.lab_wallet_read.access_uri}"
      bootstrap_status_write_par_url = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.bootstrap_status_write.access_uri}"
      order_history_read_par_url     = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.order_history_read.access_uri}"
      order_history_bucket           = local.wallet_bucket_name
      order_history_namespace        = data.oci_objectstorage_namespace.current.namespace
      order_history_access_key       = var.order_history_access_key
      order_history_secret_key       = var.order_history_secret_key
      order_history_oci_username     = var.order_history_oci_username
      order_history_oci_auth_token   = var.order_history_oci_auth_token
    }))
  }

  freeform_tags = local.common_tags
}
