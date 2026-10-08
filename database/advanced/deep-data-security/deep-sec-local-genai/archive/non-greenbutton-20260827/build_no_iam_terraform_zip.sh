#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
stage_dir=$(mktemp -d)
trap 'rm -rf "$stage_dir"' EXIT

mkdir -p "$stage_dir/terraform"
for file in \
  providers.tf \
  variables.tf \
  network.tf \
  adb.tf \
  compute.tf \
  iam.tf \
  object_storage.tf \
  jupyter.tf \
  locals.tf \
  outputs.tf \
  versions.tf \
  terraform.tfvars.example \
  schema.yaml \
  .gitignore \
  .terraform.lock.hcl; do
  cp -a "$script_dir/terraform/$file" "$stage_dir/terraform/$file"
done
cp -a "$script_dir/terraform/templates" "$stage_dir/terraform/templates"
cp "$script_dir/terraform-overrides/no-iam/iam.tf" "$stage_dir/terraform/iam.tf"
cp "$script_dir/terraform-overrides/no-iam/compute.tf" "$stage_dir/terraform/compute.tf"

# This variant never creates GenAI IAM resources, even if a caller retains an
# older tfvars file with create_genai_iam omitted.
sed -i '/variable "create_genai_iam" {/,/^}/ s/default     = true/default     = false/' "$stage_dir/terraform/variables.tf"
sed -i '/create_genai_iam          = true/c\create_genai_iam          = false' "$stage_dir/terraform/terraform.tfvars.example"
printf '%s\n' \
  '' \
  '# Required by the NO-IAM archive. Supply an existing OCI Customer Secret Key' \
  '# whose IAM user already has read/write Object Storage permission in this bucket.' \
  'order_history_access_key = "replace-with-existing-customer-secret-access-key"' \
  'order_history_secret_key = "replace-with-existing-customer-secret-key"' \
  >> "$stage_dir/terraform/terraform.tfvars.example"

awk '
  !inserted && /- title: "OCI Generative AI"/ {
    print "  - title: \"Iceberg writer credential (required)\""
    print "    variables:"
    print "      - order_history_access_key"
    print "      - order_history_secret_key"
    inserted = 1
  }
  { print }
' "$stage_dir/terraform/schema.yaml" > "$stage_dir/schema.tmp"
mv "$stage_dir/schema.tmp" "$stage_dir/terraform/schema.yaml"
awk '
  /^outputs:/ {
    print "  order_history_access_key:"
    print "    type: string"
    print "    title: \"Existing OCI Customer Secret Key access key\""
    print "    required: true"
    print "  order_history_secret_key:"
    print "    type: string"
    print "    title: \"Existing OCI Customer Secret Key secret\""
    print "    sensitive: true"
    print "    required: true"
  }
  { print }
' "$stage_dir/terraform/schema.yaml" > "$stage_dir/schema-with-inputs.tmp"
mv "$stage_dir/schema-with-inputs.tmp" "$stage_dir/terraform/schema.yaml"

rm -f "$script_dir/deep-sec-local-genai-terraform-NO-IAM.zip"
(cd "$stage_dir" && zip -qr "$script_dir/deep-sec-local-genai-terraform-NO-IAM.zip" terraform)
unzip -tq "$script_dir/deep-sec-local-genai-terraform-NO-IAM.zip"
echo "Created deep-sec-local-genai-terraform-NO-IAM.zip"
