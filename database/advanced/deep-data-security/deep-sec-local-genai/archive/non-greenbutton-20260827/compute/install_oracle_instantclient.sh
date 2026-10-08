#!/usr/bin/env bash
# Optional Oracle Instant Client and SQL*Plus installation for the Flask host.
# The Flask application itself uses python-oracledb Thin mode and does not
# require Instant Client. Install this only when SQL*Plus is useful for lab
# validation or troubleshooting.
set -euo pipefail

[ "$(id -u)" -ne 0 ] || { echo 'Run this script as the normal compute user; it invokes sudo as needed.' >&2; exit 2; }
command -v dnf >/dev/null || { echo 'ERROR: This script requires an Oracle Linux host with dnf.' >&2; exit 1; }

arch=$(uname -m)
case "$arch" in
  x86_64|aarch64) ;;
  *) echo "ERROR: Unsupported CPU architecture: $arch" >&2; exit 1 ;;
esac

source /etc/os-release
case "${VERSION_ID%%.*}" in
  9) repo=ol9_oci_included; release_rpm=oracle-instantclient-release-26ai-el9 ;;
  *) echo "ERROR: Oracle Linux 9 is required; found ${PRETTY_NAME:-unknown}." >&2; exit 1 ;;
esac

echo "Architecture: $arch"
echo "Operating system: ${PRETTY_NAME:-Oracle Linux}"
echo "Enabling repository: $repo"

sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --enable "$repo"
sudo dnf install -y "$release_rpm"
sudo dnf clean all
sudo dnf makecache

echo 'Available Instant Client packages:'
dnf list available 'oracle-instantclient*' || true

sudo dnf install -y oracle-instantclient-basic oracle-instantclient-sqlplus

echo 'SQL*Plus location and version:'
command -v sqlplus
sqlplus -version

echo 'Installed Instant Client RPMs:'
rpm -qa | grep oracle-instantclient | sort
