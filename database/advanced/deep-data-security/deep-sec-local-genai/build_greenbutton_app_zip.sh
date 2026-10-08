#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
stage_dir=$(mktemp -d)
trap 'rm -rf "$stage_dir"' EXIT

mkdir -p "$script_dir/dist"
# GreenButton owns this complete source copy. Do not use the shared lab
# directories here: changes made under greenbutton-files are intentionally
# isolated from the normal and NO-IAM application packages.
cp -a "$script_dir/greenbutton-files/flask-app" "$stage_dir/flask-app"
cp -a "$script_dir/greenbutton-files/admin-app" "$stage_dir/admin-app"
cp -a "$script_dir/greenbutton-files/setup" "$stage_dir/setup"
[[ -s "$script_dir/vibe-cli.zip" ]] || {
  echo 'ERROR: missing tracked Vibe CLI archive: vibe-cli.zip' >&2
  exit 1
}
cp -a "$script_dir/vibe-cli.zip" "$stage_dir/vibe-cli.zip"

rm -rf "$stage_dir/flask-app/.venv" "$stage_dir/flask-app/__pycache__" "$stage_dir/flask-app/logs" \
  "$stage_dir/admin-app/.venv" "$stage_dir/admin-app/__pycache__" "$stage_dir/admin-app/logs"
rm -f "$stage_dir/flask-app/.env" "$stage_dir/admin-app/.env"
find "$stage_dir" -name '__pycache__' -type d -prune -exec rm -rf {} +
find "$stage_dir" -type f \( -name '*~' -o -name '*.un~' \) -delete
( ! find "$stage_dir" -type f \( -name '.env' -o -name '*.pem' -o -name 'cwallet.sso' -o -name 'ewallet.p12' \) -print -quit | grep -q . ) || {
  echo 'ERROR: refusing to package credentials or wallet material' >&2
  exit 1
}

archive="$script_dir/dist/deep-data-security-flask-app-GreenButton.zip"
rm -f "$archive" "$archive.sha256"
(cd "$stage_dir" && zip -qr "$archive" flask-app admin-app setup vibe-cli.zip)
unzip -tq "$archive"
sha256sum "$archive" > "$archive.sha256"
echo "Created dist/deep-data-security-flask-app-GreenButton.zip and its SHA-256 file."
