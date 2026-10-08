#!/usr/bin/env bash
# Local launcher for troubleshooting. Terraform normally starts the systemd service.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir"

[[ -x .venv/bin/python ]] || { echo 'ERROR: .venv is missing.' >&2; exit 1; }
[[ -f .env ]] || { echo 'ERROR: .env is missing. Run the Terraform-provided installation first.' >&2; exit 1; }

exec .venv/bin/python -m gunicorn \
  --bind "${ADMIN_FLASK_HOST:-0.0.0.0}:${ADMIN_FLASK_PORT:-7778}" \
  --workers 1 \
  --worker-class gthread \
  --threads 4 \
  --timeout 120 \
  --log-level "${ADMIN_GUNICORN_LOG_LEVEL:-debug}" \
  --capture-output \
  --access-logfile - \
  --error-logfile - \
  admin_app:app
