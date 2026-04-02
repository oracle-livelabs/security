# Get notified about security drift on your target databases by setting up notifications in Oracle Data Safe

In this lab, you set up contextual notifications in Oracle Data Safe to notify you via email when there is security drift on your target database.

Estimated Lab Time: 20 minutes

## Objectives

In this lab, you will:

- Review the latest user assessment
- Set the latest user assessment as the baseline
- Create a notification
- Generate activity on the target database
- Refresh the latest user assessment and analyze the results
- Generate a Comparison report for User Assessment
- Review your email notification

### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console
- *Administrator* permissions in your tenancy
- Prepared your environment for this workshop (see [Prepare Your Environment](?lab=prepare-environment))
- Registered your target database with Oracle Data Safe (see [Register an Autonomous AI Database with Oracle Data Safe](?lab=register-autonomous-database))
- A valid email address

### Assumptions

- Your data values might be different than those shown in the screenshots.


## Task 1: Review the latest user assessment

1. From the navigation menu in Oracle Cloud Infrastructure, select **Oracle AI Database**, and then **Data Safe - Database Security**.

2. Under **Security center**, click **User assessment**.

3. Click the **Target summary** tab.

4. In the **Last assessed time** column, click **View report** to view the latest user assessment.

5. Review the charts on the **Overview** tab. 

    ![Latest user assessment charts1](images/latest-ua-charts1.png "Latest user assessment charts1")

    ![Latest user assessment charts2](images/latest-ua-charts2.png "Latest user assessment charts2")

6. Scroll down and review the information in the **User Details** section.

    ![Latest user assessment User Details section](images/latest-ua-user-details-section.png "Latest user assessment User Details section")


## Task 2: Set the latest user assessment as the baseline

1. While you are still viewing the latest user assessment, click **Set as baseline**.

    The **Set as baseline?** dialog box is displayed asking if you are sure.

2. Click **Yes**, and remain on the page until the following message is displayed:

     `Baseline has been set.`

3. Click **View history**. Notice that in your compartment you have a baseline assessment.

4. Click **Close**.


## Task 3: Create a notification

1. In the breadcrumb at the top of the page, click **User assessment**.

2. Click the **Notifications** tab.

3. Click **Create notification**.

    The **Create notification** panel is displayed.

4. Click **Advanced event notification**.

5. In the **Event rule** section, do the following: In the **Rule name** box, enter **Security Drift**. From the **Event type** drop-down, select **User Assessment Drift From Baseline**.

7. In the **Topics and subscriptions** section, leave **Create new topic** selected. Select your compartment if needed. In the **Topic name** box, enter **security-drift**. In the **Email address** box, enter your email address.


   ![Create notifications panel1](images/create-notifications-panel1.png "Create notifications panel1")
   ![Create notifications panel2](images/create-notifications-panel2.png "Create notifications panel2")

8. Click **Create notification**.

    An event is added on the **Notifications** tab.

    ![Notification added](images/notification-added.png "Notification added")

9. Open your email application and locate the email from Oracle. In the email, click **Confirm subscription**. 

    A **Subscription confirmed** page is displayed in the browser.



## Task 4: Generate activity on your target database

In this task, you create a user on your target database with the `PDB_DBA` role.

1. Access the SQL worksheet in Database Actions. If your session has expired, sign in again as the `ADMIN` user.

2. If needed, clear the worksheet and the **Script Output** tab.

3. On the worksheet, enter the following command. Substitute `<enter a password>` with your own password.

    ```
    <copy>CREATE USER joe_smith identified by <enter a password>;
    GRANT PDB_DBA to joe_smith;</copy>
    ```

4. On the toolbar, click the **Run Script** button.

    ![Run Script button](images/run-script.png "Run Script button")


## Task 5: Refresh the latest user assessment and analyze the results

1. Return to the browser tab for Oracle Cloud Infrastructure. You last left off on the **Notifications** tab on the **User assessment** page.

2. Click the **Target summary** tab.

3. Click **View Report** to view the latest user assessement.

4. At the top of the latest user assessment, click **Refresh Now** to get the latest data.

    The **Refresh now** panel is displayed.

7. Leave the default assessment name as is, and click **Refresh now**. Wait for the status to read as **SUCCEEDED**. 

    - This action updates the data in the latest user assessment for your target database and also saves a copy of the assessment in the Assessment history.
    - The refresh operation takes about one minute.

8. Click **View history** and verify that there is another assessment listed.

9. Compare the risk values between the baseline assessment and the new assessment that you just generated. Are there any differences?

    ![Assessment History after](images/assessment-history-after.png "Assessment History after")

10. Click **Close**.


## Task 6: Generate a Comparison report for User Assessment

1. With the latest user assessment displayed, under **Resources** on the left, click **Compare with baseline**. Oracle Data Safe automatically begins processing the comparison.

2. When the comparison operation is completed, review the **Comparison** report. 

    ![Comparison report](images/comparison-report.png "Comparison report")

3. Click **Open details** to view more information.

    ![Comparison Details panel](images/comparison-details-panel.png "Comparison Details panel")

4. Click **Close**.


## Task 7: Review your email notification

1. Open your email application.

2. Locate and open the email notification from Oracle. The message contains text similar to the following:

    ```text
    <copy>{
    "eventType" : "com.oraclecloud.datasafe.userassessmentdriftfrombaseline",
    "cloudEventsVersion" : "0.1",
    "eventTypeVersion" : "2.0",
    "source" : "DataSafe",
    "eventTime" : "2025-06-05T16:10:25Z",
    "contentType" : "application/json",
    "data" : {
     "compartmentId" : "ocid1.compartment.oc1..aaaaaa...",
     "compartmentName" : "datasafe_livelabs",
     "resourceName" : "UA_1748009336777",
     "resourceId" : "ocid1.datasafeuserassessment.oc1.iad.abuwclj...",
     "availabilityDomain" : "ad2",
     "freeformTags" : { },
     "definedTags" : { },
     "additionalDetails" : {
      "targetName" : "ATP102",
      "comparedWith" : "ocid1.datasafeuserassessment.oc1.iad.amaa..."
    }
  },
  "eventID" : "4e93466f-b1cd-4f71-9d9c-0435d6ac5be9",
  "extensions" : {
    "compartmentId" : "ocid1.compartment.oc1..aaaaaaaajs..."
  }
}


    --
    You are receiving notifications as a subscriber to the topic: security-drift (Topic OCID: ocid1.onstopic.oc1.iad.amaaaaaaknuwt...). 
    To stop receiving notifications from this topic, unsubscribe: https://cell1.notification.us-ashburn-1.oci.oraclecloud.com/20181201/subscriptions/ocid1.onssubscription.oc1.iad.aaaaaaaa.../unsubscription?token=YVpsOE4...==&protocol=EMAIL 

    Please do not reply directly to this email. If you have any questions or comments regarding this email, contact your account administrator.

    Oracle Corporation - Worldwide Headquarters
    2300 Oracle Way, Austin, Texas 78741 USA
    </copy>
    ```

## Learn More
- [Event Types for Oracle Data Safe](https://www.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/data-safe&id=ADMDS-GUID-A8D65EBC-9A53-43EC-B335-0DA0E2F9CDC8)
- [Events in Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/Events/home.htm)


## Acknowledgements
- **Author** - Jody Glover, Consulting User Assistance Developer, Database Development
- **Contributors** - Bettina Schaeumer
- **Last Updated By/Date** - Jody Glover, October 20, 2025