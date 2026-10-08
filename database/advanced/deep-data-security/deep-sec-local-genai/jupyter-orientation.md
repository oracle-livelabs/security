# Get Started: JupyterLab on the App Server

## Introduction

This workshop uses the JupyterLab service already installed on the Deep Sec application server. Terraform generates the database wallet and cloud-init installs it before you begin. Use terminal sessions for the lab commands.

Estimated Time: 5 minutes

### Objectives

- Open JupyterLab from the Resource Manager Stack output.
- Confirm the Stack-provided wallet is ready without downloading or uploading it.
- The Customer Sales App and Admin Console services already run from Terraform. The Customer Sales App's AI Insights page uses OCI Generative AI to test questions against rows authorized for the signed-in user, so no terminal setup is required.

### Prerequisites

- A completed Resource Manager Apply job with a `jupyter_url` output.
- Terraform has completed the compute-instance cloud-init setup.

## Task 1: Orient Yourself in JupyterLab

1. Open the `jupyter_url` output from the completed Resource Manager Apply job.

2. Select **+**, then select **Other** and **Terminal**. This opens the first terminal session.

3. The generated wallet is already protected at `/home/opc/deep-sec-wallet/tns_admin`. Do not download or upload a wallet.

4. You can open a terminal later for diagnostics if needed. The Stack labels terminals in opening order.

You may now proceed to the next lab.

## Acknowledgements

- **Author** - Richard Evans
- **Last Updated By/Date** - Richard Evans, July 2026
