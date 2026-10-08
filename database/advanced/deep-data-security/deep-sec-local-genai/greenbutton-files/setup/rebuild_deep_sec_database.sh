#!/usr/bin/env bash
# Rebuild the database and Deep Sec portions of the lab as ADMIN.
#
# This intentionally resets the lab first. It does not install applications,
# regenerate Iceberg files, or run Terraform. Iceberg external-table setup is
# included below as a commented block so the ordinary lab can be rebuilt while
# that compatibility work is being tested separately.

set -Eeuo pipefail
umask 077

database_dir=${DEEP_SEC_DATABASE_DIR:-/opt/deep-sec-admin-console/content/deep_data_security/database}
dsn=${DEEP_SEC_DSN:-deepsec_low}
environment_file=/home/opc/.deep-sec-lab-environment

[[ -r "$environment_file" ]] || {
  echo "Missing $environment_file. Run this on the Deep Sec VM after wallet setup." >&2
  exit 1
}
[[ -d "$database_dir" ]] || {
  echo "Missing database scripts at $database_dir. Install the Admin Console package first." >&2
  exit 1
}

source "$environment_file"
[[ -n ${LAB_PWD:-} ]] || {
  echo "LAB_PWD is empty in $environment_file." >&2
  exit 1
}
[[ -n ${TNS_ADMIN:-} && -d $TNS_ADMIN ]] || {
  echo "TNS_ADMIN is not configured or its wallet directory is missing." >&2
  exit 1
}

run_id=$(date -u +%Y%m%dT%H%M%SZ)
log_file="${DEEP_SEC_REBUILD_LOG:-$HOME/deep-sec-database-rebuild-$run_id.log}"
mkdir -p "$(dirname "$log_file")"
touch "$log_file"
chmod 0600 "$log_file"
exec > >(tee -a "$log_file") 2>&1

admin_password_sql=${LAB_PWD//\"/\"\"}

run_sql_file() {
  local label=$1
  local script_name=$2
  local argument=${3:-}
  local script_path="$database_dir/$script_name"

  [[ -f "$script_path" ]] || {
    echo "Missing required SQL script: $script_path" >&2
    exit 1
  }

  printf '\n===== %s =====\n' "$label"
  {
    printf 'whenever oserror exit failure\n'
    printf 'whenever sqlerror exit sql.sqlcode rollback\n'
    printf 'connect admin/"%s"@%s\n' "$admin_password_sql" "$dsn"
    if [[ $script_name == create_schema.sql ]]; then
      printf 'define APPLAB_PASSWORD = "%s"\n' "$admin_password_sql"
    fi
    if [[ -n $argument ]]; then
      printf '@%s "%s"\n' "$script_path" "$argument"
    else
      printf '@%s\n' "$script_path"
    fi
    printf 'exit\n'
  } | sqlplus -s -L /nolog
}

run_sql_block() {
  local label=$1
  printf '\n===== %s =====\n' "$label"
  {
    printf 'whenever oserror exit failure\n'
    printf 'whenever sqlerror exit sql.sqlcode rollback\n'
    printf 'connect admin/"%s"@%s\n' "$admin_password_sql" "$dsn"
    cat
    printf '\nexit\n'
  } | sqlplus -s -L /nolog
}

printf 'Deep Sec database rebuild started: %s\n' "$run_id"
printf 'SQL*Plus log: %s\n' "$log_file"

run_sql_file 'Reset existing Deep Sec lab objects' reset_lab.sql
run_sql_file 'Create APPLAB schema and CUSTOMERS table' create_schema.sql
run_sql_file 'Load 22 customer rows' load_sample_data.sql
run_sql_file 'Create ordinary database roles' create_db_roles.sql
run_sql_file 'Create Deep Sec data roles' create_data_roles.sql
run_sql_file 'Create initial employee data grant' create_data_grants.sql
run_sql_file 'Create MARVIN and EMMA' create_end_users.sql "$admin_password_sql"
run_sql_file 'Grant employee data role to MARVIN' grant_employee_access.sql

run_sql_block 'Customize employee data grant' <<'SQL'
create or replace data grant APPLAB.employee_customer_access
  as select (customer_id, sales_rep, customer_name, region, revenue)
  on APPLAB.customers
  where upper(sales_rep) = upper(ora_end_user_context.username)
  to hol_datarole_employee_access;
SQL

run_sql_file 'Create manager lookup' create_managers.sql
run_sql_file 'Create manager end user context' create_manager_context.sql
run_sql_file 'Authorize manager context' set_context.sql

run_sql_block 'Create manager data grant' <<'SQL'
create or replace data grant APPLAB.manager_customer_access
  as select (customer_id, manager_id, customer_name, region, sales_rep, revenue, credit_limit, sensitive_identifier)
  on APPLAB.customers
  where manager_id = ora_end_user_context.APPLAB.MGR_CTX.id
  to hol_datarole_manager_access;
SQL

run_sql_file 'Grant manager data role to MARVIN' promote_marvin_to_manager.sql

# Iceberg setup intentionally remains disabled pending the OCI-native metadata
# compatibility result. When it is approved, uncomment these lines only after
# the installed create_order_history_table.sql has its generated credential and
# substituted metadata URL in place.
# run_sql_file 'Create ORDER_HISTORY Iceberg external table' create_order_history_table.sql
# run_sql_file 'Verify ORDER_HISTORY Iceberg rows' show_order_history_data.sql

printf '\nDeep Sec database rebuild completed successfully.\n'
printf 'Log: %s\n' "$log_file"
