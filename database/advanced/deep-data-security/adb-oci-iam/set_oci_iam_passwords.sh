#!/bin/bash
# Set OCI IAM passwords for the demo users created by 00_setup_adb.sh.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

usage() {
  cat <<EOF
Usage:
  ./set_oci_iam_passwords.sh
  ./set_oci_iam_passwords.sh --user marvin
  ./set_oci_iam_passwords.sh --user marvin --password 'PasswordHere'
  ./set_oci_iam_passwords.sh --all

Options:
  --user USERNAME     Set the password for one OCI IAM user.
  --all               Set passwords for MARVIN_USERNAME and EMMA_USERNAME.
  --password VALUE    Password to set. If omitted, the script prompts securely.
  -h, --help          Show this help.

Environment:
  OCI_DOMAIN_URL      OCI IAM identity domain URL. Usually loaded from .adb-oci-iam.env.
  OCI_PROFILE         Optional OCI CLI profile.
  OCI_CONFIG_FILE     Optional OCI CLI config file.
  MARVIN_USERNAME     Default: marvin
  EMMA_USERNAME       Default: emma
EOF
}

USERS=()
PASSWORD=""

while [ $# -gt 0 ]; do
  case "$1" in
    --user)
      [ $# -ge 2 ] || { echo -e "${RED}ERROR: --user requires a value.${NC}" >&2; exit 1; }
      USERS+=("$2")
      shift 2
      ;;
    --all)
      USERS+=("${MARVIN_USERNAME:-marvin}" "${EMMA_USERNAME:-emma}")
      shift
      ;;
    --password)
      [ $# -ge 2 ] || { echo -e "${RED}ERROR: --password requires a value.${NC}" >&2; exit 1; }
      PASSWORD="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo -e "${RED}ERROR: Unknown option: $1${NC}" >&2
      usage
      exit 1
      ;;
  esac
done

if [ ${#USERS[@]} -eq 0 ]; then
  USERS=("${MARVIN_USERNAME:-marvin}" "${EMMA_USERNAME:-emma}")
fi

if [ -z "${OCI_DOMAIN_URL:-}" ] && [ -f "${SCRIPT_DIR}/.adb-oci-iam.env" ]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.adb-oci-iam.env"
fi

if [ -z "${OCI_DOMAIN_URL:-}" ]; then
  echo -e "${RED}ERROR: OCI_DOMAIN_URL is not set.${NC}" >&2
  echo -e "${YELLOW}Run ./00_setup_adb.sh and source ./.adb-oci-iam.env first.${NC}" >&2
  exit 1
fi

if ! command -v oci >/dev/null 2>&1; then
  echo -e "${RED}ERROR: OCI CLI is not installed or not on PATH.${NC}" >&2
  exit 1
fi

oci_global_args=()
[ -n "${OCI_CONFIG_FILE:-}" ] && oci_global_args+=(--config-file "$OCI_CONFIG_FILE")
[ -n "${OCI_PROFILE:-}" ] && oci_global_args+=(--profile "$OCI_PROFILE")

domain_cmd() {
  oci identity-domains "$@" --endpoint "$OCI_DOMAIN_URL" "${oci_global_args[@]}"
}

find_user_id() {
  local username="$1"
  local user_id
  user_id=$(domain_cmd users list \
    --all \
    --filter "userName eq \"${username}\"" \
    --query 'data.Resources[0].id' \
    --raw-output 2>/dev/null || true)

  if [ -z "$user_id" ] || [ "$user_id" = "null" ] || [ "$user_id" = "None" ]; then
    user_id=$(domain_cmd users list \
      --all \
      --filter "userName eq \"${username}\"" \
      --query 'data.resources[0].id' \
      --raw-output 2>/dev/null || true)
  fi

  [ "$user_id" = "null" ] || [ "$user_id" = "None" ] && user_id=""
  printf '%s' "$user_id"
}

read_password() {
  local password1 password2
  read -r -s -p "New OCI IAM password: " password1
  echo
  read -r -s -p "Confirm password: " password2
  echo

  if [ "$password1" != "$password2" ]; then
    echo -e "${RED}ERROR: Passwords do not match.${NC}" >&2
    exit 1
  fi

  if [ -z "$password1" ]; then
    echo -e "${RED}ERROR: Password cannot be empty.${NC}" >&2
    exit 1
  fi

  PASSWORD="$password1"
}

set_user_password() {
  local username="$1"
  local user_id
  user_id=$(find_user_id "$username")

  if [ -z "$user_id" ]; then
    echo -e "${YELLOW}  User not found: ${username}${NC}"
    return
  fi

  domain_cmd user-password-changer put \
    --user-password-changer-id "$user_id" \
    --schemas '["urn:ietf:params:scim:schemas:oracle:idcs:UserPasswordChanger"]' \
    --password "$PASSWORD" \
    --force \
    >/dev/null

  echo -e "${CYAN}  Password set for ${username}${NC}"
}

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Set OCI IAM Demo User Passwords                                      ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${PURPLE}Using OCI IAM domain:${NC}"
echo -e "${CYAN}  OCI_DOMAIN_URL = ${OCI_DOMAIN_URL}${NC}"
echo -e "${CYAN}  OCI_PROFILE    = ${OCI_PROFILE:-DEFAULT}${NC}"
echo

if [ -z "$PASSWORD" ]; then
  read_password
fi

for username in "${USERS[@]}"; do
  set_user_password "$username"
done

echo
echo -e "${GREEN}Done.${NC}"
echo
