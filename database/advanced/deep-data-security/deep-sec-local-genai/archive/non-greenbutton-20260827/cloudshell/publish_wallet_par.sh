#!/usr/bin/env bash
# Publish the generated ADB wallet through a short-lived, object-read-only PAR.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
requested_oci_profile=${OCI_PROFILE:-${OCI_CLI_PROFILE:-}}
[ -f "$script_dir/config.env" ] && source "$script_dir/config.env"
[ -n "$requested_oci_profile" ] && OCI_PROFILE=$requested_oci_profile
source "$script_dir/oci_profile.sh"

wallet_file="$script_dir/artifacts/Wallet_DDS26AI.zip"
bucket_name=${WALLET_BUCKET_NAME:-}
object_name=${WALLET_OBJECT_NAME:-Wallet_DDS26AI.zip}
expiry_hours=${WALLET_PAR_EXPIRY_HOURS:-24}

[ -f "$wallet_file" ] || { echo 'ERROR: Download the wallet first with download_wallet.sh' >&2; exit 1; }
[ -n "$bucket_name" ] || { echo 'ERROR: WALLET_BUCKET_NAME is required.' >&2; exit 2; }
[[ "$expiry_hours" =~ ^[1-9][0-9]*$ ]] || { echo 'ERROR: WALLET_PAR_EXPIRY_HOURS must be a positive integer.' >&2; exit 2; }
command -v oci >/dev/null || { echo 'ERROR: OCI CLI is required.' >&2; exit 1; }

show_oci_profile
namespace=$(oci_with_profile os ns get --query data --raw-output)
bucket_compartment=$(oci_with_profile os bucket get --namespace-name "$namespace" --bucket-name "$bucket_name" --query 'data."compartment-id"' --raw-output)
if [ -n "${WALLET_BUCKET_COMPARTMENT_OCID:-}" ] && [ "$bucket_compartment" != "$WALLET_BUCKET_COMPARTMENT_OCID" ]; then
  echo "ERROR: wallet bucket belongs to $bucket_compartment, not WALLET_BUCKET_COMPARTMENT_OCID." >&2
  exit 1
fi

expires_at=$(date -u -d "+${expiry_hours} hours" +%Y-%m-%dT%H:%M:%SZ)
echo "Uploading sensitive wallet to bucket $bucket_name as $object_name..."
oci_with_profile os object put --namespace-name "$namespace" --bucket-name "$bucket_name" --name "$object_name" --file "$wallet_file" --force >/dev/null

par_name="dds-wallet-$(date -u +%Y%m%dT%H%M%SZ)"
access_uri=$(oci_with_profile os preauth-request create --namespace-name "$namespace" --bucket-name "$bucket_name" --name "$par_name" --access-type ObjectRead --object-name "$object_name" --time-expires "$expires_at" --query 'data."access-uri"' --raw-output)
region=${OCI_REGION:-$(oci_with_profile iam region-subscription list --query 'data[0]."region-name"' --raw-output)}
par_url="https://objectstorage.${region}.oraclecloud.com${access_uri}"

mkdir -vp "$script_dir/generated"
umask 077
printf '%s\n' "$par_url" > "$script_dir/generated/wallet.par-url"
printf 'Wallet object: %s/%s\nPAR expires : %s\n' "$bucket_name" "$object_name" "$expires_at"
echo "Sensitive PAR URL saved to cloudshell/generated/wallet.par-url"
echo 'Copy that URL only through the lab-approved secure channel. Anyone holding it can download the wallet until it expires.'
