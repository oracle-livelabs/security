#!/usr/bin/env bash
# Extract a wallet that was uploaded to the application host.
set -euo pipefail

wallet_zip=${1:-${WALLET_ZIP:-$HOME/deep-sec-wallet/Wallet_DEEPSEC.zip}}
wallet_dir=${WALLET_DIR:-$HOME/deep-sec-wallet/tns_admin}

[ -f "$wallet_zip" ] || { echo "ERROR: wallet ZIP not found: $wallet_zip" >&2; exit 1; }
command -v unzip >/dev/null || { echo 'ERROR: unzip is required' >&2; exit 1; }
mkdir -vp "$wallet_dir"
chmod 700 "$wallet_dir"
unzip -o "$wallet_zip" -d "$wallet_dir"
for wallet_file in tnsnames.ora sqlnet.ora cwallet.sso ewallet.p12; do
  [ -f "$wallet_dir/$wallet_file" ] || { echo "ERROR: extracted wallet has no $wallet_file" >&2; exit 1; }
done

# Wallets downloaded from OCI use the Instant Client default (?/network/admin).
# Point Oracle Net at this protected directory instead.
escaped_wallet_dir=$(printf '%s' "$wallet_dir" | sed 's/[&|\\]/\\&/g')
sed -i "s|DIRECTORY=\"?/network/admin\"|DIRECTORY=\"$escaped_wallet_dir\"|g" "$wallet_dir/sqlnet.ora"
grep -F "DIRECTORY=\"$wallet_dir\"" "$wallet_dir/sqlnet.ora" >/dev/null || {
  echo "ERROR: sqlnet.ora does not point to $wallet_dir" >&2
  exit 1
}
chmod 600 "$wallet_dir"/*
echo "Wallet extracted to $wallet_dir"
echo "Updated sqlnet.ora wallet directory to $wallet_dir"
echo "Set DB_WALLET_LOCATION=$wallet_dir in flask-app/.env"
