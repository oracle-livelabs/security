#!/usr/bin/env bash
# Run the student-facing web server with Gunicorn. The lab keeps database passwords
# only in process memory, so independent Gunicorn workers cannot share that store.
# Threads share this one worker process, allowing stalled browser connections without
# losing the in-memory login store.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir"

# LAB_PWD is provided for Terminal B SQL*Plus commands. The web application does
# not need it, so do not pass it to Gunicorn or its worker process.
unset LAB_PWD

[ -x "$script_dir/.venv/bin/python" ] || { echo 'ERROR: .venv is missing. Run bash setup_venv.sh first.' >&2; exit 1; }

# Do not enter the restart loop for a configuration error that requires a person to
# fix it.  Loading app.py would also initialize the Oracle client, so validate only
# the dotenv-backed settings here.
if ! "$script_dir/.venv/bin/python" -c '
import sys
from dotenv import load_dotenv
from config import load_settings

load_dotenv()
try:
    load_settings()
except RuntimeError as exc:
    print(f"ERROR: {exc}", file=sys.stderr)
    sys.exit(1)
'; then
  echo 'Run ./configure_env.sh to create the required .env configuration.' >&2
  exit 1
fi

public_ip=""
if command -v curl >/dev/null 2>&1; then
  metadata_json=$(curl -fsS --connect-timeout 1 --max-time 2 \
    -H 'Authorization: Bearer Oracle' \
    http://169.254.169.254/opc/v2/vnics/ 2>/dev/null || true)
  if [[ -z "$metadata_json" ]]; then
    metadata_json=$(curl -fsS --connect-timeout 1 --max-time 2 \
      http://169.254.169.254/opc/v1/vnics/ 2>/dev/null || true)
  fi
  public_ip=$(printf '%s' "$metadata_json" | tr '\n' ' ' | \
    sed -n 's/.*"publicIp"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
fi

if [[ -n "$public_ip" ]]; then
  printf '\nCustomer Sales App: http://%s:7777/\n\n' "$public_ip"
else
  printf '\nCustomer Sales App listens on port 7777.\n\n'
fi

# Gunicorn replaces failed workers itself.  This small supervisor also restarts the
# Gunicorn master when it exits unexpectedly, while Ctrl+C stops both cleanly.
restart_delay="${GUNICORN_RESTART_DELAY:-2}"
if ! [[ "$restart_delay" =~ ^[0-9]+$ ]]; then
  echo 'ERROR: GUNICORN_RESTART_DELAY must be a whole number of seconds.' >&2
  exit 1
fi

gunicorn_pid=""
stopping=false
stop_server() {
  stopping=true
  if [[ -n "$gunicorn_pid" ]]; then
    kill -TERM "$gunicorn_pid" 2>/dev/null || true
    wait "$gunicorn_pid" 2>/dev/null || true
  fi
  exit 0
}
trap stop_server INT TERM

while true; do
  printf 'Starting Customer Sales App server. Press Ctrl+C to stop it.\n'
  "$script_dir/.venv/bin/python" -m gunicorn \
    --bind "${FLASK_HOST:-0.0.0.0}:7777" \
    --workers "${GUNICORN_WORKERS:-1}" \
    --worker-class gthread \
    --threads "${GUNICORN_THREADS:-4}" \
    --timeout "${GUNICORN_TIMEOUT:-120}" \
    --log-level "${GUNICORN_LOG_LEVEL:-debug}" \
    --capture-output \
    --access-logfile - \
    --error-logfile - \
    app:app &
  gunicorn_pid=$!

  set +e
  wait "$gunicorn_pid"
  gunicorn_status=$?
  set -e
  gunicorn_pid=""

  if [[ "$stopping" == true ]]; then
    exit 0
  fi
  printf 'Gunicorn exited with status %s; restarting in %s seconds.\n' \
    "$gunicorn_status" "$restart_delay" >&2
  sleep "$restart_delay"
done
