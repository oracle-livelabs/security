#!/bin/bash
# Token preflight helpers for OCI IAM OAuth2 SQL*Plus logins.

check_oauth_token() {
  local expected_user="$1"
  shift
  local required_groups=("$@")
  local token_dir="${OCI_TOKEN_DIR:-$HOME/.oci/adb-oci-iam}"
  local token_file="${token_dir}/token"

  if [ ! -f "$token_file" ]; then
    echo "ERROR: OAuth token was not found at ${token_file}." >&2
    echo "Run ./04_get_iam_oauth_token.sh --headless and sign in as ${expected_user} in a separate browser session." >&2
    return 1
  fi

  EXPECTED_USER="$expected_user" \
  REQUIRED_GROUPS="$(IFS=,; echo "${required_groups[*]}")" \
  TOKEN_FILE="$token_file" \
  python3 - <<'PY'
import base64
import json
import os
import sys

expected_user = os.environ["EXPECTED_USER"].lower()
required_groups = [g for g in os.environ.get("REQUIRED_GROUPS", "").split(",") if g]
token_file = os.environ["TOKEN_FILE"]

with open(token_file, "r", encoding="utf-8") as handle:
    token = handle.read().strip()

parts = token.split(".")
if len(parts) != 3:
    print("ERROR: Token file does not contain a JWT access token.", file=sys.stderr)
    sys.exit(1)

payload_raw = parts[1] + "=" * (-len(parts[1]) % 4)
payload = json.loads(base64.urlsafe_b64decode(payload_raw.encode("ascii")).decode("utf-8"))

subject = str(payload.get("user_name") or payload.get("sub") or "").lower()
groups = payload.get("group") or payload.get("groups") or []
if isinstance(groups, str):
    groups = [groups]
group_set = {str(group) for group in groups}

print(f"Token subject: {subject or '(missing)'}")
print(f"Token groups : {', '.join(str(group) for group in groups) if groups else '(none)'}")

if subject != expected_user:
    print(f"ERROR: Token is for {subject or '(missing)'}, expected {expected_user}.", file=sys.stderr)
    print("Remove the current token, then get a fresh token in a separate browser session.", file=sys.stderr)
    print(f"Commands: rm -rf $HOME/.oci/adb-oci-iam && ./04_get_iam_oauth_token.sh --headless", file=sys.stderr)
    print(f"Sign in as {expected_user}, not the tenancy owner or another cached OCI session.", file=sys.stderr)
    sys.exit(1)

missing = [group for group in required_groups if group not in group_set]
if missing:
    print(f"ERROR: Token is missing required group(s): {', '.join(missing)}", file=sys.stderr)
    print("Get a fresh token after confirming OCI IAM group membership.", file=sys.stderr)
    sys.exit(1)
PY
}
