# Deep Sec Marketplace OCI Resource Manager Stack

This is the Marketplace-image Deep Sec infrastructure path. It creates
walletless TLS Autonomous AI Database 26ai, an application VM from the
published Deep Sec Marketplace image, private Object Storage, network
resources, and a dedicated Stack-owned Iceberg bucket containing the
pre-created Order History data.

## Deploy

Build and deploy from the parent `deep-sec-local-genai` directory:

```bash
bash build_marketplace_app_zip.sh
bash build_marketplace_terraform_zip.sh
```

The second command creates `deep-sec-local-genai-terraform-Marketplace.zip`.
It embeds the application ZIP and the checked-in Iceberg sample, so Resource
Manager needs only this Terraform ZIP.

The published Marketplace image must pre-load the verified Python 3.9
wheelhouse at `/opt/deep-sec-offline/wheelhouse/py3.9`. When refreshing the
source image, stage it with `sudo env
OFFLINE_ROOT=/home/opc/aiworld-offline/flask-python
TARGET_ROOT=/opt/deep-sec-offline ./stage_marketplace_offline_wheelhouse.sh`.
The application ZIP includes the source and Vibe CLI archive, but not the
large wheelhouse. Cloud-init installs every Python dependency with
`pip --no-index`; it does not contact PyPI or a Python package repository. The
Marketplace image must also provide `/usr/bin/python3` with `venv` and the
host tools used by the bootstrap (`unzip`, `curl`, `wget`, `openssl`, and
SQL*Plus with Oracle Instant Client).

The Stack uses an Autonomous AI Database private endpoint and an Object
Storage service gateway. The application subnet has a public IP and an
Internet Gateway route for inbound review access, but its security list has no
general Internet egress rule. The VM can reach the private ADB endpoint,
Object Storage, and HTTPS endpoints in the regional Oracle Services Network;
it cannot initiate arbitrary Internet connections. The regional OCI service
CIDR rule is required for instance-principal token exchange and OCI
Generative AI. Inbound SSH and application access are restricted by
`allowed_ingress_home_ip_address`.

In OCI Resource Manager:

1. Select **Create stack**, choose **My configuration**, and upload
   `deep-sec-local-genai-terraform-Marketplace.zip`.
2. Set **Working directory** to `terraform`.
3. Select the target tenancy compartment and region. `us-ashburn-1` and
   `DBSec_Rich` are the known-good values for the RICH lab. The target tenancy
   must be allowed on the private Marketplace listing.
4. Confirm the package version reference. The stack resolves the launchable
   image OCID (`mp_listing_resource_id`) after it creates the subscription;
   do not substitute the publisher artifact OCID.
5. Provide an SSH public key and an OCI Auth Token for the ADB Iceberg reader:
   `order_history_oci_username` must be in
   `<identity-domain>/<username>` form, and
   `order_history_oci_auth_token` must be entered as a sensitive value.
6. Leave the legacy Customer Secret Key, user-bucket, shared-dataset, and
   Data Flow fields empty/disabled. Leave `create_genai_iam` off unless a
   tenancy administrator specifically wants a new dynamic group and policy.
7. Run **Plan**. After reviewing a successful plan, run **Apply**.

Apply provisions the database, public-IP application VM with no general
Internet egress, private Object Storage, and the
Stack-owned Iceberg bucket. It waits for the VM bootstrap health gate before
returning success. In **Application Information**, select **Unlock** and copy
the generated password for ADB ADMIN, JupyterLab, and Marvin. The application
and SSH URL outputs use the generated public IP:

- Admin Console: port `7778`
- Customer Sales App: port `7777`
- JupyterLab: port `8888`

The official Resource Manager procedure is [Creating a Stack from a Zip
File](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-local.htm).

On Destroy, Marketplace removes all object versions and pre-authenticated
requests from its unique Stack bucket before deleting the bucket. If a stack
created by an older ZIP reports `PreauthenticatedRequestStillExists`, remove
the listed bucket's remaining PARs once, then rerun Destroy.

## Stack variables

For a Marketplace deployment, enter these values in Resource Manager:

| Variable | Value |
| --- | --- |
| `tenancy_ocid` | Your OCI tenancy OCID. |
| `compartment_ocid` | The target compartment OCID; use `DBSec_Rich` when that is the intended lab compartment. |
| `marketplace_listing_id` | The consumer-facing App Catalog OCID for the private Deep Sec machine-image listing. The default is the published `ocid1.appcataloglisting...` value; do not use the publisher `ocid1.mktpublisting...` OCID. |
| `marketplace_resource_version` | The published Marketplace package version reference; the initial package is `1.0`. |
| `ssh_public_key` | The public SSH key for the person who will operate this stack. |
| `order_history_oci_username` | The Iceberg reader identity in `<identity-domain>/<username>` form. |
| `order_history_oci_auth_token` | An Auth Token for that same identity-domain user; enter it as a sensitive value. |
| `order_history_bucket_prefix` | Optional object prefix for the pre-created Iceberg table in the dedicated Stack-created bucket. The default is `order_history_iceberg`. |

`region` defaults to `us-ashburn-1`. The target tenancy must be included in
the private listing's allowed-tenancy list. Terraform accepts the Marketplace
agreement, creates the subscription in the target compartment, and waits for
that subscription before creating the compute instance. Set
`use_marketplace_image = false` only for an internal custom-image deployment.

The publisher-side artifact OCID is used while publishing the image and is
not the value that belongs in `source_details.source_id`. Oracle calls the
consumer-facing value `mp_listing_resource_id` or the published Marketplace
image OCID.

## Marketplace image subscription

The `marketplace-image.tf` resources implement Oracle's standard Terraform
image flow: obtain the listing resource-version agreement, accept the terms
through `oci_core_app_catalog_subscription`, resolve the listing resource
version's consumer image OCID, and then launch the instance from that image.
The other team can use the same configuration in its tenancy after that
tenancy is allowed on the private listing.

See Oracle's [Terraform Marketplace image subscription
guidance](https://docs.oracle.com/en-us/iaas/Content/Marketplace/Tasks/subscribe-terraform-configurations.htm).

## Order History delivery

The normal path is intentionally one operation: Apply the Stack. Terraform
creates a dedicated private bucket, uploads the checked-in
`order_history_iceberg_bundle.zip`, and gives the VM short-lived exact-object
PARs. The VM materializer rewrites the complete JSON and Avro metadata graph
for that bucket and prefix, then publishes the table. It does not run Spark,
Data Flow, or generate a new dataset.

The bucket belongs to the tenancy and compartment, not to an individual IAM
user. This Stack creates and cleans up its own dedicated bucket on Destroy, so
the learner does not need to pre-create a bucket or provide a Customer Secret
Key. The only Iceberg credential is the OCI Auth Token used by APPLAB's
`DBMS_CLOUD` reader. The generated ADB reader setup verifies the metadata object
and reads a real Iceberg row before Apply completes.

Legacy delivery-mode, user-bucket, shared-dataset, and Data Flow values may
remain in an upgraded Resource Manager Stack's saved variable map, but the
Marketplace configuration no longer reads them or provisions those paths.

After Apply, verify the VM before opening the applications:

```bash
ssh opc@<compute-public-ip>
sudo cat /var/lib/deep-sec/bootstrap-status
sudo tail -n 200 /var/log/deep-sec-bootstrap.log
```

The status file should contain `COMPLETE`. The bootstrap log should show the
schema creation, Object Storage publication, Iceberg reader setup, and
application health phases. If a phase fails, inspect the run directory named
in the log before retrying the Stack.

### ADB access to the Iceberg warehouse

Create an Oracle-SSO Auth Token for the user who will own the ADB
`DBMS_CLOUD` credential, then enter `order_history_oci_username` and
`order_history_oci_auth_token` as Stack input. Do not put the token in source
control, `terraform.tfvars`, or output files. Resource Manager cannot create
an Oracle-SSO Auth Token or Customer Secret Key through the Identity Domains
API; the retired `create_iceberg_resources` switch must remain false.

OCI Resource Principal authentication is not supported for Autonomous AI
Database Iceberg queries, so Marketplace intentionally does not offer it for
this reader.

The bundle materializer writes through Stack-created Object Storage PARs, while
the separate Auth Token lets ADB read the published dataset. Customer Secret
Key inputs remain accepted for compatibility with older Stack variable maps;
the bundle materializer does not use them. Resource Manager cannot create an
Oracle-SSO Auth Token; provide the existing token as a sensitive input.

The database-side reader follows Oracle's
[DBMS_CLOUD documentation](https://docs.oracle.com/en/cloud/paas/autonomous-database/dedicated/adbaa/dbmscloud-for-objects-and-files.html),
using a direct metadata pointer to the published Iceberg table. The schema
setup also restores the required outbound Object Storage ACL when APPLAB is
created. A reset therefore recreates APPLAB and its ACL before the Order
History table setup is run again.

To verify the external table after setup, connect as APPLAB and run:

```sql
SELECT COUNT(*) FROM order_history;
SELECT order_id, customer_id, order_date
FROM order_history
ORDER BY order_date, order_id;
```

The checked-in sample contains 1,500 rows. The external table reads those
files in Object Storage; it does not copy them into ADB.

For a reset, use **Restore to DB Setup** or **Prepare App** in the Admin
Console. Confirm the bootstrap/database log shows `create_schema.sql` and its
Object Storage ACL grant, then rerun the normal Order History table action if
the reset workflow has not already done so.

## Generative AI prerequisite

Customer Insights uses the Compute instance principal. To avoid exhausting the
tenancy dynamic-group quota when many lab stacks deploy concurrently,
Marketplace does **not** create one dynamic group per Stack by default. Before
the lab, a tenancy administrator must provide a shared dynamic group and policy
that allow the Marketplace Compute instances to use `generative-ai-chat` in the
target compartment. Set `create_genai_iam = true` only for a one-off tenancy
that has dynamic-group capacity; it creates a uniquely named per-Stack group
and policy.

## Legacy paths

The former regular, NO-IAM, FREE, and wallet-based deployment paths are under
`../archive/non-greenbutton-20260827/` and are not supported for new stacks.
