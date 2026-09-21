#!/bin/bash
# Shared lab instance ID helpers.

make_lab_instance_id() {
  local state_key="$1"
  local local_instance_file="$2"
  local env_var_name="$3"
  local configured_id="${!env_var_name:-}"
  local state_dir="${DBSEC_LAB_STATE_DIR:-$HOME/.dbsec-labs/instances}"
  local state_file="${state_dir}/${state_key}.instance"
  local legacy_state_file
  local legacy_prefix
  local host_part
  local machine_part
  local hash_part
  local random_part
  local instance_id

  if [ -n "$configured_id" ]; then
    instance_id="$configured_id"
  elif [ -f "$state_file" ]; then
    instance_id=$(tr -d '[:space:]' < "$state_file")
  elif [ -f "$local_instance_file" ]; then
    instance_id=$(tr -d '[:space:]' < "$local_instance_file")
    legacy_prefix=$(basename "$local_instance_file" | sed 's/^\.//; s/\.instance$//')
    instance_id=${instance_id#${legacy_prefix}-}
  else
    for legacy_state_file in "$state_dir"/*.instance; do
      [ -f "$legacy_state_file" ] || continue
      instance_id=$(tr -d '[:space:]' < "$legacy_state_file")
      legacy_prefix=$(basename "$legacy_state_file" .instance)
      instance_id=${instance_id#${legacy_prefix}-}
      break
    done
  fi

  if [ -z "${instance_id:-}" ]; then
    host_part=$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo dbsec-lab)
    machine_part=$(cat /etc/machine-id 2>/dev/null || cat /sys/class/dmi/id/product_uuid 2>/dev/null || echo unknown)
    hash_part=$(printf '%s-%s' "$host_part" "$machine_part" | sha256sum | awk '{print substr($1,1,6)}')
    random_part=$(python3 -c 'import uuid; print(uuid.uuid4().hex[:6])')
    instance_id=$(printf '%s-%s-%s' "$host_part" "$hash_part" "$random_part" \
      | tr '[:upper:]' '[:lower:]' \
      | tr -cs 'a-z0-9-' '-' \
      | sed 's/^-//; s/-$//')
  fi

  mkdir -p "$state_dir"
  printf '%s\n' "$instance_id" > "$state_file"
  chmod 700 "$state_dir"
  chmod 600 "$state_file"

  printf '%s\n' "$instance_id" > "$local_instance_file"
  chmod 600 "$local_instance_file"

  printf '%s' "$instance_id"
}

short_lab_instance_id() {
  local instance_id="$1"
  local length="${2:-6}"
  local short_id
  short_id=$(printf '%s' "$instance_id" | awk -F- '{print $NF}' | tr -cd 'a-z0-9' | cut -c1-"$length")
  if [ "${#short_id}" -lt "$length" ]; then
    short_id=$(printf '%s' "$instance_id" | tr -cd 'a-z0-9' | rev | cut -c1-"$length" | rev)
  fi
  if [ -z "$short_id" ]; then
    short_id=$(python3 -c 'import uuid; print(uuid.uuid4().hex[:6])')
  fi
  printf '%s' "$short_id"
}
