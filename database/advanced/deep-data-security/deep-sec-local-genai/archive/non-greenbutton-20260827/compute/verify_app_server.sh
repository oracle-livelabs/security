#!/usr/bin/env bash
# Verify the prebuilt Flask application-server image without installing anything.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
exec "$script_dir/../flask-app/verify_app_server.sh"
