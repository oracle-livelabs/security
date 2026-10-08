# Can Application Code or GenAI Bypass Oracle Deep Data Security?

## Introduction

In this lab, you use a guided web console to configure Oracle Deep Data Security for a preinstalled Customer Sales App. The database decides which rows and columns each signed-in end user can see. You then test that boundary with OCI Generative AI and with data outside the database.

![Deep Data Security architecture showing an end user and Customer Sales App or OCI Generative AI sending requests through end-user security context to Oracle AI Database, where data roles and grants enforce each user's authorized rows and columns](images/lab-architecture.png)

The console walks you through every step with instructions, DeeBee's Notes, SQL previews, and quizzes. Depending on the step, select **Run Action**, **Apply this grant**, or **Mark as viewed**. You do not need to return to this document after you enter the console.

Estimated Time: 60 minutes after provisioning completes.

### Objectives

- Create database end users, data roles, data grants, cross-table data grants, and an end user context.
- Compare how the same query returns different results as grants change.
- Test natural-language queries in AI Insights against only the data authorized for the signed-in user.
- Run the red-team exercise (#11), in which GenAI requests a read-only SQL check that still runs as the current end user.
- Show that application code and GenAI cannot bypass database authorization.

### Who this lab is for

- **Security engineers:** observe database-enforced row and column access for the signed-in end user.
- **Database administrators:** inspect the SQL used to create and validate the authorization policies.
- **Developers:** see the same application query return different data as authorization changes.
- **Managers and team leads:** see a practical demonstration of least privilege and its effect on user access.

### Prerequisites

- Complete the [Introduction](introduction.md) and [Get Started](get-started.md). 
- The lab **View Login Info** link provides three URLs and one generated password. Use the password for `ADMIN` in the console, `MARVIN` and `EMMA` in the Customer Sales App, and JupyterLab.

## Task 1: Start the Deep Data Security walkthrough

### Browser: Deep Sec Demo Setup

1. If it is not already open, open **Admin Console URL** from the **View Login Info** link.
2. Sign in as `ADMIN` with the password shown on the same tab. Read the **Overview** page. It shows the scenario, architecture, and purpose of each stage.
3. Select **?** in the header for a guided tour of the navigation. Select **Next** to continue, or **Skip tour** to close it. You can also press **Esc** or click outside the tour to close it.
4. Select **Start DB Setup** and follow the numbered steps. The console guides you through every stage from here:

    DB Setup → Deep Sec Setup → Customer Sales App → Customize Grant → Context → Iceberg → Exercises → Best Practices → Summary

5. A pending step is gray. The selected unfinished step is red. A step turns blue after its action succeeds and, if it has a quiz, you answer correctly. For observation steps, select **Mark as viewed** after completing the instructions. A check mark appears beside a page when all its steps are complete. Progress is retained while you navigate or refresh in the same Admin Console session; signing in again starts a new progress record.

6. Keep the **Customer Sales App** open in a second tab as Marvin. For Emma, right-click **Right-click for Emma** and open the link in a private window (Incognito in Chrome, InPrivate in Edge). If the menu option isn't available, copy the link into a new private window. Sign in as `EMMA` with the same password.

7. After each grant change, select **Customer Report** or **Iceberg Report** again to fetch the current authorized result. Follow the console's instructions for row restrictions and excluded columns before comparing the expected counts.

## Task 2: Inspect, troubleshoot, and clean up (optional)

The console runs real SQL against an Autonomous AI Database. Use these steps to inspect the environment or run the same checks from a terminal.

1. Open the JupyterLab URL on the **View Login Info** link. Sign in with the generated password.

2. Select either of the two **Terminal** tabs already open by default. If both are closed, select **File → New → Terminal**. These terminals run on the Compute VM that hosts both applications. Run the commands below there, not in a Python notebook cell or a terminal on your own computer.

    Check the applications:

    ```bash
    sudo /usr/local/sbin/deep-sec-status
    ```

    The lesson SQL scripts are under `content/deep_data_security/database/` in the deployed Admin Console source. The console also shows the SQL for each action.

3. Connect directly with SQL*Plus. The Stack configures the built-in `deepsec_low` TNS alias for the ADB LOW service. No wallet is required.

    ```text
    sqlplus ADMIN@deepsec_low
    ```

    Enter the generated password when SQL*Plus prompts for it. Enter `EXIT` to close the session.

4. After creating Marvin and granting his data role, connect as Marvin:

    ```text
    sqlplus MARVIN@deepsec_low
    ```

    Enter the generated password, then run:

    ```sql
    SELECT * FROM APPLAB.customers ORDER BY revenue DESC;
    ```

    Oracle evaluates Marvin's authorization. With the recommended employee grant, he sees three customer rows and the sensitive column values are unavailable. After his manager role is granted, he sees nine rows.

5. If you prefer SSH, use the stack's `ssh_command` output and the matching private key, if available. JupyterLab terminals provide the same VM access for these commands.

6. To inspect the running source, open the console's **Admin → Downloads** page. The page builds a fresh ZIP of the SQL scripts and both application source trees from the files running on the VM.

7. If a console or application page fails to open, verify that the Apply job completed successfully, then run the following in a **JupyterLab Terminal** tab. Both application services should report `active (running)`.

    ```bash
    sudo /usr/local/sbin/deep-sec-status
    ```

8. If **AI Insights** fails, expand **Troubleshooting** in its error card. The card shows selected diagnostics and commands for locating the error in the service log. Run those commands in a **JupyterLab Terminal** tab. To view recent Customer Sales App logs directly, run:

    ```bash
    sudo journalctl -u deep-sec-customer-sales.service -b -n 200 --no-pager -o short-iso
    ```

    For a throttling error, wait for the interval shown before submitting another request. Ask the lab administrator to verify the assigned GenAI region, compartment, and model. In LiveLabs, the assigned GenAI region (`ociGenAiRegion`) can differ from the resource region (`ociRegionIdentifier`). The application must use the assigned GenAI region for its endpoint.

    For more detail, see [Oracle Python SDK logging](https://docs.oracle.com/en-us/iaas/tools/python/latest/logging.html). Debug logging can include request headers and bodies; review logs before sharing them.

9. When finished with a self-managed deployment, destroy the Resource Manager stack. This permanently removes its workshop resources. The GreenButton destroy workflow removes its stack-specific Object Storage objects and pre-authenticated requests before deleting the bucket. For a LiveLabs reservation, use the reservation's end-lab controls instead.

## Acknowledgements

- **Author** - Richard Evans
- **Last Updated** - October 2026
