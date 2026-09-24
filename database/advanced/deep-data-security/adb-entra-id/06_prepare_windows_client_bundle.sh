#!/bin/bash
# Build a Windows SQL*Plus client bundle for Microsoft Entra interactive login.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_entra_env

BUNDLE_NAME="${BUNDLE_NAME:-adb-entra-id-client}"
BUNDLE_DIR="${SCRIPT_DIR}/${BUNDLE_NAME}"
BUNDLE_ZIP="${SCRIPT_DIR}/${BUNDLE_NAME}.zip"
DOWNLOAD_DIR="${HOME}/adb-entra-id-download"
DOWNLOAD_ZIP="${DOWNLOAD_DIR}/${BUNDLE_NAME}.zip"
TNSNAMES_FILE="${TNS_ADMIN}/tnsnames.ora"
WINDOWS_ALIAS="${ADB_ENTRA_WINDOWS_ALIAS:-hrdb}"
LEGACY_ALIAS="${ADB_ENTRA_ALIAS:-hrdb_entra}"
WINDOWS_TNS_ADMIN="${WINDOWS_TNS_ADMIN:-C:/temp/oracle-client/${BUNDLE_NAME}}"

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 6: Prepare Windows SQL*Plus Client Bundle                        ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}TNS_ADMIN   = ${TNS_ADMIN}${NC}"
echo -e "${CYAN}ADB_SERVICE = ${ADB_SERVICE}${NC}"
echo -e "${CYAN}BUNDLE_ZIP  = ${BUNDLE_ZIP}${NC}"
echo -e "${CYAN}WINDOWS_ALIAS = ${WINDOWS_ALIAS}${NC}"
echo -e "${CYAN}LEGACY_ALIAS  = ${LEGACY_ALIAS}${NC}"
echo

if [ ! -f "$TNSNAMES_FILE" ]; then
  echo -e "${RED}ERROR: ${TNSNAMES_FILE} was not found. Re-run ./01_setup_adb_entra_id.sh.${NC}"
  exit 1
fi

for cmd in python3 zip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo -e "${RED}ERROR: ${cmd} is not available on PATH.${NC}"
    exit 1
  fi
done

base_descriptor=$(python3 - "$TNSNAMES_FILE" "$ADB_SERVICE" <<'PY'
import re
import sys

path, alias = sys.argv[1], sys.argv[2]
text = open(path, encoding="utf-8").read()
match = re.search(rf"(?im)^\s*{re.escape(alias)}\s*=", text)
if not match:
    sys.exit(0)

start = match.start()
first_paren = text.find("(", match.end())
if first_paren < 0:
    sys.exit(0)

depth = 0
end = first_paren
for pos in range(first_paren, len(text)):
    ch = text[pos]
    if ch == "(":
        depth += 1
    elif ch == ")":
        depth -= 1
        if depth == 0:
            end = pos + 1
            break

print(text[start:end])
PY
)

if [ -z "$base_descriptor" ]; then
  echo -e "${RED}ERROR: Could not find ${ADB_SERVICE} in ${TNSNAMES_FILE}.${NC}"
  exit 1
fi

parsed=$(BASE_DESCRIPTOR="$base_descriptor" python3 -c '
import os
import re

text = os.environ["BASE_DESCRIPTOR"]

def value(name):
    match = re.search(r"\(\s*" + re.escape(name) + r"\s*=\s*(\"[^\"]*\"|[^)\s]+)", text, re.I)
    if not match:
        return ""
    value = match.group(1)
    if value.startswith("\"") and value.endswith("\""):
        value = value[1:-1]
    return value

print(value("host"))
print(value("port"))
print(value("service_name"))
print(value("ssl_server_cert_dn"))
')
host=$(printf '%s\n' "$parsed" | sed -n '1p')
port=$(printf '%s\n' "$parsed" | sed -n '2p')
service_name=$(printf '%s\n' "$parsed" | sed -n '3p')
ssl_dn=$(printf '%s\n' "$parsed" | sed -n '4p')

if [ -z "$host" ] || [ -z "$port" ] || [ -z "$service_name" ]; then
  echo -e "${RED}ERROR: Could not parse host, port, or service_name from ${ADB_SERVICE}.${NC}"
  exit 1
fi

if [ -e "$BUNDLE_ZIP" ] || [ -e "$DOWNLOAD_ZIP" ] || [ -d "$BUNDLE_DIR" ]; then
  echo -e "${YELLOW}Existing client bundle files found. This script will overwrite them.${NC}"
  echo -e "${YELLOW}  Recreate directory: ${BUNDLE_DIR}${NC}"
  echo -e "${YELLOW}  Overwrite ZIP:      ${BUNDLE_ZIP}${NC}"
  echo -e "${YELLOW}  Overwrite ZIP:      ${DOWNLOAD_ZIP}${NC}"
  echo
else
  echo -e "${CYAN}No existing client bundle files found. This script will create a new ZIP.${NC}"
  echo
fi

rm -rf "$BUNDLE_DIR" "$BUNDLE_ZIP"
mkdir -p "$BUNDLE_DIR"
cp -R "${TNS_ADMIN}/." "$BUNDLE_DIR/"

cp "$TNSNAMES_FILE" "${BUNDLE_DIR}/tnsnames.ora"
sed -i "/^${WINDOWS_ALIAS}[[:space:]]*=/,/^$/d" "${BUNDLE_DIR}/tnsnames.ora"
sed -i "/^${LEGACY_ALIAS}[[:space:]]*=/,/^$/d" "${BUNDLE_DIR}/tnsnames.ora"

if [ -f "${BUNDLE_DIR}/sqlnet.ora" ]; then
  sed -i -E "s#DIRECTORY[[:space:]]*=[[:space:]]*\"[^\"]*\"#DIRECTORY=\"${WINDOWS_TNS_ADMIN}\"#g" "${BUNDLE_DIR}/sqlnet.ora"
fi

write_entra_alias() {
  local alias="$1"
  {
    echo
    echo "${alias} ="
    echo "  (DESCRIPTION ="
    echo "    (ADDRESS = (PROTOCOL = TCPS)(HOST = ${host})(PORT = ${port}))"
    echo "    (SECURITY ="
    echo "      (SSL_SERVER_DN_MATCH = YES)"
    if [ -n "$ssl_dn" ]; then
      echo "      (SSL_SERVER_CERT_DN = \"${ssl_dn}\")"
    fi
    echo "      (TOKEN_AUTH = AZURE_INTERACTIVE)"
    echo "      (CLIENT_ID = ${CLIENT_ID})"
    echo "      (AZURE_DB_APP_ID_URI = ${APP_ID_URI})"
    echo "      (TENANT_ID = ${TENANT_ID})"
    echo "    )"
    echo "    (CONNECT_DATA ="
    echo "      (SERVICE_NAME = ${service_name})"
    echo "    )"
    echo "  )"
  } >> "${BUNDLE_DIR}/tnsnames.ora"
}

write_entra_alias "$WINDOWS_ALIAS"
if [ "$LEGACY_ALIAS" != "$WINDOWS_ALIAS" ]; then
  write_entra_alias "$LEGACY_ALIAS"
fi

cat > "${BUNDLE_DIR}/get_session.sql" <<'EOF'
set pagesize 100
set linesize 180
set tab off
set trimspool on

prompt
prompt ========================================================================
prompt Microsoft Entra ID Session Identity
prompt ========================================================================

col current_user format a30
col authenticated_identity format a55
col auth_method format a25

SELECT
  sys_context('USERENV', 'CURRENT_USER') AS current_user,
  sys_context('USERENV', 'AUTHENTICATED_IDENTITY') AS authenticated_identity,
  sys_context('USERENV', 'AUTHENTICATION_METHOD') AS auth_method
FROM dual;

prompt
prompt The Entra user is shown in AUTHENTICATED_IDENTITY. Deep Data Security
prompt activates data roles from the Entra app roles in the token, and those
prompt data roles control which HR rows and columns are visible.
prompt
EOF

cat > "${BUNDLE_DIR}/verify-marvin.sql" <<'EOF'
set pagesize 100
set linesize 180
set tab off
set trimspool on
whenever sqlerror exit sql.sqlcode

@get_session.sql

prompt
prompt ========================================================================
prompt Marvin's Active Data Roles
prompt - HRAPP_EMPLOYEES and HRAPP_MANAGERS should be active.
prompt ========================================================================

col role_name format a30
SELECT role_name
FROM v$end_user_data_role
WHERE role_name IN ('HRAPP_EMPLOYEES', 'HRAPP_MANAGERS')
ORDER BY role_name;

prompt
prompt ========================================================================
prompt Marvin's Query: same SQL, manager result set
prompt - Marvin sees himself plus direct reports.
prompt - SSN is visible for Marvin's own row and hidden for direct reports.
prompt ========================================================================

col first_name format a12
col last_name format a12
col user_name format a45
col ssn format a15
col phone_number format a15
SELECT employee_id, first_name, last_name, user_name, ssn, salary, phone_number, manager_id
FROM hr.employees
ORDER BY employee_id;

prompt
prompt ========================================================================
prompt Marvin's Column Authorization
prompt ========================================================================

col first_name format a12
col ssn_authorized format a16
SELECT
  first_name,
  DECODE(ORA_IS_COLUMN_AUTHORIZED(ssn), TRUE, 'TRUE', FALSE, 'FALSE') AS ssn_authorized
FROM hr.employees
ORDER BY employee_id;

exit;
EOF

cat > "${BUNDLE_DIR}/verify-emma.sql" <<'EOF'
set pagesize 100
set linesize 180
set tab off
set trimspool on
whenever sqlerror exit sql.sqlcode

@get_session.sql

prompt
prompt ========================================================================
prompt Emma's Active Data Roles
prompt - Only HRAPP_EMPLOYEES should be active.
prompt ========================================================================

col role_name format a30
SELECT role_name
FROM v$end_user_data_role
WHERE role_name IN ('HRAPP_EMPLOYEES', 'HRAPP_MANAGERS')
ORDER BY role_name;

prompt
prompt ========================================================================
prompt Emma's Query: same SQL, employee result set
prompt - Emma sees only her own row.
prompt ========================================================================

col first_name format a12
col last_name format a12
col user_name format a45
col ssn format a15
col phone_number format a15
SELECT employee_id, first_name, last_name, user_name, ssn, salary, phone_number, manager_id
FROM hr.employees
ORDER BY employee_id;

prompt
prompt ========================================================================
prompt Emma's Column Authorization
prompt ========================================================================

col first_name format a12
col ssn_authorized format a16
SELECT
  first_name,
  DECODE(ORA_IS_COLUMN_AUTHORIZED(ssn), TRUE, 'TRUE', FALSE, 'FALSE') AS ssn_authorized
FROM hr.employees
ORDER BY employee_id;

exit;
EOF

cat > "${BUNDLE_DIR}/run-marvin.ps1" <<'EOF'
$ErrorActionPreference = "Stop"
$ClientRoot = Split-Path -Parent $PSScriptRoot
$InstantClient = Get-ChildItem -Path $ClientRoot -Directory -Filter "instantclient_*" | Sort-Object Name -Descending | Select-Object -First 1
if (-not $InstantClient) {
  throw "Could not find instantclient_* under $ClientRoot. Unzip Instant Client Basic and SQL*Plus into C:\temp\oracle-client first."
}
$env:PATH = "$($InstantClient.FullName);$env:PATH"
$env:TNS_ADMIN = $PSScriptRoot
$Sqlnet = Join-Path $PSScriptRoot "sqlnet.ora"
$WalletPath = ($PSScriptRoot -replace "\\", "/")
(Get-Content $Sqlnet) -replace 'DIRECTORY\s*=\s*"[^"]*"', "DIRECTORY=`"$WalletPath`"" | Set-Content $Sqlnet
Write-Host "TNS_ADMIN=$env:TNS_ADMIN"
Get-Command sqlplus.exe
Push-Location $PSScriptRoot
try {
  sqlplus -L /@hrdb "@verify-marvin.sql"
} finally {
  Pop-Location
}
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "SQL*Plus launched Entra ID login but the database rejected the token."
  Write-Host "Re-run ./05_verify_db_setup.sh in Oracle Cloud Shell, then recreate and redownload this client bundle."
  exit $LASTEXITCODE
}
EOF

cat > "${BUNDLE_DIR}/run-emma.ps1" <<'EOF'
$ErrorActionPreference = "Stop"
$ClientRoot = Split-Path -Parent $PSScriptRoot
$InstantClient = Get-ChildItem -Path $ClientRoot -Directory -Filter "instantclient_*" | Sort-Object Name -Descending | Select-Object -First 1
if (-not $InstantClient) {
  throw "Could not find instantclient_* under $ClientRoot. Unzip Instant Client Basic and SQL*Plus into C:\temp\oracle-client first."
}
$env:PATH = "$($InstantClient.FullName);$env:PATH"
$env:TNS_ADMIN = $PSScriptRoot
$Sqlnet = Join-Path $PSScriptRoot "sqlnet.ora"
$WalletPath = ($PSScriptRoot -replace "\\", "/")
(Get-Content $Sqlnet) -replace 'DIRECTORY\s*=\s*"[^"]*"', "DIRECTORY=`"$WalletPath`"" | Set-Content $Sqlnet
Write-Host "TNS_ADMIN=$env:TNS_ADMIN"
Get-Command sqlplus.exe
Push-Location $PSScriptRoot
try {
  sqlplus -L /@hrdb "@verify-emma.sql"
} finally {
  Pop-Location
}
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Write-Host "SQL*Plus launched Entra ID login but the database rejected the token."
  Write-Host "Re-run ./05_verify_db_setup.sh in Oracle Cloud Shell, then recreate and redownload this client bundle."
  exit $LASTEXITCODE
}
EOF

cat > "${BUNDLE_DIR}/README-WINDOWS.txt" <<EOF
ADB Microsoft Entra ID Windows client bundle

1. Save adb-entra-id-client.zip as C:\temp\oracle-client\adb-entra-id-client.zip.
2. Unzip adb-entra-id-client.zip into C:\temp\oracle-client.
3. Unzip Oracle Instant Client Basic and SQL*Plus into C:\temp\oracle-client.
4. In PowerShell:

   cd C:\temp\oracle-client\${BUNDLE_NAME}
   .\run-marvin.ps1

Or, from a PowerShell window where PATH and TNS_ADMIN are set:

   sqlplus /@hrdb

SQL*Plus uses TOKEN_AUTH=AZURE_INTERACTIVE and should open your local browser.
Sign in as the expected Microsoft Entra user.
EOF

(
  cd "$SCRIPT_DIR"
  zip -qr "$BUNDLE_ZIP" "$BUNDLE_NAME"
)

mkdir -p "$DOWNLOAD_DIR"
cp "$BUNDLE_ZIP" "$DOWNLOAD_ZIP"

echo -e "${GREEN}Created Windows client bundle:${NC}"
echo -e "${CYAN}  ${DOWNLOAD_ZIP}${NC}"
echo -e "${GREEN}This ZIP overwrites any previous ${DOWNLOAD_ZIP} from this lab.${NC}"
echo
echo "In Oracle Cloud Shell, use Menu > Download and enter:"
echo "  adb-entra-id-download/${BUNDLE_NAME}.zip"
echo
echo "Save it on Windows to:"
echo "  C:\\temp\\oracle-client\\${BUNDLE_NAME}.zip"
echo "If Windows says the file already exists, replace it."
echo
