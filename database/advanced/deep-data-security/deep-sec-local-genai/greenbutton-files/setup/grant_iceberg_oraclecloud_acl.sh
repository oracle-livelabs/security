#!/usr/bin/env bash
# Grant the broad Oracle Cloud HTTPS/proxy ACL needed by the Iceberg lab on an existing VM.
set -Eeuo pipefail

[[ ${EUID} -eq 0 ]] || { echo 'Run this script with sudo.' >&2; exit 1; }

source /home/opc/.deep-sec-lab-environment
source /home/opc/.deep-sec-genai-defaults
source /home/opc/.deep-sec-order-history-credentials
wallet_dir=${TNS_ADMIN:-/home/opc/deep-sec-wallet/tns_admin}
tnsnames_file="$wallet_dir/tnsnames.ora"
[[ -s "$tnsnames_file" ]] || { echo "Missing installed wallet: $wallet_dir" >&2; exit 1; }

# adb_service_alias is a Terraform template value, not a value retained in
# /home/opc/.deep-sec-lab-environment. Prefer the installed console setting,
# then fall back to the first alias in the installed wallet.
service_alias=${DEEP_SEC_DSN:-}
if [[ -z "$service_alias" && -r /etc/deep-sec/admin-console.env ]]; then
  service_alias=$(sed -n 's/^ADMIN_DB_DSN=//p' /etc/deep-sec/admin-console.env | head -n 1)
fi
if [[ -z "$service_alias" ]]; then
  service_alias=$(sed -n 's/^[[:space:]]*\([[:alnum:]_.-]\+\)[[:space:]]*=.*/\1/p' "$tnsnames_file" | head -n 1)
fi
[[ -n "$service_alias" ]] || {
  echo "Could not determine the ADB service alias from the installed wallet." >&2
  echo "Set DEEP_SEC_DSN to an alias from $tnsnames_file and run this script again." >&2
  exit 1
}
[[ -n "${OCI_REGION:-}" ]] || { echo 'OCI_REGION is not configured.' >&2; exit 1; }
[[ -n "${ORDER_HISTORY_NAMESPACE:-}" ]] || { echo 'ORDER_HISTORY_NAMESPACE is not configured.' >&2; exit 1; }

sql_file=$(mktemp)
trap 'rm -f "$sql_file"' EXIT
cat > "$sql_file" <<SQL
whenever sqlerror exit sql.sqlcode rollback
connect admin/"${LAB_PWD//\"/\"\"}"@${service_alias}
declare
  procedure grant_oraclecloud_https(p_host varchar2, p_principal varchar2) is
  begin
    dbms_network_acl_admin.append_host_ace(
      host           => p_host,
      lower_port     => 443,
      upper_port     => 443,
      ace            => xs\$ace_type(
                        privilege_list => xs\$name_list('http', 'http_proxy'),
                        principal_name => p_principal,
                        principal_type => xs_acl.ptype_db
                      )
    );
  exception
    when others then
      if sqlcode != -24243 then raise; end if;
  end;
begin
  grant_oraclecloud_https('objectstorage.${OCI_REGION}.oraclecloud.com', 'ADMIN');
  grant_oraclecloud_https('objectstorage.${OCI_REGION}.oraclecloud.com', 'APPLAB');
  grant_oraclecloud_https('${ORDER_HISTORY_NAMESPACE}.objectstorage.${OCI_REGION}.oci.customer-oci.com', 'ADMIN');
  grant_oraclecloud_https('${ORDER_HISTORY_NAMESPACE}.objectstorage.${OCI_REGION}.oci.customer-oci.com', 'APPLAB');
end;
/
exit
SQL

runuser -u opc -- env TNS_ADMIN="$wallet_dir" sqlplus -s -L /nolog < "$sql_file"
echo 'Granted ADMIN and APPLAB HTTP/HTTPS and HTTP_PROXY access to the OCI Object Storage endpoints on port 443.'
