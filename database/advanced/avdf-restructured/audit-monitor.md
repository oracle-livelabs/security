# Establish visibility first: audit and monitor

## Introduction
Now that you have the necessary insights, you begin by configuring activity monitoring, followed by implementing preventive controls.
- The **Employees_search** pdb supports internal self-service applications, and contains a high volume of sensitive data and is accessible to privileged users, making insider threat mitigation the top priority. You enable auditing to track security-relevant events, privileged user activity, and access to sensitive data.
- For the **Customer_orders** pdb, the primary focus is mitigating external threats and demonstrating compliance (e.g., CIS). You enable auditing for system configuration changes, critical database activity, and schema changes, and additionally provision user activity and CIS compliance policies.

*Estimated Lab Time:* 10 minutes

*Version tested in this lab:* Oracle Database Security Central (Security Central)

### Video Preview

Watch a preview of "*LiveLabs - Oracle Database Security Central (Security Central)*" [](youtube:eLEeOLMAEec)


### Objectives
- Configure database activity monitoring with audit
- Pro-actively monitor actionable audit events with alerts


## Task 1: Configure database activity monitoring with audit

Security Central enables comprehensive database activity monitoring by collecting and aggregating audit data, along with network-based monitoring of SQL traffic. For Oracle Database, it provides centralized capabilities to manage and provision audit policies, ensuring consistent monitoring, improved visibility, and stronger security governance across the database environment.

### **Step 1: Ensure audit trails are configured for Oracle databases**

**Note** In the livelab, we have already configured the audit trail for the Oracle databases. 

You can see the same from "**Targets**" > "**Audit Trails**" (with **AVADMIN** login)

![AVDF](./images/avdf-551.png "Audit Trail")

**Notes** Ensure the **`UNIFIED_AUDIT_TRAIL`** table audit trails are either in **Collecting** or in **Idle** state

### **Step 2: Retrieve and provision the Unified audit policies for Employees_search pdb**


1. Go to Security Central Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF - Login")

2. Click on the **Policies** tab, and **Audit Policies** in the left menu
    ![AVDF](./images/360-11.png "AVDF - Audit Policies page")

    **Note**: If the **Last Retrieved time** is *Never*, select the **`Employees_search`** pdb and click **Retrieve policies** to retrieve the latest from the database.You can schedule the periodical retrieval following *Lab5->Task3->Step2*.

3. Click on **Employees_search** pdb to review the policies enabled
    ![AVDF](./images/360-12.png "AVDF - Audit Policies for Employees Search pdb")

    **Note**: We have enabled few audit policies like **System Configuration Changes**, **Critical Database Activity**, and **Database Schema changes** in the terraform for the livelab instance. 

4. Provision the audit policy to track **privileged user activity**
    - Expand **User Actions**
    - Click **User Activity**
    - Leave the default policy enable condition pick the privileged users identified by User Assessment
        ![AVDF](./images/360-13.png "AVDF - User Activity Policy enable condition")
    - Click **Enable** and review to see the status as **Enabled** in the policies page

5. Next, provision the audit policy to track **sensitive data access**
    - Expand **Data access**
    - Click **Sensitive Data Access Monitoring**
    - Unselect checkbox **Audit SELECT operations**
    - Ensure this is checked **Sensitive objects discovered by sensitive data discovery**
        ![AVDF](./images/360-14.png "AVDF - Sensitive Data Access Monitoring Policy")
    - Enable policies for all users except Application service account (`EMPLOYEESEARCH_PROD`)
         ![AVDF](./images/360-15.png "AVDF - Sensitive Data Access Monitoring Policy condition")
         - Click **Add Row**, select **User** as Type, and enter **`EMPLOYEESEARCH_PROD`**
    - Click **Enable** and review to see the status as **Enabled** in the policies page

6. Go back to **Audit Policies** 
### **Step 3: Retrieve and provision the Unified audit policies for Customer_orders pdb**

1. Click on **customer_orders** pdb to review the policies enabled
    ![AVDF](./images/360-12.png "AVDF - Audit Policies for customer orders pdb")

    **Note**: We have enabled few audit policies like **System Configuration Changes**, **Critical Database Activity**, and **Database Schema changes** in the terraform for the livelab instance. 

2. Provision the audit policy to track **privileged user activity**
    - Expand **User Actions**
    - Click **User Activity**
    - Leave the default policy enable condition pick the privileged users identified by User Assessment
        ![AVDF](./images/360-13.png "AVDF - User Activity Policy enable condition")
    - Click **Enable** and review to see the status as **Enabled** in the policies page

3. Provision the audit policy to help comply with CIS
    - Expand **Compliance**
    - Select **Center for Internet Security (CIS) Configuration** and click **Enable**
        ![AVDF](./images/360-16.png "AVDF - CIS Audit policy")

4. Go back to **Audit Policies** and review the policy count for **`Employees_search`** and **`Customer_orders`** pdb
      ![AVDF](./images/360-11.png "AVDF - Audit Policies page")

### **Step 4: Ensure the audit policy provisioning jobs succeeds, and policies enabled on the target**

1. Click on the **Settings** tab
    - Click on the **Jobs** section on the left menu bar
    - You should see at least one **Job Type** that says **Provision Audit Policies**

        ![AVDF](./images/avdf-553.png "Verify the job completed successfully")

    - If not, please refresh the web page  (press [F5] for example) until it shows **Completed** and it was provisioned on **`Employees_search`** and **`Customer_orders`**

2. Ensure the Unified Audit policies are enabled on the target using **SQL*Plus**

    - Go back to your terminal session and show the **enabled** Unified Audit policies in **`employee_search`** 

        ````
        <copy>./avs_query_enabled_unified_policies.sh freepdb1</copy>
        ````

        ![AVDF](./images/avdf-015.png "Show the enabled Unified Audit policies")
**Note** Repeat the query for **`customer_orders`** pdb and re-confirm

> [!TIP]
> You've now provisioned audit policies in the target that generates an audit event when actions tracked occur in the database. Let's see how to collect these audit events and raise actionable alerts

## Task 2: Pro-actively monitor actionable audit events with alerts

### **Step 1: Provision alert policy for account management operations**


1. Click on the **Policies** tab

2. Create the alter policy "**Alert whenever there is a user created, dropped or altered**"

    - Click on the **Policies** tab

    - Click the **Alert Policies** sub-menu on left

    - Click [**Create**]

    - Enter the following information for our new **Alert**

        - Alert policy name: *`User creation/modification`*
        - Description: *`Alert when the user is created, dropped, or altered`*
        - Target type: *`Oracle Database`*
        - Severity: *`Warning`*
        - Condition: Click on **"Copy conditions from examples"** and copy condition **"User creation/modification"**
            
            ![AVDF](./images/avdf-651.png "Copy Alerts")
    
        - Threshold (times): *`1`*

        **Note:** You can also enable email notification for the alerts
        - Click on **Configure email notification** and provide email address
        - **You need to have SMTP server** configured for the email notification

    - Your Alert should look like this.

        ![AVDF](./images/avdf-652.png "AVDF Alerts")

    - Click [**Save**]

        **Note:** Your Alert is automatically started!

           ![AVDF](./images/avdf-653.png "Confirm creation")

    **Note:** You can also create alert using global sets. 

3. Go back to your terminal session on DBSeclab VM and create users within the **`Employees_search`** and **`Customer_orders`** pluggable databases

    ````
    <copy>
    ./avs_create_users.sh freepdb1
    ./avs_create_users.sh cust1
    </copy>
    ````

    ![AVDF](./images/avdf-045.png "Create users")

    Run another script to drop the users we created in the previous script

    ````
    <copy>
    ./avs_drop_users.sh freepdb1
    ./avs_drop_users.sh cust1
    </copy>
    ````

    ![AVDF](./images/avdf-048.png "Drop the users just created")

### **Step 2: Review the alerts generated**

1. Click on **Alerts** tab

2. View the Alerts that have occurred related to our user creation SQL commands

    ![AVDF](./images/avdf-654.png "View the alerts")

    **Note**: If you don't see them, refresh the page because the system catch the alerts every minute

3. Click on the details of one of the alerts

    ![AVDF](./images/avdf-655.png "View an alert")

    **Note**: Once you understand how to create an alert, feel free to create another and test it manually


> #### What did we learn in this lab
>
>>- How to provision audit policy from Security Central on Oracle database
>>- How to pro-actively monitor actionable audit events with alerts

You may now **proceed to the next lab**.

## Acknowledgements
- **Author** - Angeline Dhanarani, Database Security- Product Manager
- **Contributors** - Nazia Zaidi, Database Security - Product Manager
- **Last Updated By/Date** - Angeline Dhanarani, Database Security - Product Manager - April 2026
