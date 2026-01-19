# Assess database configurations

## Introduction

Security Assessment helps you assess the security of your database configurations. It analyzes database configurations, user accounts, and security controls, and then reports the findings with recommendations for remediation activities that follow best practices to reduce or mitigate risk. 

Oracle Data Safe automatically creates a security assessment of your target database during registration. This assessment is referred to as the *latest assessment* and is automatically updated on a weekly basis. All assessments are stored in the Assessment History. You can analyze assessment data across all your target databases and for each target database. You can monitor security drift on your target databases by comparing the latest assessment to a baseline or to another assessment.

In this lab, you explore Security Assessment.

Estimated Time: 20 minutes

### Objectives

In this lab, you will:

- View the overview page for Security Assessment
- View the latest security assessment for your target database
- Adjust the risk level of a risk finding
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


## Task 1: View the overview page for Security Assessment

1. On the left, select **Security assessment**.

2. Next to **Applied filters**, select your compartment. Deselect **Include child compartments**, and then select **Apply filter**. From here on, we will just say *Select your compartment without child compartments* to simplify the instructions.

3. On the **Overview** tab, review the charts.

    - The **Risk level** chart shows you a percentage breakdown of the different risk levels (High, Medium, Low, Advisory, and Evaluate) across all target databases in the selected compartment(s).
    - The **Risks by category** chart shows you a percentage breakdown of the different risk categories (User accounts, Privileges and roles, Authorization control, Data encryption, Fine-grained access, Auditing, and Database configurations) across target databases in the selected compartment(s).
    - The **Top 5 common security controls** chart shows a bar graph of the number of target databases at each risk level for each of the top five common controls. The top five common controls are the five security controls that Oracle considers the most important to the security of your target databases. Clicking on any of the bars will show you the list of target databases associated with the selected data.

     ![Security assessment overview charts for all targets](images/sa_overview_charts.png "Security assessment overview charts for all targets")


4. Select the **Risk summary** tab and review the information. If needed, select your compartment without child compartments.

    - The **Risk summary** tab shows you how much risk you have across all target databases in the specified compartment(s).
    - You can compare the number of high, medium, low, advisory, and evaluate risk findings across all target databases, and view which risk categories have the greatest numbers.
    - Risk categories include Target databases, User accounts, Privileges and roles, Authorization control, Fine-grained access control, Data encryption, Auditing, and Database configuration.

    ![Security assessment risk summary tab](images/sa-risk-summary-tab.png "Security assessment risk summary tab")


5. Select the **Target summary** tab and review the information. If needed, select your compartment without child compartments.

    - The **Target summary** tab shows you the security posture of each target database.
    - You can view the number of high, medium, low, advisory, and evaluate risk findings for each target database.
    - You can view the lastest assessment date and find out if the latest assessment deviates from a baseline (if one is set).
    - You can access the latest assessment report for each target database.

    ![Security assessment target summary tab](images/sa-target-summary-tab.png "Security assessment target summary tab")

## Task 2: View the latest security assessment for your target database

1. On the **Target summary** tab, select the name of your database.

    The latest security assessment for your target database is displayed. Notice that **Latest security assessment risk details page** is displayed at the top of the page 

2. On the **Details** tab, review the details about the security assessment itself.

    Details include the assessment OCID, compartment to which the assessment was saved, date and time the assessment was created, database version, the assessed date and time, target database name, schedule, name of the baseline assessment (if one is set), whether the assessment complies with the baseline (Yes, No, or No baseline set), assessment template name, and template baseline name.

3. Select the **Assessment summary** tab and review the top 5 common security controls that Oracle considers to be the most important to the security of your target databases. 

    ![Top 5 common controls](images/top-5-common-controls.png "Top 5 common controls")

4. Scroll down and review the **Summary** table.

    - This table compares the number of findings for each category in the report and counts the number of findings per risk level (**High risk**, **Medium risk**, **Low risk**, **Advisory**, **Evaluate**, **Pass**, and **Deferred**).
    - These values help you to identify areas that need attention.

    ![Latest security assessment assessment summary](images/latest-sa-assessment-summary.png "Latest security assessment assessment summary")

5. Select the **Assessment details** tab.

    - This tab shows you all the findings for each risk category.
    - Risks are color-coded to help you easily identify categories that have high risk findings (red).
    - The high risk findings listed under **Privileges and Roles** were introduced when you ran the SQL script to populate your target database with sample data.

    ![Latest Security Assessment Assessment details section](images/latest-sa-assessment-details-section.png "Latest Security Assessment Assessment details section")

6. At the top, select the **Search and Filter**, and select **Risk**. Notice that you can select the risk levels that you want to display. Also notice that you can filter by finding, category, and documentation. Select the **X** in the box to clear the filter.

    ![Security Assessment filters](images/sa-filters.png "Security Assessment filters")

7. On the right, expand the findings and review the information.

    - Each finding shows you the risk level, finding name, finding category, documentation links, an overview of the finding, a summary of the finding, and Oracle recommended practices. It also includes remarks to help you to mitigate the risk and references for Center for Internet Security (**CIS**), European Union's General Data Protection Regulation (**EU GDPR**), Security Technical Implementation Guide (**DISA STIG**), and/or **Oracle best practices**. These references make it easy for you to identify the recommended security controls.
    - In the example below, the **Transparent Data Encryption** finding has three references: **DISA STIG**, **EU GDPR**, and **Oracle recommended practices**, 

    ![Transparent Data Encryption finding](images/transparent-data-encryption-finding.png "Transparent Data Encryption finding")

## Task 3: Adjust the risk level of a risk finding

You can defer or change the risk level of a risk finding. In this task, defer the **Users with Unlimited Concurrent Sessions** risk finding.

1. Select the three dots for the **Users with Unlimited Concurrent Sessions** finding.

   ![Adjust risk icon](images/users-with-unlimited-concurrent-sessionsX.png "Adjust risk icon")

2. In the **Update risk for finding** panel, leave **Defer risk** selected. Optionally, enter a justification and set an expiration date. Select **Save**.

    Setting an expiration date is optional. Upon expiry, the next assessment resumes evaluating the finding and displays as found. With no expiration date, the risk finding is deferred indefinitely. 

   ![Update risk for finding panel](images/update-risk-for-findingX.png "Update risk for finding panel")

3. Notice that the risk finding is recategorized in the **Assessment details** section.

   ![Deferred risk finding](images/deferred-risk-finding.png "Deferred risk finding")


## Task 4: Set the latest assessment as the baseline assessment

A baseline assessment shows you data for all your target databases in a selected compartment at a given point in time. However, because we are only dealing with one target database in your compartment, the baseline assessment shows data for only one target database. Let’s assume that we are okay with the current configuration and we want to set it as our baseline. New assessments are then automatically compared to the baseline.

1. At the top of the page, select **Set as baseline**.

    The **Set as baseline?** dialog box appears.

    ![Set as baseline dialog box](images/set-as-baseline-dialog-box.png "Set as baseline dialog box")

2. Select **Yes** to confirm that you want to set these findings as the baseline.

3. *Important! Stay on the page until the message **Baseline has been set** is displayed.*

    ![Security Assessment Baseline has been set message](images/sa-baseline-has-been-set-message.png "Security Assessment Baseline has been set message")


## Task 5: Create a risk on the target database

In this task, you manually create a new configuration risk on your database by issuing a `GRANT` command. Later, when you refresh the latest security assessment, you can compare assessments.

1. Access the SQL worksheet in Database Actions. If your session has expired, sign in again as the `ADMIN` user.

2. If needed, clear the worksheet and the **Script Output** tab.

3. On the worksheet, enter the following command:

    ```
    <copy>grant ALTER ANY ROLE to PUBLIC;</copy>
    ```

4. On the toolbar, select the **Run Statement** button (green circle with white arrow).

    ![Run Statement button](images/run-statement-button.png "Run Statement button")


## Task 6: Refresh the latest security assessment and analyze the results

1. Return to the browser tab for Oracle Data Safe.

2. From the **Actions** menu, select **Refresh now** to get the latest data.

    The **Refresh now** panel appears.

3. Leave the default name as is, and select **Refresh now**. Wait for the status to read as **Succeeded**.

    - This action updates the data in the latest security assessment for your target database and also saves a copy of the assessment to the Assessment History.
    - The refresh operation takes about one minute.

    ![Security Assessment Refresh now panel](images/sa-refresh-now-panel.png "Security Assessment Refresh now panel")

4. On the **Details** tab, notice that the assessed date and time is right now, and that **Complies with baseline** is equal to **No**.

    ![Security Assessment Assessed on right now](images/sa-assessed-on-right-nowX.png "Security Assessment assessed on right now")

5. Select the **Assessment details** tab and expand **System Privileges Granted to PUBLIC**.

    - This is a high risk finding.
    - In the **Summary** section, you can see that the grant you made in the previous task is identified.

    ![System Privileges Granted to PUBLIC finding](images/system-privileges-granted-to-publicX.png "System Privileges Granted to PUBLIC finding")

## Task 7: Compare your assessment with the baseline

1. Select the **Compare with baseline** tab.

2. From the **Baseline** drop-down list, select your baseline. Oracle Data Safe automatically begins processing the comparison. 

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
* **Last Updated By/Date** - Jody Glover, November 12, 2025
