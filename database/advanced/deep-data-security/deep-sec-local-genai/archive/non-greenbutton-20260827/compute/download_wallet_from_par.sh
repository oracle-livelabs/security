#!/usr/bin/env bash
# Download a wallet from a short-lived Object Storage PAR. No OCI CLI required.
set -euo pipefail

par_url=${1:-${WALLET_PAR_URL:-}}
staging_dir=${WALLET_STAGING_DIR:-$HOME/deep-sec-wallet}
[ -n "$par_url" ] || { echo 'Usage: download_wallet_from_par.sh <wallet-par-url>' >&2; exit 2; }

mkdir -vp "$staging_dir"
chmod 700 "$staging_dir"
wallet_zip="$staging_dir/Wallet_DEEPSEC.zip"
if command -v curl >/dev/null 2>&1; then
  curl --fail --location --show-error --verbose "$par_url" --output "$wallet_zip"
elif command -v wget >/dev/null 2>&1; then
  wget --verbose --output-document="$wallet_zip" "$par_url"
else
  echo 'ERROR: curl or wget is required.' >&2
  exit 1
fi
chmod 600 "$wallet_zip"
echo "Downloaded wallet to $wallet_zip"
echo 'Next, run compute/install_wallet.sh to extract it.'
