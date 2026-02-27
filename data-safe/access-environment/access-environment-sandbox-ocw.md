# Access your environment

## Introduction

In this lab, you access and review your LiveLabs Sandbox environment in Oracle Cloud Infrastructure. Your environment comes with a tenancy, a compartment, an Oracle Cloud account in the LiveLabs tenancy, and a pre-provisioned Autonomous AI Database. Sample data is loaded into your database and your database is registered with Oracle Data Safe.

Estimated Lab Time: 5 minutes

[Lab 1 - Access your environment](videohub:1_z0wftp16)

### Objectives

In this lab, you will:

- View your LiveLabs reservation information and sign in
- Access Oracle Data Safe and view your registered target database
- Explore the Oracle Data Safe user interface
- Access ORACLE Database Actions

### Prerequisites

This lab assumes you have:

- Reserved your environment for the HOL with the instructions given by the speaker.

## Task 1: View your LiveLabs Sandbox reservation information and sign in

1. In the upper-left corner of the lab instructions page (this page), select **View Login Info**.

    A **Reservation Information** panel is displayed.

2. Review the information. You are provided with the following in Oracle Cloud Infrastructure:

    - Access to one of the LiveLab's tenancies
    - A link that directs you to the sign-in page for Oracle Cloud Infrastructure (**Launch OCI** button)
    - A username and password to sign in to the LiveLabs tenancy. When signing in for the first time, you are prompted to change your password.
    - A compartment of your very own. We refer to this compartment as "your compartment" throughout the workshop. Make note of your compartment's name because you need to select it often throughout the workshop.
    - An Autonomous AI Database in your compartment. You are provided the password for the `ADMIN` account on your database.

3. Make note of your username and select **Copy Password** for Oracle Cloud Infrastructure.

4. On the **Reservation Information** panel, select **Launch OCI**. Leave the default domain selected, and then select **Next**.

    A new browser tab opens and the sign-in page for the LiveLabs tenancy is displayed.

5. Enter your username (if needed), paste the password into the **Password** box, and then select **Sign In**.

    The **Change Password** page is displayed.

6. In the **Current Password** box, paste your password. In the **New Password** and **Confirm New Password** boxes, enter a new password. Review the password requirements shown on the page. Select **Save New Password**.

    You are now signed in to your LiveLabs Sandbox in Oracle Cloud Infrastructure.

## Task 2: Access Oracle Data Safe and view your registered target database

A database registered with Oracle Data Safe is referred to as a *target database* in Oracle Data Safe.

1. From the navigation menu, select **Oracle AI Database**, and then **Overview** under **Data Safe - Database Security**.

    The **Overview** page titled **Simplify security for your Oracle databases** opens. If the **Welcome to Data Safe** tour dialog box is displayed, select **Stop tour**.

2. On the left under **Data Safe - Database Security**, select **Target databases**.

    The **Target databases** page opens.

3. Next to **Applied filters**, select your compartment without child compartments.

    Your registered target database is listed in the table.

    - A target database with an **Active** status means that it is currently registered with Oracle Data Safe.
    - A target database with a **Deleted** status means that it is no longer registered with Oracle Data Safe. Cloud target databases are delisted after one day. Billable target databases are delisted after 45 days.

    ![Target databases page in OCI](images/target-databases-page-oci.png "Target databases page in OCI")

## Task 3: Explore the Oracle Data Safe user interface

1. On the left, select **Target databases**, and then select **Overview**.

    The **Overview** page opens. On this page, you can register target databases; learn about Oracle Data Safe features, Oracle Data Safe private endpoints, and Oracle Data Safe on-premises connectors; and access documentation.

2. Under **Data Safe - Database Security** on the left, select and review the landing pages for each feature covered in this workshop: **Security assessment**, **User assessment**, **Data discovery**, **Data masking**, and **SQL Firewall**.

    - From here on in, we simply say *Navigate to a feature's landing page* to simplify the instructions.
    - When you register a target database, Oracle Data Safe automatically creates a security assessment and user assessment for you.
    - During registration, Oracle Data Safe also discovers audit trails on your target database.

    ![Data Safe landing pages](images/data-safe-landing-pages.png "Data Safe landing pages")

## Task 4: Access ORACLE Database Actions

Database Actions provides a way for you to run SQL commands on your database. The step-by-step instructions for accessing Database Actions are covered here. Subsequent labs simply say to "access the SQL worksheet in Database Actions." You can always refer back to these steps for help if needed.

1. From the navigation menu (hamburger menu in the upper-left corner), select **Oracle AI Database**, and then **Autonomous AI Database**.

2. Next to **Applied filters**, select your compartment under the **LiveLabs** folder. In the table, select the name of your database.

3. From the **Database actions** menu, select **SQL**.

4. If required, sign in as the `ADMIN` user.

5. Close any open dialog boxes.

6. Review the interface. Here are the ways that you use Database Actions during the workshop:

    - In the **Navigator** pane on the left, you select tables from the **HCM1** schema on your database.
    - On the **Worksheet** on the right, you run SQL commands and scripts.
    - On the **Query Result** and **Script Output** tabs at the bottom of the page, you review query results and output generated from running scripts.

    ![SQL Worksheet in Database Actions](images/database-actions.png "SQL Worksheet in Database Actions")

7. *Leave the **SQL | ORACLE Database Actions** tab open because you return to it throughout this workshop.* If your session expires, you can always sign in again.

8. Return to Oracle Data Safe: Select the **Autonomous AI Database | Oracle Cloud Infrastructure** browser tab. From the navigation menu, select **Oracle AI Database**, and then **Overview** under **Data Safe - Database Security**. The **Overview** page opens.

You may now **proceed to the next lab**.

## Learn More

- [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/iaas/Content/home.htm)
- [OCI Cloud Free Tier](https://www.oracle.com/cloud/free/)
- [Target Database Registration](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B5F255A7-07DD-4731-9FA5-668F7DD51AA6)
- [Oracle Data Safe Dashboard](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B4D784B8-F3F7-4020-891D-49D709B9A302)

## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, February 9, 2026
