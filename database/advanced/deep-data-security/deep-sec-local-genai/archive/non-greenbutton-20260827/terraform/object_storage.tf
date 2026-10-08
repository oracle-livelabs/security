data "oci_objectstorage_namespace" "current" {
  compartment_id = var.compartment_ocid
}

resource "random_id" "wallet_bucket_suffix" {
  byte_length = 4
}

resource "oci_objectstorage_bucket" "wallet" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.current.namespace
  name           = local.wallet_bucket_name
  access_type    = "NoPublicAccess"

  freeform_tags = local.common_tags
}

# OCI returns wallet bytes as base64. local_file preserves the ZIP exactly;
# content_base64 is deliberately used instead of treating the wallet as text.
resource "local_file" "lab_wallet_zip" {
  filename             = "${path.module}/.deep-sec-generated-wallet.zip"
  content_base64       = oci_database_autonomous_database_wallet.lab.content
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "oci_objectstorage_object" "lab_wallet" {
  bucket    = oci_objectstorage_bucket.wallet.name
  namespace = data.oci_objectstorage_namespace.current.namespace
  object    = var.wallet_object_name
  # `source` must remain unknown during plan. The OCI provider otherwise
  # stats this generated file before local_file has created it. local_file.id
  # becomes known only after the wallet has been written during apply.
  source       = local_file.lab_wallet_zip.id != "" ? local_file.lab_wallet_zip.filename : null
  content_type = "application/zip"

  lifecycle {
    replace_triggered_by = [local_file.lab_wallet_zip]
  }
}

# Anchor the URL lifetime at the Stack's first successful apply. The PAR is
# ObjectRead-only and is not emitted as a Stack output.
resource "time_static" "wallet_par_expiration_anchor" {}

resource "oci_objectstorage_preauthrequest" "lab_wallet_read" {
  bucket       = oci_objectstorage_bucket.wallet.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "deep-sec-wallet-bootstrap-read"
  access_type  = "ObjectRead"
  object_name  = oci_objectstorage_object.lab_wallet.object
  time_expires = timeadd(time_static.wallet_par_expiration_anchor.rfc3339, "${var.wallet_par_ttl_hours}h")
}

# Cloud-init publishes its terminal bootstrap result through this narrow,
# object-specific write PAR. Terraform polls the matching read PAR so an Apply
# cannot succeed merely because the VM was created; the lab services must be
# installed and healthy first.
resource "oci_objectstorage_preauthrequest" "bootstrap_status_write" {
  bucket       = oci_objectstorage_bucket.wallet.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "deep-sec-bootstrap-status-write"
  access_type  = "ObjectWrite"
  object_name  = "deep-sec-bootstrap-status"
  time_expires = timeadd(time_static.wallet_par_expiration_anchor.rfc3339, "${var.wallet_par_ttl_hours}h")
}

resource "oci_objectstorage_preauthrequest" "bootstrap_status_read" {
  bucket       = oci_objectstorage_bucket.wallet.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "deep-sec-bootstrap-status-read"
  access_type  = "ObjectRead"
  object_name  = "deep-sec-bootstrap-status"
  time_expires = timeadd(time_static.wallet_par_expiration_anchor.rfc3339, "${var.wallet_par_ttl_hours}h")
}

# The admin console can demonstrate the pre-existing Iceberg files before any
# database object exists. This PAR is read-only and limited to the Iceberg
# prefix, never the wallet or any other object in the private bucket.
resource "oci_objectstorage_preauthrequest" "order_history_read" {
  bucket                = oci_objectstorage_bucket.wallet.name
  namespace             = data.oci_objectstorage_namespace.current.namespace
  name                  = "deep-sec-order-history-read"
  access_type           = "AnyObjectRead"
  bucket_listing_action = "ListObjects"
  object_name           = "order_history_iceberg/"
  time_expires          = timeadd(time_static.wallet_par_expiration_anchor.rfc3339, "${var.wallet_par_ttl_hours}h")
}

# Cloud-init writes the disposable Iceberg sample files directly to this
# Stack-owned bucket. Terraform does not manage those individual objects, and
# Object Storage will not delete a bucket while objects or old object versions
# remain. Destroy this resource after the VM is gone but before Terraform
# removes the wallet object and bucket.
resource "terraform_data" "wallet_bucket_cleanup" {
  input = {
    bucket_name = oci_objectstorage_bucket.wallet.name
    namespace   = data.oci_objectstorage_namespace.current.namespace
  }

  depends_on = [
    oci_objectstorage_object.lab_wallet,
    oci_objectstorage_preauthrequest.lab_wallet_read,
    oci_objectstorage_preauthrequest.bootstrap_status_write,
    oci_objectstorage_preauthrequest.bootstrap_status_read,
    oci_objectstorage_preauthrequest.order_history_read,
  ]

  provisioner "local-exec" {
    when    = destroy
    command = "oci os object bulk-delete-versions --namespace-name '${self.input.namespace}' --bucket-name '${self.input.bucket_name}' --force"
  }
}

# Resource Manager runs this locally, without SSH access to the VM. The
# instance uploads only a non-secret status line using its object-specific PAR.
# A failed bootstrap or a missing terminal marker therefore makes Apply fail.
resource "terraform_data" "bootstrap_verification" {
  input = {
    instance_id     = oci_core_instance.flask.id
    jupyter_url     = var.assign_public_ip ? "http://${oci_core_instance.flask.public_ip}:8888/" : "JupyterLab has no public URL because assign_public_ip is false."
    status_read_url = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.bootstrap_status_read.access_uri}"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -Eeuo pipefail
      status_url='${self.input.status_read_url}'
      jupyter_url='${self.input.jupyter_url}'
      deadline=$(( $(date +%s) + 600 ))
      echo "JupyterLab URL: $jupyter_url"
      echo 'Waiting up to 10 minutes for the Deep Sec VM bootstrap health gate.'

      while (( $(date +%s) < deadline )); do
        status_file=$(mktemp)
        trap 'rm -f "$status_file"' EXIT
        http_code=$(curl --silent --output "$status_file" --write-out '%%{http_code}' "$status_url" || true)

        if [[ "$http_code" == '200' ]]; then
          cat "$status_file"
          if grep -q '^COMPLETE ' "$status_file"; then
            echo 'Deep Sec bootstrap completed and both application health checks passed.'
            exit 0
          fi
          if grep -q '^FAILED ' "$status_file"; then
            echo 'Deep Sec bootstrap failed; inspect /var/log/deep-sec-bootstrap.log and /var/log/deep-sec-order-history.log on the VM.' >&2
            exit 1
          fi
        fi

        sleep 10
      done

      echo 'Timed out waiting for Deep Sec bootstrap. Inspect /var/log/deep-sec-bootstrap.log on the VM.' >&2
      exit 1
    EOT
  }
}
