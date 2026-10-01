# Can Application Code or GenAI Bypass Oracle Deep Data Security?

## Introduction

In this lab, you build a customer-sales application. Oracle AI Database, not application code or an AI prompt, decides which rows and columns each user can see. You then test the same boundary with OCI Generative AI and with data outside the database.

Complete the lab inside a guided web console. Each page has numbered steps, a **Run Action** button, DeeBee notes, and a short check-your-understanding quiz. You do not need to return to this document after you enter the console. The console provides the remaining instructions.

Estimated time: 60 minutes once the Stack is ready. The console's Overview page also describes a twenty-minute fast path.

### Objectives

- Create database end users, data roles, data grants, cross-table data grants, and end user context.
- Walk through Oracle Deep Data Security's core authorization capabilities and observe how each one changes the authorized result.
- Use OCI Generative AI to test natural-language queries against the data already authorized for the signed-in user.
- Verify that GenAI queries cannot override or bypass database authorizations.

### Who this lab is for

- **Security engineers:** see row- and column-level enforcement that no application, script, or AI prompt can override.
- **Database administrators:** every step uses real SQL that you can read and run yourself.
- **Developers:** watch the application stay completely unchanged while what it returns changes underneath it.
- **Managers and team leads:** least privilege you can demonstrate to an auditor in under an hour.

### Prerequisites

- Complete the [Introduction](introduction.md) and deploy the GreenButton Stack.
- The Stack's **Application Information** tab provides three URLs and one generated password. Use the password for `ADMIN` in the console, `MARVIN` and `EMMA` in the Customer Sales App, and JupyterLab.

## Task 1: Start the Deep Data Security walkthrough

### Browser: Deep Sec Demo Setup

1. If it is not already open, open **Deep Sec Demo Setup** from the link in the OCI Stack page's **Application Information** tab.
2. Sign in as `ADMIN` with the password shown on the same tab. Read the **Overview** page. It shows the scenario, architecture, and purpose of each stage.
3. Press the **?** in the header for a thirty-second tour of the navigation.
4. Select **Start DB Setup** and follow the numbered steps. The console guides you through every stage from here:

    DB Setup → Deep Sec Setup → Customer Sales App → Customize Grant → End User Context → Order History → Exercises → Best Practices

5. Keep the **Customer Sales App** open in a second browser tab. The console tells you exactly when to switch to it and what to look for.

## Task 2: Inspect, troubleshoot, and clean up (optional)

The console runs real SQL against an Autonomous AI Database. Use these steps to inspect the environment or run the same checks from a terminal.

1. Open the JupyterLab link from the Stack's **Application Information** tab. Sign in with the generated password.

2. From the launcher, open a **Terminal**. You are now on the Compute VM that hosts both applications.

    Check the applications:

    ```bash
    sudo /usr/local/sbin/deep-sec-status
    ```

    Every script the console runs is under `database/` in the deployed application source. Open any of them to read exactly what a step does.

3. Connect directly with SQL*Plus. The Stack configures the built-in `deepsec_low` TNS alias for the ADB LOW service. No wallet is required.

    ```text
    sqlplus ADMIN/"<generated password>"@deepsec_low
    ```

4. Run the same query as Marvin instead of `ADMIN`. Oracle returns a different answer to the identical statement because the database evaluates Marvin's authorization context.

    ```text
    sqlplus MARVIN/"<generated password>"@deepsec_low
    SQL> SELECT * FROM APPLAB.customers ORDER BY revenue DESC;
    ```

5. If you prefer your own terminal, use the `ssh_command` output from the Stack. The command uses the SSH key supplied at deployment time.

6. To inspect the running source, open the console's **Admin → Downloads** page. The page builds a fresh ZIP of the SQL scripts and both application source trees from the files running on the VM.

7. If a console or application page returns an error on first open, wait one minute and reload. The VM may still be finishing its bootstrap. If the error persists, run this command in a JupyterLab terminal. Both services should report `active (running)`.

    ```bash
    sudo /usr/local/sbin/deep-sec-status
    ```

8. When finished, destroy the Resource Manager Stack. This permanently removes the workshop resources. The GreenButton destroy workflow removes its stack-specific Object Storage objects and pre-authenticated requests before it deletes the bucket.

    You may now proceed to the next lab.

## Acknowledgements

- **Author** - Richard Evans
- **Last Updated** - September 2026
