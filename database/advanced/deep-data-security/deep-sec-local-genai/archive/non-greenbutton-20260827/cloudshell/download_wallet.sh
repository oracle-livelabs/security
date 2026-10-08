#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/generated/adb.env"
[ -z "${OCI_PROFILE:-}" ] && OCI_PROFILE=${ADB_OCI_PROFILE:-}
source "$script_dir/oci_profile.sh"
show_oci_profile
mkdir -vp "$script_dir/artifacts"
read -r -s -p 'Wallet password: ' wallet_password; echo
[ -n "$wallet_password" ] || { echo 'ERROR: wallet password is required' >&2; exit 2; }
oci_with_profile db autonomous-database generate-wallet --autonomous-database-id "$ADB_OCID" --password "$wallet_password" --file "$script_dir/artifacts/Wallet_DDS26AI.zip"
chmod 600 "$script_dir/artifacts/Wallet_DDS26AI.zip"
echo 'Wallet saved. This ZIP contains sensitive connection material; protect it.'
