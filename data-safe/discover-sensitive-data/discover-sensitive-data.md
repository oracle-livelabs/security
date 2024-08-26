# Discover sensitive data

## Introduction

Data Discovery helps you find sensitive data in your target databases. You tell Data Discovery what kind of sensitive data to search for, and it inspects the actual data in your target database and its data dictionary, and then returns to you a list of sensitive columns. By default, Data Discovery can search for a wide variety of sensitive data pertaining to identification, biographic, IT, financial, healthcare, employment, and academic information.

In this lab, you use Oracle Data Safe to discover sensitive data on your target database and then adjust the sensitive data model.

Estimated Lab Time: 15 minutes

[Data Safe](videohub:1_d8x5ayoo)

### Objectives

In this lab, you will:

- Discover sensitive data in your target database by using Data Discovery
- Analyze the sensitive data model
- Perform an incremental discovery
- Remove a column from the sensitive data model
- Add a column to the sensitive data model


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Access to or prepared an environment for this workshop
- Access to a registered target database


### Assumptions

- Your data values might be different than those shown in the screenshots.
- Please ignore the dates for the data and database names. Screenshots are taken at various times and may differ between labs and within labs. 


## Task 1: Discover sensitive data in your target database by using Data Discovery

1. Make sure that you are on the browser tab for Oracle Data Safe. If needed, sign in again.

2. In the breadcrumb at the top of the page, click **Data Safe**.

3. On the left under **Security center**, and click **Data discovery**.

4. From the **Compartment** drop-down list, select your compartment.

    The Data discovery page is displayed with statistics for the top five target databases in your compartment. Your page is most likely empty because this is the first time you are using Data Discovery in this workshop.

5. Click **Discover sensitive data**.

    The **Create sensitive data model** wizard is displayed.

6. On the **Provide basic information** page, do the following, and then click **Next**.

    - In the **Name** box, enter **SDM1**.
    - Leave the compartment set to your compartment.
    - In the **Description** box, enter **Sensitive Data Model 1**.
    - Select your target database

    ![Provide basic information](images/provide-basic-information-page.png "Provide basic information")

7. On the **Select schemas** page, wait for the schemas to be refreshed if prompted to do so. Leave **Select specific schemas only** selected. Scroll down and select the **HCM1** schema, and then click **Next**. You might need to click the right arrow button at the bottom of the page to navigate to page 2.

    ![Select schemas](images/select-schemas-page.png "Select schemas")

8. On the **Select tables for schema** page, leave **All tables** selected, and click **Next**.

    ![Select tables for schema page](images/select-tables-for-selected-schemas.png "Select tables for schema page")
    
9. On the  **Select sensitive types** page, review the list of common sensitive types and then scroll down and review all available sensitive types. Scroll up and select the **All** check box for common sensitive types. Click **Next**.

    ![Select all common sensitive types](images/select-all-common-sensitive-types.png "Select all common sensitive types")

10. On the **Select discovery options** page, select **Collect, display and store sample data**, and then click **Create sensitive data model** at the bottom of the page to begin the data discovery process.

    ![Select discovery options page](images/select-discovery-options-page.png "Select discovery options")

11. Wait for the sensitive data model to be created. The **Sensitive data model details** page is displayed.


## Task 2: Analyze the sensitive data model

1. Review the information about the sensitive data model.

    - The **Sensitive data model information** tab lists general information about your sensitive data model, the target database, sensitive data information, and sensitive data counts.
    - You can view the selected sensitive types for discovery, sensitive schemas discovered, sensitive types discovered, and work request information by clicking the respective **View details** link.
    - The bar chart shows you the number of sensitive columns found for the top five sensitive types.
    - The **Sensitive columns** table lists the discovered sensitive columns. By default, the table is displayed in **Flat view** format. For each sensitive column, you can view its schema name, table name, column name, sensitive type, parent column, data type, estimated row count, sample data (if you chose to retrieve sample data and if it exists), and audit records. Review the sample data to get an idea of what it looks like.

    ![Sensitive Data Model Details page top](images/sensitive-data-model-details-page-1.png "Sensitive Data Model Details page top")
    ![Sensitive Data Model Details page bottom](images/sensitive-data-model-details-page-2.png "Sensitive Data Model Details page bottom")

2. Under **Sensitive columns**, from the first drop-down list, select **Sensitive type view** to sort the sensitive columns by sensitive type. By default, all items are expanded in the view. You can collapse the items by moving the **Expand all** slider to the left.

    ![Sensitive type view of sensitive data model](images/sensitive-type-view-sdm1.png "Sensitive type view of sensitive data model")

3. From the same drop-down list, select **Schema view** to sort the sensitive columns by schema and table name.

    - If a sensitive column was discovered because it has a relationship to another sensitive column as defined in the database's data dictionary, the other sensitive column is displayed in the **Parent column**. For example, `EMPLOYEE_ID` in the `EMP_EXTENDED` table has a relationship to `EMPLOYEE_ID` in the `EMPLOYEES` table.

    ![Schema view of sensitive data model](images/schema-view-sdm1.png "Schema view of sensitive data model")

## Task 3: Perform an incremental discovery

Increase the scope of the data discovery job.

1. Under **Resources** on the left, click **Lastest incremental discovery**.

2. Under **Incremental discovery** on the right, click **Run discovery now**.

    The **Run discovery now** dialog box is displayed.

3. Select **Adjust the scope for the incremental discovery**, and then click **Submit**.

    You are returned to the beginning of the data discovery wizard.

    ![Run discovery now dialog box](images/run-discovery-now-dialog-box.png "Run discovery now dialog box")

4. On the **Provide basic information** page, click **Next**.

5. On the **Select schemas** page, click **Next**.

6. On the **Select tables for schema** page, click **Next**.

7. On the **Select sensitive types** page, scroll down to the section where all sensitive types are listed. Select **Biographic Information** and **Employment Information**, and click **Next**.

8. For **Select discovery options**, select **Collect, display and store sample data**.

9. Click **Run discovery now**, and wait for the message **Incremental discovery completed successfully** to be displayed.

10. Review the additional sensitive data that was discovered. Notice that you can approve and reject incremental discovery results or specific results.

11. Select **All incremental discovery results**, and click **Approve**.

    ![Approve all incremental discovery results](images/approve-discovery-results.png "Approve all incremental discovery results")

12. In the **Approve discovery results** dialog box, click **Approve**.

    ![Approve discovery results dialog box](images/approve-discovery-results-dialog-box.png "Approve discovery results dialog box")

13. Click **Apply to SDM**.

    The **Apply to sensitive data model** dialog box is displayed.

    ![Apply to sensitive data model dialog box](images/apply-to-sensitive-data-model.png "Apply to sensitive data model dialog box")

14. Click **Submit** and wait for the message **Sensitive data model updated successfully** to be displayed.

    The sensitive data model is updated with the additional sensitive columns.


## Task 4: Remove a column from the sensitive data model

Remove the `DATE_OF_HIRE` column from the sensitive data model.

1. Under **Resources** on the left, click **Sensitive columns**. 

2. In the **Sensitive columns** section, click **Remove columns**. 

    The **Remove columns** panel is displayed.
    
3. In the **Column name** box, enter **DATE**, and then select **DATE\_OF\_HIRE**.

4. Click **Search**.

5. Select the check box for the **DATE\_OF\_HIRE** column in the **JOB_HISTORY** table, and then click **Remove columns**.

    ![Remove columns page](images/remove-columns-panel.png "Remove columns page")

## Task 5: Add a column to the sensitive data model

Add `COUNTRY_ABBREV` to the sensitive data model.

1. Click **Add columns**.

2. From the **Schema name** drop-down list, select **HCM1**.

3. From the **Table name** drop-down list, select **LOCATIONS**.

4. From the **Column name** drop-down list, select **COUNTRY_ABBREV**.

5. Click **Search**.

6. Select the check box for the `COUNTRY_ABBREV` column.

7. From the **Sensitive type** drop-down list, under **Biographic Information > Address**, select **Country**.

8. Click **Add columns**.

   ![Add columns page](images/add-columns-page.png "Add columns page")

9. Verify that `COUNTRY_ABBREV` from the `LOCATIONS` table is added to your sensitive data model.

You may now **proceed to the next lab**.


## Learn More

- [Data Discovery Overview](https://docs.oracle.com/en/cloud/paas/data-safe/udscs/data-discovery-overview.html)

## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Last Updated By/Date** - Jody Glover, August 21, 2024
