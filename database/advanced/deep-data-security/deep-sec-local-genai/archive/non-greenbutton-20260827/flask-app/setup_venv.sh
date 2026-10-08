#!/usr/bin/env bash
# Create or refresh this application's isolated Python environment.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
python_bin=${PYTHON_BIN:-python3}

command -v "$python_bin" >/dev/null || { echo "ERROR: $python_bin is required." >&2; exit 1; }
if [[ ! -x "$script_dir/.venv/bin/python" ]]; then
  "$python_bin" -m venv "$script_dir/.venv" || {
    echo 'ERROR: Could not create .venv. Install the Python venv package, then rerun this script.' >&2
    exit 1
  }
fi

"$script_dir/.venv/bin/python" -m pip install --upgrade pip
"$script_dir/.venv/bin/python" -m pip install -r "$script_dir/requirements.txt"
echo "Virtual environment ready: $script_dir/.venv"
