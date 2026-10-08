#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
install_root=${INSTALL_ROOT:-/opt/deep-sec-local-genai}
app_user=${APP_USER:-opc}
[ "$(id -u)" -eq 0 ] || { echo 'ERROR: run with sudo to install the system service' >&2; exit 1; }
id "$app_user" >/dev/null || { echo "ERROR: application user not found: $app_user" >&2; exit 1; }
install -dv -m 0755 "$install_root"
cp -av "$(cd "$script_dir/.." && pwd)/flask-app" "$install_root/"
chown -R "$app_user:$app_user" "$install_root/flask-app"
runuser -u "$app_user" -- "$install_root/flask-app/setup_venv.sh"
install -v -m 0644 "$script_dir/deep-data-security-flask.service" /etc/systemd/system/deep-data-security-flask.service
systemctl daemon-reload
systemctl enable --now deep-data-security-flask.service
systemctl --no-pager status deep-data-security-flask.service
