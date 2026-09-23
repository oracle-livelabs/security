#!/bin/bash
# Shared helpers for the ADB Microsoft Entra ID lab.

require_adb_entra_env() {
  for var in DB_NAME ADB_OCID ADB_SERVICE ADMIN_PWD WALLET_DIR TNS_ADMIN TENANT_ID APP_ID APP_ID_URI CLIENT_ID MARVIN_UPN EMMA_UPN; do
    if [ -z "${!var:-}" ]; then
      echo "ERROR: ${var} is not set. Run ./01_setup_adb_entra_id.sh and source ./.adb-entra-id.env first." >&2
      exit 1
    fi
  done

  if [ ! -f "${TNS_ADMIN}/tnsnames.ora" ] || [ ! -f "${TNS_ADMIN}/sqlnet.ora" ]; then
    echo "ERROR: Wallet files are missing under TNS_ADMIN=${TNS_ADMIN}. Re-run ./01_setup_adb_entra_id.sh." >&2
    exit 1
  fi

  if grep -q 'DIRECTORY="?/network/admin"' "${TNS_ADMIN}/sqlnet.ora" 2>/dev/null; then
    echo "ERROR: ${TNS_ADMIN}/sqlnet.ora still points to ?/network/admin. Re-run ./01_setup_adb_entra_id.sh." >&2
    exit 1
  fi
}

admin_sqlplus() {
  sqlplus -L -s "admin/${ADMIN_PWD}@${ADB_SERVICE}"
}
