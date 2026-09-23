#!/bin/bash
# Enable Microsoft Entra ID authentication on Autonomous Database using DBMS_CLOUD_ADMIN.

set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_entra_env

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 2: Enable Microsoft Entra ID Authentication on ADB               ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}Executing as ADMIN on ${ADB_SERVICE}${NC}"
echo -e "${CYAN}APP_ID      = ${APP_ID}${NC}"
echo -e "${CYAN}APP_ID_URI  = ${APP_ID_URI}${NC}"
echo -e "${CYAN}TENANT_ID   = ${TENANT_ID}${NC}"
echo

admin_sqlplus <<SQL
set echo on
set serveroutput on
set lines 180
whenever sqlerror exit sql.sqlcode

BEGIN
  DBMS_CLOUD_ADMIN.ENABLE_EXTERNAL_AUTHENTICATION(
    type   => 'AZURE_AD',
    params => JSON_OBJECT(
      'tenant_id'           VALUE '${TENANT_ID}',
      'application_id'      VALUE '${APP_ID}',
      'application_id_uri'  VALUE '${APP_ID_URI}'
    ),
    force  => TRUE
  );
END;
/

col name format a40
col value format a100
SELECT name, value
  FROM v\$parameter
 WHERE name IN ('identity_provider_type', 'identity_provider_config');

exit;
SQL

echo
echo -e "${GREEN}Task 2 completed. Next: run ./03_create_hr_schema.sh${NC}"
echo
