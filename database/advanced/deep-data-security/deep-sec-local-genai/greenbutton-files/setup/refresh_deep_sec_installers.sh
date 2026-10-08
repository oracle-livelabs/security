#!/usr/bin/env bash
# Refresh a pre-existing VM's cloud-init-created installers with the concise
# deployment logging used by newly created stacks. Run as root.
set -Eeuo pipefail

[[ ${EUID} -eq 0 ]] || { echo 'Run this script with sudo.' >&2; exit 1; }

quiet_commands() {
  local installer="$1"
  [[ -f "$installer" ]] || return 0
  sed -i \
    -e 's/rm -rfv /rm -rf /g' \
    -e 's/rm -fv /rm -f /g' \
    -e 's/mkdir -pv /mkdir -p /g' \
    -e 's/mv -v /mv /g' \
    -e 's/cp -av /cp -a /g' \
    -e 's/ln -sfnv /ln -sfn /g' \
    -e 's/restorecon -RFv /restorecon -RF /g' \
    -e 's/--progress=bar:force /-q /g' \
    "$installer"
}

add_section() {
  local installer="$1"
  local heading="$2"
  local match="$3"
  [[ -f "$installer" ]] || return 0
  grep -Fq "===== $heading =====" "$installer" && return 0
  grep -Fq "$match" "$installer" || return 0
  sed -i "/$match/i\\      printf '\\n===== $heading =====\\n'" "$installer"
}

for installer in \
  /usr/local/sbin/download-deep-sec-lab-files \
  /usr/local/sbin/download-deep-sec-wallet \
  /usr/local/sbin/generate-deep-sec-order-history \
  /usr/local/sbin/install-deep-sec-admin-console \
  /usr/local/sbin/install-deep-sec-vibe; do
  quiet_commands "$installer"
done

# Existing VMs retain the cloud-init-created generator. Wrap it so all of its
# pip and Spark output is retained for diagnosis but shown only when it fails.
generator=/usr/local/sbin/generate-deep-sec-order-history
generator_verbose="${generator}.verbose"
if [[ -f "$generator" ]] && ! grep -Fq 'Deep Sec concise log wrapper' "$generator"; then
  mv "$generator" "$generator_verbose"
  cat > "$generator" <<'SCRIPT'
#!/usr/bin/env bash
# Deep Sec concise log wrapper
set -Eeuo pipefail

log=/var/log/deep-sec-order-history.log
: > "$log"
chmod 0644 "$log"
printf '\n===== Generate Iceberg order history =====\n'
if ! /usr/local/sbin/generate-deep-sec-order-history.verbose >> "$log" 2>&1; then
  echo "ERROR: Iceberg order history generation failed. Last 80 lines from $log:" >&2
  tail -n 80 "$log" >&2 || true
  exit 1
fi
grep -E '^(Iceberg table|Wrote [0-9]+ rows|Published OCI-native Iceberg metadata|Wrote Oracle metadata URL)' "$log" || true
if [[ -r /home/opc/.deep-sec-order-history-credentials ]]; then
  source /home/opc/.deep-sec-order-history-credentials
  echo "Iceberg order history is ready in bucket ${ORDER_HISTORY_BUCKET:-<unknown>} under prefix ${ORDER_HISTORY_OCI_EXPORT_PREFIX:-${ORDER_HISTORY_PREFIX:-<unknown>}}."
else
  echo 'Iceberg order history is ready in the configured destination bucket.'
fi
SCRIPT
  chmod 0755 "$generator"
fi

# Do the same for the existing application installer. Its detailed pip and
# systemd diagnostics remain available in the log and are shown on failure.
console_installer=/usr/local/sbin/install-deep-sec-admin-console
console_verbose="${console_installer}.verbose"
if [[ -f "$console_installer" ]] && ! grep -Fq 'Deep Sec concise log wrapper' "$console_installer"; then
  mv "$console_installer" "$console_verbose"
  cat > "$console_installer" <<'SCRIPT'
#!/usr/bin/env bash
# Deep Sec concise log wrapper
set -Eeuo pipefail

log=/var/log/deep-sec-admin-console-install.log
: > "$log"
chmod 0644 "$log"
printf '\n===== Install and start Deep Sec applications =====\n'
if ! /usr/local/sbin/install-deep-sec-admin-console.verbose >> "$log" 2>&1; then
  echo "ERROR: Deep Sec application installation failed. Last 80 lines from $log:" >&2
  tail -n 80 "$log" >&2 || true
  exit 1
fi
grep -E '^(Protected original Customer Sales App|Deep Sec Customer Sales App|Deep Sec Administrator)' "$log" || true
SCRIPT
  chmod 0755 "$console_installer"
fi

add_section /usr/local/sbin/generate-deep-sec-order-history 'Prepare Iceberg generator' 'rm -rf "'
add_section /usr/local/sbin/generate-deep-sec-order-history 'Install Iceberg generator dependencies' 'python3 -m venv'
add_section /usr/local/sbin/generate-deep-sec-order-history 'Generate Iceberg order history' 'runuser -u opc -- bash -c'
add_section /usr/local/sbin/install-deep-sec-admin-console 'Install Administrator Console' 'systemctl stop deep-sec-admin-console.service'
add_section /usr/local/sbin/install-deep-sec-admin-console 'Install database setup scripts' 'chown -R opc:opc "$admin_database_dir"'
add_section /usr/local/sbin/install-deep-sec-admin-console 'Install Customer Sales App' 'customer_stage_dir'
add_section /usr/local/sbin/install-deep-sec-admin-console 'Configure and start Deep Sec services' 'install -d -m 0755 /etc/deep-sec'
add_section /usr/local/sbin/install-deep-sec-vibe 'Install Vibe Coding' 'unzip -tqq "$archive"'
add_section /usr/local/sbin/install-deep-sec-vibe 'Verify Vibe Coding' 'restorecon -RF'

echo 'Deep Sec installer output is now concise; phase dividers are enabled.'
