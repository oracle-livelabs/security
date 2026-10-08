#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
stage_dir=$(mktemp -d)
trap 'rm -rf "$stage_dir"' EXIT

mkdir -p "$stage_dir/terraform"
for file in \
  providers.tf variables.tf network.tf adb.tf compute.tf iam.tf object_storage.tf \
  jupyter.tf locals.tf outputs.tf versions.tf terraform.tfvars.example schema.yaml \
  README.md .gitignore .terraform.lock.hcl marketplace-image.tf; do
  cp -a "$script_dir/terraform-marketplace/$file" "$stage_dir/terraform/$file"
done
cp -a "$script_dir/terraform-marketplace/templates" "$stage_dir/terraform/templates"

mkdir -p "$script_dir/terraform-marketplace/artifacts"
cp -a "$script_dir/dist/deep-data-security-flask-app-Marketplace.zip" \
  "$script_dir/terraform-marketplace/artifacts/deep-data-security-flask-app-Marketplace.zip"
rm -rf "$script_dir/terraform-marketplace/artifacts/order_history_iceberg"
cp -a "$script_dir/greenbutton-files/iceberg-sample" \
  "$script_dir/terraform-marketplace/artifacts/order_history_iceberg"
rm -f "$script_dir/terraform-marketplace/artifacts/order_history_iceberg_bundle.zip"
(cd "$script_dir/greenbutton-files/iceberg-sample" && zip -qr "$script_dir/terraform-marketplace/artifacts/order_history_iceberg_bundle.zip" order_history)

mkdir -p "$stage_dir/terraform/artifacts"
cp -a "$script_dir/terraform-marketplace/artifacts/deep-data-security-flask-app-Marketplace.zip" \
  "$stage_dir/terraform/artifacts/deep-data-security-flask-app-Marketplace.zip"
cp -a "$script_dir/terraform-marketplace/artifacts/order_history_iceberg" \
  "$stage_dir/terraform/artifacts/order_history_iceberg"
cp -a "$script_dir/terraform-marketplace/artifacts/order_history_iceberg_bundle.zip" \
  "$stage_dir/terraform/artifacts/order_history_iceberg_bundle.zip"

archive="$script_dir/deep-sec-local-genai-terraform-Marketplace.zip"
rm -f "$archive"
(cd "$stage_dir" && zip -qr "$archive" terraform)
unzip -tq "$archive"
echo "Created deep-sec-local-genai-terraform-Marketplace.zip"
