#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
mkdir -p "$script_dir/dist"

archive="$script_dir/dist/order_history_iceberg_bundle-MarketplaceSeparate.zip"
rm -f "$archive" "$archive.sha256"
(cd "$script_dir/greenbutton-files/iceberg-sample" && zip -qr "$archive" order_history)
unzip -tq "$archive"
sha256sum "$archive" > "$archive.sha256"
echo "Created dist/order_history_iceberg_bundle-MarketplaceSeparate.zip and its SHA-256 file."
