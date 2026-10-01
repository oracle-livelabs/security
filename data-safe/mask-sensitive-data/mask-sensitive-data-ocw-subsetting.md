# Subset and mask sensitive data

## Introduction

In the previous labs, you have been building a more complete picture of the database you are responsible for protecting.

You first asked:
Is the database securely configured?
You used Security Assessment to identify configuration risks and detect security drift.

Next, you asked:
Who can access the database, and what can they do?
You used User Assessment to investigate potentially risky users and changes to roles and privileges.

Then, you asked:
What sensitive information are we actually protecting?
You used Data Discovery to identify sensitive data in the HCM1 schema and created a sensitive data model describing where that information resides.

Now your security team receives a common business request.
The application development team needs realistic data for development and testing.

Providing a full copy of the data creates unnecessary risk. The development team does not need every employee and every location represented in the source data. And for the records they do need, they do not need access to real names, email addresses, phone numbers, salaries, addresses, or other sensitive values.

Rather than simply copying the entire data set and masking it, you can reduce the amount of data exposed in the first place.

Oracle Data Safe Data Subsetting and Data Masking can be used together to create a smaller, safer data set for non-production use.

Data Subsetting reduces the amount of data by retaining only the records required for a particular business purpose while preserving the necessary relationships between the selected data. Data Masking then replaces sensitive values in the remaining records with fictitious or transformed values.

Together, these capabilities help you apply two complementary principles:
Keep only the data you need, and protect the sensitive data you keep.

### Scenario

Continue acting as the database security administrator from the previous labs.

Your development team is preparing a non-production environment to test the HCM application.
They initially request a copy of the production-like HCM data.

Before approving the request, you ask two questions:
Does the development team need all of the data?
No. For this testing exercise, the team only needs HCM data associated with a specific country. Employees, locations, and related information associated with other countries are unnecessary for the team's testing requirements.

Does the development team need the real sensitive values in the records they keep?
Again, no. The application needs realistic data structures and values, but developers do not need real employee names, contact information, salaries, addresses, or other sensitive information.

You therefore decide to create a fit-for-purpose non-production data set rather than providing a complete copy of the source data.

You will use what you learned about the HCM data in the Data Discovery lab as the foundation for this process.

First, you will subset the data by country, retaining only the records needed for the selected country and removing data that falls outside the development team's testing requirements. Related data is retained as needed so that the resulting subset remains useful for application testing.

Then, you will mask the sensitive information that remains using the sensitive data model you created in the Data Discovery lab.
For example, salary information can be replaced with a fixed value, while related address elements can be masked together so that the address values remain useful as a group.

Finally, you will validate the resulting data set to confirm two things:
1.	The non-production environment contains only the data required for the selected country.
2.	Sensitive values in the retained records no longer expose the original information.

This approach reduces risk in two ways.
Subsetting reduces the amount of data exposed.
If the development team only needs HCM data for one country, there is no reason to provide data associated with every other country.

Masking reduces the sensitivity of the data that remains.
Even within the selected subset, developers receive realistic data without unnecessary access to the original sensitive values.

The result is a smaller, protected data set designed around the development team's actual business need.

Estimated Time: (tbd)

[Lab 5 - Mask sensitive data](videohub:1_dh9kov8c)

### Objectives

In this lab, you will:

- Review the sensitive information in your database
- Create a subset of the HCM data based on a specific country
- Validate that the subset contains only the data required for the non-production testing scenario
- Create a masking policy based on the sensitive data model from the Data Discovery lab
- Customize how specific sensitive values are masked
- Preserve relationships between related address values by using group masking
- Perform a pre-masking check
- Mask sensitive data
- Validate that sensitive values have been transformed while remaining usable for non-production purposes


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Access to or prepared an environment for this workshop
- Access to a registered target database. Make sure to have the `ADMIN` password for your database on hand.
- Created a sensitive data model (see [Discover Sensitive Data](?lab=discover-sensitive-data-ocw))

### Assumptions

- Your data values might be different than those shown in the screenshots.
- Please ignore the dates for the data and database names. Screenshots are taken at various times and may differ between labs and within labs.

## Task 1: View sensitive data in your target database

View the sensitive data in the `HCM1.EMPLOYEES` table.

1. Return to the SQL worksheet in Database Actions. If you are prompted to sign in to your target database, sign in as the `ADMIN` user. Clear the worksheet and the **Script Output** tab.

2. On the **Navigator** tab in Database Actions, select the **HCM1** schema from the first drop-down list. If it is not listed, refresh your browser tab and try again.

3. Drag the `EMPLOYEES` table to the worksheet.

    ![EMPLOYEES table](images/drag-employees-table-to-worksheet.png "EMPLOYEES table")

4. When prompted to choose an insertion type, select **Select**, and then select **Apply**.

    ![Choose the type of insertion dialog box](images/insertion-type-select.png "Choose the type of insertion dialog box")

5. View the SQL query on the worksheet.

    ![Worksheet tab showing EMPLOYEES table](images/query-employees-table.png "Worksheet tab showing EMPLOYEES table")

6. On the toolbar, select the **Run Script** button.

    ![Run Script button](images/run-script.png "Run Script button")

7. On the **Script Output** tab, review the query results.

    - Data such as `EMPLOYEE_ID`, `FIRST_NAME`, `LAST_NAME`, `EMAIL`, and `PHONE_NUMBER` are considered sensitive data and should be masked if shared for non-production use.

8. Repeat steps 3 to 7 for the `LOCATIONS` table.

9. Keep this browser tab open because you return to it later. Return to the browser tab for Oracle Data Safe.

## Task 2: Create a masking policy for your target database

Data Masking can generate a masking policy for your target database based on your sensitive data model. It automatically tries to select a default masking format for each sensitive column. You can edit these default selections and select different ones as needed. Occasionally you might be prompted to fix issues (if they exist) in your masking formats.

1. Navigate to the **Data masking** landing page.

2. Under **Data masking**, select **Masking policies**.

3. Next to **Applied filters**, select your compartment without child compartments.

4. Select **Create masking policy**.

    The **Create masking policy** page opens.

5. Configure the masking policy as follows:

    - Name: **Mask SDM1**
    - Compartment: **Select your compartment**
    - Description: **Masking policy for SDM1**
    - Choose how you want to create the masking policy: Leave **Using a sensitive data model** selected.
    - Sensitive Data Model: Select your compartment (if needed), and then select the name of your sensitive data model (for example, **SDM1**). If you do not have a sensitive data model, please refer to the [Discover sensitive data](?lab=discover-sensitive-data-ocw) lab.

    ![Create masking policy panel using SDM1](images/create-masking-policy-sdm1.png "Create masking policy panel using SDM1")

6. Select **Create masking policy**.

    *Important! Do not close the panel. It closes automatically after all operations are completed. If you close the panel before the operations are finished, the operation to add columns to the masking policy is not initiated.*

7. Review the **Details** tab.

    - Under **General information**, you can view the masking policy's Oracle Cloud Identifier (OCID), the compartment in which the masking policy is stored, and when the masking policy was created and updated.
    - Under **Column source**, you can view the target database.
    - Under **Pre/post masking scripts**, you can view and edit the scripts.
    - Under **Masking options**, review these options: Drop temporary table, Redo logging, Refreshing stats enabled, Degree of parallelism, and Recompile.

    ![Masking policy Details tab for Mask SDM1](images/masking-policy-details-tab.png "Masking policy Details tab for Mask SDM1")

8. Select the **Masking columns** tab and review the masking columns and their masking formats. If needed, you can select a different masking format for any masking column or edit the existing one.

    ![Masking policy Masking columns tab for Mask SDM1](images/masking-columns-tab.png "Masking policy Masking columns tab for Mask SDM1")

## Task 3: Modify a masking format to use a fixed number

Set `SALARY` to a fixed number, such as 50000.

1. Locate the row for the `SALARY` column in the `EMPLOYEES` table.

2. Select the three dots, and then select **View/Edit masking format**.

    The **Edit format entry** panel opens.

3. From the **Masking format entry** dropdown list, select **Fixed Number**.

4. In the **Fixed number** box, enter **50000**.

    ![Edit masking format page](images/edit-masking-format-page.png "Edit masking format page")

5. Select **Update**.

6. Under **Masking columns**, from the **Actions** menu, select **Save masking formats**. Wait for the format to save and show as **FIXED_NUMBER**.

    ![Fixed number](images/masking-fixed-number.png "Fixed number")

## Task 4: Create a group mask

Use the group masking feature to create a group named `ADDRESS` and apply the `SHUFFLE` masking format to the group.

1. Under **Masking columns**, from the **Actions** menu, select **Assign group masking**.

    The **Assign group masking** panel opens.

2. For **Masking format entry**, select **Shuffle**.

3. For **Group name**, enter **Address**.

4. For **Condition**, enter **1=1**.

5. For **Table name**, select **HCM1.LOCATIONS**.

6. For each of the following columns, select the column from the **Group masking column name** dropdown list, and then select **Add column**.

    - `STREET_ADDRESS`
    - `CITY`
    - `STATE_PROVINCE`
    - `COUNTRY_ABBREV`
    - `POSTAL_CODE`

    Note: If `COUNTRY_ABBREV` is not available, you need to add it to your sensitive data model first before creating the group mask (see [Discover Sensitive Data](?lab=discover-sensitive-data-ocw)). Or, you can leave it out.

    ![Group mask configuration](images/group-mask1.png "Group mask configuration")

7. Select **Continue**.

8. Notice that the masking format for the columns is set to **Address** and that **Masking group** is next to each column in the group.

    ![Masking group](images/masking-group.png "Masking group")

9. From the **Actions** menu, select **Save masking formats**.


## Task 5: Perform a pre-masking check

The pre-masking check looks for any known issues that might arise during a masking run; for example, not enough tablespace, missing privileges, and so on. It alerts you to any found issues so that you can remediate them before starting the actual masking run.

1. On the left, select **Pre-masking reports**.

2. Select **Pre-masking check**.

3. Select the compartment for your target database (if needed), and then select your target database.

4. Select the compartment for your masking policy (if needed), and then select your masking policy.

5. For the **Pre-masking report compartment**, select your compartment.

    ![Pre-masking check panel](images/pre-masking-check-panel.png "Pre-masking check panel")

6. Select **Submit** and wait for the status to change to **Active**.

    The **Work requests** tab opens and shows you the status of the pre-check operations.

7. Select the **Log messages** tab and verify that each check has passed. You can also check that each operation has succeeded on the **Work requests** tab.

    ![Pre-masking verification](images/pre-masking-verification.png "Pre-masking verification")

## Task 6: Mask sensitive data in your target database

1. Under **Data masking** on the left, select **Masking policies**, and then select your masking policy.

2. Select **Mask data**.

    The **Mask sensitive data** panel opens.

3. Select your target database, and then select **Mask data**.

    ![Mask sensitive data panel](images/mask-sensitive-data-panel.png "Mask sensitive data panel")

    The **Work requests** tab opens.

4. Monitor the progress of the operation named `MASKING_JOB`, and wait for it to finish. The status at the top reads **Active** and the **MASKING_JOB** operation has a status of **Succeeded**.


## Task 7: View the Data Masking report

1. Navigate to the **Data masking** landing page.

2. On the **Masking reports** tab, ensure that your compartment is selected. At the bottom of the page, select **View report** for your target database.

    The **Masking report** page opens.

3. Review the **Details** tab.

    - Oracle Cloud Identifier (OCID) for the masking report
    - Compartment where the report is stored
    - Date and time when the masking report was created
    - Target database name
    - Masking policy name (you can select a link to view it)
    - Masking status (verify that it says **SUCCESS**)
    - Date and time when the data masking job started and finished
    - Number of masked sensitive types, tables, columns, values, total pre-mask errors, and total post-mask errors

    ![Masking report Details tab](images/masking-report-details-tab.png "Masking report Details tab")

4. Select the **Masked columns** tab and review the masked sensitive columns.

    - This table lists each masked sensitive column and its respective schema, table, masking format, sensitive type, parent column, and total number of masked values.
    - If a sensitive column does not have a masking format associated with it, a dash is shown in the masking format column.

    ![Masking report Masked columns tab](images/masking-report-masked-columns-tab.png "Masking report Masked columns tab")

## Task 8: Validate the masked data in your target database

1. Return to the SQL worksheet in Database Actions. If your session expired, sign in again as the `ADMIN` user. Clear the worksheet.

2. Drag the `EMPLOYEES` table to the worksheet and apply the **Select** insertion type.

3. On the toolbar, select the **Run Statement** button (green circle with a white arrow) to execute the query.

4. Review the masked data at the bottom of the page.

    - You can resize the panel to view more data and you can scroll down and to the right.
    - Find the `SALARY` column and verify that the values are all 50000.

    ![Masked EMPLOYEE data](images/masked-query-results.png "Masked EMPLOYEE data")

5. Clear the worksheet.

6. Drag the `LOCATIONS` table to the worksheet and apply the **Select** insertion type.

7. On the toolbar, select the **Run Statement** button.

8. Examine the data. The data for each `LOCATION_ID` has changed. `STREET_ADDRESS`, `POSTAL_CODE`, `CITY`, `STATE_PROVINCE`, and `COUNTRY_ABBREV` are shuffled as an entire group to maintain the accuracy of each location. Notice that the `COUNTRY_ID`, which has not been masked and is not included in the screenshot below, is different from `COUNTRY_ABBREV`.

    ![Addresses shuffled](images/addresses-shuffled.png "Addresses shuffled")

You may now **proceed to the next lab**.

## Learn More

- [Data Masking Overview](https://docs.oracle.com/iaas/data-safe/doc/data-masking-overview.html)


## Acknowledgements

- **Author** - Jody Glover, Lead Principal User Assistance Developer, Database Development
- **Contributor** - Bettina Schäumer, Lead Principal Product Manager, Oracle Database Security
- **Last Updated By/Date** - Bettina Schäumer, August 20, 2026