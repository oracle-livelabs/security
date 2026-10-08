#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/generated/adb.env"
[ -z "${OCI_PROFILE:-}" ] && OCI_PROFILE=${ADB_OCI_PROFILE:-}
source "$script_dir/oci_profile.sh"
show_oci_profile
echo "Waiting for $ADB_OCID to be AVAILABLE..."
oci_with_profile db autonomous-database get --autonomous-database-id "$ADB_OCID" --wait-for-state AVAILABLE --query 'data."lifecycle-state"' --raw-output
