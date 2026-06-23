#!/bin/bash
# Create the HR schema and sample data on ADB.

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_env

export OCI_USERNAME_DOMAIN="${OCI_USERNAME_DOMAIN:-}"
export MARVIN_USERNAME="${MARVIN_USERNAME:-marvin}"
export EMMA_USERNAME="${EMMA_USERNAME:-emma}"

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 2: Create HR Schema and Employee Data                            ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}OCI_USERNAME_DOMAIN = ${OCI_USERNAME_DOMAIN}${NC}"
echo -e "${CYAN}MARVIN_USERNAME     = ${MARVIN_USERNAME}${NC}"
echo -e "${CYAN}EMMA_USERNAME       = ${EMMA_USERNAME}${NC}"
echo -e "${CYAN}HR user_name values will match the OCI IAM domain users.${NC}"
echo -e "${CYAN}SQL*Plus command:${NC}"
show_cmd sqlplus -L -s "admin/<hidden>@${ADB_SERVICE}"
echo

admin_sqlplus <<SQL
set echo on
set serveroutput on
set lines 180
whenever sqlerror exit sql.sqlcode

BEGIN
  EXECUTE IMMEDIATE 'DROP USER hr CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -1918 THEN
      RAISE;
    END IF;
END;
/

CREATE USER hr NO AUTHENTICATION
  DEFAULT TABLESPACE data
  QUOTA UNLIMITED ON data;

CREATE TABLE hr.employees (
  employee_id   NUMBER PRIMARY KEY,
  first_name    VARCHAR2(50),
  last_name     VARCHAR2(50),
  job_code      VARCHAR2(10),
  department_id NUMBER,
  ssn           VARCHAR2(20),
  photo         BLOB,
  phone_number  VARCHAR2(30),
  salary        NUMBER(10,2),
  user_name     VARCHAR2(128),
  manager_id    NUMBER
);

INSERT INTO hr.employees VALUES (1, 'Grace', 'Young', 'CEO', NULL, '111-11-1111', NULL, '555-100-0001', 235000, 'grace', NULL);
INSERT INTO hr.employees VALUES (2, 'Marvin', 'Morgan', 'SWE_MGR', 1, '222-22-2222', NULL, '555-100-0002', 175000, '${MARVIN_USERNAME}', 1);
INSERT INTO hr.employees VALUES (3, 'Emma', 'Baker', 'SWE2', 1, '333-33-3333', NULL, '555-100-0003', 120000, '${EMMA_USERNAME}', 2);
INSERT INTO hr.employees VALUES (4, 'Charlie', 'Davis', 'SWE1', 1, '444-44-4444', NULL, '555-100-0004', 95000, 'charlie', 2);
INSERT INTO hr.employees VALUES (5, 'Dana', 'Lee', 'SWE3', 1, '555-55-5555', NULL, '555-100-0005', 130000, 'dana', 2);
INSERT INTO hr.employees VALUES (6, 'Bob', 'Smith', 'SALES_REP', 2, '666-66-6666', NULL, '555-100-0006', 145000, 'bob', 1);
INSERT INTO hr.employees VALUES (7, 'Fiona', 'Chen', 'HR_REP', 3, '777-77-7777', NULL, '555-100-0007', 92000, 'fiona', 1);

UPDATE hr.employees
   SET user_name =
       CASE
         WHEN '${OCI_USERNAME_DOMAIN}' IS NOT NULL
          AND LENGTH('${OCI_USERNAME_DOMAIN}') > 0
          AND user_name NOT LIKE '%@%'
         THEN user_name || '@${OCI_USERNAME_DOMAIN}'
         ELSE user_name
       END;
COMMIT;

col first_name format a12
col last_name format a12
col user_name format a45
SELECT employee_id, first_name, last_name, user_name, manager_id
FROM hr.employees
ORDER BY employee_id;

exit;
SQL

echo
echo -e "${GREEN}Task 2 completed. Next: run ./03_create_data_roles_and_grants.sh${NC}"
echo
