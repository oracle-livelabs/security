# Prepare Your Environment

## Introduction

In this lab, you prepare your environment in Oracle Cloud Infrastructure for the workshop.

*Please read the following instructions carefully!:*

- For the **Run on Your Tenancy** option: If you are the tenancy administrator, complete all tasks except for 3, 4, and 6. If you are not a tenancy administrator, enlist the help of one in your organization to complete all tasks, except for task 6.

- For the **Run on LiveLabs Sandbox** option: Complete tasks 6, 7, and 8 only. Oracle provides you with a tenancy where Oracle Data Safe is enabled, a compartment, an Oracle Cloud account in the LiveLabs tenancy, and a pre-provisioned Autonomous Database.


Estimated Lab Time: 15 minutes (Run on Your Tenancy), 5 minutes (Run on LiveLabs Sandbox)

### Objectives

In this lab, you will:

- Enable Oracle Data Safe in a region of your tenancy
- Create a compartment
- Create a user group and add an Oracle Cloud account to the group
- Create an IAM policy for the user group
- Provision an Autonomous Transaction Processing database
- (LiveLabs Sandbox reservation only) View your LiveLabs reservation information and sign in
- Access Oracle Database Actions
- Load sample data into your database


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`


## Task 1: Enable Oracle Data Safe in a region of your tenancy

Enable Oracle Data Safe in a region of your tenancy. If Oracle Data Safe is already enabled in the desired region of your tenancy, or you are working in an Oracle-provided environment, you can skip this task.

1. In Oracle Cloud Infrastructure, at the top of the page on the right, select the region of your tenancy in which you want to enable Oracle Data Safe. Usually, you leave your home region selected, for example, **US East (Ashburn)**.

   ![Select Home region](images/select-region.png "Select Home region")

2. From the navigation menu, select **Oracle Database**, and then **Data Safe**.

    The **Overview** page is displayed.

3. Click **Enable Data Safe** and wait a couple of minutes for the service to enable. When it's enabled, a confirmation message is displayed in the upper-right corner.

    ![Enable Data Safe button](images/enable-data-safe-button.png "Enable Data Safe button")


## Task 2: Create a compartment

Create a compartment for yourself in Oracle Cloud Infrastructure Identity and Access Management (IAM). From here on in, we refer to this compartment as "your compartment." If you have an existing compartment in your tenancy that you can use, you can skip this task.

1. From the navigation menu, select **Identity & Security**, and then **Compartments**.

    The **Compartments** page in IAM is displayed.

2. Click **Create Compartment**.

    The **Create Compartment** dialog box is displayed.

3. Enter a name for your compartment.

4. Enter a description for the compartment.

5. Select a parent compartment.

6. Click **Create Compartment**.


## Task 3: Create a user group and add an Oracle Cloud account to the group

Create a user group and add your Oracle Cloud account to the group.

1. From the navigation menu, select **Identity & Security**, and then **Groups**.

    The **Groups** page in IAM is displayed.

2. Click **Create Group**.

    The **Create Group** dialog box is displayed.

3. Enter a name for the group, for example, `dsg01` (short for Data Safe group 1).

4. Enter a description for the group, for example, **User group for data safe user 1**. A description is required.

5. (Optional) Click **Show Advanced Options** and create a tag.

6. Click **Create**.

    The **Group Details** page is displayed.

7. Under **Group Members**, click **Add User to Group**.

    The **Add User to Group** dialog box is displayed.

8. From the drop-down list, select the user for this workshop, and then click **Add**.

    The user is listed as a group member.


## Task 4: Create an IAM policy for the user group

Create an IAM policy that grants you the necessary permissions for the workshop.

1. From the navigation menu, select **Identity & Security**, and then **Policies**.

    The **Policies** page in IAM is displayed.

2. On the left under **COMPARTMENT**, leave the **root** compartment selected.

3. Click **Create Policy**.

    The **Create Policy** page is displayed.

4. Enter a name for the policy. It is helpful to name the policy after a group name, for example, `dsg01 `.

5. Enter a description for the policy, for example, **Policy for Data Safe group 1**.

6. From the **COMPARTMENT** drop-down list, leave the **root** compartment selected.

7. In the **Policy Builder** section, move the **Show manual editor** slider to the right to display the policy field.

8. In the policy field, enter the following policy statements. Substitute `{group name}` and `{compartment name}` with the appropriate values.

    - For the **Get Started with Oracle Data Safe Fundamentals** workshop, you require the following permissions. The first statement allows the user group to register an Oracle Database with Oracle Data Safe and create and manage Oracle Data Safe resources in the specified compartment. The second statement allows the user group to create an Autonomous Database in the specified compartment and use it with Oracle Data Safe.

    ```
    <copy>
    Allow group {group name} to manage data-safe-family in compartment {compartment name}
    Allow group {group name} to manage autonomous-database in compartment {compartment name}
    </copy>
    ```

9. Click **Create**.


## Task 5: Provision an Autonomous Transaction Processing database

Create an Autonomous Transaction Processing (ATP) database in your compartment. Before proceeding, make sure that you have enough quota in your tenancy to create an (Always Free) Autonomous Database.

> **Note**: If you plan to use an existing ATP database in your tenancy or you are using an Oracle-provided environment, you can skip this task.

1. From the navigation menu, select **Oracle Database**, and then **Autonomous Transaction Processing**.

2. In the **Filters** section on the left, make sure your workload type is **Transaction Processing** or **All** so that you can view your database listing after you create it.

3. From the **Compartment** drop-down list, select your compartment.

4. Click **Create Autonomous Database**.

5. On the **Create Autonomous Database** page, provide basic information for your database:

    - **Compartment** - If needed, select a different compartment.
    - **Display name** - Enter a memorable name for the database for display purposes.
    - **Database name** - Enter a database name. It's important to use letters and numbers only, starting with a letter. The maximum length is 14 characters. Underscores are not supported.
    - **Workload type** - Select **Transaction Processing**.
    - **Deployment type** - Leave **Shared infrastructure** selected.
    - **Always Free** - Select this option by moving the slider to the right.
    - **Database version** - Leave **19c** selected.
    - **OCPU Count** - You get **1** OCPU.
    - **Storage** - You get 0.02TB of storage.
    - **Password** and **Confirm Password** - Specify a password for the `ADMIN` database user and jot it down. The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character. It cannot contain your username or the double quote (") character.
    - **Access Type** - Leave **Secure access from everywhere** selected.
    - **License Type** - Leave **License included** selected.

6. Click **Create Autonomous Database**. The **Autonomous Database Details** page is displayed.

7. Wait a few minutes for your database instance to provision. The **Autonomous Database details** page is displayed. Wait for **AVAILABLE** to be displayed below the large ATP icon.

    ![Autonomous Database Details page](images/autonomous-database-details-page.png "Autonomous Database Details page")


## Task 6 (LiveLabs Sandbox reservation only): View your LiveLabs Sandbox reservation information and sign in

1. At the top of the lab instructions page (this page), click the **View Login Info** link. A **Reservation Information** panel is displayed.

2. Review the information. You are provided with the following in Oracle Cloud Infrastructure:

    - Access to one of the LiveLab's tenancies in a region where Oracle Data Safe is enabled
    - A link that directs you to the sign in page for Oracle Cloud Infrastructure (**Launch OCI** button)
    - A username and password to sign in to Oracle Cloud Infrastructure. When signing in for the first time, you are prompted to change your password.
    - A compartment of your very own. We refer to this compartment as "your compartment" throughout the workshop. Make note of your compartment's name because you need to select it often throughout the workshop.
    - An Autonomous Database in your compartment. You are provided the password for the `ADMIN` account on your database.

3. Make note of your username and click the **Copy Password** button for Oracle Cloud Infrastructure.

4. On the **Reservation Information** panel, click the **Launch OCI** button.

    A new browser tab is opened and the sign in page for the LiveLabs tenancy is displayed.

5. Under **Oracle Cloud Infrastructure Direct Sign-In**, enter your username (if needed) and paste the password into the **Password** box, and then click **Sign In**.

    The **Change Password** page is displayed.

6. In the **Current Password** box, paste your password. In the **New Password** and **Confirm New Password** boxes, enter a new password. Note the password requirements, which are provided on the page. Click **Save New Password**.

    You are now signed in to your LiveLabs Sandbox in Oracle Cloud Infrastructure.

7. Access your target database: From the navigation menu (hamburger menu in the upper-left corner), select **Oracle Database**, and then **Autonomous Transaction Processing**. Under **List Scope**, select your compartment under the **LiveLabs** folder. In the table on the right, click the name of your target database.

    ![Your Autonomous Database in the LiveLabs tenancy](images/ll-autonomous-database.png "Your Autonomous Database in the LiveLabs tenancy")


## Task 7: Access Oracle Database Actions

Database Actions provides a way for you to run SQL commands on your target database. The step-by-step instructions for accessing Database Actions are covered here. The labs simply say to "access the SQL worksheet in Database Actions." You can always refer back to these steps for help if needed.

1. At the top of the **Autonomous Database details** page, click **Database actions**. A new tab is opened called **Oracle Database Actions** with **Database Actions | Launchpad** displayed at the top of the page.

    - If this page is not displayed, check that pop-up windows are allowed in your browser.
    - Keep this tab open throughout the workshop. If your session expires, you can always sign in again.

2. If you are prompted to sign in to your target database, sign in as the `ADMIN` user.

    - If a tenancy administrator provided you an Autonomous Database, obtain the password from your tenancy administrator.
    - If you are using an Oracle-provided environment, enter the `ADMIN` password that was provided to you.

3. In the **Development** section, click **SQL**.

4. In the **Warning** dialog box in the upper-right corner, click the **X** to close it.

5. In the help note dialog box, click the **X** button to close it. 

6. Review the interface. Here are the ways that you use Database Actions during the workshop:

    - In the **Navigator** pane on the left, you select tables from the **HCM1** schema on your target database.
    - On the **Worksheet** on the right, you run SQL commands and scripts.
    - On the **Query Result** and **Script Output** tabs at the bottom of the page, you review query results and output generated from running scripts.

    ![SQL Worksheet in Oracle Database Actions](images/database-actions.png "SQL Worksheet in Oracle Database Actions")


## Task 8: Load sample data into your database

As the `ADMIN` user on the database, run the `load-data-safe-sample-data_admin.sql` SQL script to load sample data into your database. This script creates several tables with sample data that you can use to practice with the Oracle Data Safe features. It also generates database activity for the `ADMIN` user.

1. Download the [**load-data-safe-sample-data_admin.sql**](https://objectstorage.us-ashburn-1.oraclecloud.com/p/AUKfPIGuTde04z4OnuaZN2EP0LxNl4hJWI2jZiTw23aWzSoa2_Byvs8OGPw20-dt/n/c4u04/b/livelabsfiles/o/security-library/load-data-safe-sample-data_admin.sql) script and open it in a text editor, such as NotePad.

2. Copy the entire script to the clipboard and paste it into the worksheet in Database Actions. The last line of the script is as follows:

     `select null as "End of script" from dual;`

3. On the toolbar, click the **Run Script** button and wait for the script to finish running. Don't worry if you see some error messages on the **Script Output** tab. These are expected the first time you run the script.

    ![Run Script button](images/run-script.png "Run Script button")

    - The script takes a few minutes to run.
    - In the bottom-left corner, the cog wheel may remain still for about a minute, and then it turns as the script is processed. The script output is displayed after the script is finished running.
    - The script ends with the message **END OF SCRIPT**.

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


    If your results are different than what is specified above, rerun the [load-data-safe-sample-data_admin.sql](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/load-data-safe-sample-data_admin.sql) script.

5. Refresh Database Actions: Refresh the _browser's_ page and then verify that the `HCM1` schema is listed in the first drop-down list on the **Navigator** pane.

6. Leave the **SQL | Oracle Database Actions** tab open because you return to it throughout this workshop. Return to the **Autonomous Database | Oracle Cloud Infrastructure** tab.


## Learn More

- [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/iaas/Content/home.htm)
- [Try Oracle Cloud](https://www.oracle.com/cloud/free/)
- [Provision Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/autonomous-provision.html)
- [Loading Data with Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/load-data.html)


## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, Jan 22, 2023
