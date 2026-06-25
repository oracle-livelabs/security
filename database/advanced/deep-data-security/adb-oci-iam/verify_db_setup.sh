#!/bin/bash
# Verify the ADMIN-side ADB OCI IAM lab objects before token login.

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_env

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Verify ADB OCI IAM Data Grants Setup                                  ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}ADB_SERVICE = ${ADB_SERVICE}${NC}"
echo -e "${CYAN}SQL*Plus command:${NC}"
show_cmd sqlplus -L -s "admin/<hidden>@${ADB_SERVICE}"
echo

if ! admin_sqlplus <<'SQL'
set pagesize 100
set linesize 180
set tab off
set trimspool on
whenever sqlerror exit sql.sqlcode

col name format a35
col value format a120
SELECT name, value
FROM v$parameter
WHERE name IN ('identity_provider_type', 'identity_provider_oauth_config');

SELECT COUNT(*) AS hr_employee_rows
FROM hr.employees;

col credential_name format a35
col username format a50
SELECT credential_name, username
FROM dba_credentials
WHERE credential_name = 'OCI_IAM_DOMAIN_DB_CRED$';

col data_role format a24
col mapped_to format a45
SELECT data_role, mapped_to
FROM dba_data_roles
WHERE data_role IN ('HRAPP_EMPLOYEES', 'HRAPP_MANAGERS')
ORDER BY data_role;

col username format a24
col external_name format a45
SELECT username, authentication_type, external_name
FROM dba_users
WHERE username = 'HR'
ORDER BY username;

exit;
SQL
then
  echo -e "${RED}ERROR: Database setup verification failed.${NC}"
  exit 1
fi

echo
echo -e "${GREEN}Verification completed.${NC}"
echo
