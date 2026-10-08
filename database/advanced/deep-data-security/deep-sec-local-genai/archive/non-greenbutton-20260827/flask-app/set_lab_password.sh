#!/usr/bin/env bash
# Source this script in Terminal B to retain LAB_PWD for later SQL*Plus commands.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "Run this script with: source ./set_lab_password.sh" >&2
  exit 1
fi

unset LAB_PWD LAB_PWD_CONFIRM
read -rsp "Paste the shared lab password: " LAB_PWD
echo
read -rsp "Paste it again to confirm: " LAB_PWD_CONFIRM
echo

if [[ -z "$LAB_PWD" ]]; then
  unset LAB_PWD LAB_PWD_CONFIRM
  echo "Password was empty. Run source ./set_lab_password.sh again." >&2
  return 1
fi

if [[ "$LAB_PWD" != "$LAB_PWD_CONFIRM" ]]; then
  unset LAB_PWD LAB_PWD_CONFIRM
  echo "Passwords did not match. Run source ./set_lab_password.sh again." >&2
  return 1
fi

export LAB_PWD
unset LAB_PWD_CONFIRM
echo "Password saved for this terminal session. SQL*Plus uses it for ADMIN, and Script 05 uses it as Marvin's password."
