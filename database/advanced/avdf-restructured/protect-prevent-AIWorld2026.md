# Protect and Prevent Unauthorized Database Activity

## Introduction

In the previous labs, Security Central identified sensitive data in `employees_search` that is accessed by privileged users and requires stronger preventive controls.

In this lab, configure Database Firewall as the core control to monitor and restrict network activity on `employees_search`. You will create rules for privileged users and sensitive objects, test blocked and alerted activity, and verify the results in reports and alerts. SQL Firewall and Database Vault are optional controls. Database Vault is independent of the Database Firewall and SQL Firewall flows.

*Estimated Lab Time:*

| Task | Path | Estimated time |
| --- | --- | --- |
| Task 1: Database Firewall | Core | 15 minutes |
| Task 2: SQL Firewall | Optional | 15 minutes |
| Task 3: Database Vault | Optional | 5–10 minutes |

## Objectives

In this lab, you will:

- Configure and deploy a Database Firewall policy for privileged users and sensitive objects.
- Test blocked DML activity and alerted SELECT activity.
- Verify the results in Database Firewall reports and alerts.
- Optionally explore SQL Firewall and Database Vault controls.

## Task 1: Configure and test Database Firewall controls

Database Firewall provides network-level protection for `employees_search`. In this task, configure and deploy a policy for privileged users and sensitive objects, test blocked and alerted activity, and review the resulting evidence.


<details>
<summary><strong>Step 1: Create and deploy a Database Firewall policy</strong></summary>

1. Log in to Security Central Console as *`AVAUDITOR`*.

2. Click **Policies** and expand **Firewall Policies** in the left menu.

3. Select **Database Firewall Policies**.

4. In **User-defined Database Firewall Policies**, click **Create**.

    ![AVDF](./images/avdf-129a.png "Create a Database Firewall Policy")

5. Enter the following Database Firewall policy details:

    - Policy Name: *EmployeeSearchAccessOverNetwork*
    - Target Type: *Oracle Database*
    - Description: *Defines anomalous access patterns by DBAs to sensitive application objects in the `employees_search` database over the network*

        ![AVDF](./images/avdf-129b.png "Database Firewall Policy parameters")

    - Click **Save**.

6. Click **Sets/Profiles** to define the policy context.

    ![AVDF](./images/avdf-130.png "Create the context of this policy")

7. In the **Profile** subtab, click **Add** and enter:
    - Name: *DBAs over network*
    - DB User Set: *Database Administrators*

    ![AVDF](./images/360-41.png "Profile")
    - Click **Save**.

8. Click **Back**.

9. Expand **Database Objects** in the **Database Firewall Policy Rules** section.
    - Click **Add**.
    - Enter the following rule details:
        - Rule Name: *DBA activity on app sensitive objects*
        - Description: *DBA activity over the network*
        - Profile: *DBAs over network*
        - Commands: Select *DELETE, INSERT, UPDATE*
        - DB Object Set: *EmployeeSearchSensitiveApplicationObjects*
        - Action: *Block*
        - Logging Level: *Always*
        - Threat Severity: *Major*

        ![AVDF](./images/360-42.png "Database Object rule-1")
        This rule blocks INSERT, UPDATE, and DELETE operations by users in the Database Administrators set on sensitive objects over the network.
    - Click **Save**.

10. Create another **Database Objects** rule.

    - Enter the following rule details:
        - Rule Name: *Detect exfiltration attempt by DBAs*
        - Description: *DBA activity over the network*
        - Profile: *DBAs over network*
        - Commands: Select *SELECT*
        - Capture number of rows returned for SELECT queries: *Select*
        - DB Object Set: *EmployeeSearchSensitiveApplicationObjects*
        - Action: *Alert*
        - Logging Level: *Always*
        - Threat Severity: *Moderate*

        ![AVDF](./images/360-42a.png "Database Object rule-2")
        This rule alerts on SELECT operations by users in the Database Administrators set against the sensitive-object set and records the number of rows returned.

    - Click **Save**.

11. Select the **Default** tab to define how Database Firewall handles activity that does not match the configured rules.
    ![AVDF](./images/avdf-137.png "Specify the Database Firewall policy's default action")

    - Set the following values in **Default Rule**:
        - Action: *Pass*
        - Logging Level: *Don't log*
        - Threat Severity: *Minimal*
    
12. Click **Save**.

13. Select **EmployeeSearchAccessOverNetwork** and click **Deploy**.

    ![AVDF](./images/avdf-141a.png "HR Policy deployment")

14. Select **`employees_search`** and click **Deploy**.

    ![AVDF](./images/avdf-141b.png "Select targets for Database Firewall Policy")

15. Refresh the page and verify that **EmployeeSearchAccessOverNetwork** is deployed for **`employees_search`**.

    ![AVDF](./images/360-44.png "Database Firewall Policy deployed for employees_search")

</details>

<details>
<summary><strong>Step 2: Configure alerts for Database Firewall activity</strong></summary>

1. Click **Policies**.

2. Select **Alert Policies** from the left menu.

3. Review **Database Firewall Alert**. This alert monitors Database Firewall events that are blocked or alerted.

4. Create an alert for queries that return more than 100 rows of employee data.

    - Click **Create** and enter:

        - Alert policy name: *PII Exfiltration Alert*
        - Description: *Someone has selected more than 100 rows of PII in a single query*
        - Target type: *Oracle Database*
        - Severity: *Warning*
        - Threshold (times): *1*
        - Duration: *1*
        - Group By (Field): *USER*

        ![AVDF](./images/avdf-656.png "Alert policy parameters")

    - Click **Alert Assistant** next to the **Condition** field and enter:

        <pre class="text"><code><copy>When someone selects more than 100 records in DEMO_HR_EMPLOYEES table in a single query</copy></code></pre>

    - Click **Generate alert condition**.

    - Review the generated condition. It should check the employee table, SELECT activity, and a returned-row count greater than 100:

        <pre class="sql"><code><copy>(:OBJECT = 'DEMO_HR_EMPLOYEES') AND (:OBJECT_TYPE = 'TABLE') AND (:COMMAND_CLASS = 'SELECT') AND (:ROW_COUNT &gt; 100)</copy></code></pre>

        ![AVDF](./images/avdf-656a.png "Alert Assistant")

    - Click **Use this alert condition**, then **Save** to create the policy.

</details>

<details>
<summary><strong>Step 3: Generate activity and verify reports and alerts</strong></summary>

1. In **Remote Desktop**, open the terminal on the database host.

2. Go to the lab script directory:

    <pre class="bash"><code><copy>cd $DBSEC_LABS/avdf/avs</copy></code></pre>

3. Verify connectivity both directly and through Database Firewall.

    - Verify connectivity to **`employees_search`** without Database Firewall:

        <pre class="bash"><code><copy>./dbf_sqlplus_without_dbfw.sh freepdb1</copy></code></pre>

        ![AVDF](./images/avdf-105.png "Connectivity without Database Firewall")

        The direct connection uses listener port **1521** and shows client IP **10.0.0.150**, the DBSec-Lab VM address.

    - Verify connectivity to **`employees_search`** through Database Firewall:

        <pre class="bash"><code><copy>./dbf_sqlplus_with_dbfw.sh freepdb1</copy></code></pre>

        ![AVDF](./images/avdf-106.png "Connectivity through Database Firewall")

        The proxy connection uses port **15223** and shows client IP **10.0.0.152**, the Database Firewall VM address.

4. Run the policy test script, which connects as **`DBA_DEBRA`**:

    <pre class="bash"><code><copy>./dbf_query_fw_policy.sh freepdb1</copy></code></pre>

    ![AVDF](./images/avdf-128.png "Database Firewall policy test")

    Review the output. Database Firewall blocks the DELETE statement. SELECT statements on the sensitive objects execute and generate alert events.

5. Run the exfiltration simulation as **`DBA_DEBRA`**:

    <pre class="bash"><code><copy>./dbf_exfiltrate_with_dbfw.sh freepdb1 dba_debra</copy></code></pre>

    ![AVDF](./images/avdf-128a.png "Exfiltration simulation")

    The SELECT activity is alerted, and Database Firewall captures the number of rows returned. The PII Exfiltration Alert identifies a query returning more than 100 rows from **`DEMO_HR_EMPLOYEES`**.

6. Return to Security Central Console as *`AVAUDITOR`*.

7. Open **Reports**. Under **Database Firewall Reports**, select **Monitored Activity**.

    ![AVDF](./images/360-45.png "Database Firewall reports")

8. Review the generated activity for **`employees_search`**. Display **Action Taken**, **Policy Name**, **Rule Name**, and **Row Count** to verify that the DELETE was blocked and that SELECT activity and returned-row counts were recorded. Refresh the report if the new events have not appeared yet.

9. Open **Alerts** and review the events for **Database Firewall Alert** and **PII Exfiltration Alert**.

    ![AVDF](./images/avdf-185.png "Database Firewall and PII exfiltration alerts")

    Refresh the page if the new alert events have not appeared yet.

10. Open the **Database Firewall Alert** for the **DELETE** event.

11. Click the **paper icon** in the **Event** section to inspect the event details.

    ![AVDF](./images/avdf-187.png "Database Firewall alert details")

</details>

**Core protection complete — choose your next step**

After verifying the Database Firewall reports and alerts, you have completed the **core protection task**.

**Tasks 2 and 3 are optional.** Continue with **Task 2 (Optional): SQL Firewall** or **Task 3 (Optional): Database Vault**, or proceed to **Review Compliance Evidence and Confirm Workshop Outcomes**.


## Task 2 (Optional): Use SQL Firewall to allow only authorized SQL statements and connections

SQL Firewall restricts SQL statements and connection contexts to approved users, client programs, IP addresses, and application paths.

In this task, you can train and enforce a SQL Firewall policy for the application workload and review the resulting violations.

<details>
<summary><strong>Step 1: Ensure SQL Firewall is enabled</strong></summary>

1. Log in to Security Central Console as *`AVAUDITOR`*.

2. Click **Policies**, expand **Firewall Policies** in the left menu, and select **Oracle SQL Firewall**. Verify that **SQL Firewall status** for **`employees_search`** is **Enabled**.

    ![AVDF](./images/360-20.png "AVDF - Oracle SQL Firewall page")

3. Click **`employees_search`** to open its SQL Firewall configuration.

</details>

<details>
<summary><strong>Step 2: Train SQL Firewall to learn authorized SQL traffic</strong></summary>

1. Expand **SQL learning for users (0)**.

2. Filter for **`EMPLOYEESEARCH_PROD`**, select the user, and click **Start**.

    ![AVDF](./images/360-21.png "SQL Firewall learning for EMPLOYEESEARCH_PROD")

3. In the **Start learning** dialog, select:

    - Stop learning in: *1 day*
    - **Only top level SQL**

    ![AVDF](./images/360-22.png "SQL Firewall - Start learning dialog")

4. Click **Start** and verify that **Status** for **`EMPLOYEESEARCH_PROD`** is **Learning**.

    ![AVDF](./images/360-22b.png "SQL Firewall - Learning status")

</details>

<details>
<summary><strong>Step 3: Execute the normal workload</strong></summary>

1. Open `http://dbsec-lab:8080/hr_prod_pdb1` in a browser to access the **Glassfish** application. If you are not using the remote desktop, use `http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb1`.

2. Log in as *`hradmin`* with the password *`Oracle123`*.

    <pre class="text"><code><copy>hradmin</copy></code></pre>

    <pre class="text"><code><copy>Oracle123</copy></code></pre>

    ![AVDF](./images/avdf-111.png "HR App - Login")

    ![AVDF](./images/avdf-112.png "HR App - Login")

3. In the top-right corner of the application, click **Search Employees**.

    ![AVDF](./images/avdf-113.png "Search Employees")

4. In the **HR ID** field, enter **164** and click **Search**.

    ![AVDF](./images/avdf-123.png "Search Employee - HR ID 164")

5. Clear the **HR ID** field and click **Search** again to return all rows.

    ![AVDF](./images/avdf-114.png "Search Employees")

6. Enter the following search criteria:

    - HR ID: *196*
    - Active: *Active*
    - Employee Type: *Full-Time Employee*
    - Position: *Administrator*
    - First Name: *William*
    - Last Name: *Harvey*
    - Department: *Marketing*
    - City: *London*

    ![AVDF](./images/avdf-124.png "Search Employees criteria")

7. Click **Search**.

8. Click **Harvey, William** to view the employee's details.

    ![AVDF](./images/avdf-125.png "Employee details")

9. In the top-right corner, click **Welcome HR Administrator** to open **Session Details** and review the application's database connection.

    ![AVDF](./images/avdf-115.png "HR App - Session Details")

    - **IP Address** should be **10.0.0.150**, the DBSec-Lab VM where Glassfish is hosted.
    - **`DB_NAME`** should be **FREEPDB1** for the **`employees_search`** target.

10. Log out.

    ![AVDF](./images/avdf-117.png "HR App - Log out")

</details>

<details>
<summary><strong>Step 4: Verify SQL Firewall learning is complete</strong></summary>

1. In Security Central Console, expand **SQL learning for users (1)** and select **`EMPLOYEESEARCH_PROD`**.

    - Click **View learning data** to review the SQL statements captured from the Glassfish workload.

        ![AVDF](./images/360-23.png "SQL Firewall - View learning data")

    - If **JDBC Thin Client** activity is not yet visible in **Client program**, click **Refresh learning data**.
    - Click **Cancel** to return.

2. Click **Stop** and verify that the status changes to **Learning completed**.

    ![AVDF](./images/360-24.png "SQL Firewall - Stop learning")

</details>

<details>
<summary><strong>Step 5: Enable the SQL Firewall policy</strong></summary>

1. Expand **SQL Firewall policy for users (0)**. The policy for **`EMPLOYEESEARCH_PROD`** has been created with a status of **Disabled**.

    ![AVDF](./images/360-25.png "SQL Firewall - Disabled policy")

2. Select the policy and click **Enable**. Choose:

    - Enforcement policy: *SQL statements & session contexts*
    - Action on violations: *Block and log*

    ![AVDF](./images/360-26.png "SQL Firewall - Enforcement options")

3. Click **Enable**. Verify that the policy status is **Enabled**, the enforcement policy is **SQL statements & session contexts**, and the action on violations is **Block and log**. Refresh the page if necessary.

    ![AVDF](./images/360-27.png "SQL Firewall - Enabled policy")

4. Open the policy for **`EMPLOYEESEARCH_PROD`** and review:

    - Enforcement options
    - Session context: **Client IP address**, **Client program**, and **OS user**
    - Allowed SQL statements

    ![AVDF](./images/360-28.png "SQL Firewall - Policy details")

5. Click **Cancel**.

</details>

<details>
<summary><strong>Step 6: Ensure SQL Firewall violations are being collected</strong></summary>

1. Click **Targets**, then select **Targets** from the left menu.

2. Open **`employees_search`** to review its audit trails. The HOL is preconfigured to collect SQL Firewall violations from this target. Verify that the **`SYS.DBA_SQL_FIREWALL_VIOLATIONS`** table audit trail is **Collecting** or **Idle**.

    ![AVDF](./images/360-29.png "SQL Firewall violations audit trail")

</details>

<details>
<summary><strong>Step 7: Validate SQL Firewall protection controls</strong></summary>

Validate SQL Firewall protection by triggering connection-context and SQL-statement violations. First, connect using *SQLPLUS* to simulate a connection-context violation.

1. In your terminal session on the database host, go to the AVS directory:

    <pre class="bash"><code><copy>cd $DBSEC_LABS/avdf/avs</copy></code></pre>

    Imagine you are someone who has access to the stolen application service-account credentials of **`EMPLOYEESEARCH_PROD`** and is trying to access the database while bypassing the application's normal access path.

    <pre class="bash"><code><copy>./avs_sqlfw_risk.sh</copy></code></pre>

2. Verify that the connection is blocked with **ORA-47605: SQL Firewall violation**.

    ![AVDF](./images/360-30.png "SQL Firewall - Context violation")

    Next, simulate a SQL statement violation by attempting SQL injection through the Glassfish application.

3. Return to Glassfish, log out, and log in as *`hradmin`* with the password *`Oracle123`*. Click **Search Employees**, then click **Search** without entering any search criteria.

    ![AVDF](./images/avdf-114.png "Search Employees")

    All rows are returned because this normal search query was captured during learning and is allowed by the SQL Firewall policy.

4. Select the **Debug** checkbox to display the SQL query used by the search form.

    ![AVDF](./images/avdf-162.png "Display the search form's SQL query")

5. Click **Search** again. Review the displayed query to see the selected columns and their order.

    ![AVDF](./images/avdf-163.png "Search query in debug mode")

6. Use the following UNION-based SQL injection attempt to request **`USERID`**, **`MEMBER_ID`**, **`PAYMENT_ACCT_NO`**, and **`ROUTING_NUMBER`** from **`DEMO_HR_SUPPLEMENTAL_DATA`**. SQL Firewall should block this statement because it was not part of the learned workload.

    <pre class="sql"><code><copy>' UNION SELECT userid, ' ID: '|| member_id, 'SQLi', '1', '1', '1', '1', '1', '1', 0, 0, payment_acct_no, routing_number, sysdate, sysdate, '0', 1, '1', '1', 1 FROM demo_hr_supplemental_data --</copy></code></pre>

7. Copy the complete statement into the **Position** field and keep **Debug** selected. Include the leading single quote (`'`) and trailing comment marker (`--`) exactly as shown.

    ![AVDF](./images/avdf-164.png "SQL injection attempt in the Position field")

8. Click **Search** and verify that SQL Firewall blocks the statement. The UNION query is not an authorized SQL statement in the learned policy.

    ![AVDF](./images/360-30a.png "SQL Firewall blocks the unauthorized statement")

9. In the terminal session on the database host, go to the AVS directory:

    <pre class="bash"><code><copy>cd $DBSEC_LABS/avdf/avs</copy></code></pre>

10. Run the following test using the **`EMPLOYEESEARCH_PROD`** credentials from a non-application path. Verify that SQL Firewall rejects the connection because the client context is not the approved Glassfish application context.

    <pre class="bash"><code><copy>./dbf_exfiltrate_with_dbfw.sh freepdb1 employeesearch_prod</copy></code></pre>

    ![AVDF](./images/avdf-128b.png "SQL Firewall context violation")

</details>

<details>
<summary><strong>Step 8: Monitor SQL Firewall violations</strong></summary>

1. Return to Security Central Console as *`AVAUDITOR`*.

2. Click **Policies**, expand **Firewall Policies** in the left menu, and select **Oracle SQL Firewall**. Review the session-context violations from the SQLPLUS connection and the SQL-statement violations from the Glassfish SQL injection attempt against **`employees_search`**. Refresh the page if necessary.

    ![AVDF](./images/360-31.png "SQL Firewall - Violation summary")

3. Click **Reports**, expand **SQL Firewall Violations Report**, and open **SQL Firewall Violations**. Use **Actions → Select Columns** to display **Action Taken** and confirm that the violations were blocked.

    ![AVDF](./images/360-32.png "SQL Firewall violations report")

</details>


## Task 3 (Optional): Use Database Vault to enforce least privilege

**Note:** Database Vault is an optional and independent control. It can be completed without completing the Database Firewall or SQL Firewall tasks.

Database Vault protects the **`customer_orders`** target through realm authorization and separation of duties. It separates database administration from access to protected application data, helping prevent privileged users from bypassing the realm's access controls.

In this task, authorize **`BA_ALEX`** to access the protected Customer Orders data, then compare that access with **CUSTOMERADMIN**, who does not have realm authorization. Configure audit collection and an alert before running the tests, then verify the blocked access in reports and alerts.

<details>
<summary><strong>Step 1: Review the Database Vault realm protection</strong></summary>

1. Log in to the Security Central console as *`AVAUDITOR`*.

2. Click **Policies**, then select **Database Vault Policies**.
    ![AVDF](./images/360-50.png "AVDF - Oracle DV page")

    **Note:** Verify that **DV status** for **`customer_orders`** is **Enabled**.

    - Click **`customer_orders`** to review its configuration.

3. Click **Provide credentials to manage policies** and enter the credentials for **C##DVOWNER**, using the password *`Oracle123`*.
    ![AVDF](./images/360-51.png "AVDF - Oracle DV page credentials")

4. Expand **Object protection** to review the preconfigured LiveLabs settings.
    ![AVDF](./images/360-52.png "AVDF - Oracle DV page credentials")

    **Note:** The realm **`PROTECT_CUSTOMER_ORDERS`** is preconfigured in the instance and protects objects in the **CO** schema. Initially, only the schema owner is authorized to access these protected objects.
</details>

<details>
<summary><strong>Step 2: Authorize a user in the realm</strong></summary>

Authorize business user **`BA_ALEX`** as a realm participant for reporting on Customer Orders data.

1. Drill down into **`PROTECT_CUSTOMER_ORDERS`**, expand **Authorized users/roles**, and click **Add**.
2. Check **Select users/roles**, enter **`BA_ALEX`** as the user, and click **Add**.
    ![AVDF](./images/360-53.png "AVDF - Oracle DV page credentials-add user")
3. Expand **Audit Details** and select **Success** and **Failure**.
4. Click **Save**.
</details>

<details>
<summary><strong>Step 3: Ensure DV violation events are collected</strong></summary>

The HOL is preconfigured to collect Database Vault events and violations from **`customer_orders`**.

1. Click **Targets**, select **Targets** from the left menu, and open **`customer_orders`**.

    ![AVDF](./images/360-54.png "Database Vault audit trails")

2. Verify that the configured audit trails are **Collecting** or **Idle**.

</details>

<details>
<summary><strong>Step 4: Write the alert condition</strong></summary>

Create an alert policy before generating a realm violation so that the test event can trigger an alert.

1. Click **Policies**, select **Alert Policies** from the left menu, and click **Create**.

2. Enter the following alert policy details:

    - Alert policy name: *DV realm violation*
    - Description: *Alert when protected realm objects are accessed without appropriate authorization*
    - Target type: *Oracle Database*
    - Severity: *Warning*
    - Threshold (times): *1*

    In **Condition**, enter:

    <pre class="sql"><code><copy>:TARGET = 'customer_orders' AND :COMMAND_CLASS = 'VIOLATE' AND :OBJECT_TYPE = 'REALM'</copy></code></pre>

3. Review the alert policy details.

    ![AVDF](./images/360-57.png "Database Vault realm violation alert policy")

4. Click **Save**.

</details>

<details>
<summary><strong>Step 5: Run the load</strong></summary>

Compare authorized and unauthorized access using queries against **CO.ORDERS**.

1. Open the terminal on the database host and go to the AVS directory:

    <pre class="bash"><code><copy>cd $DBSEC_LABS/avdf/avs</copy></code></pre>

2. Run the query as **`BA_ALEX`**, who has both the required object privilege and realm authorization. The query should succeed.

    <pre class="bash"><code><copy>./avs_orders_count_sqlplus.sh BA_ALEX</copy></code></pre>

3. Run the same query as **CUSTOMERADMIN**, who has the object privilege but does not have realm authorization. Database Vault should block access and generate a realm violation.

    <pre class="bash"><code><copy>./avs_orders_count_sqlplus.sh CUSTOMERADMIN</copy></code></pre>

    ![AVDF](./images/360-55.png "Database Vault - Authorized and blocked query results")

</details>

<details>
<summary><strong>Step 6: Validate the violation report and alert result</strong></summary>

1. Return to Security Central Console as *`AVAUDITOR`*.

2. Click **Reports** and open **All Activity Report**. Review the Database Vault realm violation for **CUSTOMERADMIN** on **`customer_orders`**.

    ![AVDF](./images/360-56.png "Database Vault realm violation in the activity report")

3. Open **Alerts** and review the **DV realm violation** alert generated by the **CUSTOMERADMIN** test.

    ![AVDF](./images/avdf-654.png "Database Vault realm violation alert")

4. Refresh the report or alerts page if the new events have not appeared yet.

</details>

You may now **proceed to the next lab**.

## What did we learn in this lab

You followed the protection and prevention cycle:

- Configured and deployed a Database Firewall policy for privileged users and sensitive objects.
- Configured an alert for queries returning more than 100 rows of employee data.
- Tested blocked DML activity and alerted SELECT activity.
- Verified the results in Database Firewall reports and alerts.
- Identified SQL Firewall and Database Vault as optional controls for additional protection.
