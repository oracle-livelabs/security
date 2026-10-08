#!/usr/bin/env bash
set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
offline_root=${OFFLINE_ROOT:?Set OFFLINE_ROOT to the prepared offline cache directory.}
python_version=${PYTHON_VERSION:-3.9}
source_wheelhouse="$offline_root/wheelhouse/py${python_version}"
target_root=${TARGET_ROOT:-/opt/deep-sec-offline}
target_wheelhouse="$target_root/wheelhouse/py${python_version}"

[[ -d "$source_wheelhouse" ]] || {
  echo "ERROR: missing source wheelhouse: $source_wheelhouse" >&2
  exit 1
}
wheel_count=$(find "$source_wheelhouse" -maxdepth 1 -type f -name '*.whl' -print | wc -l)
(( wheel_count > 0 )) || {
  echo "ERROR: source wheelhouse contains no wheels: $source_wheelhouse" >&2
  exit 1
}

rm -rf "$target_wheelhouse"
mkdir -p "$target_wheelhouse"
cp -a "$source_wheelhouse"/. "$target_wheelhouse"/

if [[ -f "$offline_root/locks/requirements-py${python_version}.lock.txt" ]]; then
  mkdir -p "$target_root/locks"
  cp -a "$offline_root/locks/requirements-py${python_version}.lock.txt" \
    "$target_root/locks/"
fi

printf 'Staged %s Python %s wheels in %s\n' "$wheel_count" "$python_version" "$target_wheelhouse"
