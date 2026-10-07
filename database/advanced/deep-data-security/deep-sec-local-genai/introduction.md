# Introduction to Deep Sec GreenButton and OCI Generative AI

## Introduction

In this workshop, you configure Oracle Deep Data Security on Oracle Autonomous AI Database 26ai. You create database end users, data roles, data grants, cross-table data grants, and an end user context. You then test those policies from the Customer Sales App and OCI Generative AI.

The stack starts with a working Customer Sales App and its ordinary Oracle objects. You create Marvin and Emma as local database end users. You build employee and manager data roles, then define row- and column-level access with data grants. Next, you use an end user context to add manager access, then extend the customer policies to Order History through a cross-table data grant. At each stage, test the results with SQL queries and natural-language questions on the AI Insights page. OCI Generative AI receives only the rows and columns that Oracle authorizes for the signed-in user. Changing the question cannot override or bypass database authorization.

Estimated Workshop Time: 60 minutes after the stack is ready. Allow extra time for database provisioning and application setup when deploying your own stack. The sample Iceberg data is installed automatically.

### Objectives

- Deploy the GreenButton Oracle Cloud Infrastructure stack.
- Create local Deep Data Security end users, data roles, and data grants.
- Verify database-enforced row and column authorization in the Customer Sales App.
- Extend authorization to Order History through a cross-table data grant.
- Add manager access through an end user context.
- Query Order History through an Apache Iceberg external table without copying its data into Oracle.
- Use OCI Generative AI to test different questions against the authorized customer data.
- Show that GenAI queries cannot override or bypass database authorizations.

## Architecture

![Deep Data Security and OCI Generative AI workshop architecture](images/architecture-infographic.png)

The stack publishes the sample Iceberg files to a private Object Storage
bucket. Autonomous AI Database (ADB) queries those files through an external
table. The data stays in Object Storage.

AI Insights sends the signed-in user's Oracle-authorized customer rows to
OCI Generative AI. The service can answer different questions about that result
set. In the red-team challenge, the model can request a read-only SQL check. The application executes that check as the signed-in
end user, and Oracle enforces the same authorization rules.

### Prerequisites

LiveLabs reservations supply the environment inputs. For a self-managed deployment, you need:

- An isolated, non-production OCI compartment.
- Permission to create the Stack resources or the supplied Stack inputs from the lab owner.
- An OCI identity-domain user and Auth Token for the ADB Iceberg reader, supplied by the lab owner or entered as a sensitive stack variable.
- Access to the supplied compute image in the selected OCI region.

## Deploy the GreenButton Stack

If LiveLabs has already provisioned your environment, continue to **Get Started**.
For a self-managed deployment, use the supplied
`deep-sec-local-genai-terraform-GreenButton.zip` and follow these steps.

1. In the OCI Console, open **Developer Services**, select **Resource Manager**, then select **Stacks** and **Create stack**.
2. Select **My configuration** and upload the supplied Terraform ZIP. Set the working directory to `terraform`.
3. Configure the following core inputs. The current GreenButton path generates
    the shared database password after deployment, so `adb_admin_password` is
    intentionally not an input.

    | Input | What it means |
    | --- | --- |
    | `tenancy_ocid` | The OCID of the OCI tenancy where Resource Manager will create tenancy-scoped resources. |
    | `region` | The resource region where the supplied Compute image is available. |
    | `compartment_ocid` | The target compartment for the database, compute instance, networking, and lab resources. |
    | `ssh_public_key` | The public half of the SSH key that will be authorized on the application Compute instance. Keep the private key; it is not uploaded to the Stack. |
    | `allowed_ingress_home_ip_address` | The public IPv4 address or CIDR allowed to reach the lab services. A single address is treated as `/32`; restrict the default `0.0.0.0/0` before broader use. |
    | `create_genai_iam` | Leave disabled when a shared dynamic group and policy already authorize the Compute instance. Enable only if the stack should create them and your tenancy has capacity and permission to do so. GenAI access requires one of these authorization paths. |

    The Stack also requires the Order History reader identity and matching OCI
    Auth Token. Use the `<identity-domain>/<username>` form for
    `order_history_oci_username`. Enter the matching
    `order_history_oci_auth_token` as a sensitive value.
4. Leave the retired Customer Secret Key, user-bucket, shared-dataset, and
    Data Flow inputs empty or disabled. The stack creates its own private
    Iceberg bucket.
5. Select **Plan**. Review the plan and confirm it completes successfully
    before continuing.
6. Select **Apply**. Apply waits for the application VM bootstrap health gate.
7. In **Application Information**, unlock the generated shared password. Open
    the **Deep Sec Demo Setup** (Admin Console) URL on port `7778`,
    **Customer Sales App** on port `7777`, or **JupyterLab** on port `8888`.
    The same generated password is used for `ADMIN`, `MARVIN`, `EMMA`, and
    JupyterLab.

8. If you need to diagnose the deployment, open **JupyterLab** and select
    either of the two **Terminal** tabs already open by default. Run:

    ```bash
    sudo cat /var/lib/deep-sec/bootstrap-status
    sudo tail -n 200 /var/log/deep-sec-bootstrap.log
    ```

    The status file should contain `COMPLETE`. Run these commands in a
    JupyterLab Terminal tab, not in a notebook cell or a terminal on your own
    computer. If both Terminal tabs are closed, select **File → New → Terminal**.

> The GreenButton Stack currently defaults the browser CIDR to `0.0.0.0/0` for hands-on-lab use. This CIDR represents every IP address on the Internet and is not recommended for long-term use. Oracle recommends limiting it to a smaller set of IP addresses.

You may now proceed to the next lab.

## Learn more

- [Oracle Deep Data Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/26/ddscg/index.html)
- [Create a Resource Manager stack from a ZIP file](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Tasks/create-stack-local.htm)

## Acknowledgements

- **Author** - Richard Evans
- **Last Updated** - October 2026
