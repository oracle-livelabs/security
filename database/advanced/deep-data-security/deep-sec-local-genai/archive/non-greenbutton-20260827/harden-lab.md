I need you to harden this AI World hands-on lab against unreliable or unavailable Internet access.

The normal lab experience must remain unchanged: students should attempt the normal remote downloads and normal installs first. Offline resources are strictly an emergency fallback.

Do not make the lab normally run offline and do not bundle large wheelhouses into the Flask application ZIP or Vibe CLI ZIP. The offline caches live separately on the prebuilt Oracle Linux/Jupyter host under `/home/opc/aiworld-offline`.

Inspect the repository and existing files before changing anything. Preserve the existing architecture and naming wherever possible.

# Goal

A student should be able to complete the lab if:

* the Flask application Object Storage download fails;
* PyPI is unavailable while creating the Flask virtual environment;
* the Vibe CLI Object Storage download fails;
* PyPI is unavailable while installing Vibe;
* common Python packages need to be reconstructed;
* common Oracle Linux packages need recovery;
* a virtual environment is accidentally deleted or corrupted.

The fallback must be explicit, simple, and tested.

---

# 1. Update the lab markdown

The primary lab markdown currently contains these network-sensitive steps:

* Task 0: download `deep-sec-local-genai-terraform.zip`
* Task 1: download `deep-data-security-flask-app.zip`
* Task 1: run `bash setup_venv.sh`
* Task 7: download `vibe-cli.zip`
* Task 7: run `./install.sh --overwrite-config`

Update the markdown as follows.

## Add one connectivity note after Prerequisites

Add a concise note explaining:

* the lab normally downloads the starter application and Vibe during the exercises;
* the supplied application-server image contains emergency offline recovery assets;
* students should use a fallback only if the corresponding normal download or package installation fails;
* the wallet is NOT included in the offline cache and still comes from the provisioned Autonomous Database.

Do not make the lab sound as though offline mode is the normal path.

## Task 0 Terraform ZIP

Immediately after the Terraform ZIP download instruction, add a short fallback:

If the download is unavailable, use the `deep-sec-local-genai-terraform.zip` supplied with the workshop materials and upload it unchanged to OCI Resource Manager.

Do NOT point Task 0 to `/home/opc/aiworld-offline`, because the compute host does not exist yet at this point.

## Task 1 Flask application ZIP

Immediately after the normal:

```bash
wget -O deep-data-security-flask-app.zip ...
```

add a clearly labeled fallback.

Use:

```bash
cp /home/opc/aiworld-offline/apps/deep-data-security-flask-app.zip \
   deep-data-security-flask-app.zip
```

Then tell the student to continue with the existing `unzip` command.

Do not duplicate subsequent instructions.

## Task 1 Python / PyPI failure

Immediately after:

```bash
bash setup_venv.sh
```

add a fallback for failed Python dependency installation.

The emergency command should be:

```bash
/home/opc/aiworld-offline/flask-python/install_flask_venv_offline.sh \
    "$HOME/deep-sec-lab/flask-app"
```

Then continue with:

```bash
bash verify_app_server.sh
```

Explain briefly that this creates the application's `.venv` using only packages cached on the lab host.

## Task 7 Vibe ZIP

Immediately after:

```bash
wget -O vibe-cli.zip ...
```

add a fallback:

```bash
cp /home/opc/aiworld-offline/installers/vibe-cli.zip \
   vibe-cli.zip
```

Then continue with the existing `mkdir` and `unzip` commands.

## Task 7 Vibe dependency installation

Immediately after:

```bash
./install.sh --overwrite-config
```

add a short fallback explaining what to do if the installer reports that Python dependency retrieval failed.

Use the actual Vibe offline recovery command implemented in this work. Do not invent a command that does not exist.

## Do not add repetitive warnings

Do not add Internet warnings to Tasks 2–6 or Task 8 unless a command in those sections actually makes a new remote network download.

Keep the lab clean.

---

# 2. Harden the Flask application package

Find the source directory used to create:

```text
deep-data-security-flask-app.zip
```

Inspect:

* `requirements.txt`
* `setup_venv.sh`
* `verify_app_server.sh`
* `configure_env.sh`
* `run.sh`
* related Python code

The application's currently known direct Python dependencies include:

```text
Flask
Bootstrap-Flask
Flask-WTF
Flask-Login
flask-htmx
python-dotenv
oracledb
gunicorn
requests
oci
```

Do not remove legitimate existing dependencies.

## setup_venv.sh behavior

Normal behavior must remain:

1. use `PYTHON_BIN` if set, otherwise `python3`;
2. create `.venv`;
3. attempt the normal online pip installation.

If the online package installation fails:

1. detect whether the host recovery cache exists;
2. clearly print that the normal install failed and an offline retry is being attempted;
3. retry using the local wheelhouse only;
4. use `--no-index`;
5. use the wheelhouse matching the active Python major/minor version;
6. fail with a clear actionable error if no compatible local cache exists.

Expected cache structure:

```text
/home/opc/aiworld-offline/flask-python/
    wheelhouse/
        py3.9/
        py3.11/
        ...
    locks/
    install_flask_venv_offline.sh
```

Do not silently change Python versions.

Do not silently fall back to a different interpreter.

If Python 3.11 is being used, use Python 3.11-compatible wheels.

If Python 3.9 is being used, use Python 3.9-compatible wheels.

The script must remain usable on machines that do not have `/home/opc/aiworld-offline`; those machines should simply use the existing normal online behavior.

## verify_app_server.sh

Make sure it reports enough information to troubleshoot a workshop machine:

* Python executable
* Python version
* pip version
* `.venv` existence
* Flask import
* python-oracledb import and version
* whether python-oracledb Thick mode can initialize
* SQL*Plus availability
* Oracle Instant Client availability
* `TNS_ADMIN` when configured

Do not expose passwords or wallet secrets.

A successful online or offline setup should pass the same verification.

---

# 3. Harden Vibe CLI

Find the source used to build `vibe-cli.zip`.

Inspect:

* `install.sh`
* `requirements.txt`
* package/module layout
* launcher creation
* configuration handling

Normal Vibe installation must continue trying its normal Internet/PyPI path first.

If pip dependency installation fails, add an automatic emergency fallback to the host cache.

Use a dedicated cache such as:

```text
/home/opc/aiworld-offline/vibe-python/
    wheelhouse/
        py3.9/
        py3.11/
        ...
    locks/
```

Do not use the Flask cache as the canonical Vibe dependency cache, even if some packages overlap.

The Vibe installer should:

1. create its venv normally;
2. attempt normal dependency installation;
3. if that fails, determine the current Python major/minor version;
4. look for the matching Vibe wheelhouse;
5. retry with:

```text
--no-index
--find-links=<matching local wheelhouse>
```

6. clearly report whether the online or offline path succeeded;
7. fail cleanly if neither is available.

Do not change Vibe's project-root behavior, OCI GenAI behavior, instance-principal behavior, backup behavior, or lab-context behavior unless required for this recovery work.

---

# 4. Extend the golden-image preparation script

Locate the standalone offline preparation script we created.

The desired script should require NO Flask application directory argument.

It should identify itself clearly at startup, for example:

```text
Deep Sec offline backup preparer
No Flask app directory is required.
```

Use:

```text
/home/opc/aiworld-offline
```

as the recovery root.

The script should build the following structure:

```text
/home/opc/aiworld-offline/
├── apps/
│   └── deep-data-security-flask-app.zip
│
├── installers/
│   └── vibe-cli.zip
│
├── flask-python/
│   ├── wheelhouse/
│   │   ├── py3.9/
│   │   ├── py3.11/
│   │   └── ...
│   ├── locks/
│   ├── requirements.deepsec-app.txt
│   ├── requirements.safety-net.txt
│   ├── install_flask_venv_offline.sh
│   └── host-inventory.txt
│
├── vibe-python/
│   ├── wheelhouse/
│   │   ├── py3.9/
│   │   ├── py3.11/
│   │   └── ...
│   ├── locks/
│   └── install_vibe_venv_offline.sh
│
├── rpms/
│
└── SHA256SUMS
```

Adjust the exact organization if the existing script already has a sound equivalent, but keep Flask and Vibe recovery logically separate.

---

# 5. Cache the actual application ZIP

While Internet connectivity is good, download the exact Flask application ZIP used by the markdown into:

```text
/home/opc/aiworld-offline/apps/deep-data-security-flask-app.zip
```

Use the same canonical URL that appears in the lab markdown.

Do not make the student download this backup during the lab.

Verify after download:

* file exists;
* file is non-empty;
* `unzip -t` succeeds;
* expected application files exist inside the ZIP.

At minimum verify expected content such as:

```text
requirements.txt
setup_venv.sh
verify_app_server.sh
configure_env.sh
run.sh
```

Use the actual ZIP layout when checking paths.

Calculate a SHA-256 checksum.

---

# 6. Cache the actual Vibe ZIP

While Internet connectivity is good, download the exact Vibe ZIP used by Task 7 into:

```text
/home/opc/aiworld-offline/installers/vibe-cli.zip
```

Use the same canonical URL in the markdown.

Verify:

* file exists;
* file is non-empty;
* `unzip -t` succeeds;
* `install.sh` exists;
* `requirements.txt` exists if Vibe still uses one;
* expected `vibe_agent` modules exist.

Calculate a SHA-256 checksum.

---

# 7. Flask Python emergency wheelhouse

Build a local wheelhouse for every Python interpreter on the golden host that we reasonably expect the lab to use.

At minimum inspect:

```text
python3
python3.11
```

Do not assume both exist.

For each interpreter that exists:

* determine exact major/minor version;
* verify `venv`;
* verify `ensurepip`;
* create an isolated temporary venv;
* download/build all Flask application dependencies;
* include transitive dependencies;
* cache `pip`, `setuptools`, `wheel`, and `virtualenv`;
* generate an exact lock file;
* perform a completely offline test installation with `--no-index`;
* run `pip check`;
* import the core application modules.

Include the known application dependency set:

```text
Flask
Bootstrap-Flask
Flask-WTF
Flask-Login
flask-htmx
python-dotenv
oracledb
gunicorn
requests
oci
```

Also include this safety-net set:

```text
Flask-Cors
Flask-Session
Flask-SQLAlchemy
SQLAlchemy
waitress

httpx
pydantic
pydantic-settings
PyYAML

pytest
pytest-flask
psutil
rich
watchdog

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
```

The safety-net packages are backups only. Do not add them all to the Flask application's `requirements.txt`.

Support an optional environment variable such as:

```bash
EXTRA_PACKAGES="package1 package2"
```

for additional packages when building the golden image.

---

# 8. Vibe Python emergency wheelhouse

Inspect Vibe's real `requirements.txt`.

Build a separate local wheelhouse containing:

* every direct Vibe dependency;
* every transitive dependency;
* pip;
* setuptools;
* wheel;
* virtualenv if useful.

Generate exact lock files per Python version.

Test a completely fresh Vibe venv using:

```text
pip install --no-index --find-links=...
```

Run:

```text
pip check
```

and import the primary Vibe modules.

If a Vibe CLI help/status command can safely run without contacting OCI GenAI, run that as part of validation.

Do not require a GenAI network call to validate the local Python environment.

---

# 9. Cache Oracle Linux RPM recovery packages

Where `dnf download` is available, use dependency resolution:

```bash
dnf download --resolve --alldeps ...
```

Cache useful recovery packages and their dependencies.

Include available packages from these categories:

## Basic tools

```text
curl
wget
git
zip
unzip
tar
gzip
bzip2
xz
jq
rsync
file
which
findutils
diffutils
```

## Troubleshooting

```text
lsof
procps-ng
iproute
bind-utils
net-tools
nmap-ncat
```

## Build fallback

```text
gcc
gcc-c++
make
pkgconf-pkg-config
openssl-devel
libffi-devel
python3-devel
```

Also detect version-specific Python packages where appropriate, for example:

```text
python3.11
python3.11-pip
python3.11-setuptools
python3.11-wheel
python3.11-devel
```

Only request packages that exist in configured repositories.

Missing optional packages should generate warnings rather than abort the entire cache build.

## Oracle

Cache installed/repository-available dependencies relevant to the installed Oracle client, including:

```text
libaio
libnsl
libnsl2
```

Detect installed Oracle Instant Client RPMs rather than guessing version numbers.

Preserve/cache the installed:

* Oracle Instant Client Basic package
* SQL*Plus package
* other Instant Client packages already present and useful

Do not package an ADB wallet into this recovery directory.

---

# 10. Host inventory

Generate:

```text
/home/opc/aiworld-offline/host-inventory.txt
```

or an equivalent inventory file.

Include:

```bash
date
uname -a
cat /etc/os-release
rpm -qa | sort
```

For each relevant Python interpreter:

```text
executable path
Python version
pip version
ensurepip status
venv test
pip debug --verbose
compatible wheel tags
```

Also inventory:

```text
sqlplus -v
tnsping availability
Oracle Instant Client RPMs
libclntsh locations
TNS_ADMIN path if set
```

Do not print wallet contents or passwords.

Inventory command availability for:

```text
curl
wget
git
zip
unzip
jq
rsync
lsof
gcc
make
```

---

# 11. Recovery helpers

Generate and test:

```text
/home/opc/aiworld-offline/flask-python/install_flask_venv_offline.sh
```

Usage:

```bash
install_flask_venv_offline.sh /path/to/flask-app
```

It must:

* require an application directory;
* detect Python version;
* select compatible wheelhouse;
* remove/recreate `.venv` safely;
* prefer the application's own `requirements.txt`;
* install using `--no-index`;
* run `pip check`;
* verify important imports;
* return a nonzero status on failure.

Also generate:

```text
/home/opc/aiworld-offline/vibe-python/install_vibe_venv_offline.sh
```

with equivalent behavior for Vibe.

These recovery helpers ARE allowed to require an extracted application/Vibe directory.

The main golden-image preparation script must NOT require either directory.

---

# 12. ZIP packaging hygiene

When rebuilding the Flask ZIP and Vibe ZIP, ensure they do not accidentally contain:

```text
.venv/
__pycache__/
*.pyc
.git/
wallet files
ADB credentials
.env files containing secrets
logs
trace files
backups
temporary files
```

Preserve required executable permissions for shell scripts.

Run shell syntax checks where relevant:

```bash
bash -n script.sh
```

Run:

```bash
unzip -t
```

against final ZIPs.

Confirm their directory layout matches what the lab markdown expects after extraction.

---

# 13. End-to-end acceptance tests

Before declaring this complete, perform and report these tests.

## Flask normal path

From a clean extracted Flask ZIP:

* create `.venv`;
* install normally;
* verify application dependencies.

## Flask forced-offline path

From another clean extracted Flask ZIP:

* simulate no PyPI with `PIP_NO_INDEX=1` or directly invoke the offline helper;
* create a completely new `.venv`;
* install only from `/home/opc/aiworld-offline`;
* run `pip check`;
* run application import verification.

No package may be satisfied by an already populated test venv.

## Flask ZIP recovery

Delete the working application ZIP.

Restore it only with:

```bash
cp /home/opc/aiworld-offline/apps/deep-data-security-flask-app.zip .
```

Run `unzip -t` and extract it successfully.

## Vibe normal path

From a clean extracted Vibe ZIP:

* run normal installation;
* verify CLI/module installation.

## Vibe forced-offline path

From another clean extracted Vibe ZIP:

* prevent PyPI use;
* install into a new venv using only the Vibe wheelhouse;
* run `pip check`;
* verify imports;
* verify a non-GenAI help/status command if possible.

## Vibe ZIP recovery

Restore only from:

```bash
cp /home/opc/aiworld-offline/installers/vibe-cli.zip .
```

Validate and extract successfully.

## Oracle Python

Verify:

```python
import oracledb
oracledb.init_oracle_client()
```

Report whether Thick mode initialized successfully.

Do not require an ADB password for this library-loading test.

---

# 14. Checksums

Generate:

```text
/home/opc/aiworld-offline/SHA256SUMS
```

Include:

* cached Flask ZIP;
* cached Vibe ZIP;
* Python wheels;
* lock files;
* important recovery scripts;
* RPMs where practical.

Provide a simple verification command, preferably:

```bash
sha256sum -c SHA256SUMS
```

from the correct directory.

---

# 15. Error-handling philosophy

This is a 60-minute hands-on lab.

Prefer actionable messages such as:

```text
Normal PyPI installation failed.
Trying the AI World offline package cache...
```

and:

```text
No offline cache exists for Python 3.11.
Expected:
  /home/opc/aiworld-offline/flask-python/wheelhouse/py3.11
```

Do not dump unnecessary stack traces at students for expected recovery conditions.

Do not hide the original error entirely; preserve enough information for an instructor to diagnose it.

---

# 16. Do not weaken security

Do NOT:

* place ADMIN passwords in scripts;
* cache Marvin's password;
* cache the Autonomous Database wallet;
* weaken file permissions on wallet/config files;
* change the Deep Data Security model;
* bypass database authorization;
* add an application-side privileged database account as a recovery mechanism.

Offline recovery is for software dependencies and downloadable artifacts only.

---

# 17. Final report

When finished, give me:

1. every file changed;
2. every file added;
3. the final offline directory structure;
4. exact commands I run on the golden Jupyter host before cloning it;
5. the expected success output;
6. all end-to-end tests you performed;
7. anything that still requires Internet access;
8. any artifact that I must manually supply outside the compute image;
9. SHA-256 checksums for the final Flask and Vibe ZIPs.

Do not merely propose changes. Implement them and test them.

