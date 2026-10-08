#!/usr/bin/env bash
# Build a broad, standalone offline backup for the Deep Data Security Flask lab.
#
# Run this ON THE GOLDEN ORACLE LINUX/JUPYTER HOST while Internet access is good.
# The Flask application does NOT need to be present.
#
# What this stages:
#   * The exact Python requirements used by the current lab Flask app
#   * All transitive PyPI dependencies needed by those requirements
#   * pip, setuptools, wheel, and virtualenv
#   * A safety-net set of common Flask/web/testing/diagnostic packages that a
#     vibe-coded enhancement might introduce
#   * Per-Python-version lock files and verified offline wheelhouses
#   * Linux troubleshooting, Python build, archive, and network-tool RPMs with
#     dependency resolution when dnf download is available
#   * Installed Oracle Instant Client / SQL*Plus RPMs when discoverable
#   * Detailed host inventory (RPM list, pip compatibility tags, ensurepip,
#     Oracle client libraries, and command availability)
#   * An offline venv recovery helper
#
# Default output:
#   /home/opc/aiworld-offline/flask-python
#
# Usage:
#   chmod +x prepare_deepsec_flask_offline.sh
#   ./prepare_deepsec_flask_offline.sh
#
# Optional environment variables:
#   OFFLINE_ROOT=/home/opc/aiworld-offline/flask-python
#   PYTHON_BINS="python3 python3.11"   # cache for every listed interpreter found
#   CACHE_OS_RPMS=1                    # 1=yes, 0=no
#   CACHE_EXTRAS=1                     # 1=yes, 0=no
#   EXTRA_PACKAGES="packageA packageB" # appended to the built-in safety net
#
# Important:
#   No finite cache can cover every package an AI coding agent could invent.
#   This script deliberately covers the current app plus common likely additions.
#   Use EXTRA_PACKAGES to add anything else you want staged before cloning.

set -Eeuo pipefail

SCRIPT_VERSION="3.0-standalone"
printf 'Deep Sec offline backup preparer: %s\n' "$SCRIPT_VERSION"
printf 'No Flask app directory is required.\n'
if [[ $# -gt 0 ]]; then
    printf 'NOTE: positional arguments are ignored by this standalone preparer.\n'
fi

log()  { printf '\n==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

OFFLINE_ROOT=${OFFLINE_ROOT:-"$HOME/aiworld-offline/flask-python"}
PYTHON_BINS=${PYTHON_BINS:-"python3 python3.11"}
CACHE_OS_RPMS=${CACHE_OS_RPMS:-1}
CACHE_EXTRAS=${CACHE_EXTRAS:-1}
EXTRA_PACKAGES=${EXTRA_PACKAGES:-""}

WHEEL_BASE="$OFFLINE_ROOT/wheelhouse"
LOCK_DIR="$OFFLINE_ROOT/locks"
RPM_DIR="$OFFLINE_ROOT/rpms"
CORE_REQ="$OFFLINE_ROOT/requirements.deepsec-app.txt"
EXTRA_REQ="$OFFLINE_ROOT/requirements.safety-net.txt"
INVENTORY="$OFFLINE_ROOT/host-inventory.txt"
MANIFEST="$OFFLINE_ROOT/SHA256SUMS"
RESTORE_SCRIPT="$OFFLINE_ROOT/install_flask_venv_offline.sh"

mkdir -p "$WHEEL_BASE" "$LOCK_DIR" "$RPM_DIR"

# These are copied from the Flask app shipped in deep-sec-local-genai.
cat > "$CORE_REQ" <<'REQ_EOF'
Flask>=3.0,<4.0
Bootstrap-Flask>=2.4,<3.0
Flask-WTF>=1.2,<2.0
Flask-Login>=0.6,<1.0
flask-htmx>=0.4,<1.0
python-dotenv>=1.0,<2.0
oracledb>=3.1
gunicorn>=22.0
requests>=2.31,<3.0
oci>=2.180,<3.0
REQ_EOF

# These are NOT installed into the lab app during validation. They are simply
# cached as emergency options for common web-app changes and troubleshooting.
cat > "$EXTRA_REQ" <<'REQ_EOF'
# Packaging / environment recovery
virtualenv

# Common Flask additions an app change may reasonably introduce
Flask-Cors
Flask-Session
Flask-SQLAlchemy
SQLAlchemy
waitress

# Common HTTP / configuration / validation helpers
httpx
pydantic
pydantic-settings
PyYAML

# Common test / diagnostics / development helpers
pytest
pytest-flask
psutil
rich
watchdog

# Explicitly stage important dependency families too. Most are already pulled
# transitively by Flask, requests, OCI, or python-oracledb; listing them here
# makes the intent obvious and helps retain them if dependency graphs change.
Werkzeug
Jinja2
MarkupSafe
itsdangerous
click
blinker
WTForms
dominate
certifi
charset-normalizer
idna
urllib3
cryptography
cffi
pyOpenSSL
python-dateutil
pytz
PyJWT
circuitbreaker
crc32c
six
typing-extensions
pycparser
REQ_EOF

if [[ -n "$EXTRA_PACKAGES" ]]; then
    {
        echo
        echo "# User-supplied extras"
        for pkg in $EXTRA_PACKAGES; do
            echo "$pkg"
        done
    } >> "$EXTRA_REQ"
fi

TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/deepsec-flask-offline.XXXXXX")
cleanup() { rm -rf "$TMP_ROOT"; }
trap cleanup EXIT

# Find unique usable interpreters. The app itself defaults to python3, while
# Python 3.11 is also common in the workshop environment.
declare -a PYTHONS=()
declare -A SEEN_PY=()
for candidate in $PYTHON_BINS; do
    command -v "$candidate" >/dev/null 2>&1 || continue
    resolved=$(readlink -f "$(command -v "$candidate")")
    version=$($candidate -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)
    [[ -n "$version" ]] || continue
    key="$resolved:$version"
    [[ -z "${SEEN_PY[$key]:-}" ]] || continue
    SEEN_PY[$key]=1
    PYTHONS+=("$(command -v "$candidate")")
done

[[ ${#PYTHONS[@]} -gt 0 ]] || die "No usable Python interpreter found from: $PYTHON_BINS"

{
    echo "Prepared: $(date -Is)"
    echo "Host: $(hostname 2>/dev/null || true)"
    echo "Kernel: $(uname -a)"
    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        echo "OS: ${PRETTY_NAME:-unknown}"
    fi
    echo "Architecture: $(uname -m)"
    echo "Offline root: $OFFLINE_ROOT"
    echo
    if [[ -r /etc/os-release ]]; then
        echo "Full /etc/os-release:"
        cat /etc/os-release
        echo
    fi
    echo "Python interpreters selected:"
    for py in "${PYTHONS[@]}"; do
        echo "  $py -> $($py --version 2>&1)"
    done
    echo
    echo "Core Flask requirements:"
    cat "$CORE_REQ"
    echo
    echo "Safety-net packages:"
    cat "$EXTRA_REQ"
} > "$INVENTORY"

build_for_python() {
    local py=$1
    local pyver tag wheelhouse lock_file build_venv build_py test_venv test_py
    local pip_version setuptools_version wheel_version

    pyver=$($py -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
    tag="py${pyver}"
    wheelhouse="$WHEEL_BASE/$tag"
    lock_file="$LOCK_DIR/requirements-${tag}.lock.txt"

    mkdir -p "$wheelhouse"
    find "$wheelhouse" -maxdepth 1 -type f -delete

    log "Preparing offline Python cache for $py ($pyver)"
    "$py" --version
    "$py" -m pip --version || die "$py exists, but pip is unavailable"

    {
        echo
        echo "[$tag compatibility / bootstrap diagnostics]"
        echo "Interpreter: $py"
        echo "Python: $($py --version 2>&1)"
        echo "pip: $($py -m pip --version 2>&1)"
        echo "ensurepip:"
        $py -m ensurepip --version 2>&1 || true
        echo
        echo "pip debug --verbose:"
        $py -m pip debug --verbose 2>&1 || true
    } >> "$INVENTORY"

    # Prove venv/ensurepip works before spending time downloading anything.
    local probe="$TMP_ROOT/venv-probe-$tag"
    "$py" -m venv "$probe" || die "Python venv support is not working for $py"
    "$probe/bin/python" -m pip --version >/dev/null || die "venv exists but pip bootstrap failed for $py"
    rm -rf "$probe"
    info "venv creation: OK"

    build_venv="$TMP_ROOT/build-$tag"
    "$py" -m venv "$build_venv"
    build_py="$build_venv/bin/python"

    # Upgrade while Internet is available, then cache those exact bootstrap tools.
    "$build_py" -m pip install --upgrade pip setuptools wheel
    pip_version=$($build_py -c 'from importlib.metadata import version; print(version("pip"))')
    setuptools_version=$($build_py -c 'from importlib.metadata import version; print(version("setuptools"))')
    wheel_version=$($build_py -c 'from importlib.metadata import version; print(version("wheel"))')

    log "Caching current lab app dependencies for $tag"
    "$build_py" -m pip wheel \
        --wheel-dir "$wheelhouse" \
        -r "$CORE_REQ"

    "$build_py" -m pip wheel \
        --wheel-dir "$wheelhouse" \
        "pip==$pip_version" \
        "setuptools==$setuptools_version" \
        "wheel==$wheel_version"

    if [[ "$CACHE_EXTRAS" == "1" ]]; then
        log "Caching Flask/web safety-net packages for $tag"
        # Download one top-level package at a time so an unrelated optional
        # package cannot make the whole safety-net resolver fail from conflicts.
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] || continue
            [[ "$pkg" =~ ^[[:space:]]*# ]] && continue
            info "Caching optional: $pkg"
            if ! "$build_py" -m pip wheel --wheel-dir "$wheelhouse" "$pkg"; then
                warn "Could not cache optional package '$pkg' for $tag; continuing"
            fi
        done < "$EXTRA_REQ"
    fi

    local wheel_count
    wheel_count=$(find "$wheelhouse" -maxdepth 1 -type f -name '*.whl' | wc -l)
    [[ "$wheel_count" -gt 0 ]] || die "No wheels were created for $tag"
    info "Wheelhouse contains $wheel_count wheel files"

    log "Proving the core app installs with NO PyPI access for $tag"
    test_venv="$TMP_ROOT/offline-test-$tag"
    "$py" -m venv "$test_venv"
    test_py="$test_venv/bin/python"

    "$test_py" -m pip install \
        --no-index \
        --find-links="$wheelhouse" \
        --upgrade \
        "pip==$pip_version" \
        "setuptools==$setuptools_version" \
        "wheel==$wheel_version"

    "$test_py" -m pip install \
        --no-index \
        --find-links="$wheelhouse" \
        -r "$CORE_REQ"

    "$test_py" -m pip check
    "$test_py" -m pip freeze | sort > "$lock_file"

    "$test_py" - <<'PY'
from importlib.metadata import version

import flask
import flask_bootstrap
import flask_htmx
import flask_login
import flask_wtf
import gunicorn
import oci
import oracledb
import requests
import dotenv

packages = (
    "Flask",
    "Bootstrap-Flask",
    "Flask-WTF",
    "Flask-Login",
    "flask-htmx",
    "python-dotenv",
    "oracledb",
    "gunicorn",
    "requests",
    "oci",
)
for package in packages:
    print(f"{package}: {version(package)}")
print("Core Flask package import test: OK")
PY

    log "Proving the exact lock also installs offline for $tag"
    local lock_test="$TMP_ROOT/lock-test-$tag"
    "$py" -m venv "$lock_test"
    "$lock_test/bin/python" -m pip install \
        --no-index \
        --find-links="$wheelhouse" \
        -r "$lock_file"
    "$lock_test/bin/python" -m pip check
    info "Exact locked environment: OK"

    log "Checking python-oracledb Thick mode for $tag"
    if "$test_py" - <<'PY'
import oracledb
oracledb.init_oracle_client()
print("python-oracledb Thick mode initialization: OK")
PY
    then
        info "Oracle Client library test: OK"
    else
        warn "Thick mode could not initialize for $tag. The PyPI backup is valid, but verify Oracle Instant Client on the golden image."
    fi

    {
        echo
        echo "[$tag]"
        echo "Interpreter: $py"
        echo "Version: $($py --version 2>&1)"
        echo "Wheelhouse: $wheelhouse"
        echo "Wheel count: $wheel_count"
        echo "Lock file: $lock_file"
        echo "pip cached: $pip_version"
        echo "setuptools cached: $setuptools_version"
        echo "wheel cached: $wheel_version"
    } >> "$INVENTORY"
}

for py in "${PYTHONS[@]}"; do
    build_for_python "$py"
done

log "Checking Oracle/host tooling"
{
    echo
    echo "Host tools:"
    for cmd in sqlplus tnsping unzip zip tar gzip bzip2 xz git curl wget jq rsync file which lsof ps ss ip dig nslookup nc gcc g++ make pkg-config; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "  $cmd: $(command -v "$cmd")"
        else
            echo "  $cmd: NOT FOUND"
        fi
    done
    if command -v rpm >/dev/null 2>&1; then
        echo
        echo "Installed Oracle Instant Client RPMs:"
        rpm -qa | grep '^oracle-instantclient' | sort || true
        echo
        echo "Complete installed RPM inventory:"
        rpm -qa | sort || true
    fi
    echo
    echo "Oracle client libraries visible to the dynamic linker:"
    if command -v ldconfig >/dev/null 2>&1; then
        ldconfig -p 2>/dev/null | grep -E 'libclntsh|libnnz|libocci|libaio|libnsl' || true
    else
        echo "  ldconfig: NOT FOUND"
    fi
    echo
    echo "Oracle client library files under common locations:"
    find /usr/lib/oracle /opt/oracle /usr/local/lib -maxdepth 5 \
        -type f \( -name 'libclntsh.so*' -o -name 'libnnz*.so' -o -name 'libocci.so*' \) \
        -print 2>/dev/null | sort || true
} >> "$INVENTORY"

if command -v sqlplus >/dev/null 2>&1; then
    info "SQL*Plus found: $(command -v sqlplus)"
    sqlplus -version 2>&1 | head -2 || true
else
    warn "sqlplus is not installed/on PATH"
fi

cache_os_rpms() {
    [[ "$CACHE_OS_RPMS" == "1" ]] || { info "OS RPM caching skipped"; return 0; }
    command -v dnf >/dev/null 2>&1 || { warn "dnf not found; skipping RPM backup"; return 0; }
    command -v rpm >/dev/null 2>&1 || { warn "rpm not found; skipping RPM backup"; return 0; }

    log "Caching useful Oracle Linux RPMs for emergency recovery"

    if ! dnf download --help >/dev/null 2>&1; then
        if command -v sudo >/dev/null 2>&1; then
            info "Installing dnf-plugins-core so 'dnf download' is available"
            sudo dnf install -y dnf-plugins-core || { warn "Could not enable dnf download; skipping RPM backup"; return 0; }
        else
            warn "dnf download unavailable and sudo is not present; skipping RPM backup"
            return 0
        fi
    fi

    # Start with package owners for the actual Python interpreters and sqlplus.
    declare -A seen=()
    declare -a packages=()

    add_pkg() {
        local pkg=$1
        [[ -n "$pkg" ]] || return 0
        [[ -z "${seen[$pkg]:-}" ]] || return 0
        seen[$pkg]=1
        packages+=("$pkg")
    }

    add_owner() {
        local path=$1 pkg
        [[ -e "$path" ]] || return 0
        pkg=$(rpm -qf "$path" --qf '%{NAME}\n' 2>/dev/null || true)
        [[ -n "$pkg" ]] && add_pkg "$pkg"
    }

    for py in "${PYTHONS[@]}"; do
        add_owner "$(readlink -f "$py")"

        # Also try to stage version-specific companion RPMs when the distro
        # publishes them separately (for example python3.11-devel/pip).
        py_minor=$($py -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')
        for companion in             "$py_minor" "$py_minor-pip" "$py_minor-setuptools" "$py_minor-wheel"             "$py_minor-devel"; do
            if dnf -q list --installed "$companion" >/dev/null 2>&1 || dnf -q list --available "$companion" >/dev/null 2>&1; then
                add_pkg "$companion"
            fi
        done
    done
    command -v sqlplus >/dev/null 2>&1 && add_owner "$(readlink -f "$(command -v sqlplus)")"

    while IFS= read -r pkg; do
        [[ -n "$pkg" ]] && add_pkg "$pkg"
    done < <(rpm -qa --qf '%{NAME}\n' | grep '^oracle-instantclient' | sort -u || true)

    # Useful host-side recovery/build/debugging tools. Only add a name if dnf knows it.
    # dnf download --resolve --alldeps below also stages their RPM dependencies.
    for pkg in \
        python3 python3-pip python3-setuptools python3-wheel python3-devel python3-virtualenv \
        gcc gcc-c++ make pkgconf-pkg-config \
        libaio libnsl libnsl2 openssl-libs openssl-devel libffi-devel \
        unzip zip tar gzip bzip2 xz rsync \
        git curl wget jq which file lsof procps-ng iproute bind-utils net-tools nmap-ncat \
        findutils diffutils dnf-plugins-core; do
        if dnf -q list --installed "$pkg" >/dev/null 2>&1 || dnf -q list --available "$pkg" >/dev/null 2>&1; then
            add_pkg "$pkg"
        fi
    done

    info "Attempting to cache ${#packages[@]} RPM package families plus dependencies"
    for pkg in "${packages[@]}"; do
        info "RPM: $pkg"
        if ! dnf download --resolve --alldeps --destdir "$RPM_DIR" "$pkg"; then
            warn "Could not cache RPM '$pkg'; continuing"
        fi
    done

    local rpm_count
    rpm_count=$(find "$RPM_DIR" -maxdepth 1 -type f -name '*.rpm' | wc -l)
    info "RPM cache contains $rpm_count files"
}

cache_os_rpms

cat > "$RESTORE_SCRIPT" <<'RESTORE_EOF'
#!/usr/bin/env bash
# Rebuild a Flask app .venv using only the local Deep Sec backup cache.
set -Eeuo pipefail

APP_DIR=${1:-"$HOME/flask-app"}
OFFLINE_ROOT=${OFFLINE_ROOT:-"$HOME/aiworld-offline/flask-python"}
PYTHON_BIN=${PYTHON_BIN:-python3}

command -v "$PYTHON_BIN" >/dev/null 2>&1 || { echo "ERROR: $PYTHON_BIN not found" >&2; exit 1; }
[[ -d "$APP_DIR" ]] || { echo "ERROR: App directory not found: $APP_DIR" >&2; exit 1; }

PYVER=$($PYTHON_BIN -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
TAG="py${PYVER}"
WHEELHOUSE="$OFFLINE_ROOT/wheelhouse/$TAG"
LOCK_FILE="$OFFLINE_ROOT/locks/requirements-${TAG}.lock.txt"
CORE_REQ="$OFFLINE_ROOT/requirements.deepsec-app.txt"

[[ -d "$WHEELHOUSE" ]] || { echo "ERROR: No wheelhouse for $TAG: $WHEELHOUSE" >&2; exit 1; }
[[ -f "$LOCK_FILE" ]] || { echo "ERROR: No lock file for $TAG: $LOCK_FILE" >&2; exit 1; }

rm -rf "$APP_DIR/.venv"
"$PYTHON_BIN" -m venv "$APP_DIR/.venv"
PY="$APP_DIR/.venv/bin/python"

# Prefer the downloaded app's own requirements.txt so a later app revision can
# use any cached safety-net packages. Fall back to the known-good lock file.
if [[ -f "$APP_DIR/requirements.txt" ]]; then
    echo "Installing from app requirements.txt with NO PyPI access"
    "$PY" -m pip install --no-index --find-links="$WHEELHOUSE" -r "$APP_DIR/requirements.txt"
else
    echo "No app requirements.txt found; installing known-good Deep Sec lock"
    "$PY" -m pip install --no-index --find-links="$WHEELHOUSE" -r "$LOCK_FILE"
fi
"$PY" -m pip check

echo "Offline Flask venv ready: $APP_DIR/.venv"
echo "Python: $($PY --version 2>&1)"
echo "Wheelhouse: $WHEELHOUSE"
RESTORE_EOF
chmod 755 "$RESTORE_SCRIPT"

log "Writing integrity manifest"
(
    cd "$OFFLINE_ROOT"
    find wheelhouse rpms locks -type f \( -name '*.whl' -o -name '*.rpm' -o -name '*.txt' \) -print0 \
      | sort -z \
      | xargs -0 -r sha256sum
    sha256sum "$(basename "$CORE_REQ")" "$(basename "$EXTRA_REQ")" "$(basename "$INVENTORY")" "$(basename "$RESTORE_SCRIPT")"
) > "$MANIFEST"

log "Final integrity verification"
(
    cd "$OFFLINE_ROOT"
    sha256sum -c "$(basename "$MANIFEST")"
)

cat <<SUMMARY

SUCCESS: Deep Sec Flask emergency offline backup is ready.

No Flask app was required to build this cache.

Offline root:
  $OFFLINE_ROOT

Core app requirements:
  $CORE_REQ

Per-Python wheelhouses:
  $WHEEL_BASE

Per-Python exact lock files:
  $LOCK_DIR

Optional safety-net package list:
  $EXTRA_REQ

The safety net now includes common Flask extensions, PyYAML, pytest/pytest-flask,
psutil, rich, watchdog, HTTP/validation helpers, and packaging recovery tools.

OS RPM backup:
  $RPM_DIR

Host inventory:
  $INVENTORY

Offline recovery helper:
  $RESTORE_SCRIPT

Later, after a Flask app exists, rebuild its .venv with:
  bash $RESTORE_SCRIPT /path/to/flask-app

To force a specific interpreter during recovery:
  PYTHON_BIN=python3.11 bash $RESTORE_SCRIPT /path/to/flask-app

Notes:
  * The CURRENT lab app dependency set is fully installed and tested offline with --no-index.
  * Safety-net packages are cached but are not forced into the app environment.
  * Oracle Instant Client is not a PyPI package. The script tests Thick mode when possible,
    inventories client libraries, and attempts to cache the installed Instant Client / SQL*Plus RPMs.
  * RPM backup includes common network/debug/archive tools and Python native-build prerequisites,
    downloaded with dependency resolution when the configured Oracle Linux repositories provide them.
  * host-inventory.txt includes the complete installed RPM list and pip compatibility diagnostics.
  * No cache can predict every package an AI coding agent might add. Add extra candidates with:
      EXTRA_PACKAGES="package1 package2" ./prepare_deepsec_offline_backup_v3.sh
SUMMARY
