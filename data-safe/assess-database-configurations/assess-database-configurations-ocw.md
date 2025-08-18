# Assess database configurations

## Introduction

Security Assessment helps you assess the security of your database configurations. It analyzes database configurations, user accounts, and security controls, and then reports the findings with recommendations for remediation activities that follow best practices to reduce or mitigate risk. 

Oracle Data Safe automatically creates a security assessment of your target database during registration. This assessment is referred to as the *latest assessment* and is automatically updated on a weekly basis. All assessments are stored in the Assessment History. You can analyze assessment data across all your target databases and for each target database. You can monitor security drift on your target databases by comparing the latest assessment to a baseline or to another assessment.

In this lab, you explore Security Assessment.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

- View the latest security assessment for your target database
- Set the latest assessment as the baseline assessment
- Create a risk on the target database
- Refresh the latest security assessment and analyze the results
- Compare your assessment with the baseline

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- Access to or prepared an environment for this workshop
- Access to a registered target database


### Assumptions

- Your data values might be different than those shown in the screenshots.
- Please ignore the dates for the data and database names. Screenshots are taken at various times and may differ between labs and within labs.


## Task 1: View the latest security assessment for your target database

1. Under **Security center**, click **Security assessment**.

2. Under **List scope**, select your compartment. Deselect **Include child compartments**.

    The overview page shows statistics for your target database.

3. On the **Target summary** tab, locate the line that has your target database, and click **View report**.

    The latest security assessment for your target database is displayed. Notice that **Latest assessment for target database** is displayed at the top of the page.

4. Review the top 5 common security controls that Oracle considers to be the most important to the security of your target databases. You can click the links to quickly navigate to more detail below.

    ![Top 5 common controls](images/top-5-common-controls.png "Top 5 common controls")

5. Review the information in the table.

    - This table compares the number of findings for each category in the report and counts the number of findings per risk level (**High risk**, **Medium risk**, **Low risk**, **Advisory**, **Evaluate**, **Pass**, and **Deferred**).
    - These values help you to identify areas that need attention.

    ![Latest security assessment assessment summary tab](images/latest-sa-assessment-summary-tab.png "Latest security assessment assessment summary tab")

6. Scroll down and view the **Assessment details** section.

    - This section shows you all the findings for each risk category.
    - Risks are color-coded to help you easily identify categories that have high risk findings (red).
    - The high risk findings listed under **Privileges and Roles** were introduced when you ran the SQL script to populate your target database with sample data.

    ![Latest Security Assessment Assessment details section](images/latest-sa-assessment-details-section.png "Latest Security Assessment Assessment details section")

7. Under **Filters by risks** on the left, notice that you can select the risk levels that you want displayed. Also notice on the left that you can filter by references.

    ![Security Assessment filters](images/sa-filters.png "Security Assessment filters")

8. On the right, expand categories and review the findings.

    - Each finding shows you the status (risk level), a summary of the finding, details about the finding, remarks to help you to mitigate the risk, and references - whether a finding is recommended by the Center for Internet Security (**CIS**), European Union's General Data Protection Regulation (**EU GDPR**), Security Technical Implementation Guide (**DISA STIG**), and/or **Oracle best practices**. These references make it easy for you to identify the recommended security controls.
    - In the example below, the **Transparent Data Encryption** finding has three references: **Oracle Best Practices**, **DISA STIG**, and **GDPR**.

    ![Transparent Data Encryption finding](images/transparent-data-encryption-finding.png "Transparent Data Encryption finding")


## Task 2: Set the latest assessment as the baseline assessment

A baseline assessment shows you data for all your target databases in a selected compartment at a given point in time. However, because we are only dealing with one target database in your compartment, the baseline assessment shows data for only one target database. Let’s assume that we are okay with the current configuration and we want to set it as our baseline. New assessments are then automatically compared to the baseline.

1. At the top of the page, click **Set as baseline**.

    The **Set as baseline?** dialog box is displayed.

    ![Set as baseline dialog box](images/set-as-baseline-dialog-box.png "Set as baseline dialog box")

2. Click **Yes** to confirm that you want to set these findings as the baseline.

3. *Important! Stay on the page until the message **Baseline has been set** is displayed.*

    ![Security Assessment Baseline has been set message](images/sa-baseline-has-been-set-message.png "Security Assessment Baseline has been set message")


## Task 3: Create a risk on the target database

In this task, you manually create a new configuration risk on your database by issuing a `GRANT` command. Later, when you refresh the latest security assessment, you can compare assessments.

1. Access the SQL worksheet in Database Actions. If your session has expired, sign in again as the `ADMIN` user.

2. If needed, clear the worksheet and the **Script Output** tab.

3. On the worksheet, enter the following command:

    ```
    <copy>grant ALTER ANY ROLE to PUBLIC;</copy>
    ```

4. On the toolbar, click the **Run Statement** button (green circle with white arrow).

    ![Run Statement button](images/run-statement-button.png "Run Statement button")


## Task 4: Refresh the latest security assessment and analyze the results

1. Return to the browser tab for Oracle Data Safe.

2. At the top of the latest security assessment, click **Refresh now** to get the latest data.

    The **Refresh now** panel is displayed.

3. Leave the default name as is, and click **Refresh now**. Wait for the status to read as **SUCCEEDED**.

    - This action updates the data in the latest security assessment for your target database and also saves a copy of the assessment to the Assessment History.
    - The refresh operation takes about one minute.

    ![Security Assessment Refresh now panel](images/sa-refresh-now-panel.png "Security Assessment Refresh now panel")

4. Click the **Assessment information** tab. Notice that the assessment date and time is right now, and that **Complies with baseline** is equal to **No**.

    ![Security Assessment Assessed on right now](images/sa-assessed-on-right-now.png "Security Assessment assessed on right now")

5. Scroll down and expand **System Privileges Granted to PUBLIC**.

    - This is a high risk finding.
    - In the **Details** section, you can see that the grant you made in the previous task is identified.

    ![System Privileges Granted to PUBLIC finding](images/system-privileges-granted-to-public.png "System Privileges Granted to PUBLIC finding")

## Task 5: Compare your assessment with the baseline

1. With the latest security assessment displayed, under **Resources** on the left, click **Compare with baseline**. 

2. From the **Baseline** drop-down list, select your baseline. Oracle Data Safe automatically begins processing the comparison. 

    If you navigated away from the latest security assessment, you can return to it by doing the following: Click **Security assessment** in the breadcrumb. Click the **Target summary** tab. Click **View report** for your target database.

3. When the comparison operation is completed, scroll down the page to the **Comparison with baseline** section and review the information.

    - Review the number of findings per risk category for each risk level. Categories include **User accounts**, **Privileges and roles**, **Authorization control**, **Data encryption**, **Fine-grained access control**, **Auditing**, and **Database configuration**.
    - You can identify where the changes have occurred on your target database by viewing cells that contain the word **Modified**. The number represents the total count of new, remediated, and modified risks on the target database.
    - In the details table, you can view the risk level for each finding, the category to which the finding belongs, the finding name, and a description of what has changed on your target database. The Comparison Report column is important because it explains what is changed, added, or removed from the target database since the baseline report was generated.
    - Notice that the change you made is noted in the **Comparison report** column.

    ![Security Assessment Comparison report top](images/sa-comparison-report-top3.png "Security Assessment Comparison report top")
    ![Security Assessment Comparison report bottom](images/sa-comparison-report-bottom3.png "Security Assessment Comparison report bottom")


You may now **proceed to the next lab**.


## Learn More

- [Security Assessment Overview](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=UDSCS-GUID-030B2A14-272F-49CF-80D2-5559C722E0FF)

## Acknowledgements

* **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
* **Last Updated By/Date** - Jody Glover, August 1, 2025
