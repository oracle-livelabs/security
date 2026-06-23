#!/bin/bash
# Remove ADB OCI IAM lab database objects. Optionally remove OCI resources too.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

DELETE_ADB=false
REMOVE_ALL=false
FORCE=false
CLEANUP_FAILURES=()

for arg in "$@"; do
  case "$arg" in
    --delete-adb)
      DELETE_ADB=true
      ;;
    --remove-all)
      REMOVE_ALL=true
      DELETE_ADB=true
      ;;
    -f|--force|--DELETE)
      FORCE=true
      ;;
    *)
      echo "Usage: $0 [--delete-adb] [--remove-all] [-f|--force|--DELETE]" >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_env

confirm() {
  local prompt="$1"

  if [ "$FORCE" = true ]; then
    return 0
  fi

  echo -n "$prompt Type DELETE to continue: "
  read -r answer
  [ "$answer" = "DELETE" ]
}

record_cleanup_failure() {
  CLEANUP_FAILURES+=("$1")
}

run_cleanup_cmd() {
  local description="$1"
  shift

  echo -e "${CYAN}${description}:${NC}"
  show_cmd "$@"
  if "$@"; then
    echo -e "${CYAN}  OK${NC}"
  else
    local status=$?
    echo -e "${YELLOW}  Failed with exit code ${status}; continuing.${NC}"
    record_cleanup_failure "${description} failed with exit code ${status}"
  fi
}

delete_domain_app() {
  local app_id="${1:-}"
  local app_name="$2"

  if [ -z "${OCI_DOMAIN_URL:-}" ]; then
    echo -e "${YELLOW}Skipping ${app_name}; OCI_DOMAIN_URL is not set.${NC}"
    return 0
  fi

  if [ -z "$app_id" ] || [ "$app_id" = "null" ]; then
    echo -e "${YELLOW}Skipping ${app_name}; app OCID is not set.${NC}"
    return 0
  fi

  run_cleanup_cmd "Deactivating OCI IAM app ${app_name}" \
    oci identity-domains app patch \
      --endpoint "$OCI_DOMAIN_URL" \
      --app-id "$app_id" \
      --schemas '["urn:ietf:params:scim:api:messages:2.0:PatchOp"]' \
      --operations '[{"op":"replace","path":"active","value":false}]'

  run_cleanup_cmd "Deleting OCI IAM app ${app_name}" \
    oci identity-domains app delete \
      --endpoint "$OCI_DOMAIN_URL" \
      --app-id "$app_id" \
      --force
}

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 6: Clean Up ADB OCI IAM Data Grants Lab                          ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}ADB_SERVICE = ${ADB_SERVICE}${NC}"
echo -e "${CYAN}ADB_OCID    = ${ADB_OCID}${NC}"
echo -e "${CYAN}REMOVE_ALL  = ${REMOVE_ALL}${NC}"
echo

if confirm "This removes HR, data roles, and local lab roles."; then
  echo -e "${CYAN}SQL*Plus command:${NC}"
  show_cmd sqlplus -L -s "admin/<hidden>@${ADB_SERVICE}"
  admin_sqlplus <<'SQL'
set echo off
set serveroutput on
set feedback off
set heading off
whenever sqlerror continue

DECLARE
  TYPE step_list IS TABLE OF VARCHAR2(4000);
  steps step_list := step_list(
    'DROP DATA GRANT hr.HRAPP_MANAGER_ACCESS',
    'DROP DATA GRANT hr.EMPLOYEE_CONTEXT_GRANT',
    'DROP DATA GRANT hr.HRAPP_EMPLOYEES_ACCESS',
    'DROP DATA ROLE hrapp_managers',
    'DROP DATA ROLE hrapp_employees',
    'DROP ROLE direct_logon_role',
    'DROP ROLE employee_context_admin',
    'DROP USER hr CASCADE'
  );
  failures SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST();

  PROCEDURE record_failure(statement_text VARCHAR2, err VARCHAR2) IS
  BEGIN
    failures.EXTEND;
    failures(failures.COUNT) := statement_text || ' -> ' || err;
  END;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Running cleanup statements...');

  FOR i IN 1 .. steps.COUNT LOOP
    BEGIN
      DBMS_OUTPUT.PUT_LINE('  ' || steps(i));
      EXECUTE IMMEDIATE steps(i);
      DBMS_OUTPUT.PUT_LINE('    OK');
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE IN (-1918, -1919, -1924, -904, -942, -950) THEN
          DBMS_OUTPUT.PUT_LINE('    Skipped: ' || SQLERRM);
        ELSE
          DBMS_OUTPUT.PUT_LINE('    Failed: ' || SQLERRM);
          record_failure(steps(i), SQLERRM);
        END IF;
    END;
  END LOOP;

  IF failures.COUNT > 0 THEN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Cleanup completed with failures:');
    FOR i IN 1 .. failures.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('  - ' || failures(i));
    END LOOP;
  ELSE
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Cleanup completed without blocking failures.');
  END IF;
END;
/

exit;
SQL
else
  echo -e "${YELLOW}Skipped database object cleanup.${NC}"
fi

if [ "$DELETE_ADB" = true ]; then
  if confirm "This deletes the Autonomous AI Database ${DB_NAME}."; then
    if [ -z "${ROOT_COMP_ID:-}" ]; then
      echo -e "${RED}ERROR: ROOT_COMP_ID is not set; cannot delete ADB safely.${NC}"
      exit 1
    fi

    run_cleanup_cmd "Deleting ADB ${DB_NAME}" \
      oci db autonomous-database delete \
      --autonomous-database-id "$ADB_OCID" \
      --force \
      --wait-for-state SUCCEEDED
  else
    echo -e "${YELLOW}Skipped ADB deletion.${NC}"
  fi
fi

if [ "$REMOVE_ALL" = true ]; then
  if confirm "This deletes lab OAuth apps and removes local wallet/env/token files."; then
    echo
    echo -e "${YELLOW}Deleting lab OCI IAM OAuth applications...${NC}"
    delete_domain_app "${OCI_CLIENT_APP_ID:-}" "${OCI_CLIENT_APP_NAME:-${DB_NAME} ADB OCI IAM Public Client}"
    delete_domain_app "${OCI_DB_APP_ID:-}" "${OCI_DB_APP_NAME:-${DB_NAME} ADB OCI IAM DB Resource}"

    echo
    echo -e "${YELLOW}Removing local generated files...${NC}"
    run_cleanup_cmd "Removing wallet directory ${WALLET_DIR}" rm -rf "$WALLET_DIR"
    run_cleanup_cmd "Removing environment file ${SCRIPT_DIR}/.adb-oci-iam.env" rm -f "${SCRIPT_DIR}/.adb-oci-iam.env"
    run_cleanup_cmd "Removing local OCI IAM setup work directory" rm -rf "${SCRIPT_DIR}/.oci-iam-setup"
    run_cleanup_cmd "Removing local OCI IAM OAuth2 token cache" rm -rf "${OCI_TOKEN_DIR:-$HOME/.oci/adb-oci-iam}"

    echo
    echo -e "${YELLOW}OCI IAM domain users and groups were not deleted.${NC}"
    echo -e "${YELLOW}Review ${MARVIN_USERNAME:-marvin}, ${EMMA_USERNAME:-emma}, ${OCI_IAM_EMPLOYEE_GROUP:-EMPLOYEES}, and ${OCI_IAM_MANAGER_GROUP:-MANAGERS} manually before deleting shared identity objects.${NC}"
  else
    echo -e "${YELLOW}Skipped --remove-all OCI IAM app and local-file cleanup.${NC}"
  fi
fi

echo
if [ "${#CLEANUP_FAILURES[@]}" -gt 0 ]; then
  echo -e "${YELLOW}Cleanup completed with non-blocking failures:${NC}"
  for failure in "${CLEANUP_FAILURES[@]}"; do
    echo "  - ${failure}"
  done
  echo
fi
echo -e "${GREEN}Task 6 completed.${NC}"
echo
