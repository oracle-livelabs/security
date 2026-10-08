resource "oci_core_instance" "flask" {
  # Keep the bucket cleanup resource alive while this VM can still write its
  # generated Iceberg files. Terraform destroys the VM before the cleanup.
  depends_on = [
    terraform_data.wallet_bucket_cleanup,
    # The Stack-created bucket, archive, and object PARs must be ready before
    # cloud-init materializes the table graph.
    oci_objectstorage_preauthrequest.order_history_bundle_archive_read,
    oci_objectstorage_preauthrequest.order_history_bundle_object_write,
  ]

  availability_domain = data.oci_identity_availability_domains.available.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.compute_display_name}-${local.stack_suffix}"
  shape               = var.compute_shape

  shape_config {
    ocpus         = var.compute_ocpus
    memory_in_gbs = var.compute_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_app.id
    assign_public_ip = var.assign_public_ip
    display_name     = "${var.compute_display_name}-${local.stack_suffix}"
  }

  source_details {
    source_type = "image"
    source_id   = var.compute_image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    # OCI instance metadata is limited to 32 KB. Cloud-init recognizes the
    # decompressed YAML by its gzip header after OCI decodes this value.
    user_data = base64gzip(templatefile("${path.module}/templates/genai-defaults-cloud-init.yaml.tftpl", {
      genai_compartment_ocid    = local.genai_compartment_ocid
      genai_model_id            = var.genai_model_id
      jupyter_password          = random_password.lab_admin.result
      region                    = var.region
      adb_db_name               = local.adb_db_name
      adb_tls_connection_string = local.adb_tls_connection_string
      # The wallet installer remains in the shared cloud-init template but is
      # deliberately not called by GreenButton.
      adb_service_alias                   = ""
      adb_actual_service_alias            = ""
      wallet_par_url                      = ""
      application_par_url                 = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.greenbutton_app_read.access_uri}"
      bootstrap_status_write_par_url      = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.bootstrap_status_write.access_uri}"
      order_history_read_par_url          = local.order_history_effective_read_par_url
      order_history_metadata_read_par_url = local.order_history_effective_metadata_read_par_url
      order_history_bucket                = local.order_history_effective_bucket
      order_history_namespace             = local.order_history_effective_namespace
      order_history_prefix                = local.order_history_effective_prefix
      order_history_access_key            = var.order_history_access_key
      order_history_secret_key            = var.order_history_secret_key
      order_history_oci_username          = var.order_history_oci_username
      order_history_oci_auth_token        = var.order_history_oci_auth_token
      order_history_metadata_url          = local.order_history_effective_metadata_url
      order_history_bundle_archive_url    = local.order_history_bundle_archive_url
      order_history_bundle_write_par_urls = jsonencode(local.order_history_bundle_write_par_urls)
      # systemd EnvironmentFile syntax needs the JSON's inner quotes escaped;
      # single-quoting the whole JSON leaves literal quotes in os.environ.
      order_history_object_read_par_urls  = replace(jsonencode(local.order_history_bundle_read_par_urls), "\"", "\\\"")
      order_history_bundle_archive_sha256 = local.order_history_bundle_archive_sha256
      order_history_export_prefix         = local.order_history_target_prefix
    }))
  }

  freeform_tags = local.common_tags
}
