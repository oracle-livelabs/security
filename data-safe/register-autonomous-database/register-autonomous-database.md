# Register an Autonomous Database with Oracle Data Safe

## Introduction

To use a database with Oracle Data Safe, you first need to register it with Oracle Data Safe. A registered database is referred to as a _target database_ in Oracle Data Safe.

Begin by registering your Autonomous Transaction Database (ATP) with Oracle Data Safe. Next, navigate to Oracle Data Safe in Oracle Cloud Infrastructure and view the list of registered target databases to confirm that yours is listed. Explore Security Center, which is the central hub for Oracle Data Safe where you can access Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, Alerts, and the Oracle Data Safe dashboard.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Register your database with Oracle Data Safe
- Access Oracle Data Safe and view your list of registered target databases
- Explore Security Center

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))

### Assumptions

- Your data values are most likely different than those shown in the screenshots.


## Task 1: Register your database with Oracle Data Safe

Begin by reviewing your registration options. Oracle provides two ways to register an Autonomous Database on Shared infrastructure with secure access from everywhere:
- First option (fastest): Use the **Register** feature on the **Autonomous Database Details** page.
- Second option: Use the Autonomous Databases wizard on the **Overview** page for the Oracle Data Safe service.
For this lab, use the second option to register your database so that you can view registration options that aren't available with the first option.

If you plan to register a database other than an ATP database for this workshop, please follow the registration instructions specific for your database type in the _Administering Oracle Data Safe_ guide. See the **Learn More** section at the bottom of this page.

1. Return to the **Autonomous Database | Oracle Cloud Infrastructure** browser tab. You last left off on the **Autonomous Database Details** page.

    If you navigated away from this page: From the navigation menu, select **Oracle Database**, and then **Autonomous Transaction Processing**. Select your compartment (if needed), and then click the name of your database.

2. Scroll down the page, and then under **Data Safe**, notice that there is a **Register** option. This option provides a one-click way to register an Autonomous Database on Shared infrastructure with secure access from everywhere. Oracle Data Safe uses preset defaults during the registration. However, don't click the link, and instead, lets use the wizard.

    ![Register option for your database](images/register-database.png "Register option for your database")

3. From the navigation menu, select **Oracle Database**, and then **Data Safe**. The **Overview** page is displayed. Notice the following wizards available for registering databases:

    - Autonomous Databases
    - Oracle Cloud Databases
    - Oracle On-Premises Databases
    - Oracle Databases on Compute
    - Oracle Cloud@Customer Databases

    ![Overview page for Oracle Data Safe](images/overview-page.png "Overview page for Oracle Data Safe")

4. In the **Autonomous Databases** section, click **Start Wizard**. The first page in the wizard, **Select Database**, is displayed.

5. On the **Select Database** page, if needed, click **Change Compartment** and select the compartment that contains your database. Select your database. (Optional) Enter a display name for your database. This name will be displayed in all the Oracle Data Safe reports. (Optional) Select the compartment to which you want to register your database. Usually, you select the same compartment as your database. (Optional) Enter a description for your target database. Notice the message at the bottom of the page: **The selected database is configured to be securely accessible from everywhere. Steps 2 ('Connectivity Option) and 3 ('Add Security Rule') are not necessary and will be skipped.** If your database had a private IP address, you could configure an Oracle Data Safe private endpoint and security rules in steps 2 and 3. Click **Next**.

    ![Autonomous Database registration wizard - Select Database page](images/ADB-wizard-select-database.png "Autonomous Database registration wizard - Select Database page")
    
6. On the **Review and Submit** page, review the information. To make a change, you can return to the **Select Database** page. If everything is correct, click **Register**.

    ![Autonomous Database registration wizard - Review and Submit page](images/ADB-wizard-review-submit.png "Autonomous Database registration wizard - Review and Submit page")

7. Notice that the **Registration Progress** page is displayed briefly, and then the **Target Database Details** page is displayed.

    - When your target database is fully registered, the status is set to **ACTIVE**.
    - You can view/edit the target database name and description.
    - You can view the Oracle Cloud Identifier (OCID), when the target database was registered, the compartment name to where the target database was registered, the database type (Autonomous Database), and the connection protocol (TLS). The information varies depending on the target database type.
    - You have options to edit connection details (change the connection protocol), move the target database registration to another compartment, deregister the target database, and add tags.

    ![Target Database Details page](images/target-database-details-page.png "Target Database Details page")
    

## Task 2: Access Oracle Data Safe and view your list of registered target databases

1. In the breadcrumb at the top of the page, click **Target Databases**.

2. From the **Compartment** drop-down list under **List Scope**, select your compartment. Optionally, deselect **Include child compartments**. Your registered target database is listed on the right.

    - A target database with an **ACTIVE** status means that it is currently registered with Oracle Data Safe.
    - A target database with a **DELETED** status means that it is no longer registered with Oracle Data Safe. The listing is removed after 45 days.

    ![Target Databases page in OCI](images/target-databases-page-oci.png "Target Databases page in OCI")


## Task 3: Explore Security Center

1. In the breadcrumb at the top of the page, click **Data Safe**.

    The **Overview** page is displayed.

2. Under **Security Center** on the left, click **Dashboard** and review the dashboard. Scroll down to view all the charts. Make sure your compartment is selected under **List Scope**.

    - In Security Center, you can access all the Oracle Data Safe features, including the dashboard, Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, and Alerts.
    - When you register a target database, Oracle Data Safe automatically creates a security assessment and user assessment for you. That's why the **Security Assessment**, **User Assessment**, **Feature Usage**, and **Operations Summary** charts in the dashboard already have data.
    - During registration, Oracle Data Safe also discovers audit trails on your target database. That's why the **Audit Trails** chart in the dashboard shows one audit trail with the status **In Transition** for your Autonomous Database. Later you start this audit trail to collect audit data into Oracle Data Safe.

    ![Initial Dashboard](images/dashboard-initial.png "Initial Dashboard")


## Learn More

- [Target Database Registration](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B5F255A7-07DD-4731-9FA5-668F7DD51AA6)


## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, January 20, 2023
