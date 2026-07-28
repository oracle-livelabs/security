#!/bin/bash
# Verify ADB OCI IAM data grants with an Emma OAuth2 token.

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

export EMMA_USERNAME="${EMMA_USERNAME:-emma}"
export OCI_IAM_EMPLOYEE_GROUP="${OCI_IAM_EMPLOYEE_GROUP:-EMPLOYEES}"

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 6: Connect and Verify as Emma via OCI IAM                        ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${PURPLE}First run ./04_get_iam_oauth_token.sh and sign in as ${EMMA_USERNAME}.${NC}"
echo -e "${PURPLE}Emma must be in ${OCI_IAM_EMPLOYEE_GROUP} only for this lab.${NC}"
echo -e "${CYAN}TOKEN_LOCATION=${OCI_TOKEN_DIR:-$HOME/.oci/adb-oci-iam}${NC}"
require_sqlplus
echo "  sqlplus -L -s /@${ADB_SERVICE}"
echo

check_oauth_token "$EMMA_USERNAME" "$OCI_IAM_EMPLOYEE_GROUP"
echo

sqlplus -L -s "/@${ADB_SERVICE}" <<'SQL'
set pagesize 100
set linesize 180
set tab off
set trimspool on
whenever sqlerror exit sql.sqlcode

prompt
prompt ========================================================================
prompt Emma's OCI IAM Session Identity
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
prompt Emma's Active Data Roles
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
prompt Emma's Query: same SQL, employee result set
prompt - Emma sees only her own row.
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
prompt Emma's Column Authorization
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
echo -e "${GREEN}Task 6 completed.${NC}"
echo
