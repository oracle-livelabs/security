# Subset data

## Introduction

In the previous labs, you used Data Discovery to identify sensitive information in the HCM1 schema and Data Masking to transform sensitive values for non-production use. The development team now needs a smaller set of application data for testing. Keeping every row would add data that the team does not need.

Data Subsetting in Oracle Data Safe reduces the data in a target database while maintaining relationships between tables. In this lab, you use your sensitive data model to create a subsetting policy and select data associated with Canada. You examine the `LOCATIONS`, `DEPARTMENTS`, and `EMPLOYEES` tables before and after subsetting to see which rows remain. You also apply your existing masking policy during the subsetting job.

Estimated Time: 15 minutes


### Scenario

Continue acting as the database security administrator from the previous labs. Your development team needs data associated with Canada to test the HCM application. You have already created a sensitive data model and a masking policy. Now you need to reduce the data in the target database while preserving the relationships among the country, location, department, and employee records that the team needs.

Configure a subsetting rule for `COUNTRY_ID='CA'`, review the estimated subset, and inspect the original table data. Then submit the job, which modifies the target database in place, and monitor the subsequent masking operation. Finally, query the tables again to verify that the expected rows remain and sensitive values are masked.

### Objectives

In this lab, you will:

- Create a subsetting policy from your sensitive data model
- Configure a rule for Canada and review related tables and the estimated subset
- Inspect table data before running the subsetting job
- Run and monitor the subsetting and masking jobs
- Verify the remaining rows and masked values after the jobs finish


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Access to or prepared an environment for this workshop
- Access to a registered target database. Make sure to have the `ADMIN` password for your database on hand.
- Created a sensitive data model (see [Discover sensitive data](?lab=discover-sensitive-data-ocw)) and masking policy (see [Mask sensitive data](?lab=mask-sensitive-data-ocw)).

### Assumptions

- Your data values might be different than those shown in the screenshots.
- Please ignore the dates for the data and database names. Screenshots are taken at various times and may differ between labs and within labs.


## Task 1: Configure the subsetting job for your target database

1. Navigate to the **Data subsetting** landing page.

2. If needed, select your compartment without child compartments.

3. Select **Subset database**.

4. In the **Provide basic information** section, do the following:

    a) Select your target database's compartment and its name in the dropdown lists.

    b) Enter your user credentials for the target database. In this workshop, use the `ADMIN` user.

    c) Select **Refresh database statistics** and wait for the message **Database statistics refreshed successfully** to appear.

    d) Select **Create subsetting policy**. The **Create subsetting policy** panel opens.

    e) Make sure your compartment is selected and enter a name for the subsetting policy, for example, **SP1**.

    f) (Optional) Enter a description for the subsetting policy.

    g) Leave **Get schemas from sensitive data model** selected.

    h) In the dropdown lists, leave your compartment selected and select the name of your sensitive data model.

    i) Select **Create subsetting policy** and wait for the operation to complete.

    j) Make sure your subsetting policy compartment is selected and select the name of your subsetting policy.

    k) Select **Next**.

5. In the **Tables and subsetting rules** section, do the following:

    a) Select **Add subsetting rule**. The **Add driving tables** panel opens.

    b) Select the **COUNTRIES** table. The role for the table changes to **Driving table**.

    c) Select **Next**. The **Define rule** panel opens.

    d) Under **Select rule type**, select **Condition**.

    e) Using the dropdown lists and box, configure the condition: **COUNTRY_ID = CA**.

    f) Leave the default options selected for ancestors (**Keep only referenced rows**), descendants (**Keep only referenced rows**), and other related tables (**Keep maximum rows**).

    g) Select **View relationship graph**. The **Relationship graph** panel opens. Review the relationships between the tables in the graph, and then select **Close**.

    h) Select **Next**. The **Review and add** panel opens.

    i) Select **Add** and wait for the table estimates to be calculated. The panel closes when the operation is finished.

    j) Under **Estimated subset**, review the number of rows kept, the subset size, and the amount of reclaimed storage.

    k) Select **Next**.

6. In the **Select subsetting options** section, do the following:

    a) Under **Execution options**, leave the default selections as is.

    - Tablespace name: **DATA**
    - Parallel execution during data subsetting: **Default**
    - Degree of parallelism: Not selected
    - Disable redo log generation during subsetting: Not selected

    b) Under **Post subsetting options**, leave the default selections as is.

    - Recompile invalid objects after subsetting: **None**
    - Refresh database statistics after subsetting: Not selected

    c) Under **Pre and post subsetting scripts**, you do not need to upload any scripts.

    d) Select **Next**.

7. In the **Configure data masking** section, do the following:

    a) Leave **Apply data masking after subsetting** selected.

    b) Make sure your compartment is selected and then select the name of your masking policy.

    c) Select **Next**.

8. In the **Review and submit** section, review the configuration, but do not confirm or submit just yet.



## Task 2: Review the original table sizes before submitting the subsetting job

Use this task to inspect the target database before running the subsetting job. Earlier, you added a rule to the job that selects rows from the `COUNTRIES` table where `COUNTRY_ID = 'CA'`. The following queries show how that rule affects related tables and what data to expect after the job completes.

1. Return to the SQL worksheet in Database Actions. If your session expired, sign in again as the `ADMIN` user. Clear the worksheet.

2. Run the following SQL command and review the results. There should be 20 locations.

    ```
    SELECT * FROM HCM1.LOCATIONS;
    ```

3. Run the following SQL command and review the results. There should be 3 locations that have **CA** as the country ID: location IDs 5, 6, and 20. Remember that you configured a rule on the `COUNTRIES` table in the subsetting job where `COUNTRY_ID='CA'`.

    ```
    SELECT * FROM HCM1.LOCATIONS WHERE COUNTRY_ID='CA';
    ```

4. Run the following SQL command and review the results. There should be 40 departments.

    ```
    SELECT * FROM HCM1.DEPARTMENTS;
    ```
    
5. Run the following SQL command and review the results. There should be 6 departments with location IDs of 5, 6, or 20.

    ```
    SELECT * FROM HCM1.DEPARTMENTS WHERE LOCATION_ID IN ('5','6','20');
    ```

6. Run the following SQL command and notice that the table consists of sensitive salary data.

    ```
    SELECT * FROM HCM1.EMPLOYEES;
    ```

7. Run the following SQL command to find the total number of records in the `EMPLOYEES` table. There should be 10000 records.

    ```
    SELECT COUNT(*) FROM HCM1.EMPLOYEES;
    ```

## Task 3:  Submit the subsetting job

1. Return to the subsetting job in Oracle Data Safe.

2. Review the configuration.

3. Select **I understand this modifies the database in place**.

4. Select **Submit**. 

5. On the **Work requests** tab, monitor the **% Complete** column.

6. In the **Operation** column, select **SUBSETTING_JOB**. Notice that **Subsetting status** is set to **In Progress**.

7. Select the **Logs** tab and review the list of messages in the table. Notice that one of the messages deals with identifying rows for the rule.

8. In the breadcrumb at the top of the page, select **Work requests** to return to the **Work requests** tab. Wait for the subsetting job to be 100% complete.



## Task 4: Monitor the data masking job

1. In the left navigation pane, navigate to **Data masking** and then **Masking policies**.

2. Make sure your compartment is selected, and then select the name of your masking policy.

    Your policy opens on the **Details** tab.

3. Select the **Work requests** tab. Notice that there is a **MASKING_JOB** operation in progress. 

4. Select the masking job and then select the **Log messages** tab to review the log messages. 

5. Wait for the data masking job to complete.


## Task 5: Review the table data after the subsetting job is completed

In this task, you verify that the tables are reduced and masked according to the subsetting job.

1. Return to Database Actions.

2. Run the following SQL command to check the `EMPLOYEES` table. The number of records is reduced to 1545.

    ```
    SELECT COUNT(*) FROM HCM1.EMPLOYEES;
    ```

3. Run the following SQL command to check the `LOCATIONS` table. The number of records is reduced to 3; all have a country ID of CA.

    ```
    SELECT * FROM HCM1.LOCATIONS;
    ```

4. Run the following SQL command to check the `DEPARTMENTS` table. The number of records is reduced to 6; all the location IDs are 5, 6, or 20.

    ```
    SELECT * FROM HCM1.DEPARTMENTS;
    ```

5. Run the following SQL command to confirm the data in the `EMPLOYEES` table is masked. Notice the `FIRST_NAME`, `LAST_NAME`, `EMAIL`, `PHONE_NUMBER`, and `SALARY` columns have masked data.

    ```
    SELECT * FROM HCM1.EMPLOYEES;
    ```

You may now **proceed to the next lab**.

## Learn More

- [Data Subsetting Overview](https://docs.oracle.com/iaas/data-safe/doc/data-subsetting-overview.html)

## Acknowledgements

- **Author** - Jody Glover, Lead Principal User Assistance Developer, Database Development
- **Contributor** - Bettina Schäumer, Lead Principal Product Manager, Oracle Database Security
- **Last Updated By/Date** - Jody Glover, September 28, 2026
