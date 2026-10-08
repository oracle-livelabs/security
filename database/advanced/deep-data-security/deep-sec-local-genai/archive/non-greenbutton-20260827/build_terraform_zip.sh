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

rm -f "$script_dir/deep-sec-local-genai-terraform.zip"
(cd "$stage_dir" && zip -qr "$script_dir/deep-sec-local-genai-terraform.zip" terraform)
unzip -tq "$script_dir/deep-sec-local-genai-terraform.zip"
echo "Created deep-sec-local-genai-terraform.zip"
