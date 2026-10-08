#!/usr/bin/env bash
# Build a separate Iceberg v1 copy for an existing VM, without touching the
# existing warehouse.  The resulting metadata root is consumed by the normal
# console installer and its optional bootstrap verification.
set -Eeuo pipefail

[[ ${EUID} -eq 0 ]] || { echo 'Run this script with sudo.' >&2; exit 1; }

readonly setup_dir=/opt/deep-sec-setup/setup
readonly venv=/opt/deep-sec-order-history/.venv/bin/python
[[ -x "$venv" ]] || { echo "Missing Iceberg virtual environment: $venv" >&2; exit 1; }
[[ -r /home/opc/.deep-sec-genai-defaults ]] || { echo 'Missing /home/opc/.deep-sec-genai-defaults.' >&2; exit 1; }
[[ -r /home/opc/.deep-sec-order-history-credentials ]] || { echo 'Missing /home/opc/.deep-sec-order-history-credentials.' >&2; exit 1; }

# These prefixes are intentionally new. The Python tools fail rather than
# overwrite if a prior repair attempt already populated either prefix.
runuser -u opc -- bash -lc '
  set -Eeuo pipefail
  set -a
  source /home/opc/.deep-sec-genai-defaults
  source /home/opc/.deep-sec-order-history-credentials
  set +a
  export ORDER_HISTORY_V1_TEST_PREFIX=order_history_iceberg_v1_oracle
  export ORDER_HISTORY_OCI_EXPORT_PREFIX=order_history_iceberg_v1_oracle_oci
  exec /opt/deep-sec-order-history/.venv/bin/python /opt/deep-sec-setup/setup/create_order_history_iceberg_v1_test.py
'

runuser -u opc -- bash -lc '
  set -Eeuo pipefail
  set -a
  source /home/opc/.deep-sec-genai-defaults
  source /home/opc/.deep-sec-order-history-credentials
  set +a
  export ORDER_HISTORY_SOURCE_PREFIX=order_history_iceberg_v1_oracle
  export ORDER_HISTORY_OCI_EXPORT_PREFIX=order_history_iceberg_v1_oracle_oci
  exec /opt/deep-sec-order-history/.venv/bin/python /opt/deep-sec-setup/setup/publish_order_history_iceberg_oci.py
'

echo 'Created a separate Iceberg v1 metadata root for Oracle.'
echo 'Next run: sudo /usr/local/sbin/install-deep-sec-admin-console'
