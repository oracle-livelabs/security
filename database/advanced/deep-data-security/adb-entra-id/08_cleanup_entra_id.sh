#!/bin/bash
# Delete the Microsoft Entra ID app registrations created by this ADB lab.
# Optionally delete demo users created by the lab.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

FORCE=false
DELETE_USERS=false
for arg in "$@"; do
  case "$arg" in
    -f|--force|--DELETE)
      FORCE=true
      ;;
    --delete-users)
      DELETE_USERS=true
      ;;
    --all)
      DELETE_USERS=true
      ;;
    *)
      echo "Usage: $0 [-f|--force|--DELETE] [--delete-users|--all]" >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ENV_FILE="${SCRIPT_DIR}/.adb-entra-id.env"
AZURE_ENV_FILE="${SCRIPT_DIR}/.adb-entra-id.azure.env"
USERS_ENV_FILE="${SCRIPT_DIR}/.adb-entra-id.users.env"
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
elif [ -f "$AZURE_ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$AZURE_ENV_FILE"
fi
if [ -f "$USERS_ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$USERS_ENV_FILE"
fi

export DB_NAME="${DB_NAME:-deepsec7}"
export ENTRA_DB_APP_NAME="${ENTRA_DB_APP_NAME:-Oracle Database 26ai ADB - ${DB_NAME}}"
export ENTRA_CLIENT_APP_NAME="${ENTRA_CLIENT_APP_NAME:-Oracle Client Interactive ADB - ${DB_NAME}}"
export MARVIN_UPN="${MARVIN_UPN:-}"
export EMMA_UPN="${EMMA_UPN:-}"
export AZURE_CORE_ONLY_SHOW_ERRORS="${AZURE_CORE_ONLY_SHOW_ERRORS:-true}"

if ! command -v az >/dev/null 2>&1; then
  echo -e "${RED}ERROR: Azure CLI is not installed or not on PATH.${NC}"
  echo "Open Azure Cloud Shell from the Azure Portal and run this script there."
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo -e "${RED}ERROR: Azure CLI is not logged in.${NC}"
  echo -e "${YELLOW}Open Azure Cloud Shell from the Azure Portal, select Bash, and sign in when prompted.${NC}"
  exit 1
fi

confirm() {
  if [ "$FORCE" = true ]; then
    return 0
  fi
  local prompt="$1"
  echo -n "${prompt} Type DELETE to continue: "
  read -r answer
  [ "$answer" = "DELETE" ]
}

delete_app_by_name() {
  local display_name="$1"
  local app_id
  local sp_id

  app_id=$(az ad app list \
    --display-name "$display_name" \
    --query "[?displayName=='${display_name}'].appId | [0]" \
    --output tsv 2>/dev/null || true)

  if [ -z "$app_id" ]; then
    echo -e "${YELLOW}  App not found: ${display_name}${NC}"
    return
  fi

  sp_id=$(az ad sp show --id "$app_id" --query id --output tsv 2>/dev/null || true)

  echo -e "${CYAN}  Deleting app registration ${display_name}: ${app_id}${NC}"
  az ad app delete --id "$app_id" || true

  if [ -n "$sp_id" ]; then
    if az ad sp show --id "$sp_id" >/dev/null 2>&1; then
      echo -e "${CYAN}  Deleting enterprise application ${display_name}: ${sp_id}${NC}"
      az ad sp delete --id "$sp_id" || true
    else
      echo -e "${YELLOW}  Enterprise application already removed: ${display_name}${NC}"
    fi
  fi
}

delete_user_by_upn() {
  local upn="$1"
  local user_id

  if [ -z "$upn" ]; then
    return
  fi

  user_id=$(az ad user show --id "$upn" --query id --output tsv 2>/dev/null || true)
  if [ -z "$user_id" ]; then
    echo -e "${YELLOW}  User not found: ${upn}${NC}"
    return
  fi

  echo -e "${CYAN}  Deleting user ${upn}: ${user_id}${NC}"
  az ad user delete --id "$upn"
}

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Cleanup: Microsoft Entra ID Objects                                   ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}ENTRA_DB_APP_NAME      = ${ENTRA_DB_APP_NAME}${NC}"
echo -e "${CYAN}ENTRA_CLIENT_APP_NAME  = ${ENTRA_CLIENT_APP_NAME}${NC}"
echo -e "${CYAN}MARVIN_UPN             = ${MARVIN_UPN:-<not set>}${NC}"
echo -e "${CYAN}EMMA_UPN               = ${EMMA_UPN:-<not set>}${NC}"
echo -e "${CYAN}DELETE_USERS           = ${DELETE_USERS}${NC}"
echo

if confirm "This deletes Entra app registrations, enterprise apps, app roles, and app role assignments for ${DB_NAME}."; then
  delete_app_by_name "$ENTRA_CLIENT_APP_NAME"
  delete_app_by_name "$ENTRA_DB_APP_NAME"
else
  echo -e "${YELLOW}Skipped Entra ID cleanup.${NC}"
fi

if [ "$DELETE_USERS" = true ]; then
  if confirm "This deletes demo users ${MARVIN_UPN:-<not set>} and ${EMMA_UPN:-<not set>}."; then
    delete_user_by_upn "$EMMA_UPN"
    delete_user_by_upn "$MARVIN_UPN"
  else
    echo -e "${YELLOW}Skipped demo user deletion.${NC}"
  fi
else
  echo -e "${YELLOW}Demo users were not deleted. Add --delete-users to delete Marvin and Emma.${NC}"
fi

echo
echo -e "${GREEN}Cleanup completed.${NC}"
echo
