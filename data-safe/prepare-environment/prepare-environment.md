---
inject-note: true
---

# Prepare Your Environment

## Introduction

To do this workshop, you need access to an Oracle Data Safe service in a region of your tenancy and an Oracle database. This workshop uses an Autonomous Transaction Processing (ATP) database.

To complete most of the preparation tasks, you need to be a tenancy administrator. If you are a regular user in your organization's tenancy, enlist the help of a tenancy administrator. If you are using the LiveLabs Sandbox, you only need to do tasks 6 and 7 because Oracle provides you with a user account, a compartment, and an autonomous database.


Estimated Lab Time: 15 minutes

### Objectives

In this lab, you will:

- Enable Oracle Data Safe in a region of your tenancy
- Create a compartment
- Create a user group and add an Oracle Cloud account to the group
- Create an IAM policy for the user group
- Provision an Autonomous Transaction Processing database
- Access Database Actions
- Load sample data into your database


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`


## Task 1: Enable Oracle Data Safe in a region of your tenancy

As a tenancy administrator or an Oracle Data Safe administrator, enable Oracle Data Safe in a tenancy region.

> **Note**: If Oracle Data Safe is already enabled in the desired region of your tenancy, or you are working in an Oracle-provided environment, you can skip this task.

1. In Oracle Cloud Infrastructure, at the top of the page on the right, select the region of your tenancy in which you want to enable Oracle Data Safe. Usually, you leave your home region selected, for example, **US East (Ashburn)**.

   ![Select Home region](images/select-region.png "Select Home region")

2. From the navigation menu, select **Oracle Database**, and then **Data Safe**.

    The **Overview** page is displayed.

3. Click **Enable Data Safe** and wait a couple of minutes for the service to enable. When it's enabled, a confirmation message is displayed in the upper-right corner.

    ![Enable Data Safe button](images/enable-data-safe-button.png "Enable Data Safe button")


## Task 2: Create a compartment

As a tenancy administrator, create a compartment in Oracle Cloud Infrastructure Identity and Access Management (IAM) in which to store Oracle Data Safe resources. From here on in, we refer to this compartment as "your compartment."

> **Note**: If you have an existing compartment in your tenancy that you can use or you are using an Oracle-provided environment, you can skip this task.

1. From the navigation menu, select **Identity & Security**, and then **Compartments**.

    The **Compartments** page in IAM is displayed.

2. Click **Create Compartment**.

    The **Create Compartment** dialog box is displayed.

3. Enter a name for your compartment, for example, `dsc01` (short for Data Safe compartment 1).

4. Enter a description for the compartment, for example, **Compartment for the Oracle Data Safe Workshop**.

5. Select a parent compartment.

6. Click **Create Compartment**.


## Task 3: Create a user group and add an Oracle Cloud account to the group

As a tenancy administrator, create a user group and add an Oracle Cloud account to the group.

> **Note**: If you are a tenancy administrator or you are using an Oracle-provided environment, you can skip this task.

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

As a tenancy administrator, create an IAM policy that grants the user permission to create and manage all Oracle Data Safe resources and an Autonomous Database in the user's compartment.

> **Note**: If you are a tenancy administrator or you are using an Oracle-provided environment, you can skip this task.

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

    ```
    <copy>
    Allow group {group name} to manage data-safe-family in compartment {compartment name}
    Allow group {group name} to manage autonomous-database in compartment {compartment name}
    </copy>
    ```

    The first statement allows the user group to register an Oracle Database with Oracle Data Safe and create and manage Oracle Data Safe resources in the specified compartment. The second statement allows the user group to create an Autonomous Database in the specified compartment and use it with Oracle Data Safe.

9. Click **Create**.


## Task 5: Provision an Autonomous Transaction Processing database

As a tenancy administrator or user with appropriate permissions to manage an Autonomous Database, create an Autonomous Transaction Processing (ATP) database in your compartment. Before proceeding, make sure that you have enough quota in your tenancy to create an (Always Free) Autonomous Database.

> **Note**: If you plan to use an existing ATP database in your tenancy or you are using an Oracle-provided environment, you can skip this task.

1. From the navigation menu, select **Oracle Database**, and then **Autonomous Transaction Processing**.

2. In the **Filters** section on the left, make sure your workload type is **Transaction Processing** or **All** so that you can view your database listing after you create it.

3. From the **Compartment** drop-down list, select your compartment.

4. Click **Create Autonomous Database**.

5. On the **Create Autonomous Database** page, provide basic information for your database:

    - **Compartment** - If needed, select a different compartment.
    - **Display name** - Enter a memorable name for the database for display purposes, for example, **ad01** (short for Autonomous Database 1).
    - **Database name** - Enter **ad01**. It's important to use letters and numbers only, starting with a letter. The maximum length is 14 characters. Underscores are not supported.
    - **Workload type** - Select **Transaction Processing**.
    - **Deployment type** - Leave **Shared Infrastructure** selected.
    - **Always Free** - Select this option by moving the slider to the right.
    - **Database version** - Leave **19c** selected.
    - **OCPU Count** - You get **1** OCPU.
    - **Storage** - You get 0.02TB of storage.
    - **Password** and **Confirm Password** - Specify a password for the `ADMIN` database user and jot it down. The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character. It cannot contain your username or the double quote (") character.
    - **Access Type** - Leave **Secure access from everywhere** selected.
    - **License Type** - Leave **License Included** selected.

6. Click **Create Autonomous Database**. The **Autonomous Database Details** page is displayed.

7. Wait a few minutes for your database instance to provision. The **Autonomous Database Details** page is displayed. Wait for **AVAILABLE** to be displayed below the large ATP icon.

    ![Autonomous Database Details page](images/autonomous-database-details-page.png "Autonomous Database Details page")


## Task 6: Access Database Actions

Throughout this workshop, you access Database Actions to run SQL commands on your target database. The steps for accessing Database Actions are covered once here. In the future when asked to access Database Actions, you can refer back to this section if needed.

1. At the top of the **Autonomous Database Details** page, click **Database Actions**.

    A new tab is opened called **Oracle Database Actions** with **Database Actions | Launchpad** displayed at the top of the page. If this page is not displayed, check that pop-up windows are allowed in your browser.

2. If you are prompted to sign in to your target database, sign in as the `ADMIN` user.

    - If a tenancy administrator provided you an Autonomous Database, obtain the password from your tenancy administrator.
    - If you are using an Oracle-provided environment, enter the `ADMIN` password that was provided to you.


3. In the **Development** section, click **SQL**. If nothing happens, refresh the browser tab.

4. In the help note dialog box, click the **X** button to close it.

5. Review the interface. Here are the ways that you use Database Actions during the workshop:

    - On the left, you select schemas and tables on your target database.
    - On the right, you enter SQL statements and scripts on the SQL worksheet.
    - At the bottom, you review query results and output generated from running scripts.


## Task 7: Load sample data into your database

As the `ADMIN` user on the database, run the `load-data-safe-sample-data_admin.sql` SQL script to load sample data into your database. This script creates several tables with sample data that you can use to practice with the Oracle Data Safe features.

1. Download the [**load-data-safe-sample-data_admin.sql**](https://objectstorage.us-ashburn-1.oraclecloud.com/p/AUKfPIGuTde04z4OnuaZN2EP0LxNl4hJWI2jZiTw23aWzSoa2_Byvs8OGPw20-dt/n/c4u04/b/livelabsfiles/o/security-library/load-data-safe-sample-data_admin.sql) script, and then unzip it into a directory of your choice. Next, open the file in a text editor, such as NotePad.

2. Copy the entire script to the clipboard and then paste it into the worksheet in Database Actions. The last line of the script is `select null as "End of script" from dual;`.

3. On the toolbar, click the **Run Script** button.

    ![Run Script button](images/run-script.png "Run Script button")

    - The script takes a few minutes to run.
    - In the bottom-left corner, the cog wheel may remain still for about a minute, and then turn as the script is processed. The script output is displayed after the script is finished running.
    - Don't worry if you see some error messages on the **Script Output** tab. These are expected the first time you run the script.
    - The script ends with the message **END OF SCRIPT**.

4. When the script is finished running, click the browser's refresh button. If prompted, click **Leave Page**. The same is displayed after it is refreshed.

5. On the **Navigator** tab on the left, select the `HCM1` schema from the first drop-down list. In the second drop-down list, leave **Tables** selected.

6. On the toolbar, click the **Clear** button (trash can icon) to clear the worksheet.

7. At the bottom of the page, click the **Script Output** tab. If needed, click the **Clear output** button (trash can icon) to clear the output.

8. For each table listed below, drag the table to the worksheet. Choose **Select** as the insertion type when prompted and then click **Apply**. On the toolbar, click the **Run Script** button. Make sure that you have the same number of rows in each table as stated below. Clear the worksheet after each query.

    - `COUNTRIES` - 25 rows
    - `DEPARTMENTS` - 27 rows
    - `EMPLOYEES` - 107 rows
    - `EMP_EXTENDED` - 107 rows
    - `JOBS` - 19 rows
    - `JOB_HISTORY` - 10 rows
    - `LOCATIONS` - 23 rows
    - `REGIONS` - 4 rows
    - `SUPPLEMENTAL_DATA` - 149 rows

9. If your results are different than what is specified above, rerun the [load-data-safe-sample-data_admin.sql](https://objectstorage.us-ashburn-1.oraclecloud.com/p/VEKec7t0mGwBkJX92Jn0nMptuXIlEpJ5XJA-A6C9PymRgY2LhKbjWqHeB5rVBbaV/n/c4u04/b/livelabsfiles/o/data-management-library-files/load-data-safe-sample-data_admin.sql) script.

10. Leave the **SQL | Oracle Database Actions** tab open because you return to it throughout this workshop. Return to the **Autonomous Database | Oracle Cloud Infrastructure** tab.


## Learn More

- [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/iaas/Content/home.htm)
- [Try Oracle Cloud](https://www.oracle.com/cloud/free/)
- [Provision Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/autonomous-provision.html)
- [Loading Data with Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/load-data.html)


## Acknowledgements

- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, July 6, 2022
