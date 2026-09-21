#!/bin/bash
# Remove ADB Microsoft Entra ID lab database objects. Optionally delete the ADB instance.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

DELETE_ADB=false
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --delete-adb)
      DELETE_ADB=true
      ;;
    -f|--force|--DELETE)
      FORCE=true
      ;;
    *)
      echo "Usage: $0 [--delete-adb] [-f|--force|--DELETE]" >&2
      exit 2
      ;;
  esac
done

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_entra_env

confirm() {
  local prompt="$1"
  if [ "$FORCE" = true ]; then
    return 0
  fi
  echo -n "$prompt Type DELETE to continue: "
  read -r answer
  [ "$answer" = "DELETE" ]
}

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Cleanup: ADB Microsoft Entra ID Data Grants Lab                       ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo

if confirm "This removes HR, data roles, and local lab roles."; then
  admin_sqlplus <<'SQL'
set serveroutput on
whenever sqlerror exit sql.sqlcode

DECLARE
  PROCEDURE run_cleanup(p_label VARCHAR2, p_sql VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_label);
    EXECUTE IMMEDIATE p_sql;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('  skipped: ' || SQLERRM);
  END;
BEGIN
  run_cleanup('Dropping data grant HR.HRAPP_MANAGER_ACCESS',
              'DROP DATA GRANT hr.HRAPP_MANAGER_ACCESS');
  run_cleanup('Dropping data grant HR.EMPLOYEE_CONTEXT_GRANT',
              'DROP DATA GRANT hr.EMPLOYEE_CONTEXT_GRANT');
  run_cleanup('Dropping data grant HR.HRAPP_EMPLOYEES_ACCESS',
              'DROP DATA GRANT hr.HRAPP_EMPLOYEES_ACCESS');
  run_cleanup('Dropping data role HRAPP_MANAGERS',
              'DROP DATA ROLE hrapp_managers');
  run_cleanup('Dropping data role HRAPP_EMPLOYEES',
              'DROP DATA ROLE hrapp_employees');
  run_cleanup('Dropping role DIRECT_LOGON_ROLE',
              'DROP ROLE direct_logon_role');
  run_cleanup('Dropping role EMPLOYEE_CONTEXT_ADMIN',
              'DROP ROLE employee_context_admin');
  run_cleanup('Dropping stale preview global user HRAPP_LOGIN',
              'DROP USER hrapp_login');
  run_cleanup('Dropping end user context HR.EMP_CTX',
              'DROP END USER CONTEXT HR.EMP_CTX');
  run_cleanup('Dropping user HR',
              'DROP USER hr CASCADE');
END;
/

exit;
SQL
else
  echo -e "${YELLOW}Skipped database object cleanup.${NC}"
fi

if [ "$DELETE_ADB" = true ]; then
  if confirm "This deletes the Autonomous Database ${DB_NAME}."; then
    oci db autonomous-database delete \
      --autonomous-database-id "$ADB_OCID" \
      --force \
      --wait-for-state SUCCEEDED \
      >/dev/null
    echo -e "${CYAN}Deleted ADB ${DB_NAME}.${NC}"
  else
    echo -e "${YELLOW}Skipped ADB deletion.${NC}"
  fi
fi

echo
echo -e "${GREEN}Cleanup completed.${NC}"
echo
