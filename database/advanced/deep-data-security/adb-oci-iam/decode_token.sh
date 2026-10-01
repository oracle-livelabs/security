#!/bin/bash
# Decode and explain the local OCI IAM OAuth2 access token used by SQL*Plus.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ -f "${SCRIPT_DIR}/.adb-oci-iam.env" ]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.adb-oci-iam.env"
fi

export OCI_TOKEN_DIR="${OCI_TOKEN_DIR:-$HOME/.oci/adb-oci-iam}"
TOKEN_FILE="${1:-${OCI_TOKEN_DIR}/token}"

usage() {
  cat <<EOF
Usage:
  ./decode_token.sh
  ./decode_token.sh /path/to/token

Default token file:
  ${OCI_TOKEN_DIR}/token

This decodes the JWT header and payload locally. It does not validate the
signature or call OCI IAM.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Decode OCI IAM OAuth2 Access Token                                    ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}TOKEN_FILE = ${TOKEN_FILE}${NC}"
echo

if [ ! -f "$TOKEN_FILE" ]; then
  echo -e "${RED}ERROR: Token file was not found.${NC}"
  echo -e "${YELLOW}Run ./04_get_iam_oauth_token.sh first, or pass a token file path.${NC}"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo -e "${RED}ERROR: python3 is required.${NC}"
  exit 1
fi

python3 - "$TOKEN_FILE" <<'PY'
import base64
import datetime as dt
import json
import sys

token_path = sys.argv[1]

with open(token_path, "r", encoding="utf-8") as token_file:
    token = token_file.read().strip()

parts = token.split(".")
if len(parts) != 3:
    print("ERROR: The token does not look like a JWT access token.", file=sys.stderr)
    print("Expected three base64url sections separated by periods.", file=sys.stderr)
    sys.exit(1)

def decode_part(value):
    padding = "=" * (-len(value) % 4)
    raw = base64.urlsafe_b64decode((value + padding).encode("ascii"))
    return json.loads(raw.decode("utf-8"))

try:
    header = decode_part(parts[0])
    payload = decode_part(parts[1])
except Exception as exc:
    print(f"ERROR: Could not decode token JSON: {exc}", file=sys.stderr)
    sys.exit(1)

def as_time(value):
    if not isinstance(value, int):
        return ""
    return dt.datetime.fromtimestamp(value, tz=dt.timezone.utc).isoformat()

def show_claim(name, explanation):
    value = payload.get(name)
    if value is None:
        return
    if isinstance(value, (dict, list)):
        rendered = json.dumps(value, indent=2, sort_keys=True)
    else:
        rendered = str(value)
    print(f"{name}: {rendered}")
    if name in ("iat", "nbf", "exp"):
        converted = as_time(value)
        if converted:
            print(f"  time: {converted}")
    print(f"  why : {explanation}")
    print()

print("JWT Overview")
print("------------")
print("This is a signed OAuth2 access token from OCI IAM.")
print("SQL*Plus reads this file because sqlnet.ora uses TOKEN_AUTH=OAUTH and TOKEN_LOCATION.")
print("This script decodes the visible header and payload; it does not validate the signature.")
print()

print("Header")
print("------")
print(json.dumps(header, indent=2, sort_keys=True))
print()

print("Important Claims")
print("----------------")
show_claim("iss", "Token issuer. This should be your OCI IAM identity domain.")
show_claim("sub", "Subject identifier for the authenticated OCI IAM user.")
show_claim("user_name", "Human-readable OCI IAM username, when included by the domain.")
show_claim("client_id", "OAuth client that requested this token.")
show_claim("aud", "Audience/resource app this token is intended for.")
show_claim("scope", "OAuth scope granted to the token.")
show_claim("resource_app_id", "Resource application id checked by Oracle Database for OCI IAM OAuth login.")
show_claim("group", "OCI IAM group claim used by data roles mapped with IAM_OAUTH_GROUP.")
show_claim("groups", "OCI IAM group memberships, when emitted under the groups claim.")
show_claim("iat", "Issued-at timestamp.")
show_claim("nbf", "Not-before timestamp.")
show_claim("exp", "Expiration timestamp. Get a new token after this time.")

remaining = sorted(key for key in payload if key not in {
    "iss", "sub", "user_name", "client_id", "aud", "scope", "resource_app_id",
    "group", "groups", "iat", "nbf", "exp",
})
if remaining:
    print("Other Claims")
    print("------------")
    for key in remaining:
        value = payload[key]
        if isinstance(value, (dict, list)):
            value = json.dumps(value, indent=2, sort_keys=True)
        print(f"{key}: {value}")
    print()

print("Raw Payload")
print("-----------")
print(json.dumps(payload, indent=2, sort_keys=True))
PY

echo
echo -e "${GREEN}Done.${NC}"
echo
