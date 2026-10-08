data "oci_objectstorage_namespace" "current" {
  compartment_id = var.compartment_ocid
}

resource "random_id" "wallet_bucket_suffix" {
  byte_length = 4
}

resource "random_id" "bootstrap_status_suffix" {
  byte_length = 8

  # A VM replacement must never read the status marker left by an earlier VM.
  # Re-key when either artifact, cloud-init template, injected SSH key, or
  # subnet changes, all of which can cause a fresh bootstrap.
  keepers = {
    application_zip = filesha256("${path.module}/artifacts/deep-data-security-flask-app-GreenButton.zip")
    iceberg_bundle  = filesha256("${path.module}/artifacts/order_history_iceberg_bundle.zip")
    cloud_init      = filesha256("${path.module}/templates/genai-defaults-cloud-init.yaml.tftpl")
    ssh_public_key  = var.ssh_public_key
    subnet_id       = oci_core_subnet.public_app.id
  }
}

resource "oci_objectstorage_bucket" "wallet" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.current.namespace
  name           = local.wallet_bucket_name
  access_type    = "NoPublicAccess"

  freeform_tags = local.common_tags
}

# The bundle mode keeps the small Apache Iceberg dataset in its own
# Stack-owned bucket. It is deliberately separate from the wallet/application
# bucket so the learner can see the warehouse as an ordinary Object Storage
# data source. The bucket is created and cleaned up by this Stack only.
resource "oci_objectstorage_bucket" "order_history" {
  count          = 1
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.current.namespace
  name           = local.order_history_bundle_bucket_name
  access_type    = "NoPublicAccess"

  freeform_tags = local.common_tags
}

resource "oci_objectstorage_object" "greenbutton_app" {
  bucket       = oci_objectstorage_bucket.wallet.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  object       = "deep-data-security-flask-app-GreenButton.zip"
  source       = "${path.module}/artifacts/deep-data-security-flask-app-GreenButton.zip"
  content_type = "application/zip"

  depends_on = [terraform_data.wallet_bucket_cleanup]
}

resource "oci_objectstorage_object" "order_history_bundle" {
  count = 1

  bucket       = oci_objectstorage_bucket.order_history[0].name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  object       = local.order_history_bundle_object
  source       = local.order_history_bundle_file
  content_type = "application/zip"

  depends_on = [terraform_data.order_history_bucket_cleanup]
}

# Calculate PAR expiry at apply time. Do not use a persisted time_static value:
# a Stack upgraded after its old TTL elapsed would otherwise try to create PARs
# with an expiration that is already in the past.

resource "oci_objectstorage_preauthrequest" "greenbutton_app_read" {
  bucket       = oci_objectstorage_bucket.wallet.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "${local.stack_resource_prefix}-app-read"
  access_type  = "ObjectRead"
  object_name  = oci_objectstorage_object.greenbutton_app.object
  time_expires = timeadd(timestamp(), "${var.wallet_par_ttl_hours}h")

  depends_on = [terraform_data.wallet_bucket_cleanup]
}

# Cloud-init publishes its terminal bootstrap result through this narrow,
# object-specific write PAR. Terraform polls the matching read PAR so an Apply
# cannot succeed merely because the VM was created; the lab services must be
# installed and healthy first.
resource "oci_objectstorage_preauthrequest" "bootstrap_status_write" {
  bucket       = oci_objectstorage_bucket.wallet.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "${local.stack_resource_prefix}-bootstrap-status-write"
  access_type  = "ObjectWrite"
  object_name  = "deep-sec-bootstrap-status-${random_id.bootstrap_status_suffix.hex}"
  time_expires = timeadd(timestamp(), "${var.wallet_par_ttl_hours}h")

  depends_on = [terraform_data.wallet_bucket_cleanup]
}

resource "oci_objectstorage_preauthrequest" "bootstrap_status_read" {
  bucket       = oci_objectstorage_bucket.wallet.name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "${local.stack_resource_prefix}-bootstrap-status-read"
  access_type  = "ObjectRead"
  object_name  = "deep-sec-bootstrap-status-${random_id.bootstrap_status_suffix.hex}"
  time_expires = timeadd(timestamp(), "${var.wallet_par_ttl_hours}h")

  depends_on = [terraform_data.wallet_bucket_cleanup]
}

# The admin console reads the final Order History location through PARs. OCI
# object_name grants are exact-object grants rather than recursive prefix
# grants, so the bundle path creates exact read PARs for the published table.
resource "oci_objectstorage_preauthrequest" "order_history_read" {
  bucket       = local.order_history_target_bucket
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "${local.stack_resource_prefix}-order-history-read"
  access_type  = "ObjectRead"
  object_name  = local.order_history_bundle_data_object
  time_expires = timeadd(timestamp(), "${var.wallet_par_ttl_hours}h")

  depends_on = [
    terraform_data.wallet_bucket_cleanup,
    terraform_data.order_history_bucket_cleanup,
    oci_objectstorage_object.order_history_bundle,
  ]
}

# The metadata PAR points at the checked-in metadata JSON published by the VM.
# The Stack-created bucket and exact-object PAR keep the reader path
# deterministic for every deployment.
resource "oci_objectstorage_preauthrequest" "order_history_metadata_read" {
  bucket       = local.order_history_target_bucket
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "${local.stack_resource_prefix}-order-history-metadata-read"
  access_type  = "ObjectRead"
  object_name  = local.order_history_bundle_metadata_object
  time_expires = timeadd(timestamp(), "${var.wallet_par_ttl_hours}h")

  depends_on = [
    terraform_data.wallet_bucket_cleanup,
    terraform_data.order_history_bucket_cleanup,
    oci_objectstorage_object.order_history_bundle,
  ]
}

resource "oci_objectstorage_preauthrequest" "order_history_bundle_object_write" {
  for_each = local.order_history_bundle_upload_objects

  bucket       = oci_objectstorage_bucket.order_history[0].name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "${local.stack_resource_prefix}-order-history-write-${substr(md5(each.key), 0, 12)}"
  access_type  = "ObjectWrite"
  object_name  = each.key
  time_expires = timeadd(timestamp(), "${var.wallet_par_ttl_hours}h")

  depends_on = [
    terraform_data.order_history_bucket_cleanup,
    oci_objectstorage_object.order_history_bundle,
  ]
}

resource "oci_objectstorage_preauthrequest" "order_history_bundle_object_read" {
  for_each = local.order_history_bundle_upload_objects

  bucket       = oci_objectstorage_bucket.order_history[0].name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "${local.stack_resource_prefix}-order-history-read-${substr(md5(each.key), 0, 12)}"
  access_type  = "ObjectRead"
  object_name  = each.key
  time_expires = timeadd(timestamp(), "${var.wallet_par_ttl_hours}h")

  depends_on = [
    terraform_data.order_history_bucket_cleanup,
    oci_objectstorage_object.order_history_bundle,
  ]
}

# The archive itself gets an object-specific read PAR. OCI Object Storage
# treats a PAR with an object name as an exact object grant. The extracted
# table files use their own exact-object write PARs above.
resource "oci_objectstorage_preauthrequest" "order_history_bundle_archive_read" {
  count        = 1
  bucket       = oci_objectstorage_bucket.order_history[0].name
  namespace    = data.oci_objectstorage_namespace.current.namespace
  name         = "${local.stack_resource_prefix}-order-history-bundle-archive-read"
  access_type  = "ObjectRead"
  object_name  = oci_objectstorage_object.order_history_bundle[0].object
  time_expires = timeadd(timestamp(), "${var.wallet_par_ttl_hours}h")

  depends_on = [
    terraform_data.order_history_bucket_cleanup,
    oci_objectstorage_object.order_history_bundle,
  ]
}

# Cloud-init uploads the extracted table files through the object-specific
# write PARs, so the bucket cleanup must run only after those PARs and the
# archive object are gone.
# This cleanup is scoped to the generated bucket and cannot touch the existing
# shared Order History bucket.
resource "terraform_data" "order_history_bucket_cleanup" {
  count = 1

  input = {
    bucket_name = oci_objectstorage_bucket.order_history[0].name
    namespace   = data.oci_objectstorage_namespace.current.namespace
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -Eeuo pipefail
      namespace='${self.input.namespace}'
      bucket_name='${self.input.bucket_name}'

      par_listing=$(oci os preauth-request list \
        --namespace-name "$${namespace}" \
        --bucket-name "$${bucket_name}" \
        --all \
        --output json)

      while IFS= read -r par_id; do
        [[ -n "$${par_id}" ]] || continue
        echo "Deleting remaining pre-authenticated request $${par_id} from $${bucket_name}"
        oci os preauth-request delete \
          --namespace-name "$${namespace}" \
          --bucket-name "$${bucket_name}" \
          --par-id "$${par_id}" \
          --force
      done < <(printf '%s' "$${par_listing}" | python3 -c 'import json, sys; [print(item["id"]) for item in json.loads(sys.stdin.read() or "{}").get("data", [])]')

      oci os object bulk-delete-versions \
        --namespace-name "$${namespace}" \
        --bucket-name "$${bucket_name}" \
        --force
    EOT
  }
}

# Cloud-init writes the disposable Iceberg sample files directly to this
# Stack-owned bucket. Terraform does not manage those individual objects, and
# Object Storage will not delete a bucket while objects, old object versions,
# or pre-authenticated requests remain. Destroy this resource after the VM is
# gone but before Terraform removes the wallet object and bucket. The bucket
# name is unique to this Stack, so deleting every remaining PAR here is scoped
# to the Stack rather than to a shared bucket.
resource "terraform_data" "wallet_bucket_cleanup" {
  input = {
    bucket_name = oci_objectstorage_bucket.wallet.name
    namespace   = data.oci_objectstorage_namespace.current.namespace
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -Eeuo pipefail
      namespace='${self.input.namespace}'
      bucket_name='${self.input.bucket_name}'

      # Remove both Terraform-managed and any stale PARs first. A 404 from a
      # later provider delete is harmless; Object Storage treats it as already
      # absent. This prevents bucket deletion from failing with
      # PreauthenticatedRequestStillExists.
      # Capture the command first: an empty result is valid after Terraform
      # has already removed every managed PAR, while an OCI CLI failure must
      # still stop the cleanup rather than being hidden in a process
      # substitution.
      par_listing=$(oci os preauth-request list \
        --namespace-name "$${namespace}" \
        --bucket-name "$${bucket_name}" \
        --all \
        --output json)

      while IFS= read -r par_id; do
        [[ -n "$${par_id}" ]] || continue
        echo "Deleting remaining pre-authenticated request $${par_id} from $${bucket_name}"
        oci os preauth-request delete \
          --namespace-name "$${namespace}" \
          --bucket-name "$${bucket_name}" \
          --par-id "$${par_id}" \
          --force
      done < <(printf '%s' "$${par_listing}" | python3 -c 'import json, sys; [print(item["id"]) for item in json.loads(sys.stdin.read() or "{}").get("data", [])]')

      oci os object bulk-delete-versions \
        --namespace-name "$${namespace}" \
        --bucket-name "$${bucket_name}" \
        --force
    EOT
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

  # `input` changes update terraform_data in place, which does not rerun a
  # provisioner. Replacing this health gate when the VM or status PAR changes
  # makes both a fresh deployment and a recovery deployment wait for the real
  # application bootstrap result.
  triggers_replace = [
    oci_core_instance.flask.id,
    oci_objectstorage_preauthrequest.bootstrap_status_read.access_uri,
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -Eeuo pipefail
      status_url='${self.input.status_read_url}'
      jupyter_url='${self.input.jupyter_url}'
      deadline=$(( $(date +%s) + 600 ))
      baseline_run=''
      baseline_terminal='false'
      echo "JupyterLab URL: $jupyter_url"
      echo 'Waiting up to 10 minutes for the Deep Sec VM bootstrap health gate.'

      while (( $(date +%s) < deadline )); do
        status_file=$(mktemp)
        trap 'rm -f "$status_file"' EXIT
        http_code=$(curl --silent --output "$status_file" --write-out '%%{http_code}' "$status_url" || true)

        if [[ "$http_code" == '200' ]]; then
          cat "$status_file"
          current_run=$(sed -n 's/.* run=\([^ ]*\).*/\1/p' "$status_file")
          if [[ -z "$baseline_run" && -n "$current_run" ]]; then
            baseline_run="$current_run"
            if grep -Eq '^(COMPLETE|FAILED) ' "$status_file"; then
              baseline_terminal='true'
            fi
          fi
          if grep -q '^COMPLETE ' "$status_file"; then
            if [[ "$baseline_terminal" == 'true' && "$current_run" == "$baseline_run" ]]; then
              echo 'Ignoring a terminal marker from the prior bootstrap run.'
            else
              echo 'Deep Sec bootstrap completed and both application health checks passed.'
              exit 0
            fi
          fi
          if grep -q '^FAILED ' "$status_file"; then
            if [[ "$baseline_terminal" == 'true' && "$current_run" == "$baseline_run" ]]; then
              echo 'Ignoring a terminal marker from the prior bootstrap run.'
            else
              echo 'Deep Sec bootstrap failed; inspect /var/log/deep-sec-bootstrap.log and /var/log/deep-sec-order-history.log on the VM.' >&2
              exit 1
            fi
          fi
        fi

        sleep 10
      done

      echo 'Timed out waiting for Deep Sec bootstrap. Inspect /var/log/deep-sec-bootstrap.log on the VM.' >&2
      exit 1
    EOT
  }
}
