# Mask sensitive data

## Introduction

Data Masking provides a way for you to mask sensitive data so that the data is safe for non-production purposes. For example, organizations often need to create copies of their production data to support development and test activities. Simply copying the production data exposes sensitive data to new users. To avoid a security risk, you can use Data Masking to replace the sensitive data with realistic, but fictitious data.

The roles granted to the Oracle Data Safe service account on your target database control which Oracle Data Safe features you can use with the database. By default, Autonomous AI Database Serverless has all Oracle Data Safe roles granted during target database registration, except for the Data Masking and SQL Firewall roles. If you are working in your own tenancy, you need to grant the Data Masking role on your target database. 

Create a masking policy using the default settings and then  customize it. Mask the sensitive data that you discovered in the [Discover Sensitive Data](?lab=discover-sensitive-data) lab. View the before and after effect on the masked data by using ORACLE Database Actions.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

- (For your tenancy only) Grant the Data Masking role on your target database
- View sensitive data in your target database
- Create a masking policy for your target database
- Modify a masking format to use a fixed number
- Create a group mask
- Perform a pre-masking check
- Mask sensitive data in your target database
- View the Data Masking report
- Validate the masked data in your target database


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Access to or prepared an environment for this workshop
- Access to a registered target database. Make sure to have the `ADMIN` password for your database on hand.
- Created a sensitive data model (see [Discover Sensitive Data](?lab=discover-sensitive-data))


### Assumptions

- Your data values might be different than those shown in the screenshots.
- Please ignore the dates for the data and database names. Screenshots are taken at various times and may differ between labs and within labs.


## Task 1 (For your tenancy only): Grant the Data Masking role on your target database

Perform this task only if you are working in your own tenancy. If you are using a LiveLabs sandbox, you do not need to perform this task.

1. Return to the SQL worksheet in Database Actions. If you are prompted to sign in to your target database, sign in as the `ADMIN` user. Clear the worksheet and the **Script Output** tab.

2. On the SQL worksheet, enter the following command to grant the Data Masking role to the Oracle Data Safe service account on your target database.

    ```
    <copy>EXECUTE DS_TARGET_UTIL.GRANT_ROLE('DS$DATA_MASKING_ROLE');</copy>
    ```

3. On the toolbar, click the **Run Statement** button (green circle with a white arrow) to execute the query. 

    ![Run Statement button on toolbar](images/run-statement-button.png "Run Statement button on toolbar")

4. Verify that the script output reads as follows:

    `PL/SQL procedure successfully completed.`
    
    You are now able to mask sensitive data on your target database.

5. Clear the worksheet and script output.  


## Task 2: View sensitive data in your target database

View the sensitive data in the `HCM1.EMPLOYEES` table.

1. (If you didn't perform task 1) Return to the SQL worksheet in Database Actions. If you are prompted to sign in to your target database, sign in as the `ADMIN` user. Clear the worksheet and the **Script Output** tab.

2. On the **Navigator** tab in Database Actions, select the **HCM1** schema from the first drop-down list.

3. Drag the `EMPLOYEES` table to the worksheet.

    ![EMPLOYEES table](images/drag-employees-table-to-worksheet.png "EMPLOYEES table")

4. When prompted to choose an insertion type, click **Select**, and then select **Apply**.

    ![Choose the type of insertion dialog box](images/insertion-type-select.png "Choose the type of insertion dialog box")

5. View the SQL query on the worksheet.

    ![Worksheet tab showing EMPLOYEES table](images/query-employees-table.png "Worksheet tab showing EMPLOYEES table")


6. On the toolbar, select the **Run Script** button.

    ![Run Script button](images/run-script.png "Run Script button")


7. On the **Script Output** tab, review the query results.

    - Data such as `EMPLOYEE_ID`, `FIRST_NAME`, `LAST_NAME`, `EMAIL`, and `PHONE_NUMBER` are considered sensitive data and should be masked if shared for non-production use.

8. Repeat steps 3 to 7 for the `LOCATIONS` table.

9. Keep this browser tab open because you return to it later. Return to the browser tab for Oracle Data Safe. 


## Task 3: Create a masking policy for your target database

Data Masking can generate a masking policy for your target database based on your sensitive data model. It automatically tries to select a default masking format for each sensitive column. You can edit these default selections and select different ones as needed. Occasionally you might be prompted to fix issues (if they exist) in your masking formats.

1. Navigate to the **Data masking** landing page.

2. Under **Data masking**, select **Masking policies**.

3. Next to **Applied filters**, select your compartment without children, if needed.

4. Select **Create masking policy**.

    The **Create masking policy** page opens.

5. Configure the masking policy as follows:

    - Name: **Mask SDM1**
    - Compartment: **Select your compartment**
    - Description: **Masking policy for SDM1**
    - Choose how you want to create the masking policy: Leave **Using a sensitive data model** selected.
    - Sensitive Data Model: Select your compartment (if needed), and then select **SDM1 \[your-target-database-name\]**. If you don't have this sensitive data model, please refer to the [Discover Sensitive Data](?lab=discover-sensitive-data) lab.

    ![Create masking policy panel using SDM1](images/create-masking-policy-sdm1.png "Create masking policy panel using SDM1")

6. Select **Create masking policy**.

    *Important! Please do not close the panel. It closes automatically after all operations are completed. If you close the panel before the operations are finished, the operation to add columns to the masking policy is not initiated.*


7. Review the **Details** tab. 

    - Under **General information**, you can view the masking policy name, a description of the masking policy, the Oracle Cloud Identifier (OCID) for the masking policy, the compartment in which the masking policy is stored, when the masking policy was created and updated.
    - Under **Column source**, you can view the name of the target database and a link to the sensitive data model.
    - Under **Pre/post masking scripts**, you can view and edit the scripts.
    - Under **Masking options**, you can review how these options are configured: Drop temporary table, Redo logging, Refreshing stats enabled, Degree of parallelism, and Recompile.

    ![Masking policy Details tab for Mask SDM1](images/masking-policy-details-tab.png "Masking policy details tab for Mask SDM1")

8. Select the **Masking columns** tab and review the masking columns and their masking formats. If needed, you can select a different masking format for any masking column or edit the existing one. 

    ![Masking policy Masking columns tab for Mask SDM1](images/masking-columns-tab.png "Masking policy Masking columns tab for Mask SDM1")


## Task 4: Modify a masking format to use a fixed number

Set `SALARY` to be a fixed number, such as 50000.

1. Locate the row for the `SALARY` column in the `EMPLOYEES` table. 

2. Select the three dots, and then select **View/Edit masking format**.

    The **Edit format entry** panel opens. 

3. From the **Masking format entry** dropdown list, select **Fixed Number**. You can modify the existing masking format.

4. In the **Fixed number** box, enter **50000**.

    ![Edit masking format page](images/edit-masking-format-page.png "Edit masking format page")

5. Select **Update**.

6. Under **Masking columns**, from the **Actions** menu, select **Save masking formats**. Wait for the format to save and show as **FIXED_NUMBER**.
  

## Task 5: Create a group mask

Use the group masking feature to create a group named `ADDRESS` and apply the `SHUFFLE` masking format to the group.

1. From the **Actions** menu, select **Assign group masking**. The **Assign group masking** panel opens.

2. For **Masking format entry**, select **Shuffle**.

3. For **Group name**, enter **Address**.

4. For **Condition**, enter **1=1**.

5. For each of the following columns, select the column from the **Group masking column name** dropdown list, and then select **Add column**. 

    - `STREET_ADDRESS`
    - `CITY`
    - `STATE_PROVINCE`
    - `COUNTRY_ABBREV`
    - `POSTAL_CODE`

    Note: If `COUNTRY_ABBREV` is not available, you need to add it to your sensitive data model first before creating the group mask (see [Discover Sensitive Data](?lab=discover-sensitive-data)). Or, you can leave it out.

    ![Group mask configuration](images/group-mask1.png "Group mask configuration")


6. Select **Continue**.

7. Notice that the masking format for the columns is set to **Address**.

8. From the **Actions** menu, select  **Save masking formats**.


## Task 6: Perform a pre-masking check

The pre-masking check looks for any known issues that might arise during a masking run; for example, not enough tablespace, missing privileges, and so on. It alerts you to any found issues so that you can remediate them before starting the actual masking run.

1. On the left, select **Pre-masking reports**.

2. Select **Pre-masking check**.

3. Select the compartment for your target database (if needed), and then select your target database.

4. Select the compartment for your masking policy (if needed), and then select your masking policy.

5. For the **Pre-masking report compartment**, select your compartment.

    ![Pre-masking check panel](images/pre-masking-check-panel.png "Pre-masking check panel")

6. Select **Submit**. 

7. Select the **Work requests** tab to view the progress. 

8. Review the log messages and verify each check has passed.

    ![Pre-masking report details page](images/pre-masking-report-details-page.png "Pre-masking report details page")


## Task 7: Mask sensitive data in your target database

1. Select **Mask data**.

    The **Mask sensitive data** panel opens.

2. Select your target database, and then select **Mask data**.

    ![Mask sensitive data panel](images/mask-sensitive-data-panel.png "Mask sensitive data panel")

    The **Work request** tab is opened.

3. Monitor the progress of the work request by viewing the log messages in the table.

    ![Log messages for data masking work request](images/masking-log-messages.png "Log messages for data masking work request")

4. Wait for the operations to finish.

 
## Task 8: View the Data Masking report

1. Navigate to the **Data masking** landing page.

2. On the **Masking reports** tab, ensure that your compartment is selected. Scroll down and select **View report** for your target database.

    The **Masking report** page opens. The **Details** tab shows you the following information: 
  
    
    - Oracle Cloud Identifier (OCID) for the masking report
    - Compartment where the report is stored
    - Target database name
    - Masking policy name - you can click a link to view it
    - Masking status - verify that it says **SUCCESS**
    - Date and time when the data masking job started and finished
    - Number of masked sensitive types, schemas, tables, columns, values, total pre-mask errors, and total post-mask errors

    ![Masking report Details tab](images/masking-report-details-tab.png "Masking report Details tab")

3. Select the **Masked columns** tab and review the masked sensitive columns.

    - This table lists each masked sensitive column and its respective schema, table, masking format, sensitive type, parent column, and total number of masked values.
    - If a sensitive column doesn't have a masking format associated with it, a dash is shown in the masking format column.

    ![Masking report Masked columns tab](images/masking-report-masked-columns-tab.png "Masking report Masked columns tab")


## Task 9: Validate the masked data in your target database

1. Return to the SQL worksheet in Database Actions. If your session expired, sign in again as the `ADMIN` user. Clear the worksheet.

2. Drag the `EMPLOYEES` table to the worksheet and apply the **Select** insertion type.

3. On the toolbar, click the **Run Statement** button (green circle with a white arrow) to execute the query.

4. Review the masked data at the bottom of the page. 

    - You can resize the panel to view more data and you can scroll down and to the right.
    - Find the `SALARY` column and verify that the values are all 50000.

    ![Masked EMPLOYEE data](images/masked-query-results.png "Masked EMPLOYEE data")

5. Clear the worksheet.

6. Drag the `LOCATIONS` table to the worksheet and apply the **Select** insertion type.

7. On the toolbar, click the **Run Statement** button.

8. Examine the data. The data for each `LOCATION_ID` has changed. `STREET_ADDRESS`, `POSTAL_CODE`, `CITY`, `STATE_PROVINCE`, AND `COUNTRY_ABBREV` are shuffled as an entire group to maintain the accuracy of each location. Notice that the `COUNTRY_ID`, which has not been masked and is not included in the screenshot below, is different than the `COUNTRY_ABBREV`.

    ![Addresses shuffled](images/addresses-shuffled.png "Addresses shuffled")


## Learn More

- [Data Masking Overview](https://docs.oracle.com/en/cloud/paas/data-safe/udscs/data-masking-overview.html)
- [Target Database Registration](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B5F255A7-07DD-4731-9FA5-668F7DD51AA6)

## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, February 2, 2026