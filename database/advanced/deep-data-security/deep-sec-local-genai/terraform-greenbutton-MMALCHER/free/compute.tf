data "oci_core_images" "free_oracle_linux" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E2.1.Micro"
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "flask" {
  # Keep the bucket cleanup resource alive while this VM can still write its
  # generated Iceberg files. Terraform destroys the VM before the cleanup.
  depends_on = [terraform_data.wallet_bucket_cleanup]

  availability_domain = data.oci_identity_availability_domains.available.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = var.compute_display_name
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_app.id
    assign_public_ip = var.assign_public_ip
    display_name     = var.compute_display_name
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.free_oracle_linux.images[0].id
  }

  # This image intentionally does not bootstrap the Deep Sec application. It
  # is only a real OCI instance principal for validating the IAM policy.
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-CLOUD_CONFIG
      #cloud-config
      write_files:
        - path: /home/opc/DEEP_SEC_FREE_VERIFICATION.txt
          owner: opc:opc
          permissions: '0644'
          content: |
            This is the Always Free Deep Sec IAM verification instance.
            It is not the Deep Sec application image.
            Verify the dynamic group and policies in OCI before destroying this stack.
      CLOUD_CONFIG
    )
  }

  freeform_tags = merge(local.common_tags, { purpose = "deep-sec-free-iam-verification" })
}
