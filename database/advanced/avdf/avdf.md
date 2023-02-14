# Oracle Audit Vault and DB Firewall (AVDF)

## Introduction
This workshop introduces the various features and functionality of Oracle Audit Vault and DB Firewall (AVDF). It gives the user an opportunity to learn how to configure those appliances in order to audit, monitor and protect access to sensitive data.

*Estimated Lab Time:* 150 minutes

*Version tested in this lab:* Oracle AVDF 20.8

### Video Preview

Watch a preview of "*LiveLabs - Oracle Audit Vault and Database Firewall (May 2022)*" [](youtube:eLEeOLMAEec)

### Objectives
- Connect Audit Vault Server to an Oracle DB
- Configure the auditing for this Db and explore the auditing and reporting capacities
- Configure and manage the Firewalling monitoring
- Train the DB Firewall for expected SQL traffic and see the effects on a web App

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

### Lab Timing (estimated)

| Step No. | Feature | Approx. Time |
|--|------------------------------------------------------------|-------------|
|| **Audit Vault Labs**||
|01| Run the Deploy Agent | 5 minutes|
|02| Register a Pluggable Database as Target | <5 minutes|
|03| Register an Audit Trail | <5 minutes|
|04| Manage Unified Audit Settings | 5 minutes|
|05| Retrieve User Entitlements | <5 minutes|
|06| Access Rights and User Activity on Sensitive Data | 5 minutes|
|07| Tracking Data Changes (Auditing "Before-After" Values) | 15 minutes|
|08| Create Alert Policies | 5 minutes|
|| **DB Firewall Labs**||
|09| Add the DB Firewall Monitoring | 10 minutes|
|10| Configure and Verify the Glassfish App to Use the DB Firewall | 5 minutes|
|11| Train the DB Firewall for Expected SQL Traffic | 15 minutes|
|12| Build and Test the DB Firewall Allow-List Policy | 20 minutes|
|13| Block a SQL Injection Attack | 10 minutes|
|14| Detect Data Exfiltration Attempts | 15 minutes|
|15| Restore the Glassfish App Configuration to Use Direct Mode | <5 minutes|
|| **AVDF Advanced Labs**||
|16| (Optional) PostgreSQL Audit Collection | 10 minutes|
|17| (Optional) Linux Audit Collection | 10 minutes|
|18| (Optional) LDAP/Active Directory Configuration | <5 minutes|
|| **Reset Labs**||
|19| Reset the AVDF labs config | <5 minutes|

## Task 1: Audit Vault - Run the Deploy Agent

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````
    <copy>sudo su - oracle</copy>
    ````

    **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

2. Go to the scripts directory

    ````
    <copy>cd $DBSEC_LABS/avdf/avs</copy>
    ````

3. First, unpack the **avcli.jar** utility to install the Audit Vault Command Line Interface (avcli) so we can automate most of the Agent, host, and Audit Trail deployment

    ````
    <copy>./avs_deploy_avcli.sh</copy>
    ````

    ![AVDF](./images/avdf-001.png "AVDF")

4. Next, we will use avcli to register the host, dbsec-lab, with Audit Vault. You will see that the commands being run are stored in the `avcli_register_host.av` file. In this step you will see a activation key. **Record this Activation Key for use later in the lab!**

    ````
    <copy>./avs_register_host.sh</copy>
    ````

    ![AVDF](./images/avdf-002.png "AVDF")

    **Note**:
    - Your output will look similar to this but your **Activation Key** will be different
    - Please copy the Activation Key for use later (don't forget the hostname in your copy!)

5. Next, we will deploy the Audit Vault Agent

    ````
    <copy>./avs_deploy_agent.sh</copy>
    ````

    ![AVDF](./images/avdf-003.png "AVDF")

    **Note**: This script will unpack the **agent.jar** file into the **/u01/app/avagent** directory

6. Once deployed, we will need to activate the Audit Vault Agent

    ````
    <copy>./avs_activate_agent.sh</copy>
    ````

    ![AVDF](./images/avdf-004.png "AVDF")

    **Note**:
    - Remember the **Activation Key** we saw above and paste the key when prompted
    - Attention, because the Activation Key is enter like a password, it won't show on the screen!

7. As a final step, we will verify that the dbsec-lab host has been properly registered and is activated with Audit Vault

    ````
    <copy>./avs_show_host.sh</copy>
    ````

    ![AVDF](./images/avdf-005.png "AVDF")

    **Note**:
    - Notice the output should say "**RUNNING**" for the Agent Status column
    - If not, please restart it by using this command line

        ````
        <copy>$AV_HOME/bin/agentctl start</copy>
        ````

## Task 2: Audit Vault - Register a Pluggable Database as Target

1. Use the avcli utility to register the pluggable database **pdb1** as an AV target (the password asked here is "*`Oracle123`*")

    ````
    <copy>./avs_register_pdb.sh</copy>
    ````

    ````
    <copy>Oracle123</copy>
    ````

    ![AVDF](./images/avdf-006.png "AVDF")

    **Note**:
    - You could also perform this register from the Audit Vault Web Console
    - This script will use the database user **AVAUDITUSER** that was created, and granted the appropriate privileges, to perform database audit collection and clean-up and has `SELECT` access on several dictionary tables (for more information please see the Oracle Audit Vault and Database Firewall documentation)

## Task 3: Audit Vault - Register an Audit Trail

1. First, use the avcli utility to register the Unified Audit Trail for the pluggable database **pdb1** to collect audit data

    ````
    <copy>./avs_register_audit_trail.sh</copy>
    ````

    ![AVDF](./images/avdf-007.png "AVDF")

2. Next, list the Audit Trails for the pluggable database **pdb1**

    ````
    <copy>./avs_list_audit_trails.sh</copy>
    ````

    ![AVDF](./images/avdf-008.png "AVDF")

    **Note**:
    - You should see one row returned for the Unified Audit Trail
    - The `STATUS` column should say **COLLECTING** or **IDLE**
    - If it says something else please run the script again and verify it changes state

3. Using the Audit Vault Web Console view audit data collected via the All Activity Report

    - Open a web browser window to *`https://av`*

        **Note**:If you are not using the remote desktop you can also access this page by going to *`https://<AVS-VM_@IP-Public>`*

    - Login to Audit Vault Web Console as *`AVAUDITOR`* with the password "*`T06tron.`*" (keep it open for the rest of the lab)

        ````
        <copy>AVAUDITOR</copy>
        ````

        ````
        <copy>T06tron.</copy>
        ````

        ![AVDF](./images/avdf-300.png "AVDF")

    - Click on the **Reports** tab
    
    - Under the **Activity Reports** section titled **Summary**, click on the **All Activity** name to load the report
    
    - You should see a report that looks something like this:

        ![AVDF](./images/avdf-009.png "AVDF")

    - You can click on the **Event** header and select **'LOGON'** to add a filter on this event

        ![AVDF](./images/avdf-010a.png "AVDF")

    - It might look something like this:

        ![AVDF](./images/avdf-010b.png "AVDF")

    **Note**:
      - This was just a small example to verify that audit data was being collected and is visible in Audit Vault
      - There will be more detailed report generation labs later in the workshop

4. You have completed the lab to register the Unified Audit Trail for pdb1 with Audit Vault

## Task 4: Audit Vault - Manage Unified Audit Settings

You will retrieve and provision the Unified Audit settings for the **pdb1** pluggable database

1. Go back to Audit Vault Web Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF")

2. Click on the **Targets** tab

3. Click on the Target **pdb1**

4. On the target screen, under **Audit Policy** perform the following:
    - Checkbox *Retrieve Immediately*
    - Change the **Schedule** radio button to *Enable*
    - Set **Repeat Every** to *1 Days*
    - Click [**Save**] to save and continue

        ![AVDF](./images/avdf-011.png "AVDF")

5. Next, view the audit policy reports for **pdb1**
    - Click on the **Policies** tab and you will be placed on the **Audit Policies** page
    - Click on the Target Name **pdb1**
    - On this screen, you will see two tabs, **Unified Auditing** and **Traditional Auditing**. Since this is a modern version of Oracle, 12.1 or higher, we want to use Unified Auditing
    - In the **Unified Auditing** tab, go to the **Core Policies** section and ensure the following options are checkmarked
        - *`Critical Database Activity`*
        - *`Database Schema Changes`*
        - *`All Admin Activity`*
        - *`Center for Internet Security (CIS) Configuration`*

            ![AVDF](./images/avdf-012.png "AVDF")

    - Click [**Provision Unified Policy**]

6. Verify the job completed successfully
    - Click on the **Settings** tab
    - Click on the **Jobs** section on the left menu bar
    - You should see at least one **Job Type** that says **Unified Audit Policy**

        ![AVDF](./images/avdf-013.png "AVDF")

    - Refresh the web page  (press [F5] for example) until it shows **Complete** and it was provisioned on **pdb1**

        ![AVDF](./images/avdf-013b.png "AVDF")

7. The next thing you can do is check which Unified Audit Policies exist and which Unified Audit Policies are enabled by using **SQL*Plus**

    - Go back to your Terminal session and list **ALL** the Unified Audit Policies in **pdb1**

        ````
        <copy>./avs_query_all_unified_policies.sh</copy>
        ````

        ![AVDF](./images/avdf-014.png "AVDF")

    - Next, show the **enabled** Unified Audit policies

        ````
        <copy>./avs_query_enabled_unified_policies.sh</copy>
        ````

        ![AVDF](./images/avdf-015.png "AVDF")

8. If you want, you can re-do the previous steps and make changes to the Unified Audit Policies. For example, don't enable the **Center for Internet Security (CIS) Configuration** and re-run the two shell scripts to see what changes!

## Task 5: Audit Vault - Retrieve User Entitlements

1. Go back to Audit Vault Web Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF")

2. Click on the **Targets** tab

3. Click on the Target **pdb1**

4. Under **User Entitlements**
    - Checkbox *Retrieve Immediately*
    - Change the **Schedule** radio button to *Enable*
    - Set **Repeat Every** to *1 Days*
    - Click [**Save**] to save and continue

        ![AVDF](./images/avdf-016.png "AVDF")

5. Click on the **Reports** tab

6. Scroll down and expand the **Entitlement Reports** section

    ![AVDF](./images/avdf-017.png "AVDF")

7. Click on the **User Accounts** report
    - Under **Target Name**, select *`All`*
    - For **Label**, select *`Latest`*
    - Click [**Go**] and you will see a report that looks like this

        ![AVDF](./images/avdf-018.png "AVDF")

## Task 6: Audit Vault - Access Rights and User Activity on Sensitive Data

In this lab you will use the results from a **Database Security Assessment Tool (DBSAT)** collection job to identify the sensitive data with the pluggable database **pdb1**. For ease of execution, the required step from the DBSAT lab was performed and the output saved. The first step here will help download and stage it accordingly.

1. Before beginning the lab, you have to **download to your local computer** the sensitive data file (`pdb1_dbsat_discover.csv`) below that we have generated for you from DBSAT:

    [> Click here to download the CSV file<](https://objectstorage.us-ashburn-1.oraclecloud.com/p/g7HGibfhPXhmVXvyiP5G4yGe_MH3yPGUkiCrccuYhCKewZvgd-mlPycLPxaOAxcC/n/natdsecurity/b/labs-files/o/pdb1_dbsat_discover.csv)

2. Load the data from the downloaded DBSAT file

    - Go back to Audit Vault Web Console, logout and login as *`AVADMIN`* with the password "*`T06tron.`*"

        ````
        <copy>AVADMIN</copy>
        ````

        ````
        <copy>T06tron.</copy>
        ````

        ![AVDF](./images/avdf-400.png "AVDF")

    - Upload the `pdb1_dbsat_discover.csv` file you downloaded earlier into AVDF Console
        - Click the **Targets** tab
        - Click the target name **pdb1**
        - In the right, top, corner of the page click [**Sensitive Objects**]

            ![AVDF](./images/avdf-019c.png "AVDF")

        - Click to the **Browse** icon and load the *`pdb1_dbsat_discover.csv`* file you saved earlier to your local system

            ![AVDF](./images/avdf-019d.png "AVDF")

            ![AVDF](./images/avdf-020.png "AVDF")

        - Click [**Upload**]
        - If you click [**Sensitive Objects**] again you will see you have the **.csv** file loaded

            ![AVDF](./images/avdf-021.png "AVDF")

4. View the Sensitive Data

    - Go back to Audit Vault Web Console as *`AVAUDITOR`*

        ![AVDF](./images/avdf-300.png "AVDF")

    - Click the **Reports** tab

    - On the left side menu, select **Compliance Reports** and make sure "**Data Private Report (GDPR)**" is selected as "Compliance Reports Category"

    - Then, click [**Go**] to associate a pluggable database

        ![AVDF](./images/avdf-022a.png "AVDF")

    - Double-click on **pdb1 (Oracle Database)** to associate this database

        ![AVDF](./images/avdf-022b.png "AVDF")

    - Click [**Save**]

    - Once you associate the target with the report, click on **Sensitive Data** report

        ![AVDF](./images/avdf-023a.png "AVDF")

        ![AVDF](./images/avdf-023b.png "AVDF")

        **Note:** Here you can see the Data Privacy report of the Schema, Objects, Object Types, and Column Name and Sensitive Types

5. You can also view additional **Compliance Reports** about Sensitive Data

    ![AVDF](./images/avdf-024.png "AVDF")

## Task 7: Audit Vault - Tracking Data Changes (Auditing "Before-After" Values)

**About Oracle Audit Vault Transaction Log Audit Trail Collection**

REDO LOG files also known as TRANSACTION LOG are files used by Oracle Database to maintain logs of all the transactions that have occurred in the database. This chapter contains the recommendations for setting initialization parameters to use the **Transaction Log Audit Trail** type to collect audit data from the Redo Logs of Oracle Database target.

These log files allow Oracle Database to **recover the changes made to the database in case of a failure**. For example, if a user updates a salary value in a table that contains employee related data, a REDO record is generated. It contains the value **BEFORE** this change (old value) and the **NEW** changed value. REDO records are used **to guarantee ACID** (Atomicity, Consistency, Isolation, and Durability) **properties over crash or hardware failure**. In case of a database crash, the system performs redo (re-process) of all the changes on data files that takes the database data back to the state it was when the last REDO record was written.

REDO log records contain Before and After values for every **DML** (Data Manipulation Language) and **DDL** (Data Definition Language) operations. Oracle AVDF provides the ability to **monitor the changed values from REDO logs using Transaction Log collector**.

Transaction Log collector takes advantage of **Oracle GoldenGate’s Integrated Extract process** to move the REDO log data from database to XML files. The extract process is configured to run against the source database or it is configured to run on a Downstream Mining database (Oracle only). It captures DML and DDL operations performed on the configured objects. **The captured operations from transaction logs are transferred to GoldenGate XML trail files**. Oracle AVDF's Transaction Log collector, collects transaction log records from generated XML files. **These logs are forwarded to the Audit Vault Server** to show the before and after values changed in the Data Modification Before-After Values report. The DDL changes are available in the All Activity report. The DML changes are available in the Data Modification Before-After Values report.

**Getting Started**

The first thing we need to do is to set up the database to be ready for Golden Gate

1. Go back to your Terminal session on DBSec-Lab VM to create the Golden Gate Database Administration user **C##AVGGADMIN** in the container database **cdb1**

    ````
    <copy>./avs_create_oggadmin_db_user.sh</copy>
    ````

    ![AVDF](./images/avdf-025.png "AVDF")

2. Next, we have to configure the database to have the appropriate `SGA_TARGET` and `STREAMS_POOL_SIZE` values, enable the `ENABLE_GOLDENGATE_REPLICATION` initialization parameter and **Forcing Logging** for redo collection

    ````
    <copy>./avs_configure_db_for_ogg.sh</copy>
    ````

    ![AVDF](./images/avdf-026.png "AVDF")

     **Note**: This will require a reboot and this script will do this for you

3. Finally, verify connectivity to the **cdb1** container database before we continue with the configuration of the GoldenGate Extract

    ````
    <copy>./avs_test_dbuser_connectivity.sh</copy>
    ````

    ![AVDF](./images/avdf-027.png "AVDF")

**Configuring a GoldenGate Extract**

4. In the DBSecLab VM, the Oracle GoldenGate software has been already installed and pre-configured, but ensure the Golden Gate Administration Service is up and running

    ````
    <copy>./avs_start_ogg.sh</copy>
    ````

    ![AVDF](./images/avdf-028.png "AVDF")

5. Login to your GoldenGate Web Console

    - Open a web browser window to *`https://dbsec-lab:50002`*

        **Note**:If you are not using the remote desktop you can also access this page by going to *`https://<DBSecLab-VM_@IP-Public>:50002`*

    - Login to Golden Gate Web Console as *`OGGADMIN`* with the password "*`Oracle123`*"

        ````
        <copy>oggadmin</copy>
        ````

        ````
        <copy>Oracle123</copy>
        ````

        ![AVDF](./images/avdf-029.png "AVDF")

6. In the top left corner, open the **Burger menu** and select **Configuration**

    ![AVDF](./images/avdf-030a.png "AVDF")

7. Click the [**+**] symbol next to **Credentials**

    ![AVDF](./images/avdf-030b.png "AVDF")

8. Next, create a new Credential with the following values

    - Credential Domain: *`cdb1`*
    - Credential Aalias: *`cdb1`*
    - User ID: *`c##avggadmin@(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=10.0.0.150)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=cdb1)))`*
    - Password: *`Oracle123`*
    - Verify Password: *`Oracle123`*

        ![AVDF](./images/avdf-030c.png "AVDF")

    - Click [**Submit**]

9. Under **Action**, press the **Verify** button for the **cdb1** Domain

    ![AVDF](./images/avdf-031.png "AVDF")

10. If your connection was successful, you should now see a **Checkpoint**, a **Transaction Information** and a **Heartbeat** section

    ![AVDF](./images/avdf-032.png "AVDF")

11. Now we will navigate back to the GoldenGate Administration Server dashboard
    - In the top left corner, open the **Burger menu**
    - Select **Overview**

        ![AVDF](./images/avdf-033a.png "AVDF")

12. Create a new GoldenGate Extract

    - In the **Extracts** section, click the [**+**] symbol

        ![AVDF](./images/avdf-033b.png "AVDF")

    - Choose **Integrated Extract** and click [**Next**]

        ![AVDF](./images/avdf-033c.png "AVDF")

    - In the **Basic Information** section, fill out the fields with the following values
        - Process Name: *`pdb1`*
        - Description: *`Extract data from pdb1`*
        - Intent: *`Unidirectional`*
        - Credential Domain: *`cdb1`*
        - Credential Aalias: *`cdb1`*
        - Begin: *`Now`*
        - Trail Name: *`p1`*
        - Trail Size (MB): *`500`*

            ![AVDF](./images/avdf-034.png "AVDF")

    - and in the **Registration Information** section
        - Register to PDBs: *`pdb1`*

            ![AVDF](./images/avdf-035.png "AVDF")

    - Click [**Next**]

    - Replace the existing **Parameter File** with this

        ````
        <copy>
        extract pdb1
        useridalias cdb1 domain cdb1
        OUTPUTFORMAT XML _AUDIT_VAULT
        exttrail p1
        SOURCECATALOG pdb1
        DDL INCLUDE ALL
        TABLE employeesearch_prod.*;
        </copy>
        ````

    - It should look like this now

        ![AVDF](./images/avdf-036.png "AVDF")

    - Click [**Create and Run**]

    - You will be redirected to the dashboard and you should now have a new Extract in **RUNNING** status

        ![AVDF](./images/avdf-037.png "AVDF")

    **Note**: If it's not running, please start it:
    - On the **PDB1** Extract, click [**Action**] and click [**Start**]
    - Confirm you want to start the Extract process
    - Confirm your Extract now shows **RUNNING**

        ![AVDF](./images/avdf-038.png "AVDF")

**Configure a new Audit Trail**

13. Go back to Audit Vault Web Console as *`AVADMIN`*"

    ![AVDF](./images/avdf-400.png "AVDF")

14. Click the **Targets** tab

15. Click the **pdb1** Target

16. Click [**Modify**] to add an attribute to the Target

17. Click the **Audit Collection Attributes** tab

18. Click [**Add**] to tell the collect this database is in your timezone

    - Name: *`av.collector.TimeZoneOffset`*
    - Value: `<YOUR_DBSECLAB_VM_TIMEZONE>` (here UTC time "*`0:00`*")

        ![AVDF](./images/avdf-039.png "AVDF")

    - Click [**Save**]

19. In the **Audit Data Collection** section, click [**Add**]

    ![AVDF](./images/avdf-039b.png "AVDF")

20. For the new Audit Trail, use the following values

    - Audit Trail Type: *`TRANSACTION LOG`*
    - Trail Location: *`/u01/app/oracle/product/ogg/var/lib/data`*
    - Agent Host: *`dbseclab`*
    - Review the inputs for accuracy

        ![AVDF](./images/avdf-040.png "AVDF")

    - Click [**Save**]

21. The new Audit Trail might say **STOPPED** but if you **refresh the page** then it should switch to **COLLECTING** or **IDLE**.

    ![AVDF](./images/avdf-041.png "AVDF")

    **Note:** Attention, don't go to next step while the both **Audit Trail** and **Unified Audit Trail** are not started!

**Generate Changes and View the Audit Vault Reports**

22. Go back to your Terminal session and generate data and object changes with 2 different privileged users

    ````
    <copy>./avs_generate_employeesearch_prod_changes.sh</copy>
    ````

    ![AVDF](./images/avdf-042.png "AVDF")

23. Go back to Audit Vault Web Console as *`AVAUDITOR`*"

    ![AVDF](./images/avdf-300.png "AVDF")

24. Click the **Reports** tab

25. In the **Data Access & Modification** section, click **Data Modification Before-After Values**

    ![AVDF](./images/avdf-043a.png "AVDF")

26. You should see a "Before-After values" output similar to the following screenshot including the changes just generated previously:

    ![AVDF](./images/avdf-043b.png "AVDF")

**Troubleshooting Issues and Errors**

27. If you are not seeing Before/After value changes in Audit Vault, ensure you:
    - Are logged in as "`AVAUDITOR`" to view the AV reports
    - You properly executed the scripts in `Before_and_After_Changes` folder to create the "`C##GGAVADMIN`" user and setup the database
    - Your GoldenGate Microservices are started
    - Golden Gate Extracts are in a state of `RUNNING` (if not, from the Golden Gate Web Console, click [**Action**] for the `pdb1` extract and set it to start)
    - The Timezone of your Audit Trail is correctly set to your VM Timezone
    - Your Audit Trail is up and running

## Task 8: Audit Vault - Create Alert Policies

In this lab you will modify the Database Firewall connection for the pluggable database **pdb1**

1. Go back to Audit Vault Web Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF")

2. Click the **Policies** tab

3. Click the **Alert Policies** sub-menu on left

4. Click [**Create**]

5. Enter the following information for our new **Alert**

    - Alert Name: *`CREATE USER`*
    - Type: *`Oracle Database`*
    - Description: *`Alert on CREATE USER statements`*
    - Severity: *`Warning`*
    - Threshold (times): *`1`*
    - Condition: *`:EVENT_NAME = 'CREATE USER'`*
    - Template: *`Alert Notification Template`*

6. Your Alert should look like this

    ![AVDF](./images/avdf-044a.png "AVDF")

7. Click [**Save**]

    ![AVDF](./images/avdf-044b.png "AVDF")

    **Note:** Your Alert is automatically started!

8. Go back to your Terminal session and create users within the **pdb1** pluggable database

    ````
    <copy>./avs_create_users.sh</copy>
    ````

    ![AVDF](./images/avdf-045.png "AVDF")

9. Go back to the Audit Vault Web Console as *`AVAUDITOR`* to view alerts

    ![AVDF](./images/avdf-300.png "AVDF")

10. Click on **Alerts** tab

11. View the Alerts that have occurred related to our user creation SQL commands

    ![AVDF](./images/avdf-046.png "AVDF")

    **Note**: If you don't see them, refresh the page because the system catch the alerts every minute

12. Click on the details of one of the alerts

    ![AVDF](./images/avdf-047.png "AVDF")

13. Go back to your Terminal session and drop the users we created in the previous script

    ````
    <copy>./avs_drop_users.sh</copy>
    ````

    ![AVDF](./images/avdf-048.png "AVDF")

    **Note**: Once you understand how to create an alert, feel free to create another and test it manually

## Task 9: DB Firewall - Add the DB Firewall Monitoring

1. Now, go back to Audit Vault Web Console as *`AVADMIN`*"

    ![AVDF](./images/avdf-400.png "AVDF")

2. Click on **Database Firewalls** tab

3. Click on **dbf** Database Firewall Name

    ![AVDF](./images/avdf-101.png "AVDF")

4. Under **Configuration**, click **Network Settings**

    ![AVDF](./images/avdf-102.png "AVDF")

5. Check that the **Proxy Port** for **eth0** is set to *`dbfw_proxy(15223)`*

    ![AVDF](./images/avdf-103.png "AVDF")
    
    **Note**: FYI, follow these instructions to create a Proxy Port:
    - Click on **eth0**
    
        ![AVDF](./images/avdf-104a.png "AVDF")

    - Click [**Add**]

        ![AVDF](./images/avdf-104b.png "AVDF")

    - Name it (here *`dbfw_proxy`*) for the port *`15223`*, then click [**Save**]

        ![AVDF](./images/avdf-104c.png "AVDF")

6. Click [**Close**]

7. Now, enable DB Firewall Monitoring for `pdb1` using the Proxy Port we just created

    - Click the **Targets** tab and click **pdb1**

    - In the **Database Firewall Monitoring** section of this page, click [**Add**]

        ![AVDF](./images/avdf-105.png "AVDF")

    - Fill out the following details

        - Database Firewall: *`dbf`*
        - Mode: *`Monitoring / Blocking (Proxy)`*
        - Network Interface Card: *`eth0`*
        - Proxy Ports: *`dbfw_proxy (15223)`*

            ![AVDF](./images/avdf-106.png "AVDF")

    - Click [**Add**]

    - Fill out the fields as following
        - Host Name / IP Address: *`10.0.0.150`*
        - Port: *`1521`*
        - Service Name: *`pdb1`*

            ![AVDF](./images/avdf-107.png "AVDF")

            **Note**:
            - Ensure you use the IP Address not the hostname because the DBSecLab VMs are using DNS!
            - This is a demonstration environment limitation not an AVDF limitation

    - Click [**Save**]

    - The result should look like this:

        ![AVDF](./images/avdf-108.png "AVDF")

8. Now, verify connectivity between the database and the DB Firewall

    - Go back to your Terminal session and go to the DBF directoy

        ````
        <copy>cd $DBSEC_LABS/avdf/dbf</copy>
        ````

    - Verify connectivity to the database **WITHOUT** the Database Firewall

        ````
        <copy>./dbf_sqlplus_without_dbfw.sh</copy>
        ````

        ![AVDF](./images/avdf-109.png "AVDF")

        **Note**:
        - This will connect to the pluggable database pdb1 **directly** on the standard listener port **1521**
        - You should see that the connection shows **10.0.0.150** which is the IP Address of the DBSec-Lab VM

    - Verify connectivity to the database **WITH** the Database Firewall

        ````
        <copy>./dbf_sqlplus_with_dbfw.sh</copy>
        ````

        ![AVDF](./images/avdf-110.png "AVDF")

        **Note**:
        - This will connect to the pluggable database pdb1 **through the proxy** on the port **15223** (DB Firewall Monitoring) we just configured
        - You should see that the connection shows **10.0.0.152** which is the IP Address of the DB Firewall VM

## Task 10: DB Firewall - Configure and Verify the Glassfish App to Use the DB Firewall

In this lab you will modify the Glassfish connection (instead of connecting directly to the pluggable database **pdb1**, Glassfish will connect through the Oracle DB Firewall so we can monitor, and block, SQL commands)

1. First, verify that the application functions **before** we make any changes to connection string!

2. Open a Web Browser at the URL *`https://dbsec-lab:8080/hr_prod_pdb1`* to access to **your Glassfish App**

    **Notes:** If you are not using the remote desktop you can also access this page by going to *`https://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb1`*
    
3. Login to the application as *`hradmin`* with the password "*`Oracle123`*"

    ````
    <copy>hradmin</copy>
    ````

    ````
    <copy>Oracle123</copy>
    ````

    ![AVDF](./images/avdf-111.png "AVDF")

    ![AVDF](./images/avdf-112.png "AVDF")

4. In the top right hand corner of the App, click on the **Welcome HR Administrator** link and you will be sent to a page with session data

    ![AVDF](./images/avdf-115.png "AVDF")

5. On the **Session Details** screen, you will see how the application is connected to the database. This information is taken from the **userenv** namespace by executing the `SYS_CONTEXT` function.

    ![AVDF](./images/avdf-116.png "AVDF")

6. Logout

    ![AVDF](./images/avdf-117.png "AVDF")

7. Now, go back to your Terminal session and migrate the Glassfish Application connection string to proxy through the Database Firewall

    ````
    <copy>./dbf_start_proxy_glassfish.sh</copy>
    ````

    ![AVDF](./images/avdf-118.png "AVDF")

8. Next, verify the application functions as expected

    - Go back to your Glassfish App web page and login as *`hradmin`* with the password "*`Oracle123`*"
    - In the top right hand corner of the App, click on the **Weclome HR Administrator** link to view the **Session Details** page
    - Now, you should see that the **IP Address** row has changed from **10.0.0.150** to **10.0.0.152**, which is the IP Address of the DB Firewall VM

        ![AVDF](./images/avdf-119.png "AVDF")

## Task 11: DB Firewall - Train the DB Firewall for Expected SQL Traffic
In this lab you will use the Glassfish Application to connect through the Oracle Database Firewall so we can monitor, and block, SQL commands

1. Go back to Audit Vault Web Console as *`AVADMIN`*"

    ![AVDF](./images/avdf-400.png "AVDF")

2. Click the **Database Firewalls** tab

3. Click on the Target name **dbf**

4. Under **Configuration**, click **System Services**

    ![AVDF](./images/avdf-119b.png "AVDF")

    **Note**: According to your resources it can take up to several minutes to present the Tabs!

5. Select the **Date and Time** tab

6. Ensure the first NTP service is **ON** and the IP is *`169.254.169.254`*, and close the pop-up windows

    ![AVDF](./images/avdf-120.png "AVDF")

7. Next, set the type of DB Firewall monitoring, so go back to Audit Vault Web Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF")

8. On top, click on the **Targets** tab

9. Click **pdb1**

10. On the right, click the **Database Firewall Monitoring** sub-tab section

    ![AVDF](./images/avdf-120b.png "AVDF")

11. Change the **Database Firewall Policy**

    - Edit it by clicking on the **Edit** button

        ![AVDF](./images/avdf-121.png "AVDF")

    - Select "*`Log unique`*"
     
        ![AVDF](./images/avdf-121b.png "AVDF")

        **Note:**
        - Log unique policies enable you to log statements for offline analysis that include each distinct source of SQL traffic. Be aware that if you apply this policy, even though it stores fewer statements than if you had chosen to log all statements, it can still use a significant amount of storage for the logged data.
        - Log unique policies log SQL traffic specifically for developing a new policy. The logged data enables the Analyzer to understand how client applications use the database and enables rapid development of a policy that reflects actual use of the database and its client applications.

12. Click the **Green Check** to save

    ![AVDF](./images/avdf-122.png "AVDF")

13. Now, generate Glassfish Application Traffic

    - Go back to your Glassfish App web page and **Logout** explicitly to train the DB Firewall

        ![AVDF](./images/avdf-122b.png "AVDF")

    - Login as *`hradmin`* with the password "*`Oracle123`*"

        ![AVDF](./images/avdf-112.png "AVDF")

    - Click **Search Employees**

        ![AVDF](./images/avdf-113.png "AVDF")

14. In the **HR ID** field enter "*`164`*" and click [**Search**]

    ![AVDF](./images/avdf-123.png "AVDF")

15. Clear the **HR ID** field and click [**Search**] again to see all rows

    ![AVDF](./images/avdf-114.png "AVDF")

16. Enter the following information in the **Search Employee** fields

    - HR ID: *`196`*
    - Active: *`Active`*
    - Employee Type: *`Full-Time Employee`*
    - Position: *`Administrator`*
    - First Name: *`William`*
    - Last Name: *`Harvey`*
    - Department: *`Marketing`*
    - City: *`London`*

        ![AVDF](./images/avdf-124.png "AVDF")

17. Click [**Search**]

18. Click on "**Harvey, William**" to view the details of this employee

    ![AVDF](./images/avdf-125.png "AVDF")

19. Now, let's view the Database Firewall Activity, so go back to Audit Vault Web Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF")

20. Click **Reports**

21. Scroll down to **Database Firewall Reports**

22. Click on **Monitored Activity**

23. Your activity should show queries from `EMPLOYEESEARCH_PROD` using a "**JDBC Thin Client**"

    ![AVDF](./images/avdf-126.png "AVDF")

    **Note**: Sometimes DB Firewall activity may take 5 minutes to appear in the Database Firewall Activity Reports, hence click [**Go**] to refresh this page if needed

24. Click on the details of a query to see more information and notice the following information in the **Event** category:
    - Policy Name: *`Log unique`*
    - Threat Severity: *`minimal`*
    - Location: *`Network`*
    - Action Taken: *`Pass`*

        ![AVDF](./images/avdf-127.png "AVDF")
        ![AVDF](./images/avdf-127b.png "AVDF")

    **Note**:       
      - This information tells us a lot about our Database Firewall policies and why we are capturing this particular query
      - If your reports show a lot of unknown activity you probably have **Native Network Encryption** enabled
      - Please disable it from a terminal session and run the queries again:
         - To check, run the following script: `$DBSEC_LABS/nne/nne_view_sqlnet_ora.sh`
         - If it says `SQLNET.ENCRYPTION_SERVER=REQUESTED` or `SQLNET.ENCRYPTION_SERVER=REQUIRED` then it needs to be disabled
         - To disable it, run the following scripts: `$DBSEC_LABS/nne/nne_disable.sh`
         - To verify, run the following script: `$DBSEC_LABS/nne/nne_view_sqlnet_ora.sh`
      - It should return no contents now!

25. Once you're confortable with these metrics, click [**< Report View**]

    ![AVDF](./images/avdf-127c.png "AVDF")

26. To have a better overview of the activity in this report, add the SQL Text column

    - Click [**Actions**] and select **Select Columns**

        ![AVDF](./images/avdf-127d.png "AVDF")

    - Add "**Command Text(Event)**" to the **Display in Report** section, then click [**Apply**]

        ![AVDF](./images/avdf-127e.png "AVDF")

    - Now, you should see the SQL statements in a dedicated column

        ![AVDF](./images/avdf-127f.png "AVDF")

    - Sroll down to one of our favorite queries

        ![AVDF](./images/avdf-127g.png "AVDF")

        ````
        select USERID,FIRSTNAME,LASTNAME from DEMO_HR_USERS where ( USERSTATUS is NULL or upper( USERSTATUS ) = '######' ) and upper(USERID) = '#######' and password = '#########'
        ````

        **Note**:
        - We like this query because this is the authentication SQL the "`My HR App`" uses to validate the `hradmin` and `Oracle123` password. Remember, the application is authenticated against a table not the database so queries like this will be captured
        - Notice how the Database Firewall has removed the bind values that would have included the username and password. This is to minimize the collection of sensitive data within Audit Vault and Database Firewall

27. Feel free to continue to explore the captured SQL statements and once you are comfortable, please continue the labs!

## Task 12: DB Firewall - Build and Test the DB Firewall Allow-List Policy

1. Before we build our policy we have to make sure DB Firewall has logged the SQL Statements from the **Train the Database Firewall for expected SQL traffic** Lab as well as SQL statements from our SQL*Plus scripts

2. Go back to your terminal session to demonstrate connectivity through the Database Firewall and the ability to query the `EMPLOYEESEARCH_PROD` tables **before applying the DB Firewall policy**

    ````
    <copy>./dbf_query_fw_policy.sh</copy>
    ````

    ![AVDF](./images/avdf-128.png "AVDF")

    **Note**: You can see all rows!

3. Go back to Audit Vault Web Console as *`AVAUDITOR`* to create a Database Firewall Policy

    ![AVDF](./images/avdf-300.png "AVDF")

4. Click the **Policies** tab

5. Click the **Database Firewall Policies** sub-menu on left

6. Click [**Create**]

7. Create the Database Firewall Policy with the following information

    - Policy Name: *`HR Policy`*
    - Target Type: *`Oracle Database`*
    - Description: *`This policy will protect the My HR App`*

        ![AVDF](./images/avdf-129.png "AVDF")

    - Click [**Save**]

8. Now, create the context of this policy by clicking [**Sets/Profiles**]

    ![AVDF](./images/avdf-130.png "AVDF")

9. In the **SQL Cluster Sets** subtab, click [**Add**]

    ![AVDF](./images/avdf-131.png "AVDF")

10. In the **Add SQL Cluster Set** screen, create the list of known queries as following

    - Name: *`HR SQL Cluster`*
    - Description: *`Known SQL statements for HR App`*
    - Target: *`pdb1`*
    - Show cluster for: *`Last 24 Hours`* (or make this `Last Week`)
    - Click [**Go**]

        ![AVDF](./images/avdf-132a.png "AVDF")

    - Click [**Actions**] and select "*`ALL`*" in **Row per page** option to display all the results

        ![AVDF](./images/avdf-132b.png "AVDF")

    - Check the **Select all** box next to the "**Cluster ID**" Header to add all "trained" queries into the SQL Clusters

        ![AVDF](./images/avdf-132c.png "AVDF")

    - But please **unselect the SQL*Plus query** run earlier in Step 12-1 to block it (because here we consider that it's not an official HR App query)

        ```
        select userid, firstname, lastname, emptype, position, city, ssn, sin, nino from employeesearch_prod.demo_hr_employees where rownum < 00
        ```

        ![AVDF](./images/avdf-133a.png "AVDF")

    - Click [**Save**]

11. Click [**Back**]

    ![AVDF](./images/avdf-133b.png "AVDF")

12. Select the **SQL Statement** sub-tab and click [**Add**]

    ![AVDF](./images/avdf-133c.png "AVDF")

13. Complete the **SQL Statement** with the following information to allow the **HR SQL Cluster** created previoulsy (here we consider that these queries are official and can be executed)

    - Rule Name: *`Allows HR SQL`*
    - Description: *`Allowed SQL statements for HR App`*
    - Cluster Set(s): *`HR SQL Cluster`*
    - Action: *`Pass`*
    - Logging Level: *`Don't Log`*
    - Threat Severity: *`Minimal`*

        ![AVDF](./images/avdf-134a.png "AVDF")

    - Click [**Save**]

14. Next, add database users that we trust to connect to the database through the Database Firewall

    **Note**:
    - We will create a **Database User Set** for our DB Admin (`SYSTEM`) and for the HR App's owner (`EMPLOYEESEARCH_PROD`)
    - Only these 2 DB users will be able to run the **HR SQL Cluster**

15. Click [**Sets/Profiles**]

    ![AVDF](./images/avdf-134b.png "AVDF")

16. Select the **Database User Sets** tab and click [**Add**]

    ![AVDF](./images/avdf-134c.png "AVDF")

17. Enter the following information:

    - Name: *`Privileged Users`*
    - Description: *`Users We Trust`*
    - Sets Values: *`SYSTEM, EMPLOYEESEARCH_PROD`*

        ![AVDF](./images/avdf-135.png "AVDF")

    - Click [**Save**]
    - Click [**Back**]

        ![AVDF](./images/avdf-136.png "AVDF")

18. Finally, select the **Default** tab to specify what the DB Firewall policy has to do you if you are not in the context definied previously (here we will block all the "black-listed" queries and we will return a blank result)

    ![AVDF](./images/avdf-137.png "AVDF")

    - Click on **Default Rule** under the Rule Name, to edit the Default rule, and enter the following information
        - Action: *`Block`*
        - Logging Level: *`One-Per-Session`*
        - Threat Severity: *`Moderate`*
        - Substitution SQL: *`SELECT 100 FROM dual WHERE 1=2`*

            ![AVDF](./images/avdf-138.png "AVDF")

    - Click [**Save**]

19. Your HR Policy should look like this:

    ![AVDF](./images/avdf-139.png "AVDF")

20. Click [**Save and Publish**]

21. Once created, the policy is **automatically published**, but now you have to deploy it

    ![AVDF](./images/avdf-140.png "AVDF")

22. Click the **Targets** tab

23. Click the Target Name **pdb1**

24. Click the **Database Firewall Monitoring** sub-tab on right

25. Change **Database Firewall Policy** to "*`HR Policy`*"

    ![AVDF](./images/avdf-141a.png "AVDF")

26. Click the **Green Check** to implement this DB Firewall Policy

    ![AVDF](./images/avdf-141b.png "AVDF")

27. Once the DB Firewall Policy is enabled, we will validate the impact on the Glassfish App
    - Go back to your Glassfish App web page, logout and login as *`hradmin`* with the password "*`Oracle123`*"
    - Click **Search Employees**
    - Click [**Search**]

        ![AVDF](./images/avdf-114.png "AVDF")

        **Note**: All rows are returned... Remember, all "official" queries from the HR App have been allowed in **HR SQL Cluter** in your DB Firewall policy

28. Even if you add a search criteria and query again, you can access to the result (here we **filter by "HR ID = 196"** for example)

    ![AVDF](./images/avdf-142.png "AVDF")

29. Now, go back to your Terminal session and run the same script as at the beginning to see the impact of the DB Firewall policy

    ````
    <copy>./dbf_query_fw_policy.sh</copy>
    ````

    ![AVDF](./images/avdf-143.png "AVDF")

    **Note**:
    - The output should return "**no rows selected**" for the SQL query
    - Remember, this is because the DB Firewall policy substitute the result by "`SELECT 100 FROM dual WHERE 1=2`" for "unofficial" queries from the HR App, although you are still logged in with an authorized DB user (here SYSTEM)!

## Task 13: DB Firewall - Block a SQL Injection Attack

**SQL Injection (SQLi)** is a well-known cyber attack. Its ability to exploit security holes can be very powerful if properly exploited. It exploits security holes in an application that interacts with a database. The SQL Injection attack consists of modifying a current SQL query by injecting an unanticipated piece of the query, often through a form. The hacker can thus access the database, but also modify the content and thus compromise the security of the system.
There are different types of SQL Injection:
- "Blind-based" injects chunks that will return character by character what the attacker is trying to extract from the database. This allows to test the valid or invalid characters.
- "Error-based" injects pieces that return field by field what the hacker is trying to extract from the database. This allows to divert the error message it generates.
- "UNION-based" injects chunks that will return a set of data directly extracted from the database. This allows to retrieve entire tables from the database in one or two queries!
- "Stacked query" is the most dangerous attack. Due to a database server configuration error, this type of injection can execute any SQL query on the targeted system. Not only does it retrieve data, but it can also modify data directly in the database.

In this lab you will perform a "**UNION-based**" SQL Injection attack and see how to block it easily thanks to Database Firewall. To do that, we will use the policy "`HR Policy`" just created previously.

1. Go back to Audit Vault Web Console as *`AVAUDITOR`* to create a Database Firewall Policy

    ![AVDF](./images/avdf-300.png "AVDF")

2. Click the **Targets** tab

3. Click the Target Name **pdb1**

4. Click the **Database Firewall Monitoring** sub-tab on right

5. Change **Database Firewall Policy** to "*`Log Unique`*" to allow all traffic, even the bad one... especially the bad one!

    ![AVDF](./images/avdf-160.png "AVDF")

6. Click the **Green Check** to implement this DB Firewall Policy

    ![AVDF](./images/avdf-161.png "AVDF")

7. Once the DB Firewall Policy is enabled, we will validate the impact on the Glassfish App
    - Go back to your Glassfish App web page, logout and login as *`hradmin`* with the password "*`Oracle123`*"
    - Click **Search Employees**
    - Click [**Search**]

        ![AVDF](./images/avdf-114.png "AVDF")

        **Note**: All rows are returned... normal, because, remerber, you allowed everything!

8. Now, tick the **checkbox "Debug"** to see the SQL query behind this form

    ![AVDF](./images/avdf-162.png "AVDF")

9. Click [**Search**] again

    ![AVDF](./images/avdf-163.png "AVDF")

    **Note:**
    - Now, you can see the official SQL query executed by this form which displays the results
    - This query gives you the information of the number of columns requested, their name, their datatype and their relationship

10. Now, based on this information, you can create our "UNION-based" SQL Injection query to display all sensitive data you want extract directly from the form. Here, we will use this query to extract `USER_ID', 'MEMBER_ID', 'PAYMENT_ACCT_NO` and `ROUTING_NUMBER` from `DEMO_HR_SUPPLEMENTAL_DATA` table.

    ````
    <copy>
    ' UNION SELECT userid, ' ID: '|| member_id, 'SQLi', '1', '1', '1', '1', '1', '1', 0, 0, payment_acct_no, routing_number, sysdate, sysdate, '0', 1, '1', '1', 1 FROM demo_hr_supplemental_data --
    </copy>
    ````

11. Copy the SQL Injection query, **paste it directly into the field "Position"** on the Search form and **tick the "Debug" checkbox**

    ![AVDF](./images/avdf-164.png "AVDF")

    **Note:**
    - Don't forget the "`'`" before the UNION key word to close the SQL clause "LIKE"
    - Don't forget the "`--`" at the end to disable rest of the query

12. Click [**Search**]

    ![AVDF](./images/avdf-165.png "AVDF")

    **Note:**
    - Now, because the source code of the app is exposed to this kind of attack, instead of the results as usual, **you can see your sensitive extraction**!
    - Of course, you can modify this UNION query and extract the columns you want

13. **To block this attack, *with no app changes or reboot*, just activate at any time your Database Firewall policy!**

    - Go back to Audit Vault Web Console as *`AVAUDITOR`* to create a Database Firewall Policy

        ![AVDF](./images/avdf-300.png "AVDF")

    - Click the **Targets** tab

    - Click the Target Name **pdb1**

    - Click the **Database Firewall Monitoring** sub-tab

    - Change **Database Firewall Policy** to "*`HR Policy`*" to allow only your trusted traffic as defined previously in Step 12

        ![AVDF](./images/avdf-166.png "AVDF")

    - Click the **Green Check** to implement this DB Firewall Policy

        ![AVDF](./images/avdf-167.png "AVDF")

    - Once the DB Firewall Policy is enabled, we will validate the impact on the Glassfish App
        - Go back to your Glassfish App web page
        - **Keep the SQL Injection query** on the Search form
        - **Tick the "Debug"** checkbox

            ![AVDF](./images/avdf-164.png "AVDF")

        - Click [**Search**]

            ![AVDF](./images/avdf-168.png "AVDF")

        **Note**:
        - The output should return "**no rows**"
        - Remember, this is because the UNION query has not been added into the Allow-list in the DB Firewall policy... as simple as that!

## Task 14: DB Firewall - Detect Data Exfiltration Attempts

In this lab, you will detect sensitive data exfiltration attempts by capturing the number of rows returned for SELECT statements. Typically, when an application behaves normally, it's to display a single or maybe 50-100 rows per page displayed. But if you suddenly see a return of 1000 rows or more, this is definitely not normal application behavior. It's really important to know this automatically in real time, with no impact on the performance, to determine whether it's normal or not.

In this lab you will create the policy `PII Exfiltration Monitor` to monitor the PII exfiltration attempts

1. Go back to Audit Vault Web Console as *`AVAUDITOR`* to create a Database Firewall Policy

    ![AVDF](./images/avdf-300.png "AVDF")

2. Click the **Policies** tab

3. Click the **Database Firewall Policies** sub-menu on left

4. Click [**Create**]

5. Create the Database Firewall Policy with the following information

    - Policy Name: *`PII Exfiltration Monitor`*
    - Target Type: *`Oracle Database`*
    - Description: *`This policy will monitor the PII exfiltration attempts`*

        ![AVDF](./images/avdf-170.png "AVDF")

    - Click [**Save**]

6. In the **Database Firewall Policy Rules** section, select the **Database Objects** subtab and click [**Add**]

    ![AVDF](./images/avdf-171.png "AVDF")

7. In the **Database Objects** screen, create the rule as following (we will monitor ALL tables)

    - Rule Name: *`PII Table Monitor`*
    - Description: *`Monitor the sensitive tables`*
    - Statement Classes: select *`DML`* and *`Select`*
    - Capture number of rows returned for SELECT queries: *`Yes`*
    - Action: *`Pass`*
    - Logging Level: *`Always`*
    - Threat Severity: *`Moderate`*

        ![AVDF](./images/avdf-172.png "AVDF")

    - Click [**Save**]

8. Click [**Save and Publish**]

9. Once created, the policy is **automatically published**

    ![AVDF](./images/avdf-174.png "AVDF")

10. Now, you have to deploy the policy published

    - Click the **Targets** tab

    - Click the Target Name **pdb1**

    - Click the **Database Firewall Monitoring** sub-tab on right

    - Change **Database Firewall Policy** to "*`PII Exfiltration Monitor`*"

        ![AVDF](./images/avdf-175.png "AVDF")

    - Click the **Green Check** to implement this DB Firewall Policy

        ![AVDF](./images/avdf-176.png "AVDF")

11. Once the DB Firewall Policy is enabled, go back to you Terminal session to generate some SELECT commands on SQL*Plus via the proxy connection

    ````
    <copy>./dbf_exfiltrate_with_dbfw.sh</copy>
    ````

    ![AVDF](./images/avdf-177.png "AVDF")

    [...]

    ![AVDF](./images/avdf-178.png "AVDF")

12. Go back to Audit Vault Web Console as *`AVAUDITOR`* to create a Database Firewall Policy

    ![AVDF](./images/avdf-300.png "AVDF")

13. Click the **Reports** tab

14. In the **Database Firewall Reports**, click on **Monitored Activity** report

    ![AVDF](./images/avdf-179.png "AVDF")

15. Watch the "**Event Time**" to confirm your recent activity 

    ![AVDF](./images/avdf-180.png "AVDF")

    **Note**: If not, refresh the research because DB Firewall needs up to a few minutes to integrate the events in its report

16. But to see the "**Row Count**" number in the list, you have to add the column in your report

    - In the **Actions** drop-down list, select **Select columns**

        ![AVDF](./images/avdf-181.png "AVDF")

    - Add the columns *`Row Count(Event)`*, *`Object Type(Target Object)`* and *`Policy Name(Event)`*

        ![AVDF](./images/avdf-182.png "AVDF")

    - Click [**Apply**]

    - You can see now the "Row Count" number of queries executed previously, with the name of the table targeted and the policy name

        ![AVDF](./images/avdf-183.png "AVDF")

17. Now, to be alerted in case of exfiltration attempts, you have to create a dedicated alert

    - Click the **Policies** tab

    - Click the **Alert Policies** sub-tab

    - Click [**Create**] and fill out the field as following

        - Alert Name: *`PII Exfiltration Alert`*
        - Type: *`Oracle Database`*
        - Description: *`Someone has selected more than 100 rows of PII in a single query`*
        - Severity: *`Warning`*
        - Threshold (times): *`1`*
        - Group By (Field): *`USER_NAME`*
        - Duration: *`1`*
        - Condition: *`:ROW_COUNT > 100 and :TARGET_OBJECT like '%DEMO_HR%'`*

            ![AVDF](./images/avdf-184.png "AVDF")

        - Click [**Save**]

18. Once the DB Firewall Alert is created, go back again to your Terminal session to generate the same SELECT commands on SQL*Plus via the proxy connection

    ````
    <copy>./dbf_exfiltrate_with_dbfw.sh</copy>
    ````

    ![AVDF](./images/avdf-177.png "AVDF")

    [...]

    ![AVDF](./images/avdf-178.png "AVDF")

19. Let's check the alerts

    - Go back to Audit Vault Web Console as *`AVAUDITOR`*

        ![AVDF](./images/avdf-300.png "AVDF")

    - Click the **Alerts** tab

    - You should see some alerts "**PII Exfiltration Alert**" in the "Alert Policy Name" column

        ![AVDF](./images/avdf-185.png "AVDF")

        **Note:** Again, if you don't see them refresh the page because DB Firewall needs up to a few minutes to integrate the events

    - Click on the first alert to see its details

        ![AVDF](./images/avdf-186.png "AVDF")

    - To see the details of the event, click on the **paper icon** in the **Event** section

        ![AVDF](./images/avdf-187.png "AVDF")

        ![AVDF](./images/avdf-188.png "AVDF")

20. Now you know how to detect a sensitive data exfiltration with no impact on the performance thanks to Database Firewall!

## Task 15: DB Firewall - Restore the Glassfish App Configuration to Use Direct Mode

In this lab you will restore the Glassfish connection in order to connecting directly to the pluggable database **pdb1** without the Database Firewall

1. Restore the Glassfish App connection string to direct connect mode

    ````
    <copy>./dbf_stop_proxy_glassfish.sh</copy>
    ````

    ![AVDF](./images/avdf-144.png "AVDF")

## Task 16: Advanced Labs - (Optional) PostgreSQL Audit Collection
The objective of this lab is to collect audit log records from PostgreSQL databases (with pgaudit configured) into Oracle Audit Vault and Database Firewall:
- Ensure to that **pgaudit** is installed extension:
    - The PostgreSQL Audit Extension (or pgaudit) provides detailed session and/or object audit logging via the standard logging facility provided by PostgreSQL
    - The audit collection will be incomplete and operational details are missed out from the reports in case this extension is not enabled
- Make sure that the `LOG_DESTINATION` parameter is set to **CSVLOG** in postgresql.conf file:
    - The AVDF PostgreSQL audit collector will only be able to process CSV files
- Parameter `LOGGING_COLLECTOR` needs to be set to **ON**
- The AVDF Agent OS user needs to have read permission on the directory specified on the `LOG_DIRECTORY` parameter and the generated CSV files to be able to read them

1. Go to the scripts directory

    ````
    <copy>cd $DBSEC_LABS/avdf/adv</copy>
    ````

2. Run the script as **postgres** user to setup the pgaudit and load data

    ````
    <copy>sudo -u postgres ./adv_pgsql_init.sh</copy>
    ````

    ![AVDF](./images/avdf-201.png "AVDF")

3. Next, go back to Audit Vault Web Console as *`AVADMIN`*"

    ![AVDF](./images/avdf-400.png "AVDF")

4. Click the **Targets** tab

5. Click [**Register**]

    ![AVDF](./images/avdf-202.png "AVDF")

6. Use the following information for your new target details

    - Name: *`PostgreSQL`*
    - Type: *`PostgreSQL`*
    - Description: *`PostgreSQL Database`*
    - Connection string: *`dbsec-lab`*
    - Leave the `USER NAME` and `PASSWORD` blank because we are going to use a "**Directory**" collector

        ![AVDF](./images/avdf-203.png "AVDF")

    - Click the **Audit Collection Attributes** sub-tab and add information as following:

        - Name: *`av.collector.securedTargetVersion`*  /  Value: *`11.0`*
        - Name: *`av.collector.timezoneoffset`*  /  Value: `<YOUR_DBSECLAB-VM_TIMEZONE>` (here UTC Time: "*`0:00`*")

            ![AVDF](./images/avdf-204.png "AVDF")

    - Click [**Save**]

7. In the **Audit Data Collection** section, click [**Add**]

    ![AVDF](./images/avdf-205.png "AVDF")

8. In the **Add Audit Trail** window add the following

    - Audit Trail Type: *`DIRECTORY`*
    - Trail Location: *`/var/log/pgsql`*
    - Agent Host: *`dbseclab`*

        ![AVDF](./images/avdf-206.png "AVDF")

    - Click [**Save**]

9. Refresh the page until you see the **IDLE** status

    ![AVDF](./images/avdf-207.png "AVDF")

10. Go back to your Terminal session and generate traffic on the PostgreSQL database for auditing

    ````
    <copy>./adv_pgsql_generate_traffic.sh</copy>
    ````

    ![AVDF](./images/avdf-208.png "AVDF")

11. Next, go back to Audit Vault Web Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF")

12. Click the **Reports** tab

13. Click the **All Activity** report name

14. You should see audited events from the **PostgreSQL** target Database

    ![AVDF](./images/avdf-209.png "AVDF")

15. Finally, explore the filters and view the details on the audit data

    - Click on the **Event Status** tab and filter the report by **FAILURE**

        ![AVDF](./images/avdf-210.png "AVDF")

    - You might see some failures

        ![AVDF](./images/avdf-211.png "AVDF")

    - Click on the **paper icon** for first audit row for **DROP ROLE** and view the details
    
        ![AVDF](./images/avdf-211b.png "AVDF")
    
    - You should see a lot of audit details about this particular audited event

        ![AVDF](./images/avdf-212.png "AVDF")

16. Once you are comfortable, you can now reset the PostgreSQL audit configuration

    - Delete the "PostgreSQL" target
    
        - Go back to Audit Vault Web Console as *`AVADMIN`*"

            ![AVDF](./images/avdf-400.png "AVDF")

        - Click the **Targets** tab

        - Click "**Audit Trails**" sub-menu
        
        - Select "**PostgreSQL**" Audit Trail and click [**Stop**]

            ![AVDF](./images/avdf-212b.png "AVDF")

        - Click [**OK**] to confirm the shutdown

            ![AVDF](./images/avdf-212c.png "AVDF")

        - Refresh the page to be sure that the service is stopped

            ![AVDF](./images/avdf-212d.png "AVDF")

        - Select "**PostgreSQL**" Audit Trail and click [**Delete**]

            ![AVDF](./images/avdf-212e.png "AVDF")

        - Click [**OK**] to confirm the deletion

            ![AVDF](./images/avdf-212f.png "AVDF")

        - Click "**Targets**" sub-menu

        - Select "**PostgreSQL**" target and click [**Delete**]

            ![AVDF](./images/avdf-212g.png "AVDF")

    - Now, go back to your Terminal session and reset the PostgreSQL database auditing

        ````
        <copy>sudo -u postgres ./adv_pgsql_cleanup.sh</copy>
        ````

        ![AVDF](./images/avdf-213.png "AVDF")
    
17. Now, the PostgreSQL audit configuration is deleted for this lab!

## Task 17: Advanced Labs - (Optional) Linux Audit Collection

The objective of this lab is to collect event log from the Operating System

1. Setup the audit collection to write data with the **oinstall** Operating System group

    ````
    <copy>./adv_linux_setup_auditing.sh</copy>
    ````

    ![AVDF](./images/avdf-214.png "AVDF")

2. Next, go back to Audit Vault Web Console as *`AVADMIN`*"

    ![AVDF](./images/avdf-400.png "AVDF")

3. Click **Targets**

4. Click [**Register**]

5. Click [**Add**] and create a target with the following information

    - Name: *`dbsec-lab`*
    - Type: *`Linux`*
    - Description: *`Linux OS`*
    - In the **Audit Connection Details** section, Host Name/IP Address: *`dbsec-lab`*

        ![AVDF](./images/avdf-215.png "AVDF")

6. In the **Audit Data Collection** section

    - Click [**Add**]

        ![AVDF](./images/avdf-215b.png "AVDF")

    - Enter the following information

        - Audit Trail Type: *`DIRECTORY`*
        - Trail Location: *`/var/log/audit/audit*.log`*
        - Agent Host: *`dbseclab`*

            ![AVDF](./images/avdf-216.png "AVDF")

    - Click [**Save**]

7. Refresh the page until you see the **Collecting** status

    ![AVDF](./images/avdf-217.png "AVDF")

8. Go back to your terminal session and run the audit generation script

    ````
    <copy>./adv_linux_generate_traffic.sh</copy>
    ````

    ![AVDF](./images/avdf-218.png "AVDF")

9. Next, go back to Audit Vault Web Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF")

10. Click the **Reports** tab

11. Click the **All Activity** report name

12. You should see audited events from the **dbsec-lab** target Database

    ![AVDF](./images/avdf-219.png "AVDF")

13. Finally, explore the filters and view the details on the audit data

    - Click on the **Event Status** tab and filter the report by **UNKNOWN**

        ![AVDF](./images/avdf-220.png "AVDF")

    - You might see failures for multiple targets

        ![AVDF](./images/avdf-221.png "AVDF")

    - Click on the **paper icon** for first audit row for "`USER_CMD`" and view the details
    
        ![AVDF](./images/avdf-221b.png "AVDF")

    - You should see a lot of audit details about this particular audited event

        ![AVDF](./images/avdf-222.png "AVDF")

14. Once you are comfortable, you can now reset the Linux audit configuration

    - Delete the "Linux" target
    
        - Go back to Audit Vault Web Console as *`AVADMIN`*"

            ![AVDF](./images/avdf-400.png "AVDF")

        - Click the **Targets** tab

        - Click "**Audit Trails**" sub-menu
        
        - Select "**dbsec-lab**" Audit Trail and click [**Stop**]

            ![AVDF](./images/avdf-223.png "AVDF")

        - Click [**OK**] to confirm the shutdown

            ![AVDF](./images/avdf-224.png "AVDF")

        - Refresh the page to be sure that the service is stopped

            ![AVDF](./images/avdf-225.png "AVDF")

        - Select "**dbsec-lab**" Audit Trail and click [**Delete**]

            ![AVDF](./images/avdf-226.png "AVDF")

        - Click [**OK**] to confirm the deletion

            ![AVDF](./images/avdf-227.png "AVDF")

        - Click "**Targets**" sub-menu

        - Select "**dbsec-lab**" target and click [**Delete**]

            ![AVDF](./images/avdf-228.png "AVDF")

    - Go back to your Terminal session and reset the audit collection to the 'root' Linux OS group only

        ````
        <copy>./adv_linux_reset_auditing.sh</copy>
        ````

        ![AVDF](./images/avdf-229.png "AVDF")

15. Now, the Linux audit configuration is deleted for this lab!

## Task 18: Advanced Labs - (Optional) LDAP/Active Directory Configuration

Important: before performing this lab, you must have:
- an Microsoft Active Directory Server 2016 or higher available in the same VCN as the DBSecLab VMs
- the knowledege to configure the `MS AD 2016` server appropriately

1. Go back to Audit Vault Web Console as *`AVADMIN`*"

    ![AVDF](./images/avdf-400.png "AVDF")

2. Navigate to the Audit vault settings

    - Click the **Settings** tab

    - Click the **LDAP/Active Directory Configuration** sub tab

        ![AVDF](./images/avdf-230.png "AVDF")

    - Click [**Add**]

3. Enter the following information

    - Server Name: *`msad`*
    - Port: *`<YOUR_MSAD_PORT_FOR_SSL_CONNECTION>`*
    - Host Name / IP Address: *`<YOUR_MSAD_PRIVATE_IP_ADDRESS_10.0.0.XXX>`*
    - Domain Name: *`<YOUR_MSAD_DOMAIN_NAME>`*
    - Active Directory Username: *`<YOUR_MSAD_USERNAME>`*
    - Active Directory Password: *`<YOUR_MSAD_PASSWORD>`*
    - Wallet Password for Certificate: *`<YOUR_WALLET_PASSWORD>`*
    - Re-Type Wallet Password for Certificate: *`<YOUR_WALLET_PASSWORD>`*
    - Certificate: *`<YOUR_MSAD_SSL_CERTIFICATE>`*

        ![AVDF](./images/avdf-231.png "AVDF")

4. Click **Test Connection** to verify the connection is successful

5. Click [**Save**]

## Task 19: Reset the AVDF Lab Config

1. Delete the **Database Firewall Monitoring** configuration

    - Go back to Audit Vault Web Console as *`AVADMIN`*"

        ![AVDF](./images/avdf-400.png "AVDF")

    - Click the **Targets** tab

    - Click the Target Name **pdb1**

        ![AVDF](./images/avdf-250.png "AVDF")

    - In the section **Database Firewall Monitoring**, select "**10.0.0.150 : 1521 : pdb1**" and click [**Stop**]

        ![AVDF](./images/avdf-251.png "AVDF")

    - Check that the service is suspended

        ![AVDF](./images/avdf-252.png "AVDF")

    - Select "**10.0.0.150 : 1521 : pdb1**" and click [**Delete**]

        ![AVDF](./images/avdf-253.png "AVDF")

2. Reset **Golden Gate** configuration

    - In the section **Audit Data Collection**, select "**/u01/app/oracle/product/ogg/var/lib/data**" and click [**Stop**]

        ![AVDF](./images/avdf-254.png "AVDF")

    - Refresh the page to be sure that the service is stopped

        ![AVDF](./images/avdf-255.png "AVDF")

    - Select "**/u01/app/oracle/product/ogg/var/lib/data**" Audit Trail and click [**Delete**]

        ![AVDF](./images/avdf-256.png "AVDF")

    - Login to your GoldenGate Web Console

        - Open a web browser window to *`https://dbsec-lab:50002`*

            **Note**:If you are not using the remote desktop you can also access this page by going to *`https://<DBSecLab-VM_@IP-Public>:50002`*

        - Login to Golden Gate Web Console as *`OGGADMIN`* with the password "*`Oracle123`*"

            ````
            <copy>oggadmin</copy>
            ````

            ````
            <copy>Oracle123</copy>
            ````

            ![AVDF](./images/avdf-029.png "AVDF")

    - In the top left corner, open the **Burger menu** and select **Configuration**

        ![AVDF](./images/avdf-030a.png "AVDF")

    - Delete the "**Credentials**" by clicking on the "**Delete**" button

        ![AVDF](./images/avdf-257.png "AVDF")

    - Click [**Delete**] to confirm the deletion

        ![AVDF](./images/avdf-258.png "AVDF")

    - In the top left corner, open the **Burger menu** and select **Overview**

        ![AVDF](./images/avdf-033a.png "AVDF")

    - Stop the "**Extracts**" service by clicking on the "**Actions**" button and selecting "**Stop**"

        ![AVDF](./images/avdf-259.png "AVDF")

    - Click [**OK**] to confirm the action

        ![AVDF](./images/avdf-260.png "AVDF")

    - Delete the "**Extracts**" service by clicking on the "**Actions**" button and selecting "**Delete**"

        ![AVDF](./images/avdf-261.png "AVDF")

    - Click [**OK**] to confirm the deletion

        ![AVDF](./images/avdf-262.png "AVDF")

    - Go back to your Terminal session to reset Golden Gate

        ````
        <copy>$DBSEC_LABS/avdf/avs/avs_reset_ogg.sh</copy>
        ````

        ![AVDF](./images/avdf-263.png "AVDF")

3. Delete the **Unified Audit Trail** configuration

    - Go back to Audit Vault Web Console as *`AVADMIN`*"

        ![AVDF](./images/avdf-400.png "AVDF")

    - Click the **Targets** tab

    - Click the Target Name **pdb1**

    - In the section **Audit Data Collection**, select "**`UNIFIED_AUDIT_TRAIL`**" and click [**Stop**]

        ![AVDF](./images/avdf-264.png "AVDF")

    - Check that the service is stopped

        ![AVDF](./images/avdf-265.png "AVDF")

    - Select "**`UNIFIED_AUDIT_TRAIL`**" and click [**Delete**]

        ![AVDF](./images/avdf-266.png "AVDF")

4. Next, delete the **target**

    - Click the **Targets** tab

    - Select the Target Name **pdb1** and click [**Delete**]

        ![AVDF](./images/avdf-267.png "AVDF")

    - Now, you should see no rows

        ![AVDF](./images/avdf-268.png "AVDF")

5. Then, delete the **Agent**

    - Click the **Agents** tab

    - Select the Agent Name **dbseclab** and click [**Deactivate**]

        ![AVDF](./images/avdf-269.png "AVDF")

    - Now, the agent should be "**Not Activated**"

        ![AVDF](./images/avdf-270.png "AVDF")

    - Select the Agent Name **dbseclab** and click [**Delete**]

        ![AVDF](./images/avdf-271.png "AVDF")

    - Now, the agent is deleted

        ![AVDF](./images/avdf-272.png "AVDF")


6. Finally, reset **AVDF binaries**

    ````
    <copy>
    rm -Rf $AV_HOME/!(*.jar)
    ll $AV_HOME

    rm -Rf $AVCLI_HOME/!(*.jar)
    ll $AVCLI_HOME
    </copy>
    ````

    ![AVDF](./images/avdf-273.png "AVDF")

7. **Now, the AVDF configuration is correctly reset!**

You may now proceed to the next lab!

## **Appendix**: About the Product
### **Overview**

Oracle Audit Vault and Database Firewall (AVDF) is a complete **Database Activity Monitoring (DAM)** solution that **combines native audit data with network-based SQL traffic capture**.

AVDF includes an enterprise quality **audit data warehouse**, host-based audit data collection agents, powerful reporting and analysis tools, alert framework, audit dashboard, and a multi-stage Database Firewall. The Database Firewall uses a sophisticated **grammar analysis engine** to inspect SQL statements before they reach the database and determines with high accuracy whether to allow, log, alert, substitute, or block the incoming SQL.

AVDF comes with **collectors for Oracle Database, Oracle MySQL, Microsoft SQL Server, PostgreSQL, IBM Db2 (on LUW), SAP Sybase, Oracle Key Vault, Microsoft Active Directory, Linux, Windows, AIX, Solaris, and HPUX**. A **Quick-JSON collector** simplifies ingesting audit data from databases like MongoDB. In addition to the provided collectors, AVDF's extensible framework allows simple configuration-based audit collection from **JDBC**-accessible databases and REST, JSON, or XML sources, making collection from most other systems easy. A full featured Java SDK allows creation of collectors for applications or databases that don't use a standard technology to record their audit trail.

![AVDF](./images/avdf-concept-01.png "AVDF")

### **Benefits of Using Audit Vault and Database Firewall**
- **Software Appliance**

Oracle Audit Vault and Database Firewall are packaged as a "**Soft Appliance**" and contain everything needed to install the product on bare hardware - or in this case virtual environments.

- **Fine Grained, Customizable Reporting and Alerting**

Dozens of out-of-the-box compliance reports provide easy, schedulable, customized reporting for regulations such as GDPR, PCI, GLBA, HIPAA, IRS 1075, SOX, and UK DPA.
Reports aggregate network events and audit data from the monitored systems. Summary reports, trend charts and anomaly reports can be used to quickly review characteristics of user activity and help identify anomalous events. Report data can be easily filtered, enabling quick analysis of specific systems or events. Security managers can define threshold based alert conditions on activities that may indicate attempts to gain unauthorized access and/or abuse system privileges. Fine-grained authorizations enable security managers to restrict auditors and other users to information from specific sources, allowing a single repository to be deployed for an entire enterprise.

![AVDF](./images/avdf-concept-02.png "AVDF")

- **Deployment Flexibility and Scalability**

Security controls can be customized with in-line monitoring and blocking on some databases and monitoring only on other databases. The multi-stage Database Firewall can be deployed in-line as a database proxy server, or out-of-band in network sniffing mode, or with a host-based agent that relays network activity back to the firewall for analysis and recording. Delivered as a pre-configured software appliance that can be deployed on Linux-compatible hardware of choice, a single Audit Vault Server can consolidate audit data and firewall events from thousands of databases. Both Audit Vault Server and the Database Firewall can be configured in a High Availability mode for fault tolerance.

Oracle Audit Vault and Database Firewall 20c **supports both Cloud and On-Premise databases with one single dashboard**, giving customers insight into the activities on their databases.

## Want to Learn More?
Technical Documentation:
- [Oracle Audit Vault & Database Firewall 20c](https://docs.oracle.com/en/database/oracle/audit-vault-database-firewall/20/index.html)

Video:
- *Understanding Oracle Audit Vault and Database Firewall 20c (August 2020)* [](youtube:9xG0GFKbVJk)
- *Auditing PostgreSQL and MongoDB with Oracle Audit Vault and Database Firewall (October 2020)* [](youtube:o0LqJXwS4L0)
- *Introducing Oracle Audit Vault and Database Firewall 20 update 3 (20.3) (February 2021)* [](youtube:BkeCuU90ek4)
- *Introducing Oracle Audit Vault and Database Firewall 20.4 (June 2021)* [](youtube:Q90Htb_Lef4)

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Angeline Dhanarani, Nazia Zaidi, Rene Fontcha
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - January 2023