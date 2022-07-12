# Register an Autonomous Database with Oracle Data Safe

## Introduction

To use a database with Oracle Data Safe, you first need to register it with Oracle Data Safe. A registered database is referred to as a _target database_ in Oracle Data Safe.

After registration, you can grant and revoke roles from the Oracle Data Safe service account on your Autonomous Database to control which Oracle Data Safe features you can use with the database. Keep in mind that the roles for Autonomous Databases are different than those for non-Autonomous Databases.
- For an Autonomous Database on Shared Exadata Infrastructure, which is what we are using in this workshop, all Oracle Data Safe roles are granted by default during registration, except for the Data Masking role (`DS$DATA_MASKING_ROLE`). Registration is required before granting roles because it unlocks the Oracle Data Safe pre-seeded service account.
- For an Autonomous Database on Dedicated Exadata Infrastructure, only the User and Security Assessment role (`DS$ASSESSMENT`) and the Audit Collection role (`DS$AUDIT_COLLECTION`) are granted by default. You can grant the other roles as needed.
- For all non-Autonomous Databases, you need to run a SQL privileges script on the target database to grant roles. No roles are granted by default. You can grant roles before or after registering your database.

Begin by registering your Autonomous Transaction Database (ATP) with Oracle Data Safe. Next, grant the Data Masking role to the Oracle Data Safe service account on your target database. Navigate to Oracle Data Safe in Oracle Cloud Infrastructure and view the list of registered target databases to confirm that yours is listed. Explore Security Center, which is the central hub for Oracle Data Safe where you can access Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, Alerts, Settings, and the Oracle Data Safe dashboard.

Estimated Lab Time: 30 minutes

### Objectives

In this lab, you will:

- Register your database with Oracle Data Safe
- Grant the Data Masking role on your target database
- Access Oracle Data Safe and view the list of registered target databases to which you have access
- Explore Security Center

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))

### Assumptions

- Your data values are most likely different than those shown in the screenshots.


## Task 1: Register your database with Oracle Data Safe

If you plan to use a database other than an ATP database for this workshop, please follow the registration instructions specific for your database type in the _Administering Oracle Data Safe_ guide. See the **Learn More** section at the bottom of this page.

1. If needed, sign in to Oracle Cloud Infrastructure at `https://cloud.oracle.com` with your Oracle Cloud account. Make sure that you have the correct region selected.

2. From the navigation menu, select **Oracle Database**, and then **Autonomous Transaction Processing**.

3. From the **Compartment** drop-down list, select your compartment.

4. On the right, click the name of your database.

    The **Autonomous Database Details** page is displayed.

5. On the **Autonomous Database Information** tab under **Data Safe**, click **Register**.

     ![Register option for your database](images/register-database.png "Register option for your database")

6. In the **Register Database with Data Safe** dialog box, click **Confirm**.

7. Wait for the registration process to finish and for the status to change to **Registered**.

    ![Status reads registered](images/status-registered.png "Status reads registered" )

## Task 2: Grant the Data Masking role on your target database

If you are not going to do data masking in this workshop, you can skip this task. If you are using a target database other than an ATP database, please refer to the _Administering Oracle Data Safe_ guide for instructions on how to grant roles specific to your target database.

1. Return to the **SQL | Database Actions** browser tab.

2. If you are prompted to sign in to your target database, sign in as the `ADMIN` user.

    - If a tenancy administrator provided you an Autonomous Database, obtain the password from your tenancy administrator.
    - If you are using an Oracle-provided environment, enter the `ADMIN` password that was provided to you.

3. If needed, click the **Clear** button (trash can icon) on the toolbar to clear the worksheet. Click the **Clear output** button on the **Script Output** tab to clear the output.

4. On the SQL worksheet, enter the following command:

    ```
    <copy>EXECUTE DS_TARGET_UTIL.GRANT_ROLE('DS$DATA_MASKING_ROLE');</copy>
    ```

5. On the toolbar, click the **Run Statement** button (green circle with a white arrow) to execute the query. The script output should read **PL/SQL procedure successfully completed**.

    ![Run Statement button on toolbar](images/run-statement-button.png "Run Statement button on toolbar")

    You are now allowed to perform data masking on your target database.


## Task 3: Access Oracle Data Safe and view the list of registered target databases to which you have access

1. Return to the **Autonomous Database | Oracle Cloud Infrastructure** browser tab.

2. From the navigation menu, select **Oracle Database**, and then **Data Safe**.

    The **Overview** page for the Oracle Data Safe service is displayed. From here you can access Security Center, register target databases, and find links to useful information.

3. On the left, click **Target Databases**.

4. From the **Compartment** drop-down list under **List Scope**, select your compartment. Your registered target database is listed on the right.

    - A target database with an **ACTIVE** status means that it is currently registered with Oracle Data Safe.
    - A target database with a **DELETED** status means that it is no longer registered with Oracle Data Safe. The listing is removed after 45 days.

    ![Target Databases page in OCI](images/target-databases-page-oci.png "Target Databases page in OCI")

5. Click the name of your target database to view its registration details.

    The **Target Database Details** page is displayed.

    - You can view/edit the target database name and description.
    - You can view the Oracle Cloud Identifier (OCID), when the target database was registered, the compartment name to where the target database was registered, the database type (Autonomous Database), and the connection protocol (TLS). The information varies depending on the target database type.
    - You have options to edit connection details (change the connection protocol), move the target database registration to another compartment, deregister the target database, and add tags.

    ![Target Database Details page](images/target-database-details-page.png "Target Database Details page")


## Task 4: Explore Security Center

1. In the breadcrumb at the top of the page, click **Data Safe**.

    The **Overview** page is displayed.

2. Under **Security Center** on the left, click **Dashboard** and review the dashboard. Scroll down to view all the charts. Make sure your compartment is selected under **List Scope**.

    - In Security Center, you can access all the Oracle Data Safe features, including the dashboard, Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, and Alerts.
    - When you register a target database, Oracle Data Safe automatically creates a security assessment and user assessment for you. Therefore, the **Security Assessment**, **User Assessment**, **Feature Usage**, and **Operations Summary** charts in the dashboard already have data.
    - During registration, Oracle Data Safe also discovers audit trails on your target database. That is why the **Audit Trails** chart in the dashboard shows one audit trail with the status **In Transition** for your Autonomous Database. Later you start this audit trail to collect audit data into Oracle Data Safe.

    ![Initial Dashboard](images/dashboard-initial.png "Initial Dashboard")


## Learn More

- [Target Database Registration](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B5F255A7-07DD-4731-9FA5-668F7DD51AA6)


## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, July 12, 2022
