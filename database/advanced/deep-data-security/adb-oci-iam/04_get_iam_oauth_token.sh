#!/bin/bash
# Configure the ADB wallet for OCI IAM OAuth2 auth and get a user access token.

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "${SCRIPT_DIR}/lib_adb.sh"
require_adb_env

export OCI_TOKEN_DIR="${OCI_TOKEN_DIR:-$HOME/.oci/adb-oci-iam}"
export OCI_REDIRECT_URI="${OCI_REDIRECT_URI:-http://localhost:8888/callback}"
export OCI_REDIRECT_URIS="${OCI_REDIRECT_URIS:-${OCI_REDIRECT_URI}}"
export OCI_OPEN_BROWSER="${OCI_OPEN_BROWSER:-0}"
export OCI_HEADLESS="${OCI_HEADLESS:-0}"

DEFAULT_REDIRECT_URIS="http://localhost:8888/callback,http://localhost:8889/callback,http://localhost:8890/callback,http://127.0.0.1:8888/callback,http://127.0.0.1:8889/callback,http://127.0.0.1:8890/callback"
SQLNET_FILE="${TNS_ADMIN}/sqlnet.ora"

usage() {
  cat <<'EOF'
Usage:
  ./04_get_iam_oauth_token.sh
  ./04_get_iam_oauth_token.sh --headless
  OCI_OPEN_BROWSER=1 ./04_get_iam_oauth_token.sh

Required environment:
  OCI_DOMAIN_URL       Identity domain URL, such as https://idcs-...identity.oraclecloud.com
  OCI_CLIENT_ID        OAuth client id for the public interactive user login app
  OCI_SCOPE            Database access scope granted to the client app

Optional environment:
  OCI_CLIENT_SECRET    Only needed when using a confidential OAuth client app.

Options:
  --headless     Print the login URL and prompt for the full localhost callback URL.
  -h, --help     Show this help.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --headless)
      OCI_HEADLESS=1
      export OCI_HEADLESS
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo -e "${RED}ERROR: Unknown option: $1${NC}" >&2
      usage
      exit 1
      ;;
  esac
done

normalize_redirect_uri() {
  local first_uri
  if [[ "$OCI_REDIRECT_URI" == *":8080/"* ]] || [[ "$OCI_REDIRECT_URIS" != *"localhost:8888/callback"* ]]; then
    echo -e "${YELLOW}Replacing stale OAuth redirect settings with lab defaults.${NC}"
    OCI_REDIRECT_URIS="$DEFAULT_REDIRECT_URIS"
    export OCI_REDIRECT_URIS
  fi

  first_uri="${OCI_REDIRECT_URIS%%,*}"
  if [ -n "$OCI_REDIRECT_URIS" ] && [[ ",${OCI_REDIRECT_URIS}," != *",${OCI_REDIRECT_URI},"* ]]; then
    echo -e "${YELLOW}Ignoring stale OCI_REDIRECT_URI=${OCI_REDIRECT_URI}${NC}"
    echo -e "${YELLOW}Using OCI_REDIRECT_URI=${first_uri}${NC}"
    OCI_REDIRECT_URI="$first_uri"
    export OCI_REDIRECT_URI
  fi
}

set_sqlnet_value() {
  local key="$1"
  local value="$2"
  local escaped_value
  escaped_value=$(printf '%s' "$value" | sed 's/[&#]/\\&/g')

  if grep -Eiq "^[[:space:]]*${key}[[:space:]]*=" "$SQLNET_FILE"; then
    show_cmd sed -i.bak-oauth -E "s#^[[:space:]]*${key}[[:space:]]*=.*#${key}=${escaped_value}#I" "$SQLNET_FILE"
    sed -i.bak-oauth -E "s#^[[:space:]]*${key}[[:space:]]*=.*#${key}=${escaped_value}#I" "$SQLNET_FILE"
  else
    echo "${key}=${value}" >> "$SQLNET_FILE"
  fi
}

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 4: Get OCI IAM OAuth2 Access Token                               ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo -e "${CYAN}TNS_ADMIN      = ${TNS_ADMIN}${NC}"
echo -e "${CYAN}ADB_SERVICE    = ${ADB_SERVICE}${NC}"
echo -e "${CYAN}OCI_TOKEN_DIR  = ${OCI_TOKEN_DIR}${NC}"
echo

if [ ! -f "$SQLNET_FILE" ]; then
  echo -e "${RED}ERROR: ${SQLNET_FILE} was not found. Re-run ./00_setup_adb.sh to download the ADB wallet.${NC}"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo -e "${RED}ERROR: python3 is required.${NC}"
  exit 1
fi

missing=()
for var in OCI_DOMAIN_URL OCI_CLIENT_ID OCI_SCOPE OCI_REDIRECT_URI; do
  if [ -z "${!var:-}" ]; then
    missing+=("$var")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo -e "${RED}ERROR: Missing OAuth2 configuration:${NC}"
  for var in "${missing[@]}"; do
    echo "  - ${var}"
  done
  echo
  echo -e "${YELLOW}Source the environment file that creates the OAuth client app, or export these values manually.${NC}"
  echo -e "${YELLOW}SQL*Plus needs the user's OCI IAM OAuth2 access token for this lab.${NC}"
  exit 1
fi

normalize_redirect_uri

echo -e "${YELLOW}Step 1: Configuring sqlnet.ora for OAuth2 token login...${NC}"
show_cmd cp "$SQLNET_FILE" "${SQLNET_FILE}.bak-oauth"
cp "$SQLNET_FILE" "${SQLNET_FILE}.bak-oauth"
set_sqlnet_value TOKEN_AUTH OAUTH
set_sqlnet_value TOKEN_LOCATION "$OCI_TOKEN_DIR"
echo -e "${CYAN}  sqlnet.ora now uses TOKEN_AUTH=OAUTH and TOKEN_LOCATION=${OCI_TOKEN_DIR}${NC}"

echo
echo -e "${YELLOW}Step 2: Starting OCI IAM OAuth2 authorization-code login...${NC}"
echo -e "${PURPLE}This opens or prints an OCI IAM login URL for the user you sign in as, then writes${NC}"
echo -e "${PURPLE}the returned OAuth2 access token where SQL*Plus can read it.${NC}"
echo

python3 - <<'PY'
import base64
import json
import os
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer

domain = os.environ["OCI_DOMAIN_URL"].rstrip("/")
client_id = os.environ["OCI_CLIENT_ID"]
client_secret = os.environ.get("OCI_CLIENT_SECRET", "")
scope = os.environ["OCI_SCOPE"]
token_dir = os.environ["OCI_TOKEN_DIR"]
open_browser = os.environ.get("OCI_OPEN_BROWSER", "0").lower() in ("1", "true", "yes", "y")
headless = os.environ.get("OCI_HEADLESS", "0").lower() in ("1", "true", "yes", "y")

redirect_candidates = []
for raw_uri in os.environ.get("OCI_REDIRECT_URIS", os.environ["OCI_REDIRECT_URI"]).split(","):
    raw_uri = raw_uri.strip()
    if raw_uri:
        redirect_candidates.append(raw_uri)
if os.environ["OCI_REDIRECT_URI"] not in redirect_candidates:
    redirect_candidates.insert(0, os.environ["OCI_REDIRECT_URI"])

state = base64.urlsafe_b64encode(os.urandom(24)).decode("ascii").rstrip("=")
code_verifier = base64.urlsafe_b64encode(os.urandom(48)).decode("ascii").rstrip("=")
code_challenge = base64.urlsafe_b64encode(
    __import__("hashlib").sha256(code_verifier.encode("ascii")).digest()
).decode("ascii").rstrip("=")
result = {}
server = None
redirect_uri = None
path = None

def prompt_from_tty(prompt):
    try:
        with open("/dev/tty", "r", encoding="utf-8") as tty_in:
            with open("/dev/tty", "w", encoding="utf-8") as tty_out:
                tty_out.write(prompt)
                tty_out.flush()
                return tty_in.readline().strip()
    except OSError:
        return input(prompt).strip()

def extract_authorization_code(pasted):
    pasted = pasted.strip()
    if not pasted:
        return ""
    if "://" not in pasted and "code=" not in pasted:
        print("Using pasted value as the authorization code.")
        return pasted

    parsed = urllib.parse.urlparse(pasted)
    params = {**urllib.parse.parse_qs(parsed.fragment), **urllib.parse.parse_qs(parsed.query)}
    if "error" in params:
        error = params.get("error", [""])[0]
        description = params.get("error_description", [""])[0]
        print(f"ERROR: OCI IAM returned {error}: {description}", file=sys.stderr)
        sys.exit(1)

    returned_state = params.get("state", [""])[0]
    if returned_state and returned_state != state:
        print("ERROR: The pasted URL state value does not match this token request.", file=sys.stderr)
        sys.exit(1)

    code = params.get("code", [""])[0]
    if not code:
        print("ERROR: No code= parameter was found in the pasted value.", file=sys.stderr)
        sys.exit(1)
    print(f"Parsed authorization code ({len(code)} characters).")
    return code

class CallbackHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        return

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)
        if parsed.path != path:
            self.send_response(404)
            self.end_headers()
            return
        if params.get("state", [""])[0] != state:
            result["error"] = "Returned OAuth state did not match the request."
        elif "error" in params:
            result["error"] = params.get("error_description", params["error"])[0]
        else:
            result["code"] = params.get("code", [""])[0]

        body = b"You can close this browser tab and return to the terminal.\n"
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

def serve_once(http_server):
    http_server.handle_request()

if not headless:
    for candidate in redirect_candidates:
        parsed = urllib.parse.urlparse(candidate)
        if parsed.scheme != "http" or parsed.hostname not in ("localhost", "127.0.0.1"):
            continue
        try:
            server = HTTPServer((parsed.hostname, parsed.port or 80), CallbackHandler)
            redirect_uri = candidate
            path = parsed.path or "/"
            threading.Thread(target=serve_once, args=(server,), daemon=True).start()
            break
        except OSError as exc:
            print(f"Could not listen on {parsed.hostname}:{parsed.port or 80}: {exc}")

if not redirect_uri:
    redirect_uri = redirect_candidates[0]
    path = urllib.parse.urlparse(redirect_uri).path or "/"
    if headless:
        print("Running in headless mode.")
    else:
        print("Continuing in manual callback mode.")

auth_url = f"{domain}/oauth2/v1/authorize?" + urllib.parse.urlencode({
    "client_id": client_id,
    "response_type": "code",
    "redirect_uri": redirect_uri,
    "scope": scope,
    "state": state,
    "code_challenge": code_challenge,
    "code_challenge_method": "S256",
})

if server:
    print(f"Listening for OAuth callback on {redirect_uri}")
else:
    print(f"Manual callback mode for redirect URI {redirect_uri}")
print()

if headless:
    print("=" * 76)
    print("ACTION REQUIRED: USE A SEPARATE PRIVATE BROWSER WINDOW")
    print("=" * 76)
    print("1. Copy the login URL below into a separate browser profile, private")
    print("   window, incognito window, or different browser.")
    print("2. Do not use a browser session already signed in as the tenancy owner.")
    print("3. Sign in as the target demo user: marvin or emma.")
    print("4. The final localhost page will usually fail to load. That is expected.")
    print("5. Copy the entire localhost callback URL from that browser address bar")
    print("   and paste it back here.")
    print("=" * 76)
    print()

if open_browser:
    print("Opening browser for OCI IAM login...")
    if not webbrowser.open(auth_url, new=2):
        print("Could not open a browser automatically. Open this URL manually:")
        print(auth_url)
else:
    if not headless:
        print("Open this URL in a separate browser profile, private window, or independent browser.")
        print("Sign in as the target demo user, not the tenancy owner or another cached OCI session.")
    print("LOGIN URL:")
    print(auth_url)
print()

if server:
    deadline = time.time() + int(os.environ.get("OCI_OAUTH_TIMEOUT_SECONDS", "300"))
    while time.time() < deadline and not result:
        time.sleep(0.25)
    server.server_close()

if "error" in result:
    print(f"ERROR: {result['error']}", file=sys.stderr)
    sys.exit(1)

code = result.get("code")
if not code:
    print("Copy the entire final redirected URL from the separate browser address bar.")
    if headless:
        print("The localhost page will usually fail to load from a local browser when the script runs in Cloud Shell.")
        print("That is expected. Do not troubleshoot the page load; copy the full localhost callback URL shown in the address bar.")
    for attempt in range(1, 4):
        pasted_value = prompt_from_tty("Paste the full callback URL: ")
        if pasted_value.strip():
            code = extract_authorization_code(pasted_value)
            break
        if attempt < 3:
            print("No URL pasted. Paste the full callback URL, then press Enter.")

if not code:
    print("ERROR: Could not determine authorization code. Re-run this script and paste the full callback URL from the browser address bar.", file=sys.stderr)
    sys.exit(1)

def request_token(strip_padding=False):
    form = {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirect_uri,
        "client_id": client_id,
        "code_verifier": code_verifier,
    }
    headers = {
        "Content-Type": "application/x-www-form-urlencoded; charset=utf-8",
        "Accept": "application/json",
    }
    if client_secret:
        basic = base64.urlsafe_b64encode(f"{client_id}:{client_secret}".encode("utf-8")).decode("ascii")
        if strip_padding:
            basic = basic.rstrip("=")
        headers["Authorization"] = f"Basic {basic}"

    request = urllib.request.Request(
        f"{domain}/oauth2/v1/token",
        data=urllib.parse.urlencode(form).encode("utf-8"),
        headers=headers,
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        return {"_http_error": exc.code, "_detail": exc.read().decode("utf-8", errors="replace")}

token_response = request_token(strip_padding=False)
if client_secret and token_response.get("_http_error") and "decode client header" in token_response.get("_detail", "").lower():
    token_response = request_token(strip_padding=True)

if token_response.get("_http_error"):
    print(f"ERROR: OCI IAM token exchange failed: HTTP {token_response['_http_error']}", file=sys.stderr)
    print(token_response.get("_detail", ""), file=sys.stderr)
    sys.exit(1)

access_token = token_response.get("access_token")
if not access_token:
    print("ERROR: OCI IAM token response did not include access_token.", file=sys.stderr)
    print(json.dumps(token_response, indent=2), file=sys.stderr)
    sys.exit(1)

os.makedirs(token_dir, mode=0o700, exist_ok=True)
token_path = os.path.join(token_dir, "token")
with open(token_path, "w", encoding="utf-8") as token_file:
    token_file.write(access_token)
os.chmod(token_dir, 0o700)
os.chmod(token_path, 0o600)

print()
print("OAuth2 access token written for SQL*Plus.")
print(f"  TOKEN_LOCATION={token_dir}")
print(f"  token file     = {token_path}")
print(f"  expires_in     = {token_response.get('expires_in', 'unknown')}")
PY

echo
echo -e "${GREEN}============================================================================${NC}"
echo -e "${GREEN}      Task 4 Completed: OCI IAM OAuth2 Token Ready                          ${NC}"
echo -e "${GREEN}============================================================================${NC}"
echo
echo "Ready: run ./05_verify_as_marvin.sh or ./06_verify_as_emma.sh"
echo
