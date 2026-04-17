# Establish visibility first: audit and monitor

## Introduction
Establishing visibility is the first step toward securing your database environment. With the necessary insights in place, shift your focus to first enable continuous monitoring to track user activity, detect anomalies, and understand how data is accessed and modified.

- The **employees_search** pdb supports internal self-service applications, and contains a high volume of sensitive data and is accessible to privileged users, making insider threat mitigation the top priority. You enable auditing to track security-relevant events, privileged user activity, and access to sensitive data.
- For the **customer_orders** pdb, the primary focus is mitigating external threats and demonstrating compliance. You enable auditing for system configuration changes, critical database activity, and schema changes, and additionally provision user activity and CIS compliance policies.

*Estimated Lab Time:* 10 minutes

*Version tested in this lab:* Oracle Database Security Central (Security Central)
<!--
### Video Preview

Watch a preview of "*LiveLabs - Oracle Database Security Central (Security Central)*" [](youtube:eLEeOLMAEec)
-->

### Objectives
- Configure database activity monitoring with audit
- Pro-actively monitor actionable audit events with alerts


## Task 1: Configure database activity monitoring with audit

Security Central enables comprehensive database activity monitoring by collecting and aggregating audit data, along with network-based monitoring of SQL traffic. For Oracle Database, it provides centralized capabilities to manage and provision audit policies, ensuring consistent monitoring, improved visibility, and stronger security governance across the database environment.
<details>
<summary> **Step 1: Ensure audit trails are configured** </summary>

Audit trails represent collection endpoints for database activity events. They gather audit data from multiple sources, normalize and centralize it for monitoring and analysis. 

1. Examine the audit trails that we have already configured for you in this livelab:
    - You can see them from **Targets** tab > "**Audit Trails**" menu (with **AVADMIN** login)
        ![AVDF](./images/avdf-551.png "Audit Trail")
        **Note:** Ensure the trails are either in **Collecting** or in **Idle** state in your lab.

</details>

<details>
<summary> **Step 2: Provision audit policies for employees_search pdb** </summary>

    💡 **TIP:** Unified audit policies in Oracle Database define what database activities should be audited. They can be provisioned and managed from Security Central.

1. Go to Security Central Console as *`AVAUDITOR`*

2. Click on the **Policies** tab, and **Audit Policies** in the left menu
    ![AVDF](./images/360-11.png "AVDF - Audit Policies page")

    **Note**: If the **Last Retrieved time** is *Never*, select the **`employees_search`** pdb and click **Retrieve policies** to retrieve the latest from the database.You can schedule the periodical retrieval following *Lab5->Task3->Step2*.

3. Click on **employees_search** pdb to review the policies enabled
    ![AVDF](./images/360-12.png "AVDF - Audit Policies for Employees Search pdb")

    **Note**: We have enabled few audit policies like **System Configuration Changes**, **Critical Database Activity**, **User Login Events**, and **Database Schema changes** in the livelab instance. 

4. Provision the audit policy to track **privileged user activity**
    - Expand **User Actions**
    - Click **User Activity**
    - Use the defaults for *Policy enable condition*. Make sure this is selected: *Privileged users identified by User Assessment*
        ![AVDF](./images/360-13.png "AVDF - User Activity Policy enable condition")
        - Click **Enable** and review to see the status as **Enabled** in the policies page. You may have to refresh the page couple of times till it reflects.

5. Next, provision the audit policy to track **sensitive data access**
    - Expand **Data access**
    - Click **Sensitive Data Access Monitoring**
    - Unselect checkbox **Audit SELECT operations**
    - Ensure this is checked **Sensitive objects discovered by sensitive data discovery**
        ![AVDF](./images/360-14.png "AVDF - Sensitive Data Access Monitoring Policy")
    - Enable policies for all users except Application service account (`EMPLOYEESEARCH_PROD`)
         ![AVDF](./images/360-15.png "AVDF - Sensitive Data Access Monitoring Policy condition")
         - Select *Enable policy for* checbox as **All users except a specific set of users** 
         - Click **Add Row**, select **User** as Type, and select **`EMPLOYEESEARCH_PROD`** from the dropdown
    - Click **Enable** and review to see the status as **Enabled** in the policies page. You may have to refresh the page couple of times till it reflects.

6. Go back to **Audit Policies** 
</details>

<details>
<summary> **Step 3: Provision audit policies for customer_orders pdb**</summary>

1. Click on **customer_orders** pdb to review the policies enabled
    ![AVDF](./images/360-12a.png "AVDF - Audit Policies for customer orders pdb")

    **Note**: We have enabled few audit policies like **System Configuration Changes**, **Critical Database Activity**, and **Database Schema changes** in the terraform for the livelab instance. 

2. Provision the audit policy to track **privileged user activity**
    - Expand **User Actions**
    - Click **User Activity**
    - Use the defaults for *Policy enable condition*.
        ![AVDF](./images/360-13.png "AVDF - User Activity Policy enable condition")
    - Click **Enable** and review to see the status as **Enabled** in the policies page

3. Provision the audit policy to help comply with CIS compliance
    - Expand **Compliance**
    - Select **Center for Internet Security (CIS) Configuration** and click **Enable**
        ![AVDF](./images/360-16.png "AVDF - CIS Audit policy")

4. Go back to **Audit Policies** and review the policies for **`employees_search`** and **`customer_orders`** pdb
      ![AVDF](./images/360-11a.png "AVDF - Audit Policies page")
</details>

<details>
<summary> **Step 4: Ensure the audit policy provisioning succeeds**</summary>

1. Click on the **Settings** tab
    - Click on the **Jobs** section on the left menu
    - You should see **Job Type** that says **Provision Audit Policies**. The status should be set to **Completed**.

        ![AVDF](./images/avdf-553.png "Verify the job completed successfully")
        **Note:** If not, please refresh the web page  (press [F5] for example) until it shows **Completed** and it was provisioned on **`employees_search`** and **`customer_orders`**

2. Ensure the Unified Audit policies are enabled on the target using **SQL*Plus**

    - Go back to your terminal session and show the **enabled** Unified Audit policies in **`employee_search`** 

        ````
        <copy>./avs_query_enabled_unified_policies.sh freepdb1</copy>
        ````

        ![AVDF](./images/avdf-015.png "Show the enabled Unified Audit policies")
        **Note:** Repeat the query for **`customer_orders`** pdb and confirm

        ````
        <copy>./avs_query_enabled_unified_policies.sh cust1</copy>
        ````


    💡 **TIP:** You have provisioned unified audit policies on the target database to generate audit events for tracked actions. Next, you will learn how to turn them into actionable alerts for monitoring and response, once these are collected in **Security Central** through audit trails.

</details>

## Task 2: Pro-actively monitor actionable audit events using alerts

<details>
<summary> **Step 1: Provision alert policy**</summary>

1. Click on the **Policies** tab, and click the **Alert Policies** sub-menu on the left

2. Create the alert policy "**Alert whenever there is a user created, dropped or altered**"

    - Click [**Create**]

    - Enter the following information for the new **Alert**

        - Alert policy name: *`User creation/modification`*
        - Description: *`Alert when the user is created, dropped, or altered`*
        - Target type: *`Oracle Database`*
        - Severity: *`Warning`*
        - Condition: Click on **"Copy conditions from examples"** and copy condition **"User creation/modification"**
            
            ![AVDF](./images/avdf-651.png "Copy Alerts")
    
        - Threshold (times): *`1`*

        **Note:** (Optional)You can also enable email notification for the alerts. 
        - Select **Enable email notification** and provide email address
        - **You need to have SMTP server** configured for the email notification. If you have it configured, you can check it out.

    - Your Alert should look like this.

        ![AVDF](./images/avdf-652.png "AVDF Alerts")

    - Click [**Save**]

        **Note:** Your Alert is automatically enabled!


3. To trigger alerts, go back to your terminal session on DBSeclab VM and create users within the **`employees_search`** and **`customer_orders`** pluggable databases

    ````
    <copy>
    ./avs_create_users.sh cust1
    </copy>
    ````

    ![AVDF](./images/avdf-045.png "Create users")

    - Repeat the same for **`employees_search`** pdb
    
    ````
    <copy>
    ./avs_create_users.sh freepdb1
    </copy>
    ````

    - Run another script to drop the users we created in the previous script

    ````
    <copy>
    ./avs_drop_users.sh cust1
    </copy>
    ````

    ![AVDF](./images/avdf-048.png "Drop the users just created")
    
    - Repeat the same for **`employees_search`** pdb
    
    ````
    <copy>
    ./avs_drop_users.sh freepdb1
    </copy>
    ````

</details>

<details>
<summary>**Step 2: Review the alerts generated**</summary>

1. Click on **Alerts** tab in the console

2. View the Alerts that have occurred related to the user creation/deletion SQL commands

    ![AVDF](./images/avdf-654.png "View the alerts")

    **Note**: If you don't see them, refresh the page. 

</details>

## What did we learn in this lab

Establishing visibility is the first step toward securing your database environment. By enabling auditing and continuous monitoring, you can track user activities, detect anomalies, and understand how data is accessed and modified. Configuring alerts ensures that suspicious or policy-violating actions are promptly brought to attention, enabling faster response and mitigation. Together, auditing, monitoring, and alerting create a strong foundation for proactive security.

In this lab, you learned how to:
- Provision unified audit policies from Security Central for Oracle Databases
- Proactively monitor audit events and respond to them using actionable alerts

You may now **proceed to the next lab**.

## Acknowledgements
- **Author** - Angeline Dhanarani, Database Security- Product Manager
- **Contributors** - Nazia Zaidi, Database Security - Product Manager
- **Last Updated By/Date** - Angeline Dhanarani, Database Security - Product Manager - April 2026
