# Prepare Your Environment

## Introduction

In this lab, you prepare your environment in Oracle Cloud Infrastructure for this workshop. These instructions are for creating an environment in your own tenancy and assume that you are the tenancy administrator.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Enable Oracle Data Safe in a region of your tenancy
- Create a compartment
- Provision an Autonomous Transaction Processing database
- Access Oracle Database Actions
- Load sample data into your database


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`


## Task 1: Enable Oracle Data Safe in a region of your tenancy

Enable Oracle Data Safe in a tenancy region.

> **Note**: If Oracle Data Safe is already enabled in the desired region of your tenancy, you can skip this task.

1. In Oracle Cloud Infrastructure, at the top of the page on the right, select the region of your tenancy in which you want to enable Oracle Data Safe. Usually, you leave your home region selected, for example, **US East (Ashburn)**.

   ![Select Home region](images/select-region.png "Select Home region")

2. From the navigation menu, select **Oracle Database**, and then **Data Safe**.

    The **Overview** page is displayed.

3. Click **Enable Data Safe** and wait a couple of minutes for the service to enable. When it's enabled, a confirmation message is displayed in the upper-right corner.

    ![Enable Data Safe button](images/enable-data-safe-button.png "Enable Data Safe button")


## Task 2: Create a compartment

Create a compartment in Oracle Cloud Infrastructure Identity and Access Management (IAM) in which to store Oracle Data Safe resources. From here on in, we refer to this compartment as "your compartment."

> **Note**: If you have an existing compartment in your tenancy that you can use, you can skip this task.

1. From the navigation menu, select **Identity & Security**, and then **Compartments**.

    The **Compartments** page in IAM is displayed.

2. Click **Create Compartment**.

    The **Create Compartment** dialog box is displayed.

3. Enter a name for your compartment, for example, `dsc01` (short for Data Safe compartment 1).

4. Enter a description for the compartment, for example, **Compartment for the Oracle Data Safe Workshop**.

5. Select a parent compartment.

6. Click **Create Compartment**.


## Task 3: Provision an Autonomous Transaction Processing database

Create an Autonomous Transaction Processing (ATP) database in your compartment.

1. From the navigation menu, select **Oracle Database**, and then **Autonomous Transaction Processing**.

2. In the **Filters** section on the left, make sure your workload type is **Transaction Processing** or **All** so that you can view your database listing after you create your database.

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


## Task 4: Access Oracle Database Actions

Throughout this workshop, you access Database Actions to run SQL commands on your target database. The step-by-step instructions for accessing Database Actions are covered here. The labs simply say to "access the SQL worksheet in Database Actions." You can always refer back to these steps for help if needed.

1. At the top of the **Autonomous Database Details** page, click **Database Actions**. A new tab is opened called **Oracle Database Actions** with **Database Actions | Launchpad** displayed at the top of the page.

    - If this page is not displayed, check that pop-up windows are allowed in your browser.
    - Keep this tab open throughout the workshop. If your session expires, you can always sign in again.

2. If you are prompted to sign in to your target database, sign in as the `ADMIN` user.

3. In the **Development** section, click **SQL**.

4. In the help note dialog box, click the **X** button to close it.

5. In the **Warning** dialog box in the upper-right corner, click the **X** to close it.

6. Review the interface. Here are the ways that you use Database Actions during the workshop:

    - In the **Navigator** pane on the left, you select tables from the **HCM1** schema on your target database.
    - On the **Worksheet** on the right, you run SQL commands and scripts.
    - On the **Query Result** and **Script Output** tabs at the bottom of the page, you review query results and output generated from running scripts.

    ![SQL Worksheet in Oracle Database Actions](images/database-actions.png "SQL Worksheet in Oracle Database Actions")


## Task 5: Load sample data into your database

As the `ADMIN` user on your database, run the `load-data-safe-sample-data_admin.sql` SQL script to load sample data into your database. This script creates several tables with sample data that you can use to practice with the Oracle Data Safe features. It also generates database activity for the `ADMIN` user.

1. Download the [**load-data-safe-sample-data_admin.sql**](https://objectstorage.us-ashburn-1.oraclecloud.com/p/AUKfPIGuTde04z4OnuaZN2EP0LxNl4hJWI2jZiTw23aWzSoa2_Byvs8OGPw20-dt/n/c4u04/b/livelabsfiles/o/security-library/load-data-safe-sample-data_admin.sql) script and open it in a text editor, such as NotePad.

2. Copy the entire script to the clipboard and paste it into the worksheet in Database Actions. The last line of the script is as follows:

     `select null as "End of script" from dual;`

3. On the toolbar, click the **Run Script** button and wait for the script to finish running.

    ![Run Script button](images/run-script.png "Run Script button")

    - The script takes a few minutes to run.
    - In the bottom-left corner, the cog wheel may remain still for about a minute, and then it turns as the script is processed. The script output is displayed after the script is finished running.
    - Don't worry if you see some error messages on the **Script Output** tab. These are expected the first time you run the script.
    - The script ends with the message **END OF SCRIPT**.

4. To ensure the sample data is loaded successfully, scroll up from the bottom of the script output and review the row count for each table in the `HCM1` schema. The counts should be as follows:

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
- **Last Updated By/Date** - Jody Glover, Aug 24, 2022
