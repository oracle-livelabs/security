#!/usr/bin/env bash
# Transfer the wallet downloaded in Cloud Shell to the OL9 compute host over SCP.
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[ -f "$script_dir/config.env" ] && source "$script_dir/config.env"

wallet_file="$script_dir/artifacts/Wallet_DDS26AI.zip"
[ -f "$wallet_file" ] || { echo "ERROR: Download the wallet first with download_wallet.sh" >&2; exit 1; }

compute_host=${COMPUTE_HOST:-}
compute_user=${COMPUTE_SSH_USER:-opc}
compute_key=${COMPUTE_SSH_PRIVATE_KEY:-}
remote_dir=${COMPUTE_WALLET_STAGING_DIR:-/home/$compute_user/deep-sec-local-genai-wallet}

[ -n "$compute_host" ] || { echo "ERROR: COMPUTE_HOST is required (DNS name or IP address)." >&2; exit 2; }
[ -n "$compute_key" ] || { echo "ERROR: COMPUTE_SSH_PRIVATE_KEY is required." >&2; exit 2; }
[ -f "$compute_key" ] || { echo "ERROR: SSH key file not found: $compute_key" >&2; exit 2; }

chmod 600 "$compute_key"
ssh -i "$compute_key" -o StrictHostKeyChecking=accept-new "$compute_user@$compute_host" "install -dv -m 0700 '$remote_dir'"
scp -i "$compute_key" "$wallet_file" "$compute_user@$compute_host:$remote_dir/Wallet_DDS26AI.zip"
ssh -i "$compute_key" "$compute_user@$compute_host" "chmod 600 '$remote_dir/Wallet_DDS26AI.zip'"
echo "Transferred wallet to $compute_user@$compute_host:$remote_dir/Wallet_DDS26AI.zip"
echo 'Next, run compute/install_wallet.sh on the compute host to extract it into the protected wallet directory.'
