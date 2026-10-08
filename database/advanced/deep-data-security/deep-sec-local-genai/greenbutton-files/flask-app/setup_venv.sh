#!/usr/bin/env bash
# Create or refresh this application's isolated Python environment.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
python_bin=${PYTHON_BIN:-python3}
offline_root=${DEEP_SEC_OFFLINE_ROOT:-/opt/deep-sec-offline}

command -v "$python_bin" >/dev/null || { echo "ERROR: $python_bin is required." >&2; exit 1; }
if [[ ! -x "$script_dir/.venv/bin/python" ]]; then
  "$python_bin" -m venv "$script_dir/.venv" || {
    echo 'ERROR: Could not create .venv. Install the Python venv package, then rerun this script.' >&2
    exit 1
  }
fi

python_tag=$($python_bin -c 'import sys; print(f"py{sys.version_info.major}.{sys.version_info.minor}")')
wheelhouse="$offline_root/wheelhouse/$python_tag"
[[ -d "$wheelhouse" ]] || {
  echo "ERROR: offline Python wheelhouse is missing: $wheelhouse" >&2
  echo 'Stage the GreenButton offline wheelhouse before installing dependencies.' >&2
  exit 1
}

"$script_dir/.venv/bin/python" -m pip install \
  --no-index \
  --find-links="$wheelhouse" \
  --disable-pip-version-check \
  --no-input \
  -r "$script_dir/requirements.txt"
"$script_dir/.venv/bin/python" -m pip check
echo "Virtual environment ready: $script_dir/.venv"
