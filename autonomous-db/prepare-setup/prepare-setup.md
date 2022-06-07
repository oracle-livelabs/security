# Prepare your environment

## Introduction

This lab walks you through the steps to get started using the Oracle Autonomous Database and initialize it to use DB Vault.

Estimated time: 10 minutes

Watch the video below for a quick walk through of the lab.

[](youtube:RmiewRNMceQ)

### Objectives

-   Learn how to provision a new Autonomous Database
-   Create owner and load dataset to perform the lab

## Task 1: Provision an Autonomous Database

  **Note:** If you plan to use an existing Autonomous Database in your own tenancy, or you are using an Oracle-provided environment, you can skip this step.

1. Log in to the Oracle Cloud Infrastructure

2. Once you are logged in, you are taken to the cloud services dashboard where you can see all the services available to you. Click the navigation menu in the upper left to show top level navigation choices.

      **Note:** You can also directly access your Autonomous Database service in the **Quick Actions** section of the dashboard

    ![](./images/adb-set_001.png " ")

3. The following steps apply similarly to either Autonomous Data Warehouse (ADW) or Autonomous Transaction Processing (ATP). So please **click the provisioning of Autonomous Database of your choice** (here we choose an Oracle Autonomous Data Warehouse but again you can also choose Oracle Autonomous Transaction Processing if you prefer).

    ![](./images/adb-set_002.png " ")

4. From the **Compartment** drop-down list, select your compartment

  **Note:**
     - This console shows that no databases yet exist
     - If there were a long list of databases, you could filter the list by the **State** of the databases (Available, Stopped, Terminated, and so on)
     - You can also sort by **Workload Type** (here, we selected **All**)

         ![](./images/adb-set_003.png " ")


5. Click [**Create Autonomous Database**]

    ![](./images/adb-set_004.png " ")

6. On the **Create Autonomous Database** page, provide basic information for your database:
    - **Compartment** - If needed, select your compartment
    - **Display name** - Enter a memorable name for the database for display purposes, for this lab, use *`ADB Security`*
    - **Database Name** - Enter *`ADBSEC01`*, it's important to use letters and numbers only, starting with a letter (the maximum length is 14 characters and Underscores are not supported)
    - **Workload Type** - Select the type of your Autonomous Database to match your choice at Step 3 earlier above (here we select "Data Warehouse")
    - **Deployment Type** - Leave *`Shared Infrastructure`* selected

         ![](./images/adb-set_005.png " ")

7. Configure the database:

    - **Always Free** - Leave this option deselected (the slider should be to the left)
    - **Database version** - Leave *`19c`* selected
    - **OCPU Count** - Select *`1`*
    - **Storage** - Leave *`1`* selected
    - **Auto scaling** - Leave this checkbox selected

      **Note:** You cannot scale up/down an Always Free Autonomous Database

         ![](./images/adb-set_006.png " ")

8. Create administrator credentials:

    - **Password** and **Confirm Password** - Specify a password for the ADMIN database user and jot it down. The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character. It cannot contain your username or the double quote (") character. For example : *`WElcome_123#`*

      ````
      <copy>WElcome_123#</copy>
      ````

      ![](./images/adb-set_007.png " ")

9. Choose the network access and the license type:

    - **Network Access** - Leave *`Allow secure access from everywhere`* selected
    - **License Type** - Select *`License Included`*

         ![](./images/adb-set_008.png " ")

10. Click [**Create Autonomous Database**]

11.  Your instance will begin provisioning. In a few minutes, the state will turn from Provisioning to Available. At this point, your Autonomous Database is ready to use! Have a look at your instance's details here including its name, database version, OCPU count, and storage size.

    ![](./images/adb-set_009.png " ")


## Task 2: Set up Application Schema and Users

Although you can connect to your Autonomous Database using local PC desktop tools like Oracle SQL Developer, you can conveniently access the browser-based SQL Worksheet directly from your Oracle Autonomous Data Warehouse or Oracle Autonomous Transaction Processing

1. In your "`ADB Security`" database's details page, click the **Tools** tab

    ![](./images/adb-set_010.png " ")

2. The Tools page provides you access to database administration and developer tools for Autonomous Database: Database Actions, Oracle Application Express, Oracle ML User Administration, and SODA Drivers. In the Database Actions box, click [**Open Database Actions**]

    ![](./images/adb-set_011.png " ")

3. A sign-in page opens for Database Actions. For this lab, simply use your database instance's default administrator account, Username "*`admin`*", and click [**Next**]

    ![](./images/adb-set_012.png " ")

4. Enter the admin Password you specified when creating the database, here *`WElcome_123#`*

      ````
      <copy>WElcome_123#</copy>
      ````

    ![](./images/adb-set_013.png " ")

5. Click [**Sign in**]
 
6. The Database Actions page opens. In the Development box, click [**SQL**]

    ![](./images/adb-set_014.png " ")

  **Note:** The first time you open SQL Worksheet, a series of pop-up informational boxes introduce you to the main features. Click [**Next**] to take a tour through the informational boxes

7. Copy/Paste the following SQL queries and run them into SQL Worksheet

    - To create the working schema

      ````
      <copy>
      -- Create SH1 schema
      CREATE USER sh1 IDENTIFIED BY WElcome_123#;
      GRANT CREATE SESSION, CREATE TABLE TO sh1;
      GRANT UNLIMITED TABLESPACE TO sh1;
      BEGIN
          ORDS_ADMIN.ENABLE_SCHEMA(p_enabled => TRUE, p_schema => UPPER('sh1'), p_url_mapping_type => 'BASE_PATH', p_url_mapping_pattern => LOWER('sh1'), p_auto_rest_auth => TRUE);
      END;
      /
      CREATE TABLE sh1.customers AS SELECT * FROM sh.customers;
      CREATE TABLE sh1.countries AS SELECT * FROM sh.countries;

      </copy>
      ````

    - To create the working users

      ````
      <copy>
      -- Create DBA_DEBRA user
      CREATE USER dba_debra IDENTIFIED BY WElcome_123#;
      GRANT PDB_DBA TO dba_debra;
      BEGIN
          ORDS_ADMIN.ENABLE_SCHEMA(p_enabled => TRUE, p_schema => UPPER('dba_debra'), p_url_mapping_type => 'BASE_PATH', p_url_mapping_pattern => LOWER('dba_debra'), p_auto_rest_auth => TRUE);
      END;
      /
      -- Create APPUSER user
      CREATE USER appuser IDENTIFIED BY WElcome_123#;
      GRANT CREATE SESSION, READ ANY TABLE TO appuser;
      BEGIN
          ORDS_ADMIN.ENABLE_SCHEMA(p_enabled => TRUE, p_schema => UPPER('appuser'), p_url_mapping_type => 'BASE_PATH', p_url_mapping_pattern => LOWER('appuser'), p_auto_rest_auth => TRUE);
      END;
      /

      </copy>
      ````

    - Press [**F5**] or click the "Run Scripts" icon

         ![](./images/adb-set_015.png " ")
         ![](./images/adb-set_016.png " ")

    - Check that there are no errors

8. **Your environment is ready to use!** and you may now proceed to the next lab

## Want to Learn More?

Click [autonomous workflow](https://docs.oracle.com/en/cloud/paas/autonomous-data-warehouse-cloud/user/autonomous-workflow.html#GUID-5780368D-6D40-475C-8DEB-DBA14BA675C3) for documentation on the typical workflow for using Autonomous Data Warehouse.

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Rene Fontcha
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - September 2021
