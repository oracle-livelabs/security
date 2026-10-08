#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/generated/adb.env"
[ -z "${OCI_PROFILE:-}" ] && OCI_PROFILE=${ADB_OCI_PROFILE:-}
source "$script_dir/oci_profile.sh"
show_oci_profile
oci_with_profile db autonomous-database get --autonomous-database-id "$ADB_OCID" --query 'data.{ocid:id,display_name:"display-name",db_name:"db-name",version:"db-version",lifecycle:"lifecycle-state",compute:"compute-count",database_actions:"database-actions-url",connection_strings:"connection-strings"}' --output table
