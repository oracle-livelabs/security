# Assess Database Configurations

## Introduction

Security Assessment helps you assess the security of your database configurations. It analyzes database configurations, user accounts, and security controls, and then reports the findings with recommendations for remediation activities that follow best practices to reduce or mitigate risk. By default, Oracle Data Safe automatically generates security assessments for your target databases and stores them in the Assessment History. You can analyze assessment data across all your target databases and for each target database. You can monitor security drift on your target databases by comparing the latest assessment to a baseline or to another assessment.

In this lab, you explore Security Assessment.

Estimated Lab Time: 20 minutes

### Objectives

In this lab, you will:

- View the dashboard for Security Assessment
- View the latest security assessment for your target database
- View the history of security assessments for your target database
- Set a baseline assessment
- Generate activity on the target database
- Refresh the latest security assessment and analyze the results
- Review the high risk level findings from the dashboard
- Generate a Comparison report for Security Assessment
- Add a schedule to save a security assessment for your target database every Sunday at 11:30 PM
- View the history of all security assessments for all of your target databases

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous Database with Oracle Data Safe](?lab=register-autonomous-database))


### Assumptions

- Your data values might be different than those shown in the screenshots.


## Task 1: View the dashboard for Security Assessment

1. In Security Center, click **Security Assessment**.

2. Under **List Scope**, select your compartment. Deselect **Include child compartments**.

    The dashboard shows statistics for your target database.

3. At the top of the page, review the **Risk Level** and **Risks by Category** charts.

    - The **Risk Level** chart shows you a percentage breakdown of the different risk levels (High, Medium, Low, Advisory, and Evaluate) across all target databases in the selected compartment(s).
    - The **Risks by Category** chart shows you a percentage breakdown of the different risk categories (User Accounts, Privileges and Roles, Authorization Control, Data Encryption, Fine-Grained Access, Auditing, and Database Configurations) across target databases in the selected compartment(s).

    ![Security Assessment Risk Level and Risks by Category charts for all targets](images/sa_risklevel_risksbycategory.png "Security Assessment Risk Level and Risks by Category charts for all targets")


4. View the **Risk Summary** tab.

    - The **Risk Summary** tab shows you how much risk you have across all target databases in the specified compartment(s).
    - You can compare the number of high, medium, low, advisory, and evaluate risk findings across all target databases, and view which risk categories have the greatest numbers.
    - Risk categories include Target Databases, User Accounts, Privileges and Roles, Authorization Control, Fine-Grained Access Control, Data Encryption, Auditing, and Database Configuration.

    ![Security Assessment Risk Summary tab](images/sa-risk-summary-tab.png "Security Assessment Risk Summary tab")


5. Click the **Target Summary** tab and view the information.

    - The **Target Summary** tab shows you the security posture of each target database.
    - You can view the number of high, medium, low, advisory, and evaluate risk findings for each target database.
    - You can view the assessment date and find out if the latest assessment deviates from a baseline (if one is set).
    - You can access the latest assessment report for each target database.

    ![Security Assessment Target Summary tab](images/sa-target-summary-tab.png "Security Assessment Target Summary tab")

## Task 2: View the latest security assessment for your target database

Oracle Data Safe automatically creates a security assessment of your target database during registration. This assessment is referred to as the *latest assessment*.

1. On the **Target Summary** tab, locate the line that has your target database, and click **View Report**.

    The latest security assessment for your target database is displayed. Notice that **Latest assessment for target database** is displayed at the top of the page.

2. Review the table on the **Assessment Summary** tab.

    - This table compares the number of findings for each category in the report and counts the number of findings per risk level (**High Risk**, **Medium Risk**, **Low Risk**, **Advisory**, **Evaluate**, and **Pass**).
    - These values help you to identify areas that need attention.

    ![Latest Security Assessment Assessment Summary tab](images/latest-sa-assessment-summary-tab.png "Latest Security Assessment Assessment Summary tab")


3. To view details about the security assessment itself, click the **Assessment Information** tab.

    - Details include assessment name, OCID, compartment to which the assessment was saved, target database name, target database version, assessment date, schedule (if applicable), name of the baseline assessment (if one is set), and whether the assessment complies with the baseline assessment (Yes, No, or No Baseline Set).

    ![Latest Security Assessment Assessment Information tab](images/latest-sa-assessment-information-tab.png "Latest Security Assessment Assessment Information tab")

4. Rename the latest security assessment: Click the pencil icon to the right of **Name**, enter **Latest Security Assessment**, and click the **Save** icon.

    ![Rename Latest Security Assessment](images/rename-latest-sa-assessment.png "Rename Latest Security Assessment")

5. Scroll down and view the **Assessment Details** section.

    - This section shows you all the findings for each risk category.
    - Risks are color-coded to help you easily identify categories that have high risk findings (red).
    - The high risk findings listed under **Privileges and Roles** were introduced when you ran the SQL script to populate your target database with sample data.

    ![Latest Security Assessment Assessment Details section](images/latest-sa-assessment-details-section.png "Latest Security Assessment Assessment Details section")


6. Under **Filters By Risks** on the left, notice that you can select the risk levels that you want displayed. Select **Pass**, and then click **Apply**.

    The **Assessment Details** section is updated to include findings with no risk found (they have a **Pass** level).

    ![Security Assessment filters for risk levels](images/sa-filters-risk-levels.png "Security Assessment filters for risk levels")

7. Under **Filters By References** on the left, notice that you can also filter the list of findings based on recommendations from DISA STIG (Security Technical Implementation Guide), CIS Benchmark (Center for Internet Security), EU GDPR (European Union's General Data Protection Regulation), and Oracle Best Practices.

    ![Filters by references](images/filters-by-references.png "Filters by references")

8. Under **User Accounts**, expand **User Details**.

    - For each user in your target database, the table shows the user status, profile used, the user's default tablespace, whether the user is Oracle Defined (Yes or No), and how the user is authenticated (Auth Type).

    ![Security Assessment user details](images/sa-user-details.png "Security Assessment user details")

9. Expand another category and review the findings.

    - Each finding shows you the status (risk level), a summary of the finding, details about the finding, remarks to help you to mitigate the risk, and references. The references make it easy for you to identify the recommended security controls.
    - In the example below, the **Password Verification Functions** finding is a medium risk finding that has two references: **STIG** and **CIS**.

    ![Password Verification Functions finding](images/password-verification-functions.png "Password Verification Functions finding")


10. Expand a few categories under **Privileges and Roles**, and review the findings.

11. Scroll down further and expand other categories. Each category lists related findings about your target database and how you can make changes to improve its security.


## Task 3: View the history of security assessments for your target database

1. At the top of the page, click **View History**.

2. Make sure that your compartment is selected. Deselect **Include child compartments**.

3. Notice that you have one security assessment listed for your target database. This is a *static* copy (separate copy) of the latest security assessment.

    ![Assessment History](images/assessment-history.png "Assessment History")


## Task 4: Set a baseline assessment

A baseline assessment shows you data for all your target databases in a selected compartment at a given point in time. However, because we are only dealing with one target database in your compartment, the baseline assessment shows data for only one target database. Let's set the first security assessment as the baseline.

1. While you are on the **Assessment History** page for your target database, click the name of your security assessment. The security assessment details are displayed.

    ![First security assessment on Assessment History page](images/first-security-assessment-on-assessment-history-page.png "First security assessment on Assessment History page")


2. Click **Set As Baseline**.

    The **Set As Baseline?** dialog box is displayed.

3. Click **Yes** to confirm that you want to set these findings as the baseline.

    ![Set As Baseline dialog box](images/set-as-baseline-dialog-box.png "Set As Baseline dialog box")

4. *Important! Stay on the page until the message **Baseline has been set** is displayed.*

    ![Security Assessment Baseline has been set message](images/sa-baseline-has-been-set-message.png "Security Assessment Baseline has been set message")

5. Click **Close**.

    You are returned to the **Latest Security Assessment** page.

6. Click **View History**, and confirm that there is a new row in the table for the baseline assessment. The assessment name starts with **SA_baseline**.

    ![Assessment history with baseline assessment](images/sa-assessment-history-with-baseline.png "Assessment history with baseline assessment")

7. Click **Close**. 

    The latest security assessment is displayed.


## Task 5: Generate activity on the target database

In this task, you issue a `GRANT` command on your target database so that later, when you refresh the latest security assessment, you can compare assessments.

1. Access the SQL worksheet in Database Actions. If your session has expired, sign in again as the `ADMIN` user.

2. If needed, clear the worksheet and the **Script Output** tab.

3. On the worksheet, enter the following command:

    ```
    <copy>grant ALTER ANY ROLE to PUBLIC;</copy>
    ```

4. On the toolbar, click the **Run Statement** button (green circle with white arrow).

    ![Run Statement button](images/run-statement-button.png "Run Statement button")


## Task 6: Refresh the latest security assessment and analyze the results

1. Return to the browser tab for Oracle Data Safe.

2. At the top of the latest security assessment, click **Refresh Now** to get the latest data.

    The **Refresh Now** panel is displayed.

3. In the **Save Latest Assessment** box, enter **My Security Assessment**, and then click **Refresh Now**. Wait for the status to read as **SUCCEEDED**.

    - This action updates the data in the latest security assessment for your target database and also saves a copy of the assessment (named My Security Assessment) in the Assessment History.
    - The refresh operation takes about one minute.

    ![Security Assessment Refresh Now panel](images/sa-refresh-now-panel.png "Security Assessment Refresh Now panel")

4. Click the **Assessment Information** tab and observe that the assessment date and time is right now.

    ![Security Assessment Assessed On right now](images/sa-assessed-on-right-now.png "Security Assessment Assessed On right now")

5. Scroll down and expand **System Privileges Granted to Public**.

    - This is a high risk finding.
    - In the **Details** section, you can see that the grant you made in the previous task is identified.

    ![System Privileges Granted to PUBLIC finding](images/system-privileges-granted-to-public.png "System Privileges Granted to PUBLIC finding")


## Task 7: Generate a Comparison report for Security Assessment

1. With the latest security assessment displayed, under **Resources** on the left, click **Compare with Baseline**. Oracle Data Safe automatically begins processing the comparison.

    If you navigated away from the latest security assessment, you can return to it by doing the following: Click **Security Assessment** in the breadcrumb. Click the **Target Summary** tab. Click **View Report** for your target database.

    ![Compare With Baseline option under Resources](images/sa-resources-compare-with-baseline-option.png "Compare With Baseline option under Resources")

2. When the comparison operation is completed, scroll down and review the **Comparison** report.

    - Review the number of findings per risk category for each risk level. Categories include **User Accounts**, **Privileges and Roles**, **Authorization Control**, **Data Encryption**, **Fine-Grained Access Control**, **Auditing**, and **Database Configuration**.
    - You can identify where the changes have occurred on your target database by viewing cells that contain the word **Modified**. The number represents the total count of new, remediated, and modified risks on the target database.
    - In the details table, you can view the risk level for each finding, the category to which the finding belongs, the finding name, and a description of what has changed on your target database. The Comparison Report column is important because it provides explanations of what is changed, added, or removed from the target database since the baseline report was generated.
    - Notice the **`PUBLIC: [ALTER ANY ROLE]` Modification Details(added)** notes for some of the findings. The changes introduced by granting the masking role to `DS$ADMIN` are also included.

    ![Security Assessment Comparison report top](images/sa-comparison-report-top.png "Security Assessment Comparison report top")
    ![Security Assessment Comparison report bottom](images/sa-comparison-report-bottom.png "Security Assessment Comparison report bottom")


## Task 8: Review high risk level findings from the dashboard

1. In the breadcrumb at the top of the page, click **Security Assessment** to return to the dashboard. Make sure your compartment is selected. Deselect **Include child compartments**.

2. In the **Risk Level** column, click **High** to view all the high risk findings.

    ![Security Assessment High Risk link](images/sa-high-risk-link.png "Security Assessment High Risk link")

3. On the **Overview** tab, review the **Risks by Category** chart. You can position your cursor over the percentage values to view the category name and count.

    ![Security Assessment High Risk findings for all target databases](images/sa-high-risk-findings-all-targets.png "Security Assessment High Risk findings for all target databases")

4. In the **Risk Details** section, expand **System Privileges Granted to PUBLIC**.
    - The **Remarks** section explains the risk and how you can mitigate it.
    - The **Target Databases** section lists the target databases to which the high risk applies. Notice that your target database is listed.

    ![Security Assessment System Privileges Granted to Public](images/sa-system-privileges-granted-to-public.png "Security Assessment System Privileges Granted to Public")

5. Click your target database name to view the details about the finding for your target database.

    - The finding includes your target database name, risk level, a summary about the risk, details on your target database, remarks that explain the risk and help you to mitigate it, and references.
    - The **Summary** section tells you how many grants to `PUBLIC` exist.
    - In the **Details** section, you can see that **`PUBLIC`** has **`ALTER ANY ROLE`** grant, which is what you did in task 5.
    - The **Remarks** section says **Privileges granted to PUBLIC are available to all users. This generally should include few, if any, system privileges since these will not be needed by ordinary users who are not administrators.**
    - The **References** section tells you the Security Technical Information Guide (STIG) rule number, which is **RULE SV-75925R1**.

    ![Security Assessment System Privileges Granted to PUBLIC Details](images/sa-system-privileges-granted-to-public-details.png "Security Assessment System Privileges Granted to PUBLIC Details")

6. To view the latest assessment for your target database, scroll down to the bottom of the page and click the **click here** link. You are returned to the latest security assessment.

    ![Click Here link to view latest security assessment](images/sa-click-here-link.png "Click Here link to view latest security assessment")




## Task 9: Add a schedule to save a security assessment for your target database every Sunday at 11:30 PM

1. In the breadcrumb at the top of the page, click **Security Assessment**.

2. Under **Related Resources** on the left, click **Schedules**.

    The **Schedules** page is displayed.

3. In the table, notice that a schedule already exists. Its type is LATEST. This is the default schedule that automatically runs a security assessment job on your target database once per week. You can update it and rename it, but you can't delete it.

    ![Default schedule for Security Assessment](images/sa-default-schedule.png "Default schedule for Security Assessment")

4. Click **Add Schedule**.

    The **Add Schedule To Save An Assessment** panel is displayed.

5. If the compartment shown at the top of the page is not yours, click **Change Compartment** and select your compartment.

6. From the **Target Database** drop-down list, select your target database.

7. In the **Schedule Name** box, enter **Sunday Security Assessment**.

8. From the **Compartment To Save The Assessments** drop-down list, select your compartment.

9. From the **Schedule Type** drop-down list, select **Weekly**.

10. From the **Every** drop-down list, select **Sunday**.

11. Click the **Time** box, scroll down, and select **11:30 PM**. You can manually enter the time too.

12. Click **Add Schedule**.

    ![Add Schedule to Save Assessments page](images/sa-add-schedule-to-save-an-assessment.png "Add Schedule to Save Assessments page")

    The **Schedule Details** page is displayed.

13. Notice that when the schedule is created, its status changes to **SUCCEEDED**. The schedule type is **SAVED**.

    ![Schedule Details page](images/sa-schedule-details-page.png "Schedule Details page")


## Task 10: View the history of all security assessments for all of your target databases

1. In the breadcrumb at the top of the page, click **Security Assessment**.

2. Under **Related Resources**, click **Assessment History**.

3. Under **List Scope** on the left, select your compartment. Optionally, select **Include child compartments**.

4. View the list of security assessments.

    - The table shows the target database name, the assessment name, whether the assessment is a baseline assessment, the date and time the assessment was created, the state of the assessment (for example, Succeeded), and the number of high, medium, low, advisory, and evaluate risk findings.
    - You can click on an assessment name to view it.
    - You can click **Save Latest Assessment As** and create a copy of the latest assessment for a selected target database.

    ![Assessment History page](images/sa-assessment-history-page.png "Assessment History page")


## Learn More

- [Security Assessment Overview](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-030B2A14-272F-49CF-80D2-5559C722E0FF)

## Acknowledgements

* **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
* **Last Updated By/Date** - Jody Glover, January 21, 2023
