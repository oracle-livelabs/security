#!/bin/bash
# Create Deep Data Security roles, context, and grants for ADB OCI IAM.

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_env

export OCI_IAM_EMPLOYEE_GROUP="${OCI_IAM_EMPLOYEE_GROUP:-EMPLOYEES}"
export OCI_IAM_MANAGER_GROUP="${OCI_IAM_MANAGER_GROUP:-MANAGERS}"

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 4: Create Data Roles and Data Grants                             ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}OCI_IAM_EMPLOYEE_GROUP = ${OCI_IAM_EMPLOYEE_GROUP}${NC}"
echo -e "${CYAN}OCI_IAM_MANAGER_GROUP  = ${OCI_IAM_MANAGER_GROUP}${NC}"
echo -e "${CYAN}SQL*Plus command:${NC}"
show_cmd sqlplus -L -s "admin/<hidden>@${ADB_SERVICE}"
echo

admin_sqlplus <<SQL
set echo on
set serveroutput on
set lines 180
whenever sqlerror exit sql.sqlcode

CREATE ROLE IF NOT EXISTS employee_context_admin;
GRANT UPDATE ANY END USER CONTEXT TO hr;

CREATE OR REPLACE DATA ROLE hrapp_employees
  MAPPED TO 'IAM_OAUTH_GROUP=${OCI_IAM_EMPLOYEE_GROUP}';

CREATE OR REPLACE DATA ROLE hrapp_managers
  MAPPED TO 'IAM_OAUTH_GROUP=${OCI_IAM_MANAGER_GROUP}';

CREATE ROLE IF NOT EXISTS direct_logon_role;
GRANT CREATE SESSION TO direct_logon_role;
GRANT direct_logon_role TO HRAPP_EMPLOYEES;
GRANT direct_logon_role TO HRAPP_MANAGERS;

CREATE OR REPLACE END USER CONTEXT HR.EMP_CTX USING JSON SCHEMA '{
  "type": "object",
  "properties": {
    "ID": {
      "type": "integer",
      "o:onFirstRead": "HR.ctx_pkg.init_user_context"
    }
  }
}';

CREATE OR REPLACE PACKAGE hr.ctx_pkg AS
  PROCEDURE init_user_context;
END;
/

CREATE OR REPLACE PACKAGE BODY hr.ctx_pkg AS
  PROCEDURE init_user_context IS
    sql_stmt VARCHAR2(4000);
  BEGIN
    sql_stmt := '
      UPDATE END_USER_CONTEXT t
      SET t.CONTEXT.ID = (
         SELECT e.employee_id
         FROM hr.employees e
         WHERE upper(e.user_name) = upper(ora_end_user_context.USERNAME)
       )
      WHERE owner = ''HR''
      AND name = ''EMP_CTX''';
    EXECUTE IMMEDIATE sql_stmt;
  END;
END;
/

GRANT EXECUTE ON hr.ctx_pkg TO employee_context_admin;
GRANT employee_context_admin TO HRAPP_EMPLOYEES;
GRANT employee_context_admin TO HRAPP_MANAGERS;

CREATE OR REPLACE DATA GRANT hr.HRAPP_EMPLOYEES_ACCESS
  AS SELECT (employee_id, first_name, last_name, user_name, department_id, manager_id, ssn, salary, phone_number), UPDATE(phone_number, first_name)
  ON hr.employees
  WHERE upper(user_name) = upper(ora_end_user_context.username)
  TO HRAPP_EMPLOYEES;

CREATE OR REPLACE DATA GRANT hr.EMPLOYEE_CONTEXT_GRANT
  AS SELECT ON SYS.END_USER_CONTEXT
   WHERE OWNER = 'HR' AND NAME = 'EMP_CTX'
    TO HRAPP_EMPLOYEES, HRAPP_MANAGERS;

CREATE OR REPLACE DATA GRANT hr.HRAPP_MANAGER_ACCESS
  AS SELECT (ALL COLUMNS EXCEPT ssn), UPDATE (salary, department_id, first_name)
  ON hr.employees
  WHERE manager_id = ORA_END_USER_CONTEXT.HR.EMP_CTX.ID
  TO HRAPP_MANAGERS;

col data_role format a24
col mapped_to format a45
SELECT data_role, mapped_to
  FROM dba_data_roles
 WHERE data_role IN ('HRAPP_EMPLOYEES', 'HRAPP_MANAGERS')
 ORDER BY data_role;

exit;
SQL

echo
echo -e "${GREEN}Task 4 completed. Next: run ./verify_db_setup.sh${NC}"
echo
