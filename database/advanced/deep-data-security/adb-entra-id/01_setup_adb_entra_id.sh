#!/bin/bash
# Create or reuse the ADB-S instance and wallet after Entra apps are prepared.
# Run this from Oracle Cloud Shell. Run 00_create_entra_apps_azure_cloud_shell.sh
# in Azure Cloud Shell first, then copy its .adb-entra-id.azure.env file here.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ENV_FILE="${SCRIPT_DIR}/.adb-entra-id.env"
AZURE_ENV_FILE="${SCRIPT_DIR}/.adb-entra-id.azure.env"
INSTANCE_FILE="${SCRIPT_DIR}/.adb-entra-id.instance"
source "${SCRIPT_DIR}/lib_lab_instance.sh"

if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi
if [ -f "$AZURE_ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$AZURE_ENV_FILE"
fi

ADB_ENTRA_LAB_INSTANCE_ID=$(make_lab_instance_id "dbsec-lab-machine" "$INSTANCE_FILE" "ADB_ENTRA_LAB_INSTANCE_ID")
export ADB_ENTRA_LAB_INSTANCE_ID
ADB_ENTRA_LAB_INSTANCE_SHORT=$(short_lab_instance_id "$ADB_ENTRA_LAB_INSTANCE_ID" 6)
export ADB_ENTRA_LAB_INSTANCE_SHORT

export DB_NAME="${DB_NAME:-deepsec7${ADB_ENTRA_LAB_INSTANCE_SHORT}}"
export DB_DISPLAY_NAME="${DB_DISPLAY_NAME:-${DB_NAME}}"
export DB_VERSION="${DB_VERSION:-26ai}"
export ADB_IS_FREE_TIER="${ADB_IS_FREE_TIER:-true}"
ADB_IS_FREE_TIER=$(printf '%s' "$ADB_IS_FREE_TIER" | tr '[:upper:]' '[:lower:]')
if [ "$ADB_IS_FREE_TIER" != "true" ] && [ "$ADB_IS_FREE_TIER" != "false" ]; then
  echo -e "${RED}ERROR: ADB_IS_FREE_TIER must be true or false.${NC}" >&2
  exit 1
fi
export ADB_IS_FREE_TIER
export ADB_LICENSE_MODEL="${ADB_LICENSE_MODEL:-LICENSE_INCLUDED}"
export WALLET_PWD="${WALLET_PWD:-Oracle123+}"
export WALLET_DIR="${WALLET_DIR:-$HOME/adb_wallet/${DB_NAME}-entra}"
export ADB_SERVICE="${ADB_SERVICE:-${DB_NAME}_low}"
export OCI_COMPARTMENT="${1:-${OCI_COMPARTMENT:-root}}"
export TENANCY_OCID="${TENANCY_OCID:-${OCI_TENANCY:-}}"
export ADB_ENTRA_ALIAS="${ADB_ENTRA_ALIAS:-hrdb_entra}"

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 1B: Create Autonomous Database and Wallet in Oracle Cloud Shell  ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo

for cmd in oci python3 unzip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo -e "${RED}ERROR: ${cmd} is not available on PATH.${NC}"
    exit 1
  fi
done

if ! oci iam region list >/dev/null 2>&1; then
  echo -e "${RED}ERROR: OCI CLI cannot call OCI. In Oracle Cloud Shell, refresh the session or check your tenancy.${NC}"
  exit 1
fi

missing_entra_vars=()
for var_name in TENANT_ID DOMAIN_NAME APP_ID APP_ID_URI CLIENT_ID ENTRA_DB_APP_NAME ENTRA_CLIENT_APP_NAME MARVIN_UPN EMMA_UPN; do
  if [ -z "${!var_name:-}" ]; then
    missing_entra_vars+=("$var_name")
  fi
done
if [ "${#missing_entra_vars[@]}" -gt 0 ]; then
  echo -e "${RED}ERROR: Missing Entra ID values: ${missing_entra_vars[*]}${NC}"
  echo
  echo "Run ./00_create_entra_apps_azure_cloud_shell.sh in Azure Cloud Shell first."
  echo "Then copy the generated .adb-entra-id.azure.env file into this directory in Oracle Cloud Shell."
  exit 1
fi

generate_adb_admin_password() {
  python3 - <<'PY'
import secrets
import string

# Conservative ADB admin password:
# - 20 characters, within ADB's password length range
# - contains uppercase, lowercase, and digits
# - uses only letters and digits to avoid shell and wallet escaping issues
# - avoids readable policy-sensitive substrings such as admin/oracle/password
alphabet = string.ascii_letters + string.digits
blocked = ("admin", "oracle", "password")
while True:
    password = "".join(secrets.choice(alphabet) for _ in range(20))
    lower = password.lower()
    if any(word in lower for word in blocked):
        continue
    if (any(c.islower() for c in password)
            and any(c.isupper() for c in password)
            and any(c.isdigit() for c in password)):
        print(password)
        break
PY
}

if [ -z "${ADMIN_PWD:-}" ]; then
  ADMIN_PWD=$(generate_adb_admin_password)
  export ADMIN_PWD
  ADMIN_PWD_WAS_GENERATED=1
else
  export ADMIN_PWD
  ADMIN_PWD_WAS_GENERATED=0
fi

read_oci_config_value() {
  local key="$1"
  local profile="${OCI_PROFILE:-${OCI_CLI_PROFILE:-DEFAULT}}"
  local config_file="${OCI_CONFIG_FILE:-${OCI_CLI_CONFIG_FILE:-$HOME/.oci/config}}"

  [ -f "$config_file" ] || return 0

  awk -F= -v section="[$profile]" -v key="$key" '
    $0 == section { in_section = 1; next }
    /^\[/ { in_section = 0 }
    in_section && $1 == key {
      value = $2
      sub(/^[ \t]+/, "", value)
      sub(/[ \t]+$/, "", value)
      print value
      exit
    }
  ' "$config_file"
}

if [ -z "$TENANCY_OCID" ]; then
  TENANCY_OCID=$(read_oci_config_value tenancy || true)
fi

if [ -z "${ROOT_COMP_ID:-}" ]; then
  if [ "$OCI_COMPARTMENT" = "root" ]; then
    ROOT_COMP_ID="$TENANCY_OCID"
  elif [[ "$OCI_COMPARTMENT" == ocid1.compartment.* ]]; then
    ROOT_COMP_ID="$OCI_COMPARTMENT"
  else
    ROOT_COMP_ID=$(oci iam compartment list \
      --compartment-id "$TENANCY_OCID" \
      --all \
      --compartment-id-in-subtree true \
      --query "data[?name=='${OCI_COMPARTMENT}' && lifecycle-state=='ACTIVE'].id | [0]" \
      --raw-output)
  fi
fi

if [ -z "${ROOT_COMP_ID:-}" ] || [ "$ROOT_COMP_ID" = "null" ] || [ "$ROOT_COMP_ID" = "None" ]; then
  echo -e "${RED}ERROR: Could not resolve target compartment.${NC}"
  echo "Set OCI_COMPARTMENT to a compartment name, root, or an OCID."
  echo "Example:"
  echo "  export OCI_COMPARTMENT=root"
  exit 1
fi
export ROOT_COMP_ID

echo -e "${PURPLE}Configuration:${NC}"
echo -e "${CYAN}  ROOT_COMP_ID          = ${ROOT_COMP_ID}${NC}"
echo -e "${CYAN}  DB_NAME               = ${DB_NAME}${NC}"
echo -e "${CYAN}  LAB_INSTANCE_ID       = ${ADB_ENTRA_LAB_INSTANCE_ID}${NC}"
echo -e "${CYAN}  DB_VERSION            = ${DB_VERSION}${NC}"
echo -e "${CYAN}  IS_FREE_TIER          = ${ADB_IS_FREE_TIER}${NC}"
if [ "$ADB_IS_FREE_TIER" = "false" ]; then
  echo -e "${CYAN}  LICENSE_MODEL         = ${ADB_LICENSE_MODEL}${NC}"
fi
echo -e "${CYAN}  ADB_SERVICE           = ${ADB_SERVICE}${NC}"
echo -e "${CYAN}  WALLET_DIR            = ${WALLET_DIR}${NC}"
if [ "$ADMIN_PWD_WAS_GENERATED" = "1" ]; then
  echo -e "${CYAN}  ADMIN_PWD             = generated and saved to .adb-entra-id.env${NC}"
else
  echo -e "${CYAN}  ADMIN_PWD             = loaded from environment or .adb-entra-id.env${NC}"
fi
echo -e "${CYAN}  TENANT_ID             = ${TENANT_ID}${NC}"
echo -e "${CYAN}  DOMAIN_NAME           = ${DOMAIN_NAME}${NC}"
echo -e "${CYAN}  APP_ID_URI            = ${APP_ID_URI}${NC}"
echo -e "${CYAN}  ENTRA_DB_APP_NAME     = ${ENTRA_DB_APP_NAME}${NC}"
echo -e "${CYAN}  ENTRA_CLIENT_APP_NAME = ${ENTRA_CLIENT_APP_NAME}${NC}"
echo -e "${CYAN}  MARVIN_UPN            = ${MARVIN_UPN}${NC}"
echo -e "${CYAN}  EMMA_UPN              = ${EMMA_UPN}${NC}"
echo

echo -e "${YELLOW}Step 1: Creating or reusing Autonomous Database...${NC}"
ADB_OCID=$(oci db autonomous-database list \
  --compartment-id "$ROOT_COMP_ID" \
  --all \
  --raw-output \
  --query "data[?\"db-name\"=='${DB_NAME}' && \"lifecycle-state\"!='TERMINATED'].id | [0]")

if [ -z "$ADB_OCID" ] || [ "$ADB_OCID" = "null" ]; then
  adb_license_args=()
  if [ "$ADB_IS_FREE_TIER" = "false" ]; then
    adb_license_args=(--license-model "$ADB_LICENSE_MODEL")
  fi

  oci db autonomous-database create \
    --compartment-id "$ROOT_COMP_ID" \
    --db-name "$DB_NAME" \
    --display-name "$DB_DISPLAY_NAME" \
    --admin-password "$ADMIN_PWD" \
    --db-version "$DB_VERSION" \
    --is-free-tier "$ADB_IS_FREE_TIER" \
    --compute-model ECPU \
    --compute-count 2 \
    --data-storage-size-in-tbs 1 \
    "${adb_license_args[@]}" \
    --wait-for-state AVAILABLE \
    >/dev/null

  ADB_OCID=$(oci db autonomous-database list \
    --compartment-id "$ROOT_COMP_ID" \
    --all \
    --raw-output \
    --query "data[?\"db-name\"=='${DB_NAME}' && \"lifecycle-state\"!='TERMINATED'].id | [0]")
  echo -e "${CYAN}  Created ADB: ${ADB_OCID}${NC}"
else
  echo -e "${CYAN}  Reusing ADB: ${ADB_OCID}${NC}"
fi

echo
echo -e "${YELLOW}Step 2: Downloading wallet...${NC}"
mkdir -p "$WALLET_DIR"
oci db autonomous-database generate-wallet \
  --autonomous-database-id "$ADB_OCID" \
  --password "$WALLET_PWD" \
  --file "${WALLET_DIR}/${DB_NAME}_wallet.zip" \
  >/dev/null
(
  cd "$WALLET_DIR"
  unzip -oq "${DB_NAME}_wallet.zip"
)

if [ -f "${WALLET_DIR}/sqlnet.ora" ]; then
  sed -i.bak-wallet-dir -E "s#DIRECTORY=\"\\?/network/admin\"#DIRECTORY=\"${WALLET_DIR}\"#g" "${WALLET_DIR}/sqlnet.ora"
fi

cat > "$ENV_FILE" <<EOF
export ROOT_COMP_ID='${ROOT_COMP_ID}'
export DB_NAME='${DB_NAME}'
export DB_DISPLAY_NAME='${DB_DISPLAY_NAME}'
export DB_VERSION='${DB_VERSION}'
export ADB_IS_FREE_TIER='${ADB_IS_FREE_TIER}'
export ADB_LICENSE_MODEL='${ADB_LICENSE_MODEL}'
export ADB_OCID='${ADB_OCID}'
export ADB_SERVICE='${ADB_SERVICE}'
export ADMIN_PWD='${ADMIN_PWD}'
export WALLET_PWD='${WALLET_PWD}'
export WALLET_DIR='${WALLET_DIR}'
export TNS_ADMIN='${WALLET_DIR}'
export TENANT_ID='${TENANT_ID}'
export DOMAIN_NAME='${DOMAIN_NAME}'
export APP_ID='${APP_ID}'
export APP_ID_URI='${APP_ID_URI}'
export CLIENT_ID='${CLIENT_ID}'
export ADB_ENTRA_LAB_INSTANCE_ID='${ADB_ENTRA_LAB_INSTANCE_ID}'
export ENTRA_DB_APP_NAME='${ENTRA_DB_APP_NAME}'
export ENTRA_CLIENT_APP_NAME='${ENTRA_CLIENT_APP_NAME}'
export MARVIN_UPN='${MARVIN_UPN}'
export EMMA_UPN='${EMMA_UPN}'
export ADB_ENTRA_ALIAS='${ADB_ENTRA_ALIAS}'
EOF
chmod 600 "$ENV_FILE"

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 1B Completed: ADB and Wallet Ready                               ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}Environment file: ${ENV_FILE}${NC}"
echo "Load it before continuing:"
echo "  source ./.adb-entra-id.env"
echo
