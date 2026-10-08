#!/usr/bin/env bash
set -euo pipefail
if systemctl is-active --quiet firewalld; then
  echo 'firewalld is active. This prebuilt image expects it to remain disabled; do not open ports here.'
else
  echo 'firewalld is disabled. No OS firewall change is needed; the VCN security list controls access.'
fi
