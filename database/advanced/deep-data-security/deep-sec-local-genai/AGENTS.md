# Deep Sec Local GenAI maintenance instructions

These instructions apply to `database/advanced/deep-data-security/deep-sec-local-genai`.

## Scope

- `greenbutton-files/` and `terraform-greenbutton/` are the active GreenButton source.
- GreenButton is the supported deployment path. Treat Marketplace, old wallet,
  NO-IAM, FREE, Data Flow, and other archived paths as historical unless the
  user explicitly asks for one of them.
- Work only in this lab directory unless the user explicitly expands the scope.
- Inspect the existing worktree before editing. Preserve unrelated dirty changes.
- Do not push, publish a PAR, upload an archive, apply or destroy an OCI stack,
  or change a live host unless the user explicitly authorizes that action.

## Edit map

- Learner wording, page order, steps, actions, notes, quizzes, and lesson
  configuration: `greenbutton-files/admin-app/content/deep_data_security/lab.yaml`.
- Executable SQL: `greenbutton-files/admin-app/content/deep_data_security/database/*.sql`.
- Learner-display SQL: matching `*.display.sql` files.
- Admin Console behavior: `greenbutton-files/admin-app/` Python, templates,
  JavaScript, and CSS.
- Customer Sales App and GenAI behavior: `greenbutton-files/flask-app/`.
- Bootstrap, Iceberg materialization, and VM installers: `greenbutton-files/setup/`
  and the active Terraform cloud-init template.
- OCI resources and Resource Manager inputs: `terraform-greenbutton/`.

Content-only changes should remain content-only. Do not move SQL into Python,
add arbitrary code to YAML, or describe MCP, IAM, Iceberg, or GenAI behavior
without checking the active source and the linked Oracle documentation.

## Local validation

From `greenbutton-files/admin-app/`:

```bash
python3 validate_content.py
python3 -m unittest discover -s tests -q
```

From the lab root:

```bash
terraform fmt -check -recursive terraform-greenbutton
find . -type f -name '*.sh' -not -path './archive/*' -print0 \
  | xargs -0 -r -n1 bash -n
```

Run `terraform validate` from `terraform-greenbutton/` when Terraform is
initialized locally. A fresh clone may need Terraform provider initialization;
do not do that for a content-only change unless it is useful for the requested
verification.

## Packaging

Build in this order because the Terraform archive embeds the application ZIP:

```bash
bash build_greenbutton_app_zip.sh
bash build_greenbutton_terraform_zip.sh
```

Before declaring a package current, verify both ZIPs with `unzip -tq` and
compare the standalone application ZIP with the application ZIP embedded in
`deep-sec-local-genai-terraform-GreenButton.zip`. A successful ZIP test does
not prove that the embedded application matches source.

Do not rebuild archives merely to validate prose or SQL unless the user asks
for a release artifact. The builders currently update generated files under
`dist/` and `terraform-greenbutton/artifacts/`; inspect the diff before staging.

## Runtime boundary

Static validation does not establish learner readiness. A live release requires
the supplied custom image, its Python 3.9 offline wheelhouse, SQL*Plus and
Oracle Instant Client, an accessible Compute image, OCI quotas and permissions,
an identity-domain Auth Token for the ADB Iceberg reader, and GenAI IAM access.
See `HANDOFF.md` and `IMAGE-CONTRACT.md`.

The GreenButton ingress default is currently `0.0.0.0/0`; treat that as an
explicit security decision and prefer an operator IPv4 address or trusted CIDR.
Never put Auth Tokens, wallets, `.env` files, Terraform state, or private keys
in source control or archives.

## Oracle references

- Resource Manager ZIP stacks: <https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-local.htm>
- Deep Data Security data grants: <https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/create-data-grants.html>
- `DBMS_CLOUD` and Iceberg external tables: <https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-subprograms.html>
- Generative AI IAM policies: <https://docs.oracle.com/en-us/iaas/Content/generative-ai/iam-policies.htm>
