#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
requested_oci_profile=${OCI_PROFILE:-${OCI_CLI_PROFILE:-}}
[ -f "$script_dir/config.env" ] && source "$script_dir/config.env"
[ -n "$requested_oci_profile" ] && OCI_PROFILE=$requested_oci_profile
usage() {
  cat <<'EOF'
Usage: create_adb.sh [--compartment-id OCID] [--db-name NAME] [--display-name NAME]

Values supplied as arguments override cloudshell/config.env. ADB database names
must use Oracle database-name characters and are normalized to uppercase.
EOF
}
while [ "$#" -gt 0 ]; do
  case "$1" in
    --compartment-id) COMPARTMENT_OCID=${2:?--compartment-id requires an OCID}; shift 2 ;;
    --db-name) ADB_DB_NAME=${2:?--db-name requires a name}; shift 2 ;;
    --display-name) ADB_DISPLAY_NAME=${2:?--display-name requires a name}; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
source "$script_dir/oci_profile.sh"
for var in COMPARTMENT_OCID ADB_DISPLAY_NAME ADB_DB_NAME ADB_ADMIN_PASSWORD; do
  [ -n "${!var:-}" ] || { echo "ERROR: $var is required" >&2; exit 2; }
done
command -v oci >/dev/null || { echo "ERROR: OCI CLI is required" >&2; exit 1; }
ADB_DB_NAME=${ADB_DB_NAME^^}
[[ "$ADB_DB_NAME" =~ ^[A-Z][A-Z0-9_$#]{0,29}$ ]] || { echo 'ERROR: ADB_DB_NAME must be a valid Oracle database name (up to 30 characters).' >&2; exit 2; }
show_oci_profile
printf 'Target compartment: %s\nTarget DB name    : %s\n' "$COMPARTMENT_OCID" "$ADB_DB_NAME"
mkdir -vp "$script_dir/generated"
existing=$(oci_with_profile db autonomous-database list --compartment-id "$COMPARTMENT_OCID" --display-name "$ADB_DISPLAY_NAME" --query 'data[0].id' --raw-output)
if [ "$existing" = "null" ] || [ -z "$existing" ]; then
  echo "Creating Autonomous AI Database $ADB_DISPLAY_NAME..."
  existing=$(oci_with_profile db autonomous-database create --compartment-id "$COMPARTMENT_OCID" --display-name "$ADB_DISPLAY_NAME" --db-name "$ADB_DB_NAME" --db-version 26ai --db-workload OLTP --compute-model ECPU --compute-count "${ADB_COMPUTE_COUNT:-2}" --data-storage-size-in-gbs "${ADB_STORAGE_GB:-20}" --license-model "${ADB_LICENSE_MODEL:-LICENSE_INCLUDED}" --admin-password "$ADB_ADMIN_PASSWORD" --is-auto-scaling-enabled true --wait-for-state AVAILABLE --query 'data.id' --raw-output)
else
  echo "Reusing Autonomous Database $existing and waiting for it to become available..."
  oci_with_profile db autonomous-database get --autonomous-database-id "$existing" --wait-for-state AVAILABLE >/dev/null
  existing_db_name=$(oci_with_profile db autonomous-database get --autonomous-database-id "$existing" --query 'data."db-name"' --raw-output)
  [ "$existing_db_name" = "$ADB_DB_NAME" ] || { echo "ERROR: $ADB_DISPLAY_NAME exists with DB name $existing_db_name, not $ADB_DB_NAME." >&2; exit 1; }
fi
cat > "$script_dir/generated/adb.env" <<EOF
ADB_OCID=$existing
ADB_DB_NAME=$ADB_DB_NAME
ADB_DISPLAY_NAME=$ADB_DISPLAY_NAME
ADB_COMPARTMENT_OCID=$COMPARTMENT_OCID
ADB_OCI_PROFILE=$OCI_PROFILE_NAME
ADB_REGION=${OCI_REGION:-$(oci_with_profile iam region-subscription list --query 'data[0]."region-name"' --raw-output)}
EOF
chmod 600 "$script_dir/generated/adb.env"
echo "Saved non-secret ADB details to cloudshell/generated/adb.env"
