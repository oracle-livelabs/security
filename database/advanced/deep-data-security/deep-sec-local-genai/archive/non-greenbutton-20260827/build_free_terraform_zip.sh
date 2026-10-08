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
  iam.tf \
  object_storage.tf \
  jupyter.tf \
  locals.tf \
  .gitignore \
  .terraform.lock.hcl; do
  cp -a "$script_dir/terraform/$file" "$stage_dir/terraform/$file"
done

# Replace the production custom-image deployment with the deliberately small,
# Always Free policy-verification variant.  Keep iam.tf unchanged: the point of
# this archive is to exercise the same dynamic-group and policy resources.
for file in adb.tf compute.tf outputs.tf schema.yaml terraform.tfvars.example versions.tf; do
  cp "$script_dir/terraform/free/$file" "$stage_dir/terraform/$file"
done

rm -f "$script_dir/deep-sec-local-genai-terraform-FREE.zip"
# OCI Resource Manager uses the ZIP root as its working directory. Package the
# Terraform files directly at that root; the regular download archives retain
# their historical terraform/ wrapper, but would not be uploadable as stacks.
(cd "$stage_dir/terraform" && zip -qr "$script_dir/deep-sec-local-genai-terraform-FREE.zip" .)
unzip -tq "$script_dir/deep-sec-local-genai-terraform-FREE.zip"
echo "Created deep-sec-local-genai-terraform-FREE.zip"
