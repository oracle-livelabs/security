#!/usr/bin/env bash
# Verify the application virtual environment and preinstalled SQL tools.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[ -x "$script_dir/.venv/bin/python" ] || { echo 'ERROR: .venv is missing. Run bash setup_venv.sh first.' >&2; exit 1; }
python_bin="$script_dir/.venv/bin/python"

command -v "$python_bin" >/dev/null || { echo 'ERROR: Python is not installed.' >&2; exit 1; }
"$python_bin" - <<'PY'
import flask
import flask_bootstrap
import flask_htmx
import flask_login
import flask_wtf
import gunicorn
import oracledb
import requests
import dotenv
from importlib.metadata import version

for package in ("Flask", "Bootstrap-Flask", "Flask-HTMX", "Flask-Login",
                "Flask-WTF", "gunicorn", "oracledb", "requests",
                "python-dotenv"):
    print(f"{package}: {version(package)}")
PY

command -v sqlplus >/dev/null || { echo 'ERROR: sqlplus is not installed or not on PATH.' >&2; exit 1; }
echo 'SQL*Plus:'
sqlplus -version

if command -v rpm >/dev/null; then
  echo 'Installed Oracle Instant Client RPMs:'
  rpm -qa | grep '^oracle-instantclient' | sort || true
fi

echo 'Application environment verification passed. No packages were installed.'
