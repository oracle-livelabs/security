#!/bin/bash
# Verify ADMIN-side ADB Microsoft Entra ID lab objects before browser login.

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_entra_env

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 5: Verify ADB Microsoft Entra ID Data Grants Setup               ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}ADB_SERVICE = ${ADB_SERVICE}${NC}"
echo

if ! admin_sqlplus <<'SQL'
set pagesize 100
set linesize 180
set tab off
set trimspool on
whenever sqlerror exit sql.sqlcode

col name format a35
col value format a100
SELECT name, value
FROM v$parameter
WHERE name IN ('identity_provider_type', 'identity_provider_config');

SELECT COUNT(*) AS hr_employee_rows
FROM hr.employees;

col data_role format a24
col mapped_to format a45
SELECT data_role, mapped_to
FROM dba_data_roles
WHERE data_role IN ('HRAPP_EMPLOYEES', 'HRAPP_MANAGERS')
ORDER BY data_role;

col username format a24
col authentication_type format a20
col external_name format a45
SELECT username, authentication_type, external_name
FROM dba_users
WHERE username = 'HR'
ORDER BY username;

col grantee format a24
col granted_role format a24
SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee IN ('HRAPP_EMPLOYEES', 'HRAPP_MANAGERS')
  AND granted_role = 'DIRECT_LOGON_ROLE'
ORDER BY grantee, granted_role;

col privilege format a24
SELECT grantee, privilege
FROM dba_sys_privs
WHERE grantee = 'DIRECT_LOGON_ROLE'
  AND privilege = 'CREATE SESSION'
ORDER BY grantee, privilege;

col context_owner format a14
col context_name format a20
col handler_package format a24
col handler_procedure format a24
col handler_status format a16
SELECT context_owner, context_name, handler_package, handler_procedure, handler_status
FROM dba_end_user_context_definitions
WHERE context_owner = 'HR'
  AND context_name = 'EMP_CTX'
ORDER BY context_owner, context_name;

col grant_name format a35
col object_owner format a12
col object_name format a24
col predicate format a70
SELECT grant_name, object_owner, object_name, predicate
FROM dba_data_grants
WHERE grant_name IN ('HRAPP_EMPLOYEES_ACCESS', 'EMPLOYEE_CONTEXT_GRANT', 'HRAPP_MANAGER_ACCESS')
ORDER BY grant_name, privilege;

exit;
SQL
then
  echo -e "${RED}ERROR: Database setup verification failed.${NC}"
  exit 1
fi

echo
echo -e "${GREEN}Task 5 completed. Next: run ./06_prepare_windows_client_bundle.sh${NC}"
echo
