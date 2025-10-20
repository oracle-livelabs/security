# Prepare your environment

## Introduction

In this lab, you prepare your environment in Oracle Cloud Infrastructure for the workshop.

*Please read the following instructions carefully!*

- For the **Run on Your Tenancy** option: If you are the tenancy administrator, complete all tasks except for 2, 3, and 5. If you are not a tenancy administrator, enlist the help of one in your organization to complete all tasks, except for task 5.

- For the **Run on LiveLabs Sandbox** option: Complete tasks 5, 6, and 7 only. Oracle provides you with a tenancy, a compartment, an Oracle Cloud account in the LiveLabs tenancy, and a pre-provisioned Autonomous AI Database.


Estimated Lab Time: 15 minutes (Run on Your Tenancy), 5 minutes (Run on LiveLabs Sandbox)

### Objectives

In this lab, you will:

- Create a compartment
- Create a user group and add an Oracle Cloud account to the group
- Create an IAM policy for the user group
- Provision an Autonomous Transaction Processing database
- (LiveLabs Sandbox reservation only) View your LiveLabs reservation information and sign in
- Access ORACLE Database Actions
- Load sample data into your database


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`


## Task 1: Create a compartment

Create a compartment for yourself in Oracle Cloud Infrastructure Identity and Access Management (IAM). From here on in, we refer to this compartment as "your compartment." If you have an existing compartment in your tenancy that you can use, you can skip this task.

1. From the navigation menu, select **Identity & Security**, and then **Compartments**.

    The **Compartments** page in IAM is displayed.

2. Click **Create Compartment**.

    The **Create Compartment** dialog box is displayed.

3. Enter a name for your compartment.

4. Enter a description for the compartment.

5. Select a parent compartment.

6. Click **Create Compartment**.


## Task 2: Create a user group and add an Oracle Cloud account to the group

Create a user group and add your Oracle Cloud account to the group.

1. From the navigation menu, select **Identity & Security**, and then **Domains**. Change to the correct compartment, and then click the name of your domain (for example, **Default**).

2. Click the **User management** tab.

3. Scroll down, and then click **Create group**.

    The **Create group** page is displayed.

4. Enter a name for the group, for example, `dsg01` (short for Data Safe group 1).

5. Enter a description for the group, for example, **User group for data safe user 1**. A description is required.

6. (Optional) Click **Add tag** and create a tag.

7. Click **Create**.

8. Click the **Users** tab.

9. Search for the user for this workshop, and then click **Assign user to group**.

    The user is listed as a group member.


## Task 3: Create an IAM policy for the user group

Create an IAM policy that grants you the necessary permissions for the workshop.

1. On the left, select **Policies**.

    The **Policies** page is displayed.

2. Change the compartment to the **root** compartment.

3. Click **Create Policy**.

    The **Create Policy** page is displayed.

4. Enter a name for the policy. It is helpful to name the policy after a group name, for example, `dsg01 `.

5. Enter a description for the policy, for example, **Policy for Data Safe group 1**.

6. From the **COMPARTMENT** drop-down list, leave the **root** compartment selected.

7. In the **Policy Builder** section, click **Show manual editor**.

8. In the policy field, enter the following policy statements. Substitute `{group name}` and `{compartment name}` with the appropriate values.

    - For the **Get Started with Oracle Data Safe Fundamentals** workshop, you require the following permissions:

    ```text
    <copy>
    Allow group {group name} to manage data-safe-family in compartment {compartment name}
    Allow group {group name} to manage autonomous-database in compartment {compartment name}
    </copy>
    ```

    - For the **Integrate Oracle Data Safe with Applications and Services** workshop, you require the following permissions: 

    ```text
    <copy>
    Allow group {group name} to read compartments in compartment {compartment name}
    Allow group {group name} to manage data-safe-family in compartment {compartment name}
    Allow group {group name} to manage autonomous-database in compartment {compartment name}
    Allow group {group name} to use cloud-shell in tenancy
    Allow group {group name} to manage buckets in compartment {compartment name}
    Allow group {group name} to manage objects in compartment {compartment name}
    Allow group {group name} to manage instance-family in compartment {compartment name}
    Allow group {group name} to read app-catalog-listing in tenancy
    Allow group {group name} to manage virtual-network-family in compartment {compartment name}
    Allow group {user-group} to manage ons-topic in compartment {compartment name}
    Allow group {user-group} to manage cloudevents-rules in compartment {compartment name}
    Allow group {user-group} to manage alarms in compartment {compartment name}
    Allow group {user-group} to read metrics in compartment {compartment name}

    </copy>
    ```
   

9. Click **Create**.


## Task 4: Provision an Autonomous Transaction Processing database

Create an Autonomous Transaction Processing (ATP) database in your compartment. You can create an Always Free Autonomous AI Database for this workshop provided your tenancy has enough quota.

> **Note**: If you plan to use an existing ATP database in your tenancy or you are using an Oracle-provided environment, you can skip this task.

1. From the navigation menu, select **Oracle AI Database**, and then **Autonomous AI Database**.

2. If needed, change your compartment.

4. Click **Create Autonomous AI Database**.

5. On the **Create Autonomous AI Database Serverless** page, provide basic information for your database:

    - **Display name** - Enter a memorable name for the database for display purposes.
    - **Database name** - Enter a database name. It's important to use letters and numbers only, starting with a letter. The maximum length is 14 characters. Underscores are not supported.
    - **Compartment** - If needed, select a different compartment.
    - **Workload type** - Select **Transaction Processing**.
    - **Always Free** - (Optional) Select this option by moving the slider to the right.
    - **Database version** - If possible, select **23ai** (required to do the SQL Firewall lab in the Get Started with Oracle Data Safe Fundamentals workshop).
    - **Password** and **Confirm Password** - Specify a password for the `ADMIN` database user and jot it down. In order for you to later register this database with Data Safe, the password must be between 14 and 30 characters long and must include at least one uppercase letter, one lowercase letter, one numeric character, and one special character. It cannot contain your username or the double quote (") character.
    - **Access Type** - Leave **Secure access from everywhere** selected.

6. Click **Create**. 

    The **Autonomous AI Database** page is displayed.

7. Wait a few minutes for your database instance to provision. 

    **Available** is displayed next to the name of your database.

    ![Autonomous AI Database page](images/autonomous-database-details-page.png "Autonomous AI Database page")


## Task 5 (LiveLabs Sandbox reservation only): View your LiveLabs Sandbox reservation information and sign in

1. In the upper-left corner of the lab instructions page (this page), click the **View Login Info** link. 

    A **Reservation Information** panel is displayed.

2. Review the information. You are provided with the following in Oracle Cloud Infrastructure:

    - Access to one of the LiveLab's tenancies
    - A link that directs you to the sign-in page for Oracle Cloud Infrastructure (**Launch OCI** button)
    - A username and password to sign in to the LiveLabs tenancy. When signing in for the first time, you are prompted to change your password.
    - A compartment of your very own. We refer to this compartment as "your compartment" throughout the workshop. Make note of your compartment's name because you need to select it often throughout the workshop.
    - An Autonomous AI Database in your compartment. You are provided the password for the `ADMIN` account on your database.

3. Make note of your Oracle Cloud Infrastructure username and click the **Copy Password** button.

4. On the **Reservation Information** panel, click the **Launch OCI** button.

    A new browser tab is opened and the sign in page for the LiveLabs tenancy is displayed.

5. Enter your username (if needed) and paste the password into the **Password** box, and then click **Sign In**.

    The **Change Password** page is displayed.

6. In the **Current Password** box, paste your password. In the **New Password** and **Confirm New Password** boxes, enter a new password. Note the password requirements, which are provided on the page. Click **Save New Password**.

    You are now signed in to your LiveLabs Sandbox in Oracle Cloud Infrastructure.

7. Access your target database: From the navigation menu (hamburger menu in the upper-left corner), select **Oracle AI Database**, and then **Autonomous Transaction Processing**. Under **List scope**, select your compartment under the **LiveLabs** folder. In the table on the right, click the name of your database.


## Task 6: Access ORACLE Database Actions

Database Actions provides a way for you to run SQL commands on your target database. The step-by-step instructions for accessing Database Actions are covered here. The labs simply say to "access the SQL worksheet in Database Actions." You can always refer back to these steps for help if needed.

1. At the top of the **Autonomous AI Database** page, from the **Database actions** menu, select **SQL**.

2. If required, sign in as the `ADMIN` user. 

    - If a tenancy administrator provided you an Autonomous AI Database, obtain the password from that person.
    - If you are using an Oracle-provided environment, enter the database password provided to you.

3. Close the **SQL History** and **Warning** dialog boxes.

4. Review the interface. Here are the ways that you use Database Actions during the workshop:

    - In the **Navigator** pane on the left, you select tables from the **HCM1** schema on your target database.
    - On the **Worksheet** on the right, you run SQL commands and scripts.
    - On the **Query Result** and **Script Output** tabs at the bottom of the page, you review query results and output generated from running scripts.

    ![SQL Worksheet in Database Actions](images/database-actions.png "SQL Worksheet in Database Actions")


## Task 7: Load sample data into your database

As the `ADMIN` user on the database, run the `load-data-safe-sample-data_admin.sql` SQL script to load sample data into your database. This script creates several tables with sample data that you can use to practice with the Oracle Data Safe features. It also generates database activity for the `ADMIN` user.

1. Download the [**load-data-safe-sample-data_admin.sql**](https://objectstorage.us-ashburn-1.oraclecloud.com/p/QqCOrIg8vwNsrtXHFosXcmFRIWkjKv4yNbXj6_bUNx2ZQy-KsK564UWBxJKqkdVM/n/c4u04/b/livelabsfiles/o/load-data-safe-sample-data_admin.sql) script and open it in a text editor, such as NotePad.

2. Copy the entire script to the clipboard and paste it into the worksheet in Database Actions. The last line of the script is as follows:

     `select null as "End of script" from dual;`

3. On the toolbar, click the **Run Script** button and wait for the script to finish running. Don't worry if you see some error messages on the **Script Output** tab. These are expected the first time you run the script.

    - The script takes a few minutes to run.
    - In the bottom-left corner, the cog wheel may remain still for about a minute, and then it turns as the script is processed. The script output is displayed after the script is finished running.
    - The script ends with the message **END OF SCRIPT**.

    ![Run Script button](images/run-script.png "Run Script button")

4. To ensure the sample data is loaded successfully, at the end of the script output, review the row count for each table in the `HCM1` schema. The counts should be as follows:

    - `COUNTRIES` - 25 rows
    - `DEPARTMENTS` - 27 rows
    - `EMPLOYEES` - 107 rows
    - `EMP_EXTENDED` - 107 rows
    - `JOBS` - 19 rows
    - `JOB_HISTORY` - 10 rows
    - `LOCATIONS` - 23 rows
    - `REGIONS` - 4 rows
    - `SUPPLEMENTAL_DATA` - 149 rows


    If your results are different than what is specified above, rerun the [**load-data-safe-sample-data_admin.sql**](https://objectstorage.us-ashburn-1.oraclecloud.com/p/QqCOrIg8vwNsrtXHFosXcmFRIWkjKv4yNbXj6_bUNx2ZQy-KsK564UWBxJKqkdVM/n/c4u04/b/livelabsfiles/o/load-data-safe-sample-data_admin.sql) script.

5. Refresh Database Actions by refreshing the _browser_ page. If prompted, click **Leave page**.

6. Verify that the `HCM1` schema is listed in the first drop-down list on the **Navigator** pane.

7. *Leave the **SQL | ORACLE Database Actions** tab open because you return to it throughout this workshop.* If your session expires, you can always sign in again. 

8. Return to the **Autonomous AI Database | Oracle Cloud Infrastructure** tab.

You may now **proceed to the next lab**.

## Learn More

- [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/iaas/Content/home.htm)
- [OCI Cloud Free Tier](https://www.oracle.com/cloud/free/)
- [Provision Autonomous AI Database Instance](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/autonomous-provision.html)
- [Loading Data](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/load-data.html)


## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, October 20, 2025
