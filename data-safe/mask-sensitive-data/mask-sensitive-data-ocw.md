# Mask sensitive data

## Introduction

Data Masking provides a way for you to mask sensitive data so that the data is safe for non-production purposes. For example, organizations often need to create copies of their production data to support development and test activities. Simply copying the production data exposes sensitive data to new users. To avoid a security risk, you can use Data Masking to replace the sensitive data with realistic, but fictitious data.

Create a masking policy using the default settings and then  customize it. Mask the sensitive data that you discovered in the [Discover Sensitive Data](?lab=discover-sensitive-data-ocw) lab. View the before and after effect on the masked data by using Oracle Database Actions.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

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
- Granted the service account on your target database the Data Masking role (this is already done for you in the LiveLabs sandbox).


### Assumptions

- Your data values might be different than those shown in the screenshots.
- Please ignore the dates for the data and database names. Screenshots are taken at various times and may differ between labs and within labs.


## Task 1: View sensitive data in your target database

View the sensitive data in the `HCM1.EMPLOYEES` table.

1. Return to the SQL worksheet in Database Actions.

2. If you are prompted to sign in to your target database, sign in as the `ADMIN` user.

3. Clear the worksheet and the **Script Output** tab.

4. On the **Navigator** tab in Database Actions, select the **HCM1** schema from the first drop-down list.

5. Drag the `EMPLOYEES` table to the worksheet.

    ![EMPLOYEES table](images/drag-employees-table-to-worksheet.png "EMPLOYEES table")

6. When prompted to choose an insertion type, click **Select**, and then click **Apply**.

    ![Choose the type of insertion dialog box](images/insertion-type-select.png "Choose the type of insertion dialog box")

7. View the SQL query on the worksheet.

    ![Worksheet tab showing EMPLOYEES table](images/query-employees-table.png "Worksheet tab showing EMPLOYEES table")


8. On the toolbar, click the **Run Script** button.

    ![Run Script button](images/run-script.png "Run Script button")


9. On the **Script Output** tab, review the query results.

    - Data such as `EMPLOYEE_ID`, `FIRST_NAME`, `LAST_NAME`, `EMAIL`, and `PHONE_NUMBER` are considered sensitive data and should be masked if shared for non-production use.

10. Return to the browser tab for Oracle Data Safe. Keep this browser tab open because you return to it later.


## Task 2: Create a masking policy for your target database

Data Masking can generate a masking policy for your target database based on your sensitive data model. It automatically tries to select a default masking format for each sensitive column. You can edit these default selections and select different ones as needed. Occasionally you might be prompted to fix issues (if they exist) in your masking formats.

1. In the breadcrumb at the top of the page, click **Data Safe**.

2. On the left under **Security center**, click **Data masking**.

3. Under **Related resources**, click **Masking policies**.

4. Under **List scope** on the left, select your compartment.

5. On the right, click **Create masking policy**.

    The **Create masking policy** panel is displayed.

6. Configure the masking policy as follows:

    - Name: **Mask SDM1**
    - Compartment: **Select your compartment**
    - Description: **Masking policy for SDM1**
    - Choose how you want to create the masking policy: Leave **Using a sensitive data model** selected.
    - Sensitive Data Model: Select **SDM1\[your-target-database-name\]**. If you don't have this sensitive data model, please refer to the [Discover Sensitive Data](?lab=discover-sensitive-data-ocw) lab.

    ![Create masking policy panel using SDM1](images/create-masking-policy-sdm1.png "Create masking policy panel using SDM1")

7. Click **Create masking policy**.

    *Important! Please do not close the panel. It closes automatically after all operations are completed. If you close the panel before the operations are finished, the operation to add columns to the masking policy is not initiated.*

    The **Masking policy details** page is displayed.

8. Review the masking policy.

    - On the **Masking policy information** tab, you can view the masking policy name (and edit it), the Oracle Cloud Identifier (OCID) for the masking policy, the compartment in which the masking policy is stored, a link to the work request for the masking policy, a link to masking options, the target database and sensitive data model to which the masking policy is associated, and the date/time in which the masking policy was created and last updated.
    - The **Masking columns** table lists all the masking columns and their masking formats. If needed, you can select a different masking format for any masking column. You can click the pencil icon next to a masking format to edit it.

    ![Masking policy details page for Mask SDM1 top](images/masking-policy-details-top.png "Masking policy details page for Mask SDM1 top")

    ![Masking policy details page for Mask SDM1 middle](images/masking-policy-details-middle.png "Masking policy details page for Mask SDM1 middle")

    ![Masking policy details page for Mask SDM1 bottom](images/masking-policy-details-bottom.png "Masking policy details page for Mask SDM1 bottom")


## Task 3: Modify a masking format to use a fixed number

Set `SALARY` to be a fixed number, such as 50000.

1. Locate the row for the `SALARY` column in the `EMPLOYEES` table. 

2. Click the pencil button next to the masking format.

    The **Edit masking format** page is displayed. 

3. From the **Masking format entry** drop-down list, select **Fixed Number**. 

4. In the **Fixed number** box, enter **50000**.

    ![Edit masking format page](images/edit-masking-format-page.png "Edit masking format page")

5. Click **Continue**. 

    Notice that the updated row is highlighted.
    
    ![Updated row is highlighted](images/updated-row-is-highlighted.png "Updated row is highlighted")
    
6. To save your update, click **Save masking formats** and wait for the update operation to finish.


## Task 4: Create a group mask

Use the group masking feature to create a group named `ADDRESS` and apply the `SHUFFLE` masking format to the group.

1. In the list of columns in the masking policy, find `STREET_ADDRESS` from the `LOCATIONS` table, and then select the masking format called **Group Masking**.

    The **Edit masking format** page is displayed.

2. For **Group name**, enter **Address**.

3. From the **Masking format entry** drop-down list, select **Shuffle**.

4. Notice that **STREET_ADDRESS** is listed as a column for the group.

5. For each of the following columns, click **+Another** column and select the column.

    - `CITY`
    - `STATE_PROVINCE`
    - `COUNTRY_ABBREV`
    - `POSTAL_CODE`

    Note: If `COUNTRY_ABBREV` is not available, you need to add it to your sensitive data model first before creating the group mask (see [Discover Sensitive Data](?lab=discover-sensitive-data)). Or, you can leave it out.

    ![Group mask configuration](images/group-mask1.png "Group mask configuration")

6. Click **Continue**.

7. Notice that the masking format for the columns is set to **Address**.

8. Click **Save masking formats**.


## Task 5: Perform a pre-masking check

1. In the breadcrumb at the top of the page, click **Data Masking**.

2. Click **Pre-masking check**.

3. Select your target database.

4. Select your masking policy.

    ![Pre-masking check panel](images/pre-masking-check-panel.png "Pre-masking check panel")

5. Click **Submit**. 

     The **Pre-masking report details** page is displayed.

    ![Pre-masking report details page](images/pre-masking-report-details-page.png "Pre-masking report details page")

6. Review the log messages and verify each check has passed.


## Task 6: Mask sensitive data in your target database

1. On the **Pre-masking report details** page, click the name of your masking policy (**Mask SDM1**). 

    The **Masking policy details** page is displayed.

2. Click **Mask target**.

    The **Mask sensitive data** panel is displayed.

3. Select your target database, and click **Mask data**.

    ![Mask sensitive data panel](images/mask-sensitive-data-panel2.png "Mask sensitive data panel")

    The **Work request** page is displayed.

4. Monitor the progress of the work request by viewing the log messages in the **Log messages** table.

    ![Log messages for data masking work request](images/masking-log-messages.png "Log messages for data masking work request")

5. Wait for the status to read as **SUCCEEDED**.

 
## Task 7: View the Data Masking report

1. While on the **Work request** page, next to **Masking report** on the **Work request information** tab, click **View details**.

    The **Masking report details** page is displayed.

2. Review the masking report.

    - The **Masking report information** tab shows you the target database name, masking policy name (you can click a link to view it), the Oracle Cloud Identifier (OCID) for the masking report, the date and time when the data masking job started and finished, and the number of masked sensitive types, schemas, tables, columns, and values. You can click a link to view masking options. There is also a pie chart that shows you the masked value percentages for each sensitive type. You can click on a pie slice to drill down into the chart.
    - The **Masked columns** table lists each masked sensitive column and its respective schema, table, masking format, sensitive type, parent column, and total number of masked values.

    ![Masking report top](images/masking-report-top3.png "Masking report top")
    ![Masking report bottom](images/masking-report-bottom.png "Masking report bottom")


## Task 8: Validate the masked data in your target database

1. Return to the SQL worksheet in Database Actions. If your session expired, sign in again as the `ADMIN` user. The `SELECT` statement against the `EMPLOYEES` table should be displayed on the worksheet.

2. On the toolbar, click the **Run Statement** button (green circle with a white arrow) to execute the query.

    Clicking the **Run Statement** button (instead of the **Run Script** button) will show the results on the **Query Results** tab instead of the **Script Output** tab. This will allow you to do a before and after comparison of the masked data.

3. Review the masked data on the **Query Result** tab at the bottom of the page. 

    - You can resize the panel to view more data and you can scroll down and to the right.
    - Find the `SALARY` column and verify that the values are all 50000.

    ![Masked EMPLOYEE data](images/masked-query-results.png "Masked EMPLOYEE data")

4. (Optional) Click the **Script Output** tab to view the original unmasked data.

5. Clear the worksheet.

6. Drag the `LOCATIONS` table to the worksheet.

7. When prompted to choose an insertion type, click **Select**, and then click **Apply**.

8. On the toolbar, click the **Run Script** button.

    ![Run Script button](images/run-script.png "Run Script button")

9. Examine the data on the **Script Output** tab. The data for each `LOCATION_ID` has changed. `STREET_ADDRESS`, `POSTAL_CODE`, `CITY`, `STATE_PROVINCE`, AND `COUNTRY_ABBREV` are shuffled as an entire group to maintain the accuracy of each location. Notice that the `COUNTRY_ID`, which has not been masked and is not included in the screenshot below, is different than the `COUNTRY_ABBREV`.

    ![Addresses shuffled](images/addresses-shuffled.png "Addresses shuffled")



## Learn More

- [Data Masking Overview](https://docs.oracle.com/en/cloud/paas/data-safe/udscs/data-masking-overview.html)
- [Target Database Registration](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-B5F255A7-07DD-4731-9FA5-668F7DD51AA6)

## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, August 22, 2024
