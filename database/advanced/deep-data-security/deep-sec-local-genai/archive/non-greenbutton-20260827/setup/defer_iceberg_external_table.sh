#!/usr/bin/env bash
# Disable only the optional Iceberg external-table health gate on an existing VM.
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
marker = "Iceberg external-table bootstrap is deferred"
if marker in text:
    print("Iceberg external-table health gate is already deferred.")
    raise SystemExit(0)

pattern = re.compile(
    r"(?m)^[ \t]*run_logged 'Iceberg native metadata and row-read bootstrap verification'[^\r\n]*\r?\n"
    r"[ \t]*runuser -u opc -- env TNS_ADMIN=.*sqlplus -s -L /nolog < .*bootstrap_sqlplus_input[^\r\n]*\r?\n"
)
match = pattern.search(text)
if match is None:
    print("No legacy Iceberg verification command found; leaving this installer unchanged.")
    raise SystemExit(0)

replacement = (
    '      # Iceberg external-table bootstrap is deferred on this existing VM.\n'
    "      echo 'Iceberg external-table bootstrap is deferred; continuing with application installation.'\n"
)
path.write_text(text[:match.start()] + replacement + text[match.end():], encoding="utf-8")
print("Deferred the Iceberg external-table health gate.")
PY
