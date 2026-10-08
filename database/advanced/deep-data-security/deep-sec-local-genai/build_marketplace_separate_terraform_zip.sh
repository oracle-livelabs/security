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
  cp -a "$script_dir/terraform-marketplace-separate/$file" "$stage_dir/terraform/$file"
done
cp -a "$script_dir/terraform-marketplace-separate/templates" "$stage_dir/terraform/templates"

archive="$script_dir/deep-sec-local-genai-terraform-MarketplaceSeparate.zip"
rm -f "$archive"
(cd "$stage_dir" && zip -qr "$archive" terraform)
unzip -tq "$archive"
if unzip -Z1 "$archive" | grep -q '/artifacts/'; then
  echo 'ERROR: MarketplaceSeparate Terraform archive unexpectedly contains artifacts.' >&2
  exit 1
fi
echo "Created deep-sec-local-genai-terraform-MarketplaceSeparate.zip"
