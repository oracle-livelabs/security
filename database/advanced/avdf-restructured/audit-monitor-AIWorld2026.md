# Audit, Monitor, and Alert on Privileged Activity

## Introduction
In the previous lab, Security Central identified a control gap: sensitive employee data in the **employees_search** and **customer_orders** PDBs is accessed by privileged users, but the activity is not yet consistently audited and surfaced for response.

In this lab, turn the findings into actionable protection. Centralized auditing creates the evidence needed to understand privileged activity and sensitive-data access, while alerts make important events visible for response. You will first provision the audit policies, then use a new alert to validate that activity by privileged users can be detected.

*Estimated Lab Time:* 15 minutes


<!--
### Video Preview

Watch a preview of "*LiveLabs - Oracle Database Security Central (Security Central)*" [](youtube:eLEeOLMAEec)
-->

## Objectives
- Provision audit policies for privileged users and sensitive objects
- Create and validate an alert for privileged-user activity


## Task 1: Provision audit policies for privileged users and sensitive objects

Begin by provisioning the audit policies that collect the evidence for the next task. Apply **User Activity** to both PDBs, **Sensitive Data Access Monitoring** to **employees_search**, and the **CIS Configuration** policy to **customer_orders**.
<details>
<summary> **Step 1: Provision audit policies for employees_search** </summary>

1. Open the Security Central console as **AVAUDITOR**

2. Click **Policies**, then select **Audit Policies** from the left menu
    ![AVDF](./images/360-11.png "AVDF - Audit Policies page")

    **Note**: If the **Last Retrieved time** is *Never*, select the **`employees_search`** pdb and click **Retrieve policies** to retrieve the latest from the database.

3. Select **employees_search** PDB to review the enabled policies
    ![AVDF](./images/360-12.png "AVDF - Audit Policies for Employees Search pdb")

    **Note:** A few audit policies, including **System Configuration Changes**, **Critical Database Activity**, **User Login Events**, and **Database schema changes**, are already enabled in the LiveLabs instance. 

4. Provision **User Activity** to track privileged-user activity
    - Expand **User Actions**
    - Click **User Activity**
    - Keep the default *Policy enable condition* and ensure that *Privileged users identified by User Assessment* is selected.
        ![AVDF](./images/360-13.png "AVDF - User Activity Policy enable condition")
        - Click **Enable**. Refresh the page if necessary until the status shows **Enabled**.

5. Provision **Sensitive Data Access Monitoring** to track sensitive-data access
    - Expand **Data access**
    - Click **Sensitive Data Access Monitoring**
    - Ensure that **Audit SELECT operations** remains selected.
    - Ensure that **Sensitive objects discovered by Sensitive Data Discovery** is selected.
        ![AVDF](./images/360-14.png "AVDF - Sensitive Data Access Monitoring Policy")
    - Enable the policy for all users except the application service account (`EMPLOYEESEARCH_PROD`).
         ![AVDF](./images/360-15.png "AVDF - Sensitive Data Access Monitoring Policy condition")
         - Set *Enable policy for* to **All users except a specific set of users**. 
         - Click **Add Row**, select **User** as the type, and select **`EMPLOYEESEARCH_PROD`** from the dropdown.
    - Click **Enable** and review to see the status as **Enabled** in the policies page. You may have to refresh the page couple of times till it reflects.

</details>


<details>
<summary> **Step 2: Provision audit policies for customer_orders**</summary>

1. Click on **customer_orders** pdb to review the policies enabled
    ![AVDF](./images/360-12a.png "AVDF - Audit Policies for customer orders pdb")

    **Note:** A few audit policies, including **System Configuration Changes**, **Critical Database Activity**, **User Login Events**, and **Database schema changes**, are already enabled in the LiveLabs Terraform configuration. 

2. Provision the audit policy to track **privileged user activity**
    - Expand **User Actions**
    - Click **User Activity**
    - Keep the default *Policy enable condition* and ensure that *Privileged users identified by User Assessment* is selected.
        ![AVDF](./images/360-13.png "AVDF - User Activity Policy enable condition")
    - Click **Enable** and review to see the status as **Enabled** in the policies page

Security Central also provides ready-to-deploy audit policies for common compliance frameworks. For this target, enable the CIS Configuration policy with a single action.

3. Provision the CIS Configuration policy for compliance coverage
    - Expand **Compliance**
    - Select **Center for Internet Security (CIS) Configuration** and click **Enable**
        ![AVDF](./images/360-16.png "AVDF - CIS Audit policy")

4. Review the enabled policies for the **customer_orders** PDB.
      ![AVDF](./images/360-11a.png "AVDF - Audit Policies page")
</details>


<details>
<summary> **Step 3: Verify audit-policy provisioning completed**</summary>

1. Click on the **Settings** tab
    - Click on the **Jobs** section on the left menu
    - You should see **Job Type** that says **Provision Audit Policies**. The status should be set to **Completed**.

        ![AVDF](./images/avdf-553.png "Verify the job completed successfully")
        **Note:** If not, please refresh the web page  (press [F5] for example) until it shows **Completed** and it was provisioned on **`employees_search`** and **`customer_orders`**

</details>

> **Expected outcome:** **User Activity** is enabled for both PDBs, **Sensitive Data Access Monitoring** is enabled for **employees_search**, the **CIS Configuration** policy is enabled for **customer_orders**, and the provisioning job has completed for both targets.

## Task 2: Create an alert for privileged-user activity


Audit policies now collect the evidence needed to understand database activity. In this task, turn that evidence into an actionable signal by creating an alert for activity by users in the privileged-user set. Use the Alert Assistant to define the condition in plain English, then verify that the alert is enabled.


<details>
<summary> **Step 1: Create an alert for privileged-user activity** </summary>


1. Click **Policies**, then select **Alert Policies** from the left menu.


2. Click **Create**.


3. Enter the following information:


    - Alert policy name: *`Privileged-user activity`*
    - Description: *`Alert when any user in the Database Administrators set performs database activity.`*
    - Target type: *`Oracle Database`*
    - Severity: *`Warning`*


        ![AVDF](./images/alert-policy-form-before-condition-AIWorld2026.png "Alert policy form before defining the condition")


4. Click the **Alert Assistant** icon next to the **Condition** field.


5. In **Describe the condition**, enter:


    ```
    Create an alert when any user in Database Administrators set performs any database activity.
    ```


6. Click **Generate alert condition**.


7. Review the generated condition:


    ```
    (avsys.ae_globalset.check_user(:USER, 'IN', 'Database Administrators') = 1)
    ```


    **Note:** AI-generated conditions are not guaranteed to be complete or correct. Review the generated condition before using it.


    ![Alert Assistant generated condition](./images/alert-assistant-generated-AIWorld2026.png "Generate an alert condition using the Alert Assistant")


8. Click **Use this alert condition**.


9. Leave **Threshold (number)** set to *`1`*.


10. Review the completed alert configuration.


    Your alert should look like this:


    ![AVDF](./images/alert-policy-form-completed-AIWorld2026.png "Completed alert policy configuration")


11. Click **Save**.


12. When prompted to enable the policy, click **OK**.


13. On the **Alert Policies** page, verify that **Privileged-user activity** is listed as **Enabled**. <br><img src="./images/alert_enabled.png" alt="Alert policy enabled">


</details>


> **Expected outcome:** An enabled alert policy monitors activity performed by users in the **Database Administrators** set.

## Task 3: Generate activity and verify audit evidence

The audit policies and alert policy are now enabled. In this task, generate controlled activity using two users in the **Database Administrators** set. Then verify that the activity appears in Security Central reports and generates alerts.

### Step 1: Generate privileged-user activity

1. Open the terminal on the database host.

2. Run the tested script for **DBA_DEBRA**:

    ```bash
    ./dbf_exfiltrate_with_dbfw.sh freepdb1 dba_debra
    ```

3. Run the script again for **DBA_HARVEY**:

    ```bash
    ./dbf_exfiltrate_with_dbfw.sh freepdb1 DBA_HARVEY
    ```

4. After both commands complete, return to Security Central.

> **Note:** `freepdb1` is the PDB name used by the script. In Security Central, this PDB is registered as the **employees_search** target.

> **Database console screenshot:** To be added.

### Step 2: Verify activity in reports

1. Open **Reports**.
2. Open **Sensitive Data Discovery Reports**.
3. Select **Activity on sensitive data by privileged users**.
4. Refresh the report.
5. Verify activity from **DBA_DEBRA** and **DBA_HARVEY** for the **employees_search** target.
6. Confirm the user, registered target, PDB or database, sensitive object, activity or action, and event time.

![Activity on sensitive data by privileged users](./images/activity-sensitive-data-privileged-users-AIWorld2026.jpeg "Activity on sensitive data by privileged users")

7. Return to the reports list and open **All Activity by Privileged Users**.
8. Refresh the report.
9. Verify activity from both users for **employees_search**.

![All Activity by Privileged Users](./images/all-activity-by-privileged-users-AIWorld2026.jpeg "All Activity by Privileged Users")

> **Expected outcome:** Activity is visible in both the sensitive-data report and the broader privileged-user activity report.

### Step 3: Verify generated alerts

1. Open **Alerts**.
2. Filter the results for the **Privileged-user activity** policy.
3. Verify alert events corresponding to **DBA_DEBRA** and **DBA_HARVEY**, and confirm the policy, severity, user, target, and event details.

![Generated Privileged-user activity alerts](./images/alert-generated-privileged-user-activity-AIWorld2026.jpeg "Generated Privileged-user activity alerts")

> **Expected outcome:** The enabled **Privileged-user activity** policy generates alert events for users in the **Database Administrators** set.

> **Final validation:** Activity generated by **DBA_DEBRA** and **DBA_HARVEY** against the `freepdb1` PDB is visible under the registered **employees_search** target in audit reports and generates corresponding alert events.

## What did we learn in this lab

Security Central turns audit data into actionable visibility. In this lab, you provisioned audit policies for privileged users and sensitive objects, then used the Alert Assistant to create an alert from a plain-English description. Together, these controls provide evidence of database activity and a signal that helps security teams respond to privileged-user activity.

In this lab, you learned how to:
- Provision audit policies for privileged users and sensitive objects
- Use the Alert Assistant to translate a plain-English requirement into an alert condition.
- Enable an alert and verify that it monitors activity performed by users in the Database Administrators set.

You may now **proceed to the next lab**.

