#!/usr/bin/env bash
# Create or refresh the isolated application environment.
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
exec "$script_dir/setup_venv.sh"
