#!/usr/bin/env bash
# Optional Flask development-server launcher for local troubleshooting only.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir"

if [[ -x "$script_dir/.venv/bin/python" ]]; then
  exec "$script_dir/.venv/bin/python" app.py
fi
echo 'ERROR: .venv is missing. Run bash setup_venv.sh first.' >&2
exit 1
