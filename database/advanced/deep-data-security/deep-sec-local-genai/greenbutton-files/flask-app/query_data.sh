#!/usr/bin/env bash
# Run the fixed Deep Data Security validation query as one local database user.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
requested_user=${1:-}
provided_password=${2:-}
dsn=${DB_DSN:-deepsec_low}
validation_sql="${DEEP_SEC_DATABASE_DIR:-/opt/deep-sec-admin-console/content/deep_data_security/database}/validation_queries.sql"

usage() {
  echo "Usage: $0 <marvin> [password]" >&2
  echo "Set DB_DSN to override the default service: deepsec_low." >&2
}

case "${requested_user,,}" in
  marvin) db_user=MARVIN ;;
  *) usage; exit 2 ;;
esac

[ "$#" -le 2 ] || { usage; exit 2; }
[ -n "${TNS_ADMIN:-}" ] || { echo 'ERROR: TNS_ADMIN must point to the extracted wallet directory.' >&2; exit 1; }
[ -f "$TNS_ADMIN/tnsnames.ora" ] || { echo "ERROR: tnsnames.ora is missing from $TNS_ADMIN" >&2; exit 1; }
[ -f "$TNS_ADMIN/cwallet.sso" ] || { echo "ERROR: cwallet.sso is missing from $TNS_ADMIN" >&2; exit 1; }
[ -f "$validation_sql" ] || { echo "ERROR: validation SQL is missing: $validation_sql" >&2; exit 1; }
command -v sqlplus >/dev/null || { echo 'ERROR: sqlplus is required.' >&2; exit 1; }

if [ -n "$provided_password" ]; then
  db_password=$provided_password
  echo 'WARNING: a password supplied on the command line can be visible in shell history or process listings.' >&2
else
  read -r -s -p "Password for $db_user: " db_password
  echo
fi

echo "Running the fixed query as $db_user against $dsn."
sqlplus -L -s /nolog <<SQL
whenever oserror exit 9
whenever sqlerror exit sql.sqlcode
connect $db_user/"$db_password"@$dsn
@$validation_sql
exit success
SQL
