#!/usr/bin/env bash
# Make the optional Iceberg verification on an already-created VM best effort.
set -Eeuo pipefail

[[ ${EUID} -eq 0 ]] || { echo 'Run this script with sudo.' >&2; exit 1; }

installer=${INSTALLER_PATH:-/usr/local/sbin/install-deep-sec-admin-console}
[[ -f "$installer" ]] || { echo "Missing installer: $installer" >&2; exit 1; }

python3 - "$installer" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
marker = "Iceberg external-table bootstrap is best effort"
if marker in text:
    print("Iceberg external-table bootstrap is already best effort.")
    raise SystemExit(0)

replacement = '''      # Iceberg external-table bootstrap is best effort on this existing VM.
      if run_logged 'Iceberg native metadata and row-read bootstrap verification' \\
        runuser -u opc -- env TNS_ADMIN="$wallet_dir" sqlplus -s -L /nolog < "$order_history_bootstrap_sqlplus_input"; then
        echo 'Iceberg external-table bootstrap verification succeeded.'
      else
        echo 'WARNING: Iceberg external-table bootstrap failed; continuing with application installation.' >&2
      fi
'''
deferred = re.compile(
    r"(?m)^[^\r\n]*Iceberg external-table bootstrap is deferred[^\r\n]*\r?\n"
    r"(?:^[^\r\n]*Iceberg external-table bootstrap is deferred[^\r\n]*\r?\n)?"
)
original = re.compile(
    r"(?m)^[ \t]*run_logged 'Iceberg native metadata and row-read bootstrap verification'[\s\S]*?"
    r"^[ \t]*runuser -u opc -- env TNS_ADMIN=.*bootstrap_sqlplus_input[^\r\n]*\r?\n"
)
match = deferred.search(text) or original.search(text)
if match is None:
    print("No legacy Iceberg verification command found; leaving this installer unchanged.")
    raise SystemExit(0)

path.write_text(text[:match.start()] + replacement + text[match.end():], encoding="utf-8")
print("Iceberg external-table bootstrap will now be attempted without blocking installation.")
PY
