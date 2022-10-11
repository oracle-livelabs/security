# Audit Database Activity

## Introduction

In Oracle Data Safe, you can provision audit policies on your target databases and collect audit data into the Oracle Data Safe repository. There are basic, administrator, user, Oracle pre-defined, and custom audit policies, as well as audit policies designed to help your organization meet compliance standards. When you register a target database, Oracle Data Safe automatically creates an audit profile, audit policy, and audit trails relevant for the target database.

Start by reviewing the global settings in Oracle Data Safe. Then, review the audit profile, audit trail(s), and audit policy that are automatically created for your target database. Start audit data collection on your target database and provision a few audit policies. Analyze the audit events, view reports, create a custom audit report, and download the custom audit report as a PDF.

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you will:

- Review the global settings for Oracle Data Safe
- Review the audit profile for your target database
- Review the audit policy for your target database
- Review the audit trail(s) for your target database
- View the quantity of audit records available on your target database for the discovered audit trail(s)
- Start audit data collection
- Review the Activity Auditing dashboard
- Provision audit policies on your target database
- Analyze the audit events for your target database
- View the All Activity report
- (Optional) Create a custom audit report
- (Optional) Generate and download a custom audit report as a PDF

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account
- Signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous Database with Oracle Data Safe](?lab=register-autonomous-database))


### Assumptions

- Your data values are most likely different than those shown in the screenshots.

## Task 1: Review the global settings for Oracle Data Safe

1. Access the **Overview** page for Oracle Data Safe by clicking **Data Safe** in the breadcrumb at the top of the page.

2. Under **Data Safe**, click **Settings**.

3. Review the global settings.

    - Each regional Oracle Data Safe service in a tenancy has global settings for paid usage, online retention period, and archive retention period.
    - Global settings are applied to all target databases unless their audit profiles override them.
    - By default, paid usage is enabled for all target databases, the online retention period is set to the maximum value of 12 months, and the archive retention period is set to the minimum value of 0 months. Note that you cannot enable paid usage for a free trial account.

    ![Global Settings](images/global-settings.png "Global Settings")


## Task 2: Review the audit profile for your target database

1. In the breadcrumb, click **Data Safe**.

2. Under **Security Center** on the left, click **Activity Auditing**.

3. Under **Related Resources**, click **Audit Profiles**.

4. From the **Compartment** drop-down list under **List Scope**, make sure your compartment is selected.

5. On the right, review the audit profile information about your target database, and then click your target database name to view more detail.

    ![Audit Profiles page](images/audit-profiles-page.png "Audit Profiles page")

6. Review the details in the audit profile.

    - There are default settings for paid usage, online retention period, and offline retention period.
    - All initial audit profile settings for your target database are inherited from the global settings for Oracle Data Safe, but you can modify them here as needed.

    ![Audit Profile Details page](images/audit-profile-details-page.png "Audit Profile Details page")

## Task 3: Review the audit trail(s) for your target database

1. In the breadcrumb at the top of the page, click **Activity Auditing**.

2. On the left under **Related Resources**, click **Audit Trails**.

3. Under **List Scope** on the left, make sure your compartment is selected.

4. Under **Filters** on the left, select your target database.

5. On the right, review the audit trail(s) for your target database. Oracle Data Safe discovers one audit trail for an Autonomous Database, which is the `UNIFIED_AUDIT_TRAIL`.

    ![Audit Trails page](images/audit-trails-page.png "Audit Trails page")

6. Click your target database name for one of the audit trails and review the information on the **Audit Trail Details** page. This is where you can manage audit data collection for the audit trail. Notice that the audit trail is currently inactive.

    ![Audit Trail Details page](images/audit-trail-details-page.png "Audit Trail Details page")


## Task 4: Review the audit policy for your target database

1. In the breadcrumb at the top of the page, click **Activity Auditing**.

2. Under **Related Resources**, click **Audit Policies**.

3. From the **Compartment** drop-down list on the left, make sure your compartment is selected.

4. From the **Target Databases** drop-down list on the left, select your target database.

5. On the right, review the information provided for your target database's audit policy.

    ![Audit Policies page](images/audit-policies-page.png "Audit Policies page")

6.  Click your target database name to view more detail on the **Audit Policy Details** page. Scroll down and review the list of audit policies available for your target database.

    - A grey circle means the audit policy is not yet provisioned on the target database. A green circle means the audit policy is provisioned.
    - You can choose to provision and enable any number of audit policies on your target database and set filters on users and roles.

    ![Audit Policies Details page](images/audit-policies-details-page.png "Audit Policies Details page")


## Task 5: View the quantity of audit records available on your target database for the discovered audit trail(s)

1. In the breadcrumb at the top of the page, click **Activity Auditing**.

2. On the left under **Related Resources**, click **Audit Profiles**.

3. From the **Compartment** drop-down list on the left, make sure your compartment is selected.

4. From the **Target Databases** drop-down list on the left, select your target database.

5. On the right, click the name of your target database.

6. Scroll down to the **Compute Audit Volume** section, and click **Available on Target Database**.

    ![Compute Audit Volume section](images/compute-audit-volume-section.png "Compute Audit Volume section")

    The **Compute Available Volume** dialog box is displayed.

7. For the start date, click the calendar widget and select the current date at 00:00 UTC. You select the current date because your target database is brand new.

8. From the **Trail Locations** drop-down list, select `UNIFIED_AUDIT_TRAIL`.

9. Click **Compute** and wait for Oracle Data Safe to calculate the available audit volume.

    ![Compute Available Volume dialog box](images/compute-available-volume-dialog-box.png "Compute Available Volume dialog box")

10. In the **Available in Target Database** column, view the number of audit records for the `UNIFIED_AUDIT_TRAIL`.

    - In our case, the number of records in the `UNIFIED_AUDIT_TRAIL` is small because your target database has just been provisioned. For an older target database, however, there are probably a large number of audit records.
    - Oracle Data Safe splits up the numbers by month. These values help you to decide on a start date for the Oracle Data Safe audit trail.
    - Don't worry if the number of audit records on your system is different than what is shown below.

    ![Available in Target Database column](images/available-in-target-database3.png "Available in Target Database column")


## Task 6: Start audit data collection

1. In the breadcrumb at the top of the page, click **Activity Auditing**.

2. On the left under **Related Resources**, click **Audit Trails**.

3. From the **Compartment** drop-down list on the left, make sure your compartment is selected.

4. From the **Target Databases** drop-down list on the left, select your target database.

5. On the right, click the name of your target database for the `UNIFIED_AUDIT_TRAIL`.

    The **Audit Trail Details** page is displayed.

6. Click **Start**.

    A **Start Audit Trail: UNIFIED\_AUDIT\_TRAIL** dialog box is displayed.

7. Configure a start date based on the data in the **Compute Audit Volume** region of the audit profile that you viewed in task 5 (step 10). For example, if you have one month listed (July 2022), you can set the start date to the beginning of July.

    ![Start Audit Trail dialog box](images/start-audit-trail-dialog-box.png "Start Audit Trail dialog box")

8. Click **Start**. Wait for the **Collection State** to change from **STARTING** to **COLLECTING** and then to **IDLE**. It takes about a minute.

    ![Collection State Idle](images/collection-state-idle.png "Collection State Idle")


## Task 7: Review the Activity Auditing dashboard

By default, the Activity Auditing dashboard shows you a summary of audit events for the last one week for all target databases in the form of charts and tables. On the left under **List Scope** and **Filters**, you can filter by compartment, time period, and target database.

1. In the breadcrumb at the top of the page, click **Activity Auditing**.

    By default, the Activity Auditing dashboard shows you a summary of audit events for the last one week for all target databases in the form of charts and tables. On the left under **List Scope** and **Filters**, you can filter by compartment, time period, and target database.

2. From the **Compartments** drop-down list on the left, make sure your compartment is selected.

3. From the **Target Databases** drop-down list on the left, select your target database. The dashboard is automatically updated to include audit event statistics for only your target database.

4. Review the charts.

    - The **Failed Login Activity** chart shows you the number of failed logins on your target database for the last one week. You may or may not have any failed logins, depending on how you have interacted in Database Actions so far.
    - The **Admin Activity** chart shows you the number of database schema changes, logins, audit setting changes, and entitlement changes on your target database for the last one week.
    - The **All Activity** chart shows you the total count of audit events on your target database for the specified time period.

    ![Activity Auditing dashboard initial charts](images/activity-auditing-dashboard-charts-initial.png "Activity Auditing dashboard initial charts")

5. On the **Events Summary** tab, review the statistics for audit event categories.

    Statistics include the number of target databases that have an audit event in each event category and the total number of events per category. Because you are viewing statistics for your target database only, the **Target Databases** column shows ones.

    ![Activity Auditing dashboard initial table](images/activity-auditing-dashboard-table-initial.png "Activity Auditing dashboard initial table")

4. Click the **Target Summary** tab and review the various audit event counts per target database.

    Audit events include the number of login failures, schema changes, entitlement changes, audit settings changes, all activity (all audit events), database vault realm violations and command rule violations, and database vault policy changes.

    ![Activity Auditing dashboard initial target summary](images/activity-auditing-dashboard-targetsummary-initial.png "Activity Auditing dashboard initial target summary")

## Task 8: Provision audit policies

1. In the breadcrumb at the top of the page, click **Activity Auditing**.

2. Under **Related Resources**, click **Audit Policies**.

3. From the **Compartment** drop-down list on the left, make sure your compartment is selected.

4. From the **Target Databases** drop-down list on the left, select your target database.

5. On the right, click the name of your target database.

6. Notice that there are three custom audit policies provisioned on your target database, but they are not yet enabled. You provisioned these on your target database when you loaded the sample data in the [Prepare Your Environment](?lab=prepare-environment) lab.

    - `APP_USER_NOT_APP_SERVER`
    - `EMPSEARCH_SELECT_USAGE_BY_PETE`
    - `EMP_RECORD_CHANGES`

    ![Custom policies](images/custom-policies.png "Custom policies")

7. Click **Update and Provision**.

    The **Provision Audit Policies** panel is displayed.

8. Select **Exclude Data Safe user activity**.

9. Under **Basic Auditing**, select **Database Schema Changes** and **Critical Database Activity**.

10. Under **Admin Activity Auditing**, select **Admin User Activity**.

11. Under **Custom Policies**, select **APP\_USER\_NOT\_APP\_SERVER**.

12. Click **Update and Provision** to provision the selected policies on your target database.

    ![Provision Audit Policies panel](images/provision-audit-policies-panel.png "Provision Audit Policies panel")

13. Wait for the provisioning to finish, and then view the updated policy information on the page. Notice that the policies you enabled now have green circles.


## Task 9: Analyze the audit events for your target database

1. In the breadcrumb at the top of the page, click **Activity Auditing**.

2. From the **Compartments** drop-down list on the left, make sure your compartment is selected.

3. From the **Target Databases** drop-down list on the left, select your target database. Deselect **Include child compartments**.

    The dashboard is automatically updated to include audit event statistics for your target database. Do you notice any difference in the numbers?

    ![Activity Auditing dashboard charts after provisioning policies](images/activity-auditing-dashboard-charts-afterprovision.png "Activity Auditing dashboard charts after provisioning policies")
    ![Activity Auditing dashboard table after provisioning policies](images/activity-auditing-dashboard-table-afterprovision.png "Activity Auditing dashboard table after provisioning policies")

4. You notice that there are schema changes. To investigate, on the **Events Summary** tab and click **Schema Changes By Admin** to view more detail.

    ![Schema Changes By Admin event category](images/schema-changes-by-admin-event-category.png "Schema Changes By Admin event category")

5. On the **Schema Changes By Admin** page, review the following:

    - The filters set at the top of the page. There are two filters on **Operation Time**, setting the time period for the past one week.
    - The total number of database users, client hosts, create statements, alter statements, and drop statements
    - The total number of events
    - The individual audit events

    ![Schema Changes By Admin page](images/schema-changes-by-admin-page2.png "Schema Changes By Admin page")

6. Click the down arrow at the end of any row in the event table to view more detail about the event. When you click the down arrow, it changes to an up arrow.

    ![Audit event table expander](images/audit-event-table-expander2.png "Audit event table expander")

7. What was the SQL issued?

    Answer: Scroll down to the **SQL Text** line item. Here you can choose to show the SQL or copy it. The SQL issued was as follows:

    ```<copy>
    drop function HCM1.return_condition</copy>
    ```

## Task 10: View the All Activity report

The All Activity report shows audit events for the past one week (by default) for all target databases in the selected compartment(s).

1. Under **Related Resources**, click **Audit Reports**. Oracle Data Safe has the following predefined audit reports:

    - All Activity
    - Admin Activity
    - User/Entitlement Changes
    - Audit Policy Changes
    - Login Activity
    - Data Access
    - Data Modification
    - Database Schema Changes
    - Data Safe Activity
    - Database Vault Activity

    ![Audit Reports page](images/audit-reports-page.png "Audit Reports page")

2. Make sure that your compartment is selected. Deselect **Include child compartments**.

3. Click the **All Activity** report to view it.

4. View the filters set in the report.

    - By default, the report is filtered to show audit events for the past one week for all target databases in the selected compartment(s).
    - You can create additional filters as needed.

5. View the totals in the report.

    - You can click **Targets**, **DB Users**, and **Client Hosts** to view the list of targets, database users, and client hosts respectively.
    - If you click **DMLs**, **Privilege Changes**, **DDLs**, **User/Entitlement Changes**, **Login Failures**, **Login Successes**, or **Total Events**, the audit events table is filtered accordingly.

6. Scroll down and view the individual audit events.

7. To view more detail for a particular audit event, click the down arrow to expand the row and show details for the particular event. For some details, you can copy their values to the clipboard.

    ![All Activity report](images/all-activity-report2.png "All Activity report")


## Task 11 (Optional): Create a custom audit report

1. At the top of the **All Activity** report, add the following two filters. To add a filter, click **+ Another Filter**. When you are done setting the filter parameters, click **Apply**.

    - **Target = your-target-database-name**
    - **Object Owner = HCM1**

2. Click **Manage Columns**. In the **Manage Columns** panel, select **Target**, **DB User**, **Event**, **Object**, **Operation Time**, and **Unified Audit Policies** columns. Click **Apply Changes**. The table displays the selected columns. Also notice that the totals are adjusted too.

3. Click **Create Custom Report**.

    The **Create Custom Report** dialog box is displayed.

4. Enter the report name **All Activity Report on schema: HCM1 in the target your-target-database-name**. Enter an optional description. Select your compartment. Click **Create Custom Report** and wait for the report to generate.

    ![Create Custom Report dialog box](images/create-custom-report-dialog-box.png "Create Custom Report dialog box")

5. In the **Create Custom Report** dialog box, click the **click here** link to navigate to your custom report.

    - If you need to modify your custom report, you can click **Save Report** to save the changes.
    - To view your custom report in the future, under **Related Resources** for **Activity Auditing**, click **Audit Reports**. Click the **Custom Reports** tab, and then click the name of your custom audit report.


## Task 12 (Optional): Generate and download a custom audit report as a PDF

1. On the custom audit report page, click **Generate PDF/XLS Report**.

    The **Generate Report** dialog box is displayed.

2. Leave **PDF** selected.

3. For **Display Name**, enter **All Activity Report on schema: HCM1 in the target your-target-database-name**.

4. (Optional) Enter a description.

5. Make sure your compartment is selected.

6. Click **Generate Report** and wait until the PDF report is generated.

    A message is displayed stating that report generation is complete.

    ![Generate PDF of custom audit report](images/generate-pdf-custom-audit-report.png "Generate PDF of custom audit report")

7. Click the **click here** link to download the report.

    A dialog box is displayed providing you options to open or save the document.

8. Save the report to your local computer and close the **Generate Report** dialog box.

9. Open the PDF report and view it.

## Learn More

* [Activity Auditing Overview](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-A73D8630-E59F-44C3-B467-F8E13041A680)

## Acknowledgements

* **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
* **Last Updated By/Date** - Jody Glover, July 15, 2022
