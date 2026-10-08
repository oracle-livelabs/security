# Deep Sec Local GenAI maintainer handoff

This document is the maintainer inventory for the Deep Sec Local GenAI lab.
It is written for someone who has not worked on the lab before and for a fresh
Codex installation. The supported path is GreenButton.

## Executive summary

The lab has a good content boundary already: the Admin Console loads a lesson
pack from YAML, executes checked-in SQL, and uses a small explicit Python
handler registry for interactive behavior. Content authors can change most
lesson wording and SQL without editing Flask routes.

The handoff is not yet simple because the checkout contains several historical
deployment families, the VM image and offline wheelhouse are maintained outside
this repository, and generated packages can become stale relative to source.

The most important release rule is:

```text
Build the application ZIP first, then the Terraform ZIP, then verify that the
application ZIP embedded in the Terraform ZIP has the same checksum as the
standalone application ZIP.
```

The current audit found that the standalone GreenButton application ZIP contains
the current `greenbutton-files/flask-app/ai.py`, while the existing deployable
Terraform ZIP embeds an older application ZIP. Both archives pass ZIP integrity
tests, but the deployable package is not current. Do not use that Terraform ZIP
as a release artifact without rebuilding it.

## Supported runtime flow

```text
greenbutton-files/
  -> build_greenbutton_app_zip.sh
  -> build_greenbutton_terraform_zip.sh
  -> deep-sec-local-genai-terraform-GreenButton.zip
  -> OCI Resource Manager stack, working directory terraform
  -> ADB + Compute + Object Storage + network + bootstrap
  -> Admin Console, Customer Sales App, and JupyterLab
```

Resource Manager officially supports creating a stack from a local Terraform
ZIP and selecting the working directory:
<https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-local.htm>

GreenButton creates the ADB, a Compute application server, private Object
Storage, the Iceberg sample destination, network resources, and bootstrap
configuration. Apply waits for the VM bootstrap health gate. The application
outputs are:

- Admin Console: port `7778`
- Customer Sales App: port `7777`
- JupyterLab: port `8888`

## Source inventory

| Area | Active source | Maintainer responsibility |
| --- | --- | --- |
| Lesson content | `greenbutton-files/admin-app/content/deep_data_security/` | Edit `lab.yaml`, executable SQL, display SQL, and lesson assets. |
| Content engine | `greenbutton-files/admin-app/content_loader.py`, `content_runtime.py` | Change only when the content contract or runtime model changes. |
| Admin Console | `greenbutton-files/admin-app/admin_app.py`, templates, static files | Login, SQL*Plus execution, state, downloads, handlers, and UI behavior. |
| Interactive grant wizard | `greenbutton-files/admin-app/handlers/data_grant.py` | Safe, allow-listed SQL generation. Keep browser input separate from SQL. |
| Customer Sales App | `greenbutton-files/flask-app/` | Local end-user login, customer queries, AI Insights, and Vibe execution. |
| Database/bootstrap setup | `greenbutton-files/setup/` | Database rebuild, Iceberg materialization, ACLs, and installer scripts. |
| Infrastructure | `terraform-greenbutton/` | ADB, Compute, network, Object Storage, PARs, IAM, outputs, and cloud-init. |
| Packages | `build_greenbutton_*.sh`, `dist/`, Terraform artifacts | Rebuild in dependency order and verify embedded contents. |
| VM image contract | `IMAGE-CONTRACT.md` | Keep image, wheelhouse, system tools, and owner information current. |

The lesson currently contains 10 pages, 41 steps, 42 actions, and 33 SQL
scripts. The content validator is the source of truth for those counts.

## Requirements to run the lab

### OCI requirements

The operator needs:

- an isolated, non-production OCI compartment;
- permission to create or use the Resource Manager stack inputs;
- ADB, Compute, VCN, subnet, Object Storage, public IP, and PAR quota;
- access to the supplied Compute image in the selected region;
- an SSH public key;
- an identity-domain username and matching OCI Auth Token for the ADB
  `DBMS_CLOUD` Iceberg reader;
- a trusted ingress IPv4 address or CIDR;
- an existing shared dynamic group and policy for GenAI, or permission and
  quota to create one with `create_genai_iam`.

The Auth Token must be entered as a sensitive Resource Manager value. It must
not be placed in source control, `terraform.tfvars`, output files, ZIPs, or
the VM image.

The Stack creates a private Stack-owned Iceberg bucket and uses the checked-in
sample. It does not require a user-owned bucket, Customer Secret Keys, manual
uploads, Spark, Data Flow, or a Hadoop catalog on the normal GreenButton path.

### Custom image requirements

The image is an external runtime dependency. It must provide:

- `/usr/bin/python3` compatible with the staged Python 3.9 wheelhouse;
- Python `venv` support;
- `/opt/deep-sec-offline/wheelhouse/py3.9`;
- the application dependencies plus `fastavro`, `pyiceberg` with the required
  PyArrow and SQLite extras, and `tomli`;
- `unzip`, `curl`, `wget`, and `openssl`;
- SQL*Plus and Oracle Instant Client;
- systemd and the preinstalled JupyterLab service expected by the bootstrap;
- the network and operating-system behavior documented in `IMAGE-CONTRACT.md`.

The application ZIP contains source and `vibe-cli.zip`; it does not contain the
large wheelhouse. The offline runtime is documented in
`greenbutton-files/offline/README.md`.

### Local maintainer requirements

For content-only work, the maintainer needs:

- Bash;
- Python 3 with PyYAML for content validation and the standard-library tests;
- `zip`, `unzip`, `sha256sum`, `find`, and `xargs`;
- Terraform for formatting and optional validation.

For application or live work, use the application requirements in
`greenbutton-files/admin-app/requirements.txt` and
`greenbutton-files/flask-app/requirements.txt`, plus SQL*Plus and a live
database connection. A local live database is not required to edit lesson
content or run the content tests.

## Edit map

### Content-only update

Edit:

- `greenbutton-files/admin-app/content/deep_data_security/lab.yaml`
- `greenbutton-files/admin-app/content/deep_data_security/database/*.sql`
- matching `*.display.sql` files
- lesson images under `greenbutton-files/admin-app/static/images/`

Run:

```bash
cd greenbutton-files/admin-app
python3 validate_content.py
python3 -m unittest discover -s tests -q
```

Do not add Python imports, shell commands, passwords, wallet material, or
arbitrary executable SQL to YAML. New interactive behavior belongs in a
reviewed handler and its tests.

### Application behavior update

Edit the relevant files under `greenbutton-files/admin-app/` or
`greenbutton-files/flask-app/`. Run the content tests plus Python compilation,
then rebuild both release archives before claiming that the deployed package
contains the change.

### Infrastructure or bootstrap update

Edit `terraform-greenbutton/`, `greenbutton-files/setup/`, or the active
cloud-init template. Run Terraform formatting and validation, rebuild the
archives, inspect the exact plan, and live-test only an explicitly authorized
stack.

### Documentation-only update

Keep learner-facing workshop copy separate from maintainer instructions. Do not
change deployment artifacts for prose-only changes.

## Local validation and packaging

Run the following from the lab root for a normal source check:

```bash
cd greenbutton-files/admin-app
python3 validate_content.py
python3 -m unittest discover -s tests -q
cd ../..
terraform fmt -check -recursive terraform-greenbutton
find . -type f -name '*.sh' -not -path './archive/*' -print0 \
  | xargs -0 -r -n1 bash -n
```

Run `terraform validate` from `terraform-greenbutton/` when Terraform has been
initialized locally. A fresh clone may need provider initialization; that is
not required for a content-only change.

Build only when a package is needed:

```bash
bash build_greenbutton_app_zip.sh
bash build_greenbutton_terraform_zip.sh
unzip -tq dist/deep-data-security-flask-app-GreenButton.zip
unzip -tq deep-sec-local-genai-terraform-GreenButton.zip
```

The Terraform builder currently updates `dist/` and
`terraform-greenbutton/artifacts/`. Inspect the diff and do not stage unrelated
generated changes. The eventual release wrapper should build in a temporary
staging area and compare the embedded application checksum automatically.

## Live verification gates

Static checks do not establish learner readiness. Before a release is called
usable, verify all of the following:

1. Resource Manager target stack and compartment are correct.
2. Plan completed successfully and Apply used that reviewed plan.
3. `/var/lib/deep-sec/bootstrap-status` contains `COMPLETE`.
4. `/var/log/deep-sec-bootstrap.log` contains successful database, Iceberg,
   application, and health phases.
5. `deep-sec-admin-console.service` and
   `deep-sec-customer-sales.service` are active.
6. Admin Console, Customer Sales App, and JupyterLab return HTTP 200 from the
   trusted ingress network.
7. The Admin Console can prepare and reset the database.
8. The Customer Sales App demonstrates different authorized results for Marvin
   and Emma.
9. The Iceberg external table reads a real row from Object Storage.
10. Customer Insights and the Vibe/red-team flow reach OCI Generative AI and
    remain subject to Oracle authorization.
11. Destroy removes the Stack-owned bucket objects, PARs, and other resources.

Useful VM commands are emitted by Terraform, including:

```bash
sudo /usr/local/sbin/deep-sec-status
sudo cat /var/lib/deep-sec/bootstrap-status
sudo tail -n 200 /var/log/deep-sec-bootstrap.log
sudo systemctl status deep-sec-admin-console.service --no-pager -l
sudo systemctl status deep-sec-customer-sales.service --no-pager -l
```

## Current simplification backlog

### Priority 0: release correctness

- Add a single release command that builds app first and Terraform second.
- Compare the standalone and embedded application ZIP checksums.
- Do not treat `unzip -tq` as proof that a package matches source.
- Make generated artifact ownership and staging explicit.

### Priority 1: reduce maintainer choices

- Make GreenButton the only active deployment path in the normal directory.
- Move Marketplace, old wallet, NO-IAM, FREE, Data Flow, and historical
  provider binaries out of the default maintainer path.
- Retire or clearly label `terraform-greenbutton-MMALCHER`, which is a near
  duplicate of the canonical GreenButton tree.
- Add a `doctor` command that checks tools, required files, image assumptions,
  package freshness, and safe archive members.
- Add an owner and versioned checksum to `IMAGE-CONTRACT.md`.

### Priority 2: fail earlier and document boundaries

- Add Terraform validation for the required Iceberg username and Auth Token.
- Require an explicit ingress CIDR or make the open default an intentional,
  separately confirmed choice.
- Split the large cloud-init template into reviewable bootstrap phases when
  there is a functional reason to touch it.
- Keep `lab.yaml` as the content boundary for now. Split prose into Markdown
  page packs incrementally only when the single manifest becomes a real editing
  problem.

## Fresh Codex workflow

Codex should be started in this directory so it loads this file and the local
`AGENTS.md` instructions. The first task should be read-only:

```text
Read AGENTS.md, HANDOFF.md, IMAGE-CONTRACT.md, README.md, and the active
GreenButton source. Inspect the worktree, run the local validation commands,
and report the exact files needed for the requested change. Do not deploy,
publish, destroy, rebuild archives, or modify unrelated dirty files.
```

For future work, ask Codex to classify the change first:

- content-only;
- application behavior;
- Terraform/bootstrap/image;
- package/release;
- live OCI operation.

Each class has a different validation boundary. Codex should not infer live
readiness from static checks, and it should not infer authorization, quota, or
deployment success from a source file or a launched OCI job.

## Official references

- Resource Manager ZIP stacks: <https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-local.htm>
- Deep Data Security data grants: <https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/create-data-grants.html>
- `CREATE DATA GRANT`: <https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/create-data-grant.html>
- `DBMS_CLOUD` and Iceberg external tables: <https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-subprograms.html>
- Generative AI IAM policies: <https://docs.oracle.com/en-us/iaas/Content/generative-ai/iam-policies.htm>
- Codex project instructions: <https://developers.openai.com/es-419/docs/agent-configuration/agents-md>
- Codex CLI: <https://developers.openai.com/es-419/docs/codex/cli>

## Handoff status

This document records the source and static-validation state inspected on
2026-09-18. It is not a live deployment certificate. Before using a new
release, refresh the package checksums, image contract, OCI stack identity,
bootstrap logs, application endpoints, and database/GenAI behavior.
