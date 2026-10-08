#!/usr/bin/env bash
# Run Terraform with the same OCI profile selection used by the Cloud Shell scripts.
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
selected_profile=${OCI_PROFILE:-${OCI_CLI_PROFILE:-}}

if [[ -n "$selected_profile" && -z "${TF_VAR_oci_profile:-}" ]]; then
  export TF_VAR_oci_profile="$selected_profile"
fi

cd "$script_dir"
exec terraform "$@"
