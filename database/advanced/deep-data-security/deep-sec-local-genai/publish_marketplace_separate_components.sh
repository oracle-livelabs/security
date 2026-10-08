#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
profile=${OCI_CLI_PROFILE:-DEFAULT}
config_file=${OCI_CLI_CONFIG_FILE:-/home/revans/.oci/config}
bucket_name=${OCI_BUCKET_NAME:-dbsec_public}
namespace=${OCI_NAMESPACE:-}

if [[ $# -gt 1 || ( $# -eq 1 && $1 != application && $1 != all ) ]]; then
  echo "Usage: $0 [application|all]" >&2
  exit 2
fi

component=${1:-application}
if [[ -z "$namespace" ]]; then
  namespace=$(oci os ns get --profile "$profile" --config-file "$config_file" --query data --raw-output)
fi

upload() {
  local archive=$1
  local object_name=$2
  oci os object put \
    --profile "$profile" \
    --config-file "$config_file" \
    --namespace-name "$namespace" \
    --bucket-name "$bucket_name" \
    --name "$object_name" \
    --file "$archive" \
    --content-type application/zip \
    --force >/dev/null
  echo "Uploaded $object_name"
}

bash "$script_dir/build_marketplace_separate_app_zip.sh"
upload \
  "$script_dir/dist/deep-data-security-flask-app-MarketplaceSeparate.zip" \
  deep-data-security-flask-app-MarketplaceSeparate.zip

if [[ "$component" == all ]]; then
  bash "$script_dir/build_marketplace_separate_bundle.sh"
  upload \
    "$script_dir/dist/order_history_iceberg_bundle-MarketplaceSeparate.zip" \
    order_history_iceberg_bundle-MarketplaceSeparate.zip
fi

echo "Existing exact-object PARs remain valid; no Terraform archive was rebuilt."
