#!/bin/bash
# Verify ADB OCI IAM data grants with a Marvin OAuth2 token.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
source "${SCRIPT_DIR}/lib_token_check.sh"
require_adb_env

export MARVIN_USERNAME="${MARVIN_USERNAME:-marvin}"
export OCI_IAM_EMPLOYEE_GROUP="${OCI_IAM_EMPLOYEE_GROUP:-EMPLOYEES}"
export OCI_IAM_MANAGER_GROUP="${OCI_IAM_MANAGER_GROUP:-MANAGERS}"

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 5: Connect and Verify as Marvin via OCI IAM                      ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${PURPLE}First run ./04_get_iam_oauth_token.sh and sign in as ${MARVIN_USERNAME}.${NC}"
echo -e "${PURPLE}Marvin must be in ${OCI_IAM_EMPLOYEE_GROUP} and ${OCI_IAM_MANAGER_GROUP}.${NC}"
echo -e "${CYAN}TOKEN_LOCATION=${OCI_TOKEN_DIR:-$HOME/.oci/adb-oci-iam}${NC}"
require_sqlplus
echo "  sqlplus -L -s /@${ADB_SERVICE}"
echo

check_oauth_token "$MARVIN_USERNAME" "$OCI_IAM_EMPLOYEE_GROUP" "$OCI_IAM_MANAGER_GROUP"
echo

sqlplus -L -s "/@${ADB_SERVICE}" <<'SQL'
set pagesize 100
set linesize 180
set tab off
set trimspool on
whenever sqlerror exit sql.sqlcode

prompt
prompt ========================================================================
prompt Marvin's OCI IAM Session Identity
prompt ========================================================================

col current_user format a30
col authenticated_identity format a45
col auth_method format a25

SELECT
  sys_context('USERENV', 'CURRENT_USER') AS current_user,
  sys_context('USERENV', 'AUTHENTICATED_IDENTITY') AS authenticated_identity,
  sys_context('USERENV', 'AUTHENTICATION_METHOD') AS auth_method
FROM dual;

prompt
prompt ========================================================================
prompt Marvin's Active Data Roles
prompt ========================================================================

col role_name format a30
SELECT role_name
FROM v$end_user_data_role
WHERE role_name IN ('HRAPP_EMPLOYEES', 'HRAPP_MANAGERS')
ORDER BY role_name;

prompt
prompt Direct Logon Session Role
prompt ========================================================================

col role format a30
SELECT role
FROM session_roles
WHERE role = 'DIRECT_LOGON_ROLE';

prompt
prompt ========================================================================
prompt Marvin's Query: same SQL, manager result set
prompt - Marvin sees himself plus direct reports.
prompt - SSN is visible for Marvin's own row and hidden for direct reports.
prompt ========================================================================

col first_name format a12
col last_name format a12
col user_name format a32
col ssn format a15
col phone_number format a15
SELECT employee_id, first_name, last_name, user_name, ssn, salary, phone_number, manager_id
FROM hr.employees
ORDER BY employee_id;

prompt
prompt ========================================================================
prompt Marvin's Column Authorization
prompt ========================================================================

col ssn_authorized format a16
SELECT
  first_name,
  DECODE(ORA_IS_COLUMN_AUTHORIZED(ssn), TRUE, 'TRUE', FALSE, 'FALSE') AS ssn_authorized
FROM hr.employees
ORDER BY employee_id;

exit;
SQL

echo
echo -e "${GREEN}Task 5 completed. Next: clear the token, get an Emma token, then run ./06_verify_as_emma.sh${NC}"
echo
