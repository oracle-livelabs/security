# Deep Sec GreenButton

GreenButton is the canonical Deep Sec deployment and development path.

## Build

```bash
bash build_greenbutton_app_zip.sh
bash build_greenbutton_terraform_zip.sh
```

The deployable Terraform package is
`deep-sec-local-genai-terraform-GreenButton.zip`. Upload it to OCI Resource
Manager with `terraform` as the working directory. The application package is
embedded in that Terraform archive; do not upload a second application ZIP.

The active sources are:

- `greenbutton-files/` — isolated Flask, lesson-driven Admin Console, and setup files. Each lesson owns its SQL under `admin-app/content/<lesson>/database/`.
- `terraform-greenbutton/` — walletless-TLS OCI Resource Manager Stack.

For maintainers and a fresh Codex installation, start with
[HANDOFF.md](HANDOFF.md), [AGENTS.md](AGENTS.md), and
[IMAGE-CONTRACT.md](IMAGE-CONTRACT.md). They describe the runtime contract,
edit boundaries, validation gates, package freshness checks, and the external
Compute image dependency.

The former wallet-based, regular, NO-IAM, and FREE paths are preserved under
`archive/non-greenbutton-20260827/`. They are historical reference material,
not supported deployment inputs.

See [terraform-greenbutton/README.md](terraform-greenbutton/README.md) for the
complete Resource Manager deployment procedure, required inputs, bootstrap
verification, reset behavior, and the Stack-owned Iceberg bucket flow.

## Deploy the GreenButton Stack

1. Build the application and Terraform archives from this directory:

   ```bash
   bash build_greenbutton_app_zip.sh
   bash build_greenbutton_terraform_zip.sh
   ```

2. In OCI Resource Manager, choose **Create stack**, **My configuration**, and
   upload `deep-sec-local-genai-terraform-GreenButton.zip`. Set the working
   directory to `terraform`.
3. Enter the tenancy, target compartment, region, SSH public key, and the
   existing OCI Auth Token identity used by ADB to read Iceberg:
   `order_history_oci_username` in `<identity-domain>/<username>` form and
   `order_history_oci_auth_token` as a sensitive value.
4. Run **Plan**, review it, and then run **Apply**. Apply waits for the
   application VM bootstrap health gate.
5. Unlock the sensitive password in Application Information. Use the emitted
   Admin Console, Customer Sales App, JupyterLab, and SSH outputs.

The GreenButton path creates a private Stack-owned bucket and publishes the
checked-in Iceberg sample during bootstrap. It does not require a user-owned
bucket, Customer Secret Keys, manual Iceberg uploads, Spark, Data Flow, or a
Hadoop catalog.

## Deploy the Marketplace Stack

The Marketplace path uses the published Deep Sec machine image listing. It
keeps the same offline-safe application and database deployment, but its
Terraform configuration accepts the Marketplace agreement, creates the image
subscription in the target tenancy, and launches the application VM from the
published Marketplace image.

```bash
bash build_marketplace_app_zip.sh
bash build_marketplace_terraform_zip.sh
```

The deployable package is
`deep-sec-local-genai-terraform-Marketplace.zip`. Upload it to OCI Resource
Manager with `terraform` as the working directory. The target tenancy must be
allowed on the private Marketplace listing. Provide the package version
reference (`1.0` for the initial package); the stack resolves the consumer
image OCID (`mp_listing_resource_id`) after it creates the subscription. Do not
use the publisher artifact OCID.

See [terraform-marketplace/README.md](terraform-marketplace/README.md) for the
Marketplace subscription inputs and deployment procedure.
