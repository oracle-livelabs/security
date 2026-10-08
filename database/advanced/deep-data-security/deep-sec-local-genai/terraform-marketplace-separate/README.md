# Deep Sec MarketplaceSeparate OCI Resource Manager Stack

This ZIP contains infrastructure only. It creates an Autonomous AI Database
26ai, a VM launched from the private Deep Sec Marketplace image, a VCN, and
private Object Storage. The application ZIP and Iceberg bundle stay in the
`dbsec_public` bucket and are downloaded by the VM through exact-object read
PARs. A PAR is a URL that grants access to one Object Storage object; treat it
like a secret.

## Operator quick start

### Before creating the stack

You need:

- Access to the target OCI tenancy and compartment. For the RICH lab, use
  `DBSec_Rich` in `us-ashburn-1`.
- Permission to create the database, compute, networking, and Object Storage
  resources. The target tenancy must also be allowed on the private
  Marketplace listing.
- These two objects in `dbsec_public`, each with a two-year exact-object read
  PAR: `deep-data-security-flask-app-MarketplaceSeparate.zip` and
  `order_history_iceberg_bundle-MarketplaceSeparate.zip`.
- An SSH public key for the person operating the VM.
- An Oracle-SSO Auth Token for the identity that APPLAB will use to read the
  Iceberg table. The token is entered only as a sensitive Resource Manager
  value; never put it in source control or this ZIP.

The published consumer-facing Marketplace listing OCID and package version
are already the defaults in this ZIP. Do not replace the listing OCID with the
publisher's `ocid1.mktpublisting...` OCID.

### Create the Resource Manager stack

1. In the OCI Console, open **Developer Services → Resource Manager → Stacks**
   and select **Create stack**.
2. Choose **My configuration** and upload
   `deep-sec-local-genai-terraform-MarketplaceSeparate.zip`.
3. Set **Working directory** to `terraform` and use Terraform `1.5.x`.
4. Select the target compartment and region.
5. Enter the values below. Resource Manager displays some optional and
   deprecated variables; leave those at the stated defaults.
6. Run **Plan**. Review the plan, then run **Apply** only after Plan succeeds.

### Required values

| Variable | Set it to |
| --- | --- |
| `tenancy_ocid` | OCID of the target OCI tenancy. |
| `compartment_ocid` | OCID of the target compartment; use the compartment containing `DBSec_Rich` for the RICH lab. |
| `region` | `us-ashburn-1`, unless the published image is available in another approved region. |
| `use_marketplace_image` | `true`. Leave hidden default unchanged. |
| `marketplace_listing_id` | Leave the published consumer-facing default unchanged. |
| `marketplace_resource_version` | `1.0`, unless the listing owner gives you a newer version. |
| `application_bundle_par_url` | The exact-object read PAR for `deep-data-security-flask-app-MarketplaceSeparate.zip` in `dbsec_public`. |
| `order_history_bundle_par_url` | The exact-object read PAR for `order_history_iceberg_bundle-MarketplaceSeparate.zip` in `dbsec_public`. |
| `ssh_public_key` | Your SSH public key, for example the contents of `~/.ssh/id_ed25519.pub`. |
| `allowed_ingress_home_ip_address` | Your current public IPv4 address with `/32`, or your approved IPv4 CIDR. Do not leave `0.0.0.0/0`. |
| `order_history_oci_username` | The Oracle-SSO identity in `<identity-domain>/<username>` form. |
| `order_history_oci_auth_token` | Auth Token for that same identity. Mark it **sensitive**. |

### Recommended defaults

Leave these values unchanged for the normal lab:

| Variable | Default |
| --- | --- |
| `adb_db_name` | Blank; Terraform generates a unique name. |
| `adb_display_name` | `Deep Sec` |
| `adb_compute_count` | `2` ECPUs |
| `adb_storage_tbs` | `1` TB |
| `adb_license_model` | `BRING_YOUR_OWN_LICENSE` |
| `compute_shape` | `VM.Standard.E5.Flex` |
| `compute_ocpus` / `compute_memory_in_gbs` | `1` / `16` |
| `compute_display_name` | `deep-sec-app-server` |
| `assign_public_ip` | `true` |
| `vcn_cidr` / `public_subnet_cidr` | `10.0.0.0/16` / `10.0.1.0/24` |
| `wallet_bucket_name` | Blank; Terraform generates a unique private bucket. |
| `wallet_par_ttl_hours` | `17520` hours, or two years. |
| `order_history_bucket_prefix` | `order_history_iceberg` |
| `create_genai_iam` | `false`; use the tenancy's existing shared GenAI dynamic group and policy. |
| `genai_model_id` | `google.gemini-2.5-flash` |

If you intentionally set `create_genai_iam = true`, the tenancy administrator
must approve creating a new dynamic group and policy. Set
`genai_policy_compartment_ocid` only when the GenAI policy belongs in a
different compartment.

If Resource Manager shows deprecated fields, leave them blank or disabled:
`oci_profile`, `compute_image_ocid`, `order_history_bucket_name`,
`order_history_access_key`, `order_history_secret_key`,
`use_shared_order_history_dataset`, all `shared_order_history_*` values,
`create_iceberg_resources`, and all `dataflow_*` values. Leave
`order_history_delivery_mode` as `bundle` and `current_user_ocid` blank.

## What Apply does

Terraform accepts the Marketplace terms, creates the subscription, and obtains
the consumer-tenancy image OCID before launching the VM. The VM then:

1. Downloads the application and Iceberg bundle from their PAR URLs.
2. Creates the lesson database and publishes the Iceberg files into its own
   private Stack-owned bucket.
3. Creates and verifies the APPLAB Iceberg external table.
4. Starts the Customer Sales App, Admin Console, and JupyterLab.

The subnet permits inbound review traffic only from
`allowed_ingress_home_ip_address`. It has no general Internet egress rule;
regional OCI service access is provided for Object Storage and GenAI.

After Apply, select **Unlock** in **Application Information** and copy the
generated password. It is used for ADB ADMIN, JupyterLab, and Marvin.

Verify the VM before opening the applications:

~~~
ssh opc@<compute-public-ip>
sudo cat /var/lib/deep-sec/bootstrap-status
sudo tail -n 200 /var/log/deep-sec-bootstrap.log
~~~

The status must be `COMPLETE`. The application endpoints are:

- Admin Console: `http://<compute-public-ip>:7778/`
- Customer Sales App: `http://<compute-public-ip>:7777/`
- JupyterLab: `http://<compute-public-ip>:8888/`

## Updating the application

From the parent `deep-sec-local-genai` directory, rebuild and publish only the
application object:

~~~
bash build_marketplace_separate_app_zip.sh
bash publish_marketplace_separate_components.sh
~~~

Keep the application object name and PAR unchanged. The Terraform ZIP does not
need to be rebuilt for application-only changes. An existing VM does not
automatically install the new code; use the application's refresh/restart
procedure or create a new VM.

If the Iceberg bundle changes, use:

~~~
bash publish_marketplace_separate_components.sh all
~~~

Only rebuild the Terraform ZIP when the infrastructure or cloud-init changes:

~~~
bash build_marketplace_separate_terraform_zip.sh
~~~

## Destroy and troubleshooting

Destroy removes the VM, database, PARs, objects, and the Stack-owned buckets.
If an older deployment reports `PreauthenticatedRequestStillExists`, remove
the remaining PARs listed for that Stack-owned bucket and run Destroy again.

Useful VM diagnostics:

~~~
sudo /usr/local/sbin/deep-sec-status
sudo systemctl status deep-sec-customer-sales.service --no-pager -l
sudo systemctl status deep-sec-admin-console.service --no-pager -l
sudo journalctl -u cloud-final.service -b -n 200 --no-pager -o short-iso
~~~

## Local Terraform use

The same `terraform/` directory can be used outside Resource Manager. Set the
required values as `TF_VAR_...` environment variables or in an untracked
local tfvars file, then run Terraform from the `terraform` directory. Do not
store PAR URLs, Auth Tokens, private keys, or database passwords in the
repository.

Oracle references: [Creating a Stack from a ZIP
File](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-local.htm),
[Terraform Marketplace image
subscriptions](https://docs.oracle.com/en-us/iaas/Content/Marketplace/Tasks/subscribe-terraform-configurations.htm),
and [DBMS_CLOUD for Object Storage and
files](https://docs.oracle.com/en/cloud/paas/autonomous-database/dedicated/adbaa/dbmscloud-for-objects-and-files.html).
