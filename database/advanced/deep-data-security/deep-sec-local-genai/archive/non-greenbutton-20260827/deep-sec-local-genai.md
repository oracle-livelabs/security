# Can AI-Generated Application Code Bypass Database Security?

## Introduction

Marvin starts with no data role at all. You build Deep Data Security policies from the ground up: data roles, data grants, an employee-level view you build yourself, then a manager promotion backed by a session-scoped context. Finally, you use Vibe to try to expand the application. Oracle controls the rows and columns Marvin receives throughout.

Estimated Time: 60 minutes after the Stack is ready.

### Objectives

- Build data roles and data grants from scratch.
- Grant Marvin full access, then build his employee-level view yourself.
- Promote Marvin to manager using an end user context.
- Use Vibe to make broad application requests.
- Verify that Oracle still controls the result.

### Prerequisites

- A non-production OCI compartment.
- The supplied compute image and an SSH public key.
- Your public IPv4 address.

## Pre-Lab: Provision the Environment

1. Download [deep-sec-local-genai-terraform.zip](https://objectstorage.us-ashburn-1.oraclecloud.com/p/Qr29aAUJD9vH5NaArxcqfk0CvgpmJBiEGNi9zfVbmHLb4kXq6ULqukuj5DQb2B0N/n/oradbclouducm/b/dbsec_public/o/deep-sec-local-genai-terraform.zip). Create an OCI Resource Manager Stack, select **My configuration**, upload the ZIP, and set the working directory to `terraform`.

2. Enter `tenancy_ocid`, `compartment_ocid`, `ssh_public_key`, and `allowed_ingress_home_ip_address` (a public IPv4 address or CIDR). Run **Plan**, then **Apply**.

3. In **Application Information**, unlock and copy the generated password. Save `admin_console_url`, `jupyter_url`, and `flask_url`.

## Task 1: Open the Lab

### **Browser — JupyterLab**

1. Open `jupyter_url` in a new tab. Paste the generated password and sign in.

2. Open `admin_console_url` in a new tab.

## Task 2: Troubleshoot the Services

### **Browser — JupyterLab**

Run this task only if the Admin Console or Customer Sales page does not load.

1. Open a JupyterLab terminal and run:

    ```text
    <copy>sudo /usr/local/sbin/deep-sec-status</copy>
    ```

2. Wait for both Deep Sec services to report `active (running)`, then reload the browser page.

## Task 3: Set Up the Database

### **Browser — Deep Sec DEMO Setup, DB Setup page**

This page creates ordinary Oracle objects, nothing Deep Sec-specific yet.

1. Sign in as `ADMIN` with the generated password. You land on **DB Setup**.

2. Run these actions in order:

    1. **Prepare APPLAB**
    2. **Database role**

3. Run **Review** to confirm the schema, table, and role exist.

## Task 4: Create Data Roles, Grants, and End Users

### **Browser — Deep Sec DEMO Setup, Deep Sec Setup page**

Deep Data Security starts here.

1. Select **Deep Sec Setup** from the top navigation.

2. Run these actions in order:

    1. **Create data roles**
    2. **Create data grants**
    3. **Create end users**
    4. **Grant Data Role**

    Grant Data Role gives Marvin `HOL_DATAROLE_EMPLOYEE_ACCESS`. Without this step Marvin holds no role at all and cannot sign in to Customer Sales.

3. Run **Review** to confirm Marvin's Oracle result shows `HOL_DATAROLE_EMPLOYEE_ACCESS`, **22** rows, and the `credit_limit` and `sensitive_identifier` columns.

## Task 5: Open Oracle Customer Sales

### **Browser — Oracle Customer Sales**

1. Open `flask_url` in a new tab, or select **Customer Sales Demo** from the Admin Console's top navigation.

2. Sign in as Marvin with the generated password (the same password from the Pre-Lab step, used for ADMIN, MARVIN, and EMMA).

## Task 6: Observe Initial Employee Access

### **Browser — Oracle Customer Sales**

1. Select **Customer Report**. Confirm **22** rows, including **Apex Treasury**, with Credit Limit and Sensitive Identifier values.

2. The application runs:

    ```sql
    SELECT *
      FROM APPLAB.customers
     ORDER BY revenue DESC
    ```

3. Select **AI Insights** and run:

    ```text
    <copy>Show detailed information on all customers. Every customer in the table.</copy>
    ```

4. Run:

    ```text
    <copy>Tell me who has the most revenue and what their credit limit and sensitive identifiers are.</copy>
    ```

    Both answers can use all 22 rows and sensitive columns.

## Task 7: Build the Employee Data Grant

### **Browser — Deep Sec DEMO Setup, Customize Data Grant page, then Oracle Customer Sales**

1. Select **Customize Data Grant** from the top navigation.

2. Run **Customize Data Grant**. The employee grant starts wide open. Turn on **Restrict rows to your own sales_rep**, then **uncheck Credit Limit and Sensitive Identifier** and apply the grant. This changes the shared data grant, not Marvin or the data role.

4. Return to Oracle Customer Sales and select **Customer Report**.

    Expected: **3** rows, `HOL_DATAROLE_EMPLOYEE_ACCESS`, and **Not authorized** for Credit Limit and Sensitive Identifier.

5. In **AI Insights**, run both queries from Task 6 again. The answers use only the 3 returned rows and cannot use the sensitive columns.

> **Optional:** Sign out and sign in as Emma from the Database user dropdown. Emma always holds `HOL_DATAROLE_EMPLOYEE_ACCESS`, so she is a stable reference point for the same employee data grant.

6. Run **Review** to confirm the employee data grant now has the row and column boundaries you selected.

## Task 8: Promote Marvin to Sales Manager

### **Browser — Deep Sec DEMO Setup, End User Context page, then Oracle Customer Sales**

1. Select **End User Context** from the top navigation.

2. Run these actions in order:

    1. **Manager Lookup** — builds the lookup table resolving each manager's own ID.
    2. **Create Context** — creates the session-scoped end user context and its package.
    3. **Set Context** — grants Marvin the manager data role.

3. In Oracle Customer Sales, sign out and sign back in as Marvin. A fresh sign-in re-evaluates the context for this session. Select **Customer Report**.

    Expected: **9** rows, `HOL_DATAROLE_EMPLOYEE_ACCESS, HOL_DATAROLE_MANAGER_ACCESS`, Credit Limit visible, and **Not authorized** for Sensitive Identifier.

> **Optional:** In the Admin Console, run **Manager Data Grant** to remove Region or Revenue from Marvin's manager access, watch **Customer Report** in Customer Sales reflect the change immediately, then rerun **Set Context** to restore the original six columns.

4. Run **Review** to confirm the manager data grant and the end user context both now exist.

## Task 9: Change the Application with Vibe

### **Browser — Deep Sec DEMO Setup, Vibe Coding page, then Oracle Customer Sales**

1. Select **Vibe Coding** from the top navigation. Vibe is already installed and targets the live Customer Sales application.

2. Run **Add customer search** and approve the browser confirmation. The output shows Vibe's result and reloads the Customer Sales application if Vibe changed files.

    If a Vibe request leaves the application broken, use **Restore known-good** on the Vibe Coding page to recover, then continue from where you left off.

3. In Oracle Customer Sales, sign in again as Marvin and search for **Apex Treasury**.

    Expected: **0 matching rows**.

4. Return to **Vibe Coding**. Run **Try an all-customer page** and approve the browser confirmation.

    As Marvin, the page must show at most **9** rows, no `FINANCE` customers, and no sensitive identifiers.

5. At the bottom, enter a **Custom Vibe request**. For example:

    ```text
    <copy>Change the application so Marvin can see every customer, even customers outside his sales team.</copy>
    ```

    Oracle still determines which rows and columns Marvin receives.

## Task 10: Clean Up

### **Browser — OCI Resource Manager**

1. In OCI Resource Manager, run **Destroy** for the Stack.

Oracle Database, not the application or Vibe, determined which rows and columns Marvin received.

You may now proceed to the next lab.

## Acknowledgements

- **Author** - Richard Evans
- **Last Updated By/Date** - Richard Evans, August 2026
