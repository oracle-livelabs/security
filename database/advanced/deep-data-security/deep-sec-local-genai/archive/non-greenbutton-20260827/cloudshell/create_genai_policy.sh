#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
requested_oci_profile=${OCI_PROFILE:-${OCI_CLI_PROFILE:-}}
requested_compute_instance_ocid=${COMPUTE_INSTANCE_OCID:-}
requested_dynamic_group_name=${COMPUTE_DYNAMIC_GROUP_NAME:-}
requested_genai_compartment_ocid=${GENAI_COMPARTMENT_OCID:-}
[ -f "$script_dir/config.env" ] && source "$script_dir/config.env"
[ -n "$requested_oci_profile" ] && OCI_PROFILE=$requested_oci_profile
[ -n "$requested_compute_instance_ocid" ] && COMPUTE_INSTANCE_OCID=$requested_compute_instance_ocid
[ -n "$requested_dynamic_group_name" ] && COMPUTE_DYNAMIC_GROUP_NAME=$requested_dynamic_group_name
[ -n "$requested_genai_compartment_ocid" ] && GENAI_COMPARTMENT_OCID=$requested_genai_compartment_ocid
source "$script_dir/oci_profile.sh"
for var in COMPUTE_DYNAMIC_GROUP_NAME GENAI_COMPARTMENT_OCID; do [ -n "${!var:-}" ] || { echo "ERROR: $var is required" >&2; exit 2; }; done
show_oci_profile
echo 'Create the dynamic group with a rule similar to:'
echo "  ALL {instance.id = '${COMPUTE_INSTANCE_OCID:-<compute-instance-ocid>}'}"
echo
echo 'An OCI administrator can create this least-privilege policy:'
echo "  Allow dynamic-group ${COMPUTE_DYNAMIC_GROUP_NAME} to use generative-ai-chat in compartment id ${GENAI_COMPARTMENT_OCID}"
echo 'This script prints policy guidance only; it makes no tenancy-level IAM changes.'
