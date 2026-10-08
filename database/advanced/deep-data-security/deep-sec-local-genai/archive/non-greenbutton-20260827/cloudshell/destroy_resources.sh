#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/generated/adb.env"
[ -z "${OCI_PROFILE:-}" ] && OCI_PROFILE=${ADB_OCI_PROFILE:-}
source "$script_dir/oci_profile.sh"
show_oci_profile
read -r -p "Type the ADB name ($ADB_DB_NAME) to terminate it: " answer
[ "$answer" = "$ADB_DB_NAME" ] || { echo 'No resources changed.'; exit 1; }
oci_with_profile db autonomous-database delete --autonomous-database-id "$ADB_OCID" --force --wait-for-state TERMINATED
echo "Terminated $ADB_OCID"
