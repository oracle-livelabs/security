#!/usr/bin/env bash
# Shared OCI CLI profile handling. Source this file; do not execute it directly.

set -euo pipefail

OCI_PROFILE_NAME=${OCI_PROFILE:-${OCI_CLI_PROFILE:-${OCI_PROFILE_NAME:-DEFAULT}}}
OCI_CONFIG_PATH=${OCI_CONFIG_FILE:-${OCI_CLI_CONFIG_FILE:-}}
export OCI_PROFILE_NAME OCI_CONFIG_PATH

oci_with_profile() {
  local args=(--profile "$OCI_PROFILE_NAME")
  [ -n "$OCI_CONFIG_PATH" ] && args+=(--config-file "$OCI_CONFIG_PATH")
  command oci "${args[@]}" "$@"
}

show_oci_profile() {
  printf 'OCI profile: %s\n' "$OCI_PROFILE_NAME"
  [ -n "$OCI_CONFIG_PATH" ] && printf 'OCI config : %s\n' "$OCI_CONFIG_PATH"
}
