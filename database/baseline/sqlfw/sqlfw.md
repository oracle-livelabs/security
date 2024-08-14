# Oracle SQL Firewall

## Introduction
This workshop introduces the functionality of Oracle SQL Firewall. It gives the user an opportunity to learn how to configure SQL Firewall to protect against common database risks such as SQL injection attacks and compromised accounts. SQL Firewall helps ensure that only authorized SQL statements from trusted database connections are permitted for execution inside the Oracle Database while blocking and logging unauthorized SQL or database connections.

*Estimated Lab Time:* 30 minutes

*Version tested in this lab:* Oracle Database 23ai Free

### Video Preview
Watch a preview of "*Introducing SQL Firewall – a new security capability in Oracle Database 23ai*" [DB Security - SQL Firewall](videohub:1_gbm8p6ba)

### Objectives
- Train the SQL Firewall to learn the normal activity 
- Deploy and enforce the firewall policy with allow-lists
- Use SQL Firewall to protect against common database risks such as SQL injection attacks and compromised accounts
- Manage SQL Firewall in two ways:
    - **Oracle Data Safe** enables you to manage your database's SQL Firewalls centrally and provides a comprehensive view of SQL Firewall violations across your fleet of Oracle Databases.
    - Use **PL/SQL procedures** in `SYS.DBMS_SQL_FIREWALL` package if you wish to manage SQL Firewall within each database instance.

        **Note:**
        - To learn how to manage SQL Firewall with Oracle Data Safe, proceed to Task 1, skip Task 2.
        - To learn how to manage SQL Firewall with PL/SQL procedures, proceed to Task 2 skipping Task 1.

### Prerequisites
This lab assumes you have:
<if type="brown">
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment
</if>
<if type="green">
- An Oracle Cloud account
- You have completed:
    - Introduction Tasks
</if>

### Lab Timing (estimated)
| Step No. | Feature | Approx. Time |
|--|------------------------------------------------------------|-------------|
| 1 | Use SQL Firewall with Data Safe
| 1a| Validate the on-premise Oracle Database in Data Safe is active | 5 minutes |
| 1b| Enable SQL Firewall on Data Safe to protect Glassfish HR Application | 10 minutes |
| 1c| Detect an insider threat of stolen credential access with SQL Firewall | 10 minutes |
| 1d| Enforce allowed SQL and access patterns with SQL Firewall, mitigating the risk of SQL Injection attacks | 10 minutes |
| 1e| Reset the SQL Firewall Labs Environment for Data Safe | <5 minutes |
| 2 | Use SQL Firewall with PL/SQL API
| 2a| Enable SQL Firewall to protect Glassfish HR Application | 10 minutes |
| 2b| Detect an insider threat of stolen credential access with SQL Firewall | 10 minutes |
| 2c| Enforce allowed SQL and access patterns with SQL Firewall, mitigating the risk of SQL Injection attacks | 10 minutes |
| 2d| Reset the SQL Firewall Labs Environment for PL/SQL API | <5 minutes |

## Task 1: Use SQL Firewall with Data Safe

With Data Safe you can manage multiple SQL firewalls centrally and get a comprehensive view of SQL Firewall violations across a fleet of Oracle databases. SQL Firewall administrators can use Data Safe to collect SQL activities of a database user with its associated database connection paths (IP address, OS program, OS user), and monitor the progress of the collection. Data Safe lets you generate and enable the SQL Firewall policy from the collected SQL traffic. Data Safe automatically collects SQL Firewall violation logs and lets you analyze and report on violations.

**Note**:
- During the initial deployment of the VM, we have registered Free Oracle Database 23ai (**`DBSeclabs_DB23ai-freepdb1`**) of Glassfish App in Data Safe with private endpoint in this lab
- You can now proceed to configure protection for SQL Firewall

## Task 1a: Validate the on-premise Oracle Database in Data Safe is active

1. Open a web browser window to your OCI console and login with your OCI account

2. On the Burger menu, click on **Oracle Database**, then on "**Data Safe - Database Security**"

    ![SQLFW](./images/sqlfw-001.png "Open Data Safe")

3. Click on "**Target databases**"

    ![SQLFW](./images/sqlfw-002.png "Target Databases")
 
    **Note:** All your registered target databases are listed on the right

    ![SQLFW](./images/sqlfw-015.png "List of registered target databases")

4. Check that the State of the target database **`DBSeclabs_DB23ai-freepdb1`** is **ACTIVE** in Data Safe

## Task 1b: Enable SQL Firewall to protect Glassfish HR Application

In this task you will learn how the administrator trains the system to learn the authorized SQL statements and the trusted connection paths of HR application. SQL Firewall policy is generated with allow-lists representing authorized SQL connections and statements, and deployed to the target.

### Step 1: Enable SQL Firewall

1. In Data Safe, click on **Overview** sub-menu

    ![SQLFW](./images/sqlfw-023.png "Click on Security Center sub-menu")

2. Click on **SQL Firewall** sub-menu

    ![SQLFW](./images/sqlfw-026.png "Click on SQL Firewall sub-menu")


3. Click on the target database **`DBSeclabs_DB23ai-freepdb1`**

    ![SQLFW](./images/sqlfw-027.png "Click on the target DB")

4. Click on **Enable** to enable SQL Firewall for this target db

    ![SQLFW](./images/sqlfw-028.png "Enable SQL Firewall")

    **Note:**
    - During the process, the status should be "UPDATING"

        ![SQLFW](./images/sqlfw-029.png "SQL Firewall is enabling")

5. Now, SQL Firewall should be **ACTIVE** for this target db

    ![SQLFW](./images/sqlfw-030.png "SQL Firewall is active")

6. Let's create now a SQL collection for the HR apps user `EMPLOYEESEARCH_PROD` by clicking [**Create and start SQL collection**]

    ![SQLFW](./images/sqlfw-031.png "Create a SQL collection")

7. Select the **`EMPLOYEESEARCH_PROD`** db user

    ![SQLFW](./images/sqlfw-032.png "Select db user")

8. Click [**Create and start SQL collection**]

    **Note:**
    - During the process, the status should be "CREATING"

        ![SQLFW](./images/sqlfw-033.png "SQL collection is creating")

9. Now, the SQL collection should be succeeded and it's **COLLECTING**

    ![SQLFW](./images/sqlfw-034.png "SQL Firewall is collecting")

### Step 2: Enable SQL Firewall to learn authorized SQL traffic of HR Application user

1. Now, use your Glassfish App to generated activity on your database:

    - Click on **Search Employees**

        ![SQLFW](./images/sqlfw-110.png "Search Employees")

    - Click [**Search**]

        ![SQLFW](./images/sqlfw-111.png "Search Employee")

    - Change some of the criteria and Search again
    - **Repeat 2-3 times** to ensure you have enough traffic

3. Go back to your Data Safe session and to ensure that the application workload SQL statements and connections are appropriately captured

    - Click on **SQL collection insights** tab 
    
        ![SQLFW](./images/sqlfw-035.png "SQL collections insights tab")

    - Now, you should see data in the chart **Unique SQL statements**

        ![SQLFW](./images/sqlfw-036.png "Refresh SQL collections insights")

        **Note:** Click [**Refresh insights**] if you don't see any data!
        
           <!-- ![SQLFW](./images/sqlfw-037.png "Refresh SQL collections insights") -->

4. If you are satisfied, click [**Stop**] to stop the SQL workload capture

    ![SQLFW](./images/sqlfw-038.png "Stop the SQL workload capture")

5. Now, your SQL workload capture is completed

    ![SQLFW](./images/sqlfw-039.png "SQL workload completed")
    
### Step 3: Generate and enable SQL Firewall policy with allow-lists for HR Application user

1. Click [**Generate firewall policy**] to generate the SQL Firewall policy with the allow lists

    ![SQLFW](./images/sqlfw-040.png "Generate firewall policy")

    **Note:**
    - The firewall policy is creating

        ![SQLFW](./images/sqlfw-041.png "Generating firewall policy")

    - Once it's done, you should see the following context values
    
        ![SQLFW](./images/sqlfw-041b.png "Generating firewall policy - Good Session context value")

2. Scroll down to review the allow-lists in the generated SQL Firewall policy

    ![SQLFW](./images/sqlfw-042.png "Review allow-lists")

    **Note:**
    - Generated Firewall policy remains inactive until deployed
    - You can generate the report of allowed SQL statements for offline review

3. Click [**Deploy and enforce**] to deploy the SQL Firewall policy for `EMPLOYEESEARCH_PROD`

    ![SQLFW](./images/sqlfw-043.png "Deploy SQL Firewall policy")

4. Select the following options:

    - Enforcement scope: *`All (Session contexts and SQL statements)`*
    - Action on violations: *`Observe (Allow) and log violations`*
    - Audit for violations: *`On`*

        ![SQLFW](./images/sqlfw-044.png "Fill out the Deploy SQL Firewall policy")

5. Click [**Deploy and enforce**]

6. Now, the SQL Firewall policy should be enabled

    ![SQLFW](./images/sqlfw-045.png "SQL Firewall policy is enabled")

7. Then, start the Unified Audit trail for the target database

    - Click on **Security center** to go to Security center

        ![SQLFW](./images/sqlfw-046.png "Security Center")

    - Click on **Activity auditing** sub-menu

        ![SQLFW](./images/sqlfw-047.png "Activity auditing sub-menu")

    - Click on **Audit trails** sub-menu

        ![SQLFW](./images/sqlfw-048.png "Audit trails sub-menu")

    - Click on your target database

        ![SQLFW](./images/sqlfw-049.png "Target DB Audit trails")

    - Click [**Start**]

        ![SQLFW](./images/sqlfw-050.png "Start Audit trail")

    - Select a start date and click [**Start**]

        ![SQLFW](./images/sqlfw-051.png "Select a start date")

    <if type="green">
        **Note**: The start date is invariably current date  with no way to go before it!
    </if>
    <if type="brown">
        **Note**: Choose the appropriate start date
    </if>

    - Now, the Audit trail is **COLLECTING**

        ![SQLFW](./images/sqlfw-052.png "Audit trail is COLLECTING")

8. Associate alert policy to trigger alerts for SQL Firewall violations

    - Click on **Security center** to go to Security center

        ![SQLFW](./images/sqlfw-053.png "Security Center")

    - Click on **Alerts** sub-menu

        ![SQLFW](./images/sqlfw-054.png "Alerts sub-menu")

    - Click on **Target-policy associations** sub-menu

        ![SQLFW](./images/sqlfw-055.png "Target-policy associations sub-menu")

    - Click [**Apply policy**]

        ![SQLFW](./images/sqlfw-056.png "Apply policy")

    - Associate the SQL Firewall violation policy to your target database
    
        - Ensure that your compartment is selected, otherwise please click on "**Change Compartment**" 
        - Select **Selected targets only (up to 10)** and choose *`DBSeclabs_DB23ai-freepdb1`*
        - Select **Selected policies only** and choose *`SQL Firewall violations`*

            ![SQLFW](./images/sqlfw-057.png "Associate the SQL Firewall violation policy")

    - Click [**Apply policy**]

    - Once the association is done, you can click on **Close** to close the window

        ![SQLFW](./images/sqlfw-058.png "Apply policy")

    - Now, you should see your target database associated to the SQL Firewall violations policy

        ![SQLFW](./images/sqlfw-059.png "SQL Firewall violations policy associated")

<!--
9. Finally, integrate with OCI Events and Notifications for pro-active notifications

    - Open the Burger menu and click on **Developer Services**, then **Notifications** in the **Application Integration** section

        ![SQLFW](./images/sqlfw-060.png "Notification menu")

    - Click [**Create Topic**]

        ![SQLFW](./images/sqlfw-061.png "Create Topic")

    - Fill out the form as following:

        - Name: *`DBSeclabs_SQLFW_Notif`*
        - Description: *`Notification of the SQL Firewall alerts`*

            ![SQLFW](./images/sqlfw-062.png "Fill out the Notification form")

    - Click [**Create**]

    - Click on the notification just created to edit it

        ![SQLFW](./images/sqlfw-063.png "Edit notification")

    - Click [**Create Subscription**]

        ![SQLFW](./images/sqlfw-064.png "Create Subscription")

    - Set your email where to send the notifications

        ![SQLFW](./images/sqlfw-065.png "Set email notification")

    - You'll received an email in your mailbox, please **click on the confirmation link** to confirma your email address

    - Now, the status should be **Active**

        ![SQLFW](./images/sqlfw-066.png "Email enabling")

    - On the Burger menu, click on **Oracle Database**, then on "**Data Safe - Database Security**"

        ![SQLFW](./images/sqlfw-001.png "Open Data Safe")
 
    - Click on **Alerts** sub-menu

        ![SQLFW](./images/sqlfw-054.png "Alerts sub-menu")

    - Click on "**Alert policies**"

        ![SQLFW](./images/sqlfw-067a.png "Alert policies")

    - Click on "**SQL Firewall violaions**"

        ![SQLFW](./images/sqlfw-067b.png "SQL Firewall violations policy")

    - Then, copy the OCID of this alert to associate to the rule (just next step)

        ![SQLFW](./images/sqlfw-067c.png "Copy the OCID of the alert")

    - Open the Burger menu and click on **Observability & Management**, then **Rules** in the **Events Service** section

        ![SQLFW](./images/sqlfw-068.png "Events Service Rules")

    - Click [**Create Rule**]

    - Fill out the form as following:

        - Display Name: *`DBSeclabs_SQLFW-Violation_Alert`*
        - Description: *`Send a notification when SQL Firewall violation occurs`*
        - **Rule Conditions**
            - Condition: Select *`Event Type`*
            - Service Name: Select *`Data Safe`*
            - Event Type: Select *`Alert Generated`*
            - Condition: Select *`Attribute`*
            - Attribute Name: Select *`policyId`*
            - Attributes Values: **paste the OCID of the alert copied just before**
        - **Actions**
            - Action type: Select *`Notifications`*
            - Notifications Compartment: Select your compartment
            - Topic: Select your topic just created before (here *`DBSeclabs_SQLFW_Notif`*)

            ![SQLFW](./images/sqlfw-069a.png "Fill out the Rule Notification form")

    - Click [**Create Rule**]

    - Now, the Event Rule is created and Active

        ![SQLFW](./images/sqlfw-069b.png "Events Service Rules")

    - Finally, click on **Actions** to check that the association with the notification is enabled

        ![SQLFW](./images/sqlfw-069c.png "Events Service Rules with notification active")
-->

## Task 1c: Detect an insider threat of stolen credential access with SQL Firewall

Let's assume there is a malicious insider who had access to the stolen credential of HR Apps user `EMPLOYEESEARCH_PROD`, and to bypass the HR application authorization he uses SQL Developer to gain access to the sensitive employee data.

1. First, let's validate that normal application SQL workload is allowed to the database

    - Use your Glassfish App to generated activity on your database and perform your normal operations (matched, no violation log): 

        - Go back to your web browser window to *`http://dbsec-lab:8080/hr_prod_pdb1`*
    
            **Notes:** If you are not using the remote desktop you can also access this page by going to *`http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb1`*
    
        - Click on **Search Employees**

            ![SQLFW](./images/sqlfw-110.png "Search Employees")

        - Click [**Search**]

            ![SQLFW](./images/sqlfw-111.png "Search Employee")

        - Change some of the criteria (the same than previously) and Search again
        
        - **Repeat 2-3 times** to ensure you have enough traffic

    - Now, go back to your Data Safe session and click on **SQL Firewall** to check the violation logs

        ![SQLFW](./images/sqlfw-070.png "Check violation logs")

        ![SQLFW](./images/sqlfw-071.png "No violation")

        **Note:** No violations are reported because the incoming SQL statements and connections are already in allow-list in the SQL Firewall policy

2. Now, let's detect an insider threat of stolen credential access
 
    - Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

        ```
        <copy>sudo su - oracle</copy>
        ```

        **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

    - Go to the scripts directory

        ```
        <copy>cd $DBSEC_LABS/sqlfw</copy>
        ```

    - The insider uses SQL*Plus to gain access to the sensitive employee data, so go back to your Terminal session and execute

        ```
        <copy>./sqlfw_select_sensitive_data.sh</copy>
        ```

        ![SQLFW](./images/sqlfw-120.png "Select sensitive employee data")

    - Administrator analyses the SQL Firewall Context violations in Oracle Data Safe to spot abnormal access pattern trend over time and across fleet

        ![SQLFW](./images/sqlfw-073.png "Check violation logs")

        **Note:**
        - SQL Firewall context violation is raised since SQL*Plus is not in the allowed OS program allow list, catching attention of security administrators
        - Be patient, it can take 2 or 3 minutes to display it in the dashboard!

    - Drilldown into violation report to analyse them further and appropriately take action

        - Click on the **Violation reports** sub-menu on the left

            ![SQLFW](./images/sqlfw-074a.png "Violation reports sub-menu")

        - Ensure that your compartment is selected, otherwise please change it accordingly 
        
        - Click on the **All violations** report

            ![SQLFW](./images/sqlfw-074b.png "Violation reports - All violation")

        - Now, you can see all the violations detected

            ![SQLFW](./images/sqlfw-074c.png "Violation logs")

## Task 1d: Enforce allowed SQL and access patterns with SQL Firewall to mitigate the risks of SQL Injection attacks

With the suspicious encounter of malicious insider, administrator enables the SQL Firewall in blocking mode to disallow any UN-authorized attempts to access sensitive employee information. Learn how SQL Firewall can enforce allowed patterns including approved SQL statements and database connection paths, and alert on potential SQL injection attacks, and anomalous access of HR apps DB.

Here, we will enable the SQL Firewall to block on detection of unauthorized SQL connections/statements

1. Update the allow-list rule enforcement to **blocking mode**

    - Click on **SQL Firewall policies** sub-menu on the left
    
        ![SQLFW](./images/sqlfw-075.png "SQL Firewall policies sub-menu")

    - Click on the **`EMPLOYEESEARCH_PROD`** SQL Firewall policy
    
        ![SQLFW](./images/sqlfw-076.png "EMPLOYEESEARCH_PROD SQL Firewall policy")

    <!--
    - Click [**Disable**]
    
        ![SQLFW](./images/sqlfw-077.png "Disable SQL Firewall policy")

    - Click [**Disable**] again to confirm
    
        ![SQLFW](./images/sqlfw-078.png "Confirm disabling of the SQL Firewall policy")

    -->
    
    - Now, click [**Deploy and enforce**]
    
    - Then, select the following options:

        - Enforcement scope: *`All (Session contexts and SQL statements)`*
        - Action on violations: *`Block and log violations`*
        - Audit for violations: *`On`*

            ![SQLFW](./images/sqlfw-079.png "Fill out the Deploy SQL Firewall policy")
        
        - Click [**Deploy and enforce**]

            ![SQLFW](./images/sqlfw-080.png "Update the SQL Firewall policy to blocking mode")

        **Note:** Please wait until the SQL Firewall shows [**Action on violations: Block and log violations**] to block SQL Injection attempts!

2. Go back to your Terminal session to see how SQL Firewall blocks attempts to use stolen credential access
 
    ```
    <copy>./sqlfw_select_sensitive_data.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-081.png "Select sensitive employee data")

    **Note:** SQL Firewall now blocks with "ORA-47605: SQL Firewall violation" error and raises context violation

3. Now, a hacker logs into Glassfish application to perform a SQL injection attack

    - Go back to your Glassfish App web page, logout and login as *`hradmin`* with the password "*`Oracle123`*"

    - Click **Search Employees**

        ![SQLFW](./images/sqlfw-110.png "Search employees")

    - Click [**Search**]

        ![SQLFW](./images/sqlfw-111.png "Search employees")

        **Note**: All rows are returned... normal, because, remember, you allowed everything!

    - Now, tick the **checkbox "Debug"** to see the SQL query behind this form

        ![SQLFW](./images/sqlfw-123.png "See the SQL query executed behind the form")

    - Click [**Search**] again

        ![SQLFW](./images/sqlfw-124.png "Search employees")

        **Note:**
        - Now, you can see the official SQL query executed by this form which displays the results
        - This query gives you the information of the number of columns requested, their name, their datatype and their relationship

    - Now, based on this information, you can create our "UNION-based" SQL Injection query to display all sensitive data you want extract directly from the form. Here, we will use this query to extract `USER_ID', 'MEMBER_ID', 'PAYMENT_ACCT_NO` and `ROUTING_NUMBER` from `DEMO_HR_SUPPLEMENTAL_DATA` table.

        ```
        <copy>
        ' UNION SELECT userid, ' ID: '|| member_id, 'SQLi', '1', '1', '1', '1', '1', '1', 0, 0, payment_acct_no, routing_number, sysdate, sysdate, '0', 1, '1', '1', 1 FROM demo_hr_supplemental_data --
        </copy>
        ```

    - Copy the SQL Injection query, **paste it directly into the field "Position"** on the Search form and **tick the "Debug" checkbox**

        ![SQLFW](./images/sqlfw-125.png "Copy/Paste the SQL Injection query")

        **Note:**
        - Don't forget the "`'`" before the UNION key word to close the SQL clause "LIKE"
        - Don't forget the "`--`" at the end to disable rest of the query

    - Click [**Search**]

        ![SQLFW](./images/sqlfw-126.png "Search employees")

        **Note:**
        - The output should return an ORA-failures on these attempts
        - Remember, this is because the UNION query has not been added into the Allow-list in the SQL Firewall policy... as simple as that!

4. Administrator analyses the SQL violations in Oracle Data Safe to spot abnormal access pattern trends over time and across fleet

    - Go back to the Data Safe session then click on SQL Firewall

        ![SQLFW](./images/sqlfw-090.png "Check violation logs")

    - You can see the violation report

        ![SQLFW](./images/sqlfw-091.png "Check violation logs")

        **Note:**
        - SQL Firewall violations are raised due to the SQL Injection attempts and login from unauthorized client!
        - Be patient, it can take 2 or 3 minutes to display it in the dashboard!

    - Drilldown into violation report to analyse them further and appropriately take action

        - Click on the **Violation reports** sub-menu on the left

            ![SQLFW](./images/sqlfw-074a.png "Violation reports sub-menu")

        - Ensure that your compartment is selected, otherwise please change it accordingly 

        - Click on the **All violations** report

            ![SQLFW](./images/sqlfw-074b.png "Violation reports - All violation")

        - Now, you can see all the violations detected

            ![SQLFW](./images/sqlfw-092.png "Violation logs")

<!--
5. SQL violation alert is raised, catching attention of security administrators by email!

    ![SQLFW](./images/sqlfw-082.png "Alert violation email")
-->

5. Check the SQL Firewall violation alerts

    - Click on **Alerts** sub-menu on the left
    
        ![SQLFW](./images/sqlfw-083.png "Alerts sub-menu")

    - Click on **Critical** alerts to show the SQL Firewall violation alerts raised

        ![SQLFW](./images/sqlfw-084.png "Alerts dashboard")

    - Open the recent SQL Firewall violation alert

        ![SQLFW](./images/sqlfw-085.png "SQL Firewall violation alerts")

    - Highlight the SQL Injection query in the command text of the alert as shown here by clicking **Show**

        ![SQLFW](./images/sqlfw-086.png "SQL Firewall violation alers - SQL injection Alert")

        ![SQLFW](./images/sqlfw-087.png "SQL Firewall violation alers - SQL injection Query")

## Task 1e: Reset the SQL Firewall Labs Environment for Data Safe

1. Once you are comfortable with the SQL Firewall concept, go back to the Data Safe session to stop Activity Auditing

    - Click on **Data Safe**

        ![SQLFW](./images/sqlfw-201a.png "Data Safe main page")

    - Click on **Activity auditing** sub-menu

        ![SQLFW](./images/sqlfw-047.png "Activity auditing sub-menu")

    - Click on **Audit trails** sub-menu

        ![SQLFW](./images/sqlfw-048.png "Audit trails sub-menu")

    - Click on your target database

        ![SQLFW](./images/sqlfw-049.png "Target DB Audit trails")

    - Click [**Stop**]

    - Wait until the Audit Trail is **INACTIVE**, so it means that the collection is **STOPPED** 

        ![SQLFW](./images/sqlfw-201b.png "Audit Trail Stopped")

2. Now, let's drop SQL Firewall settings

    - Click on **Data Safe**

    - Click on **SQL Firewall** sub-menu

    - Click on **SQL Firewall policies** sub-menu

    - Click on **EMPLOYEESEARCH_PROD** database user **ACTIVE**

    - Click [**Disable**]

    - Then click [**Drop**]

        ![SQLFW](./images/sqlfw-220.png "Drop SQL Firewall policy")

    - Click on **SQL collections** sub-menu

    - Click on **EMPLOYEESEARCH_PROD** database user **ACTIVE**

    - Click [**Purge**]

    - Then click [**More actions**], and select **Drop**

        ![SQLFW](./images/sqlfw-221.png "Drop SQL collection")

    - Click on **SQL Firewall** link on the top

    - Click on **SQL Firewall** sub-menu

    - Click on the target database **`DBSeclabs_DB23ai-freepdb1`**

    - Click [**Disable**]

        ![SQLFW](./images/sqlfw-222.png "Disable SQL Firewall")

3. Finally, go back to your terminal session to reset the environment within the database

    ```
    <copy>./sqlfw_reset_env_ds.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-211.png "Reset the SQL Firewall Labs Environment")

    **Note**: If you want to redo the entire Task1, please follow these instrcutions:
    - Execute the following script to create the *`DS_ADMIN`* user

        ```
        <copy>
        cd $DBSEC_LABS/sqlfw
        ./sqlfw_crea_ds-admin-user.sh</copy>
        ```

    - and click [**Refresh**] in the **SQL Firewall configuration details** page

        ![SQLFW](./images/sqlfw-223.png "refresh SQL Firewall config")

4. **Now your Data Safe configuration is correctly reset!**

## Task 2: Use SQL Firewall with PL/SQL API

With PL/SQL procedures in the `SYS.DBMS_SQL_FIREWALL` package, you can administer and manage SQL Firewall within each database instance.

## Task 2a: Enable SQL Firewall to protect Glassfish HR Application

In this lab you will learn how the administrator trains the system to learn the authorized SQL statements and the trusted connection paths of HR application. SQL Firewall policy is generated with allow-lists representing authorized SQL connections and statements, and deployed to the target.

### Step 1: Setup SQL Firewall env

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ```
    <copy>sudo su - oracle</copy>
    ```

    **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

2. Go to the scripts directory

    ```
    <copy>cd $DBSEC_LABS/sqlfw</copy>
    ```

3. Create an administrator (**`dba_tom`**) to manage SQL Firewall

    ```
    <copy>./sqlfw_crea_admin-user.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-107.png "Create the SQL Firewall Admin user")

4. Enable SQL Firewall

    ```
    <copy>./sqlfw_enable.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-108.png "Enable SQL Firewall")

    **Note**: You must see `ENABLED`

### Step 2: Enable SQL Firewall to learn authorized SQL traffic of HR Application user

1. Start the SQL workload capture of the application user EMPLOYEESEARCH_PROD

    ```
    <copy>./sqlfw_capture_start.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-109.png "Start the SQL workload capture of the application user")

2. Now, use your Glassfish App to generated activity on your database:

    - Go back to your web browser window to *`http://dbsec-lab:8080/hr_prod_pdb1`*
    
        **Notes:** If you are not using the remote desktop you can also access this page by going to *`http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb1`*
    
    - Click on **Search Employees**

        ![SQLFW](./images/sqlfw-110.png "Search Employees")

    - Click [**Search**]

        ![SQLFW](./images/sqlfw-111.png "Search Employee")

    - Change some of the criteria and Search again
    - **Repeat 2-3 times** to ensure you have enough traffic

3. Go back to your terminal session to ensure that the application workload SQL statements and connections are appropriately captured

    ```
    <copy>./sqlfw_capture_check.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-112.png "Check the sessions and capture logs")

    **Note:** Here, we check the session and capture logs

4. If you are satisfied, stop the SQL workload capture

    ```
    <copy>./sqlfw_capture_stop.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-113.png "Stop the SQL workload capture")

### Step 3: Generate and enable allow list rules for HR Application user

1. Generate the allow list rule

    ```
    <copy>./sqlfw_allow_list_rule_gen.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-114.png "Generate allow list rule")

<!--
2. Compare this list to the events we captured

    ```
    <copy>./sqlfw_capture_count_events.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-115.png "Count the events captured")

    **Note:** The count matches the count of distinct events we captured
-->

2. Examine the SQL Firewall allow list rules for trusted database connections and SQL statements

    ```
    <copy>./sqlfw_allow_list_rule_exam.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-116.png "Examine the SQL Firewall allow list rules")

    **Note:** Here, we allow only connections from the Web App (`JDBC ThinClient`) initiated by the user `oracle` on server `10.0.0.150`

3. Set up the audit policies for SQL Firewall violations

    ```
    <copy>./sqlfw_setup_audit_policies.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-117.png "Set up the audit policies for SQL Firewall violations")


4. Enable the allow-list rule for `EMPLOYEESEARCH_PROD` in **observation mode**

    ```
    <copy>./sqlfw_allow_list_rule_enable_monitor.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-118.png "Enable the allow-list rule in observation mode")

    **Note:** Here, we will observe and not block SQL Firewall violations

## Task 2b: Detect an insider threat of stolen credential access with SQL Firewall

Let's assume there is a malicious insider who had access to the stolen credential of HR Apps user `EMPLOYEESEARCH_PROD`, and to bypass the HR application authorization he uses SQL Developer to gain access to the sensitive employee data.

1. First, let's validate that normal application SQL workload is allowed to the database

    - Use your Glassfish App to generated activity on your database and perform your normal operations (matched, no violation log): 

        - Go back to your web browser window to *`http://dbsec-lab:8080/hr_prod_pdb1`*
    
            **Notes:** If you are not using the remote desktop you can also access this page by going to *`http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb1`*
    
        - Click on **Search Employees**

            ![SQLFW](./images/sqlfw-110.png "Search Employees")

        - Click [**Search**]

            ![SQLFW](./images/sqlfw-111.png "Search Employee")

        - Change some of the criteria (the same than previously) and Search again
        
        - **Repeat 2-3 times** to ensure you have enough traffic

    - Now, go back to your terminal session to check violation logs and audit records

        ```
        <copy>./sqlfw_check_events.sh</copy>
        ```

        ![SQLFW](./images/sqlfw-119.png "Check violation logs and audit records")

        **Note:** No records is found because these queries are already listed as SQL statements allowed into the database

2. Now, let's detect an insider threat of stolen credential access
 
     - The insider uses SQL*Plus to gain access to the sensitive employee data

        ```
        <copy>./sqlfw_select_sensitive_data.sh</copy>
        ```

        ![SQLFW](./images/sqlfw-120.png "Select sensitive employee data")

    - Check again violation logs and audit records

        ```
        <copy>./sqlfw_check_events.sh</copy>
        ```

        ![SQLFW](./images/sqlfw-121.png "Check violation logs and audit records")

        **Note:** SQL Firewall context violation is raised since SQL*Plus is not in the allowed OS program allow list, catching attention of security administrators

## Task 2c: Enforce allowed SQL and access patterns with SQL Firewall to mitigate the risks of SQL Injection attacks

With the suspicious encounter of malicious insider, administrator enables the SQL Firewall in blocking mode to disallow any UN-authorized attempts to access sensitive employee information. Learn how SQL Firewall can enforce allowed patterns including approved SQL statements and database connection paths, and alert on potential SQL injection attacks, and anomalous access of HR apps DB.

Here, we will enable the SQL Firewall to block on detection of unauthorized SQL connections/statements

1. Update the allow-list rule enforcement to **blocking mode**

    ```
    <copy>./sqlfw_allow_list_rule_enable_block.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-122.png "Update the allow-list rule to blocking mode")

    **Note:** SQL Firewall can now block SQL Injection attempts

2. Now, let's see how SQL Firewall blocks attempts to use stolen credential access
 
    ```
    <copy>./sqlfw_select_sensitive_data.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-122b.png "Select sensitive employee data")

    **Note:** SQL Firewall now blocks with "ORA-47605: SQL Firewall violation" error and raises context violation

3. Check again violation logs and audit records

    ```
    <copy>./sqlfw_check_events.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-122c.png "Check violation logs and audit records")

4. Now, a hacker logs into Glassfish application to perform a SQL injection attack

    - Go back to your Glassfish App web page, logout and login as *`hradmin`* with the password "*`Oracle123`*"

    - Click **Search Employees**

        ![SQLFW](./images/sqlfw-110.png "Search employees")

    - Click [**Search**]

        ![SQLFW](./images/sqlfw-111.png "Search employees")

        **Note**: All rows are returned... normal, because, remember, you allowed everything!

    - Now, tick the **checkbox "Debug"** to see the SQL query behind this form

        ![SQLFW](./images/sqlfw-123.png "See the SQL query executed behind the form")

    - Click [**Search**] again

        ![SQLFW](./images/sqlfw-124.png "Search employees")

        **Note:**
        - Now, you can see the official SQL query executed by this form which displays the results
        - This query gives you the information of the number of columns requested, their name, their datatype and their relationship

    - Now, based on this information, you can create our "UNION-based" SQL Injection query to display all sensitive data you want extract directly from the form. Here, we will use this query to extract `USER_ID', 'MEMBER_ID', 'PAYMENT_ACCT_NO` and `ROUTING_NUMBER` from `DEMO_HR_SUPPLEMENTAL_DATA` table.

        ```
        <copy>
        ' UNION SELECT userid, ' ID: '|| member_id, 'SQLi', '1', '1', '1', '1', '1', '1', 0, 0, payment_acct_no, routing_number, sysdate, sysdate, '0', 1, '1', '1', 1 FROM demo_hr_supplemental_data --
        </copy>
        ```

    - Copy the SQL Injection query, **paste it directly into the field "Position"** on the Search form and **tick the "Debug" checkbox**

        ![SQLFW](./images/sqlfw-125.png "Copy/Paste the SQL Injection query")

        **Note:**
        - Don't forget the "`'`" before the UNION key word to close the SQL clause "LIKE"
        - Don't forget the "`--`" at the end to disable rest of the query

    - Click [**Search**]

        ![SQLFW](./images/sqlfw-126.png "Search employees")

        **Note:**
        - The output should return an ORA-failures on these attempts
        - Remember, this is because the UNION query has not been added into the Allow-list in the SQL Firewall policy... as simple as that!

5. Now, check violation logs and audit records

    ```
    <copy>./sqlfw_check_events.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-127.png "Check violation logs and audit records")

    **Note:** SQL violation is raised, catching attention of security administrators!

## Task 2d: Reset the SQL Firewall Labs Environment for PL/SQL API

1. Once you are comfortable with the SQL Firewall concept, you can reset the environment

    ```
    <copy>./sqlfw_reset_env_api.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-250.png "Reset the SQL Firewall Labs Environment")

<!--
2. Migrate the Glassfish Application connection string in order to target the default database (**pdb1**)

    ```
    <copy>./sqlfw_glassfish_stop_db23ai.sh</copy>
    ```

    ![SQLFW](./images/sqlfw-251.png "Set HR App with PDB1")

    **Note**: Now, we connect Glassfish to the database **`PDB1`** (DB 19c) on the **`dbsec-lab`** VM
-->

2. **Now your SQL Firewall configuration is correctly reset!**

You may now **proceed to the next lab**

## **Appendix**: About the Product
### **Overview**

SQL Firewall is a database security feature built into the Oracle Database kernel that inspects all incoming SQL statements and can log or block SQL statements/connections that do not fall within the SQL Firewall allow-list policy. SQL Firewall ensures that only explicitly authorized SQL is executed. It offers best-in-class protection against common database risks such as SQL Injection attacks and compromised accounts.

SQL injection is a common database attack pattern for data-driven web applications. Exploiting vulnerabilities and security flaws in web applications, attackers can potentially modify database information, access sensitive data, execute admin tasks on the database, steal credentials and move laterally to access other sensitive systems.

While other database security features embedded within Oracle Database provide different security controls to monitor/prevent such web application attacks, the SQL Firewall is the only one that inspects all incoming SQL statements and allows only authorized SQL. It logs and blocks unauthorized SQL queries from executing in the database.

SQL Firewall operates within the Oracle Database kernel, in line with all incoming SQL statements irrespective of origin. SQL Firewall can allow, log and optionally block SQL traffic when it detects a violation of its rules.

![SQLFW](./images/sqlfw-concept.png "SQL Firewall concept")

Figure 1: Oracle SQL Firewall built into Oracle Database kernel

Oracle SQL Firewall policies work at a database account level, whether of an application service account or a direct database user, such as a reporting user or a database administrator. SQL Firewall policy for every database account comprises allow-lists of authorized SQL statements and associated trusted database connection paths. The allow-listing approach provides a higher level of protection against risks such as SQL Injection attacks and compromised accounts. It ensures that only authorized SQL statements from trusted database connections are permitted for execution inside the Oracle database while alerting/blocking any unauthorized attempts at accessing sensitive data stored within them. Unlike signature-based protection mechanisms, SQL Firewall cannot be fooled by encoding the SQL statement or referencing synonyms or dynamically generated object names.

PL/SQL procedures in `SYS.DBMS_SQL_FIREWALL` package lets you administer and manage the SQL Firewall configuration within Oracle Database. Oracle SQL Firewall is available only for Oracle Database Enterprise Edition (version 23.1 and later). Oracle SQL Firewall must be licensed for use. There are two paths to its license:

- Oracle SQL Firewall is included with Oracle Database Vault. Database Vault is an extra cost option.
- Oracle SQL Firewall is included with Oracle Audit Vault and Database Firewall (AVDF). AVDF is a separate product and requires a license.

### **Benefits of using Oracle SQL Firewall**
- Provides real-time protection against common database attacks by restricting database access to only authorized SQL statements/connections. 
- Mitigates risks from SQL injection attacks, anomalous access, and credential theft/abuse.
- Enforce trusted database connection paths.

## Want to Learn More?
Technical Documentation:
- [Oracle SQL Firewall](https://docs.oracle.com/en/database/oracle/oracle-database/23/dbseg/using-sql-firewall.html)

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Angeline Dhanarani
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - August 2024