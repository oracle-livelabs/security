#!/bin/bash
# Set or reset Microsoft Entra demo user passwords for the ADB lab.
# Run this from Azure Cloud Shell, not Oracle Cloud Shell.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
AZURE_ENV_FILE="${SCRIPT_DIR}/.adb-entra-id.azure.env"
USERS_ENV_FILE="${SCRIPT_DIR}/.adb-entra-id.users.env"

usage() {
  cat <<EOF
Usage:
  ./set_entra_user_passwords_azure_cloud_shell.sh
  ./set_entra_user_passwords_azure_cloud_shell.sh --user marvin
  ./set_entra_user_passwords_azure_cloud_shell.sh --user emma
  ./set_entra_user_passwords_azure_cloud_shell.sh --user marvin --password 'PasswordHere'
  ./set_entra_user_passwords_azure_cloud_shell.sh --all

Options:
  --user USER       Set password for marvin, emma, or a full UPN.
  --all             Set passwords for MARVIN_UPN and EMMA_UPN.
  --password VALUE  Password to set. If omitted, the script prompts securely.
  --generate        Generate a compliant password instead of prompting.
  -h, --help        Show this help.

Environment:
  MARVIN_UPN        Default: loaded from .adb-entra-id.azure.env or marvin@DOMAIN_NAME
  EMMA_UPN          Default: loaded from .adb-entra-id.azure.env or emma@DOMAIN_NAME
  DOMAIN_NAME       Required if MARVIN_UPN or EMMA_UPN are not already set.
EOF
}

if [ -f "$AZURE_ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$AZURE_ENV_FILE"
fi

USERS=()
PASSWORD=""
GENERATE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --user)
      [ $# -ge 2 ] || { echo -e "${RED}ERROR: --user requires a value.${NC}" >&2; exit 1; }
      USERS+=("$2")
      shift 2
      ;;
    --all)
      USERS+=("${MARVIN_UPN:-marvin@${DOMAIN_NAME:-}}" "${EMMA_UPN:-emma@${DOMAIN_NAME:-}}")
      shift
      ;;
    --password)
      [ $# -ge 2 ] || { echo -e "${RED}ERROR: --password requires a value.${NC}" >&2; exit 1; }
      PASSWORD="$2"
      shift 2
      ;;
    --generate)
      GENERATE=1
      shift
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
  USERS=("${MARVIN_UPN:-marvin@${DOMAIN_NAME:-}}" "${EMMA_UPN:-emma@${DOMAIN_NAME:-}}")
fi

resolve_user() {
  local user="$1"
  case "$user" in
    marvin|Marvin)
      printf '%s' "${MARVIN_UPN:-marvin@${DOMAIN_NAME:-}}"
      ;;
    emma|Emma)
      printf '%s' "${EMMA_UPN:-emma@${DOMAIN_NAME:-}}"
      ;;
    *)
      printf '%s' "$user"
      ;;
  esac
}

generate_password() {
  python3 - <<'PY'
import secrets
import string

# Conservative Entra password:
# - 24 characters
# - includes uppercase, lowercase, digit, and symbol
# - avoids readable policy-sensitive substrings
chars = string.ascii_letters + string.digits + "!@#$%*-_+="
blocked = ("password", "oracle", "admin", "marvin", "emma")
while True:
    password = "".join(secrets.choice(chars) for _ in range(24))
    lower = password.lower()
    if any(word in lower for word in blocked):
        continue
    if (any(c.islower() for c in password) and any(c.isupper() for c in password)
            and any(c.isdigit() for c in password) and any(c in "!@#$%*-_+=" for c in password)):
        print(password)
        break
PY
}

quote_shell() {
  python3 - "$1" <<'PY'
import shlex
import sys
print(shlex.quote(sys.argv[1]))
PY
}

read_password() {
  local password1 password2
  read -r -s -p "New Entra password: " password1
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

if ! command -v az >/dev/null 2>&1; then
  echo -e "${RED}ERROR: Azure CLI is not installed or not on PATH.${NC}" >&2
  echo "Open Azure Cloud Shell from the Azure Portal and run this script there."
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo -e "${RED}ERROR: Azure CLI is not logged in.${NC}" >&2
  exit 1
fi

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Set Microsoft Entra Demo User Passwords                              ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo

passwords_output=()
for requested in "${USERS[@]}"; do
  upn=$(resolve_user "$requested")
  if [ -z "$upn" ] || [[ "$upn" != *@* ]]; then
    echo -e "${RED}ERROR: Could not resolve user '${requested}' to a UPN.${NC}" >&2
    exit 1
  fi

  if ! az ad user show --id "$upn" >/dev/null 2>&1; then
    echo -e "${YELLOW}  User not found, skipping password reset: ${upn}${NC}"
    continue
  fi

  if [ "$GENERATE" = "1" ]; then
    password=$(generate_password)
  elif [ -n "$PASSWORD" ]; then
    password="$PASSWORD"
  else
    read_password
    password="$PASSWORD"
  fi

  az ad user update \
    --id "$upn" \
    --password "$password" \
    --force-change-password-next-sign-in false \
    >/dev/null
  echo -e "${CYAN}  Password set for ${upn}${NC}"
  passwords_output+=("$upn=$password")
done

{
  echo "# Demo Entra user credentials reset by this lab."
  echo "# Keep this file in Azure Cloud Shell. Do not copy it into source control."
  echo "export MARVIN_UPN=$(quote_shell "${MARVIN_UPN:-}")"
  echo "export EMMA_UPN=$(quote_shell "${EMMA_UPN:-}")"
  for entry in "${passwords_output[@]}"; do
    upn="${entry%%=*}"
    password="${entry#*=}"
    if [ "$upn" = "${MARVIN_UPN:-}" ]; then
      echo "export MARVIN_PASSWORD=$(quote_shell "$password")"
    elif [ "$upn" = "${EMMA_UPN:-}" ]; then
      echo "export EMMA_PASSWORD=$(quote_shell "$password")"
    fi
  done
} > "$USERS_ENV_FILE"
chmod 600 "$USERS_ENV_FILE"

echo
echo -e "${GREEN}Done.${NC}"
echo -e "${CYAN}Saved generated passwords to: ${USERS_ENV_FILE}${NC}"
echo "To display generated passwords in Azure Cloud Shell:"
echo "  source ./.adb-entra-id.users.env"
echo "  env | grep '_PASSWORD='"
echo
