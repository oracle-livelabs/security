# Get notified about SQL Firewall violations in Data Safe

## Introduction

In this lab you configure alerts and notifications in Data Safe to inform you when there is a SQL violation.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Configure the SQL Firewall policy to audit for violations
- Start the audit trail for Oracle Database 23ai
- Associate the SQL Firewall violations alert policy with your target database
- Obtain the OCID for SQL Firewall violations
- Create a notification
- Test the alert and notification


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`
- Prepared your environment
- Registered Oracle Database 23ai on a compute instance and granted the `SQL_Firewall` role to the Data Safe service account on Oracle Database 23ai
- Deployed a SQL Firewall policy in Data Safe


## Task 1: Configure the SQL Firewall policy to audit for violations

1. In Data Safe, click the name of your SQL Firewall policy.

2. Click **Deploy and enforce** to deploy the SQL Firewall policy for the `EMPLOYEESEARCH_PROD` user.

    The **Deploy SQL Firewall policy** dialog box is displayed.

3. For **Audit for violations**, select **On**. After you select this option, a message is displayed **Ensure the audit trail for the target database db23c-hol-... is started."
    
4. Click **Deploy and enforce**.


## Task 2: Start the audit trail for Oracle Database 23ai

1. In the breadcrumb at the top of the page, click **Security center**.

2. Click **Activity auditing**.

3. Under **Related resources**, click **Audit trails**.

4. Click your target database name.

5. Click **Start**. 

    The **Start audit trail: UNIFIED_AUDIT_TRAIL** dialog box is displayed.

6. Set the start date to the beginning of the current month.

7. Click **Start**.

8. Wait for the status of the collection state to change from **STARTING** to **COLLECTING** to **IDLE**. It takes a minute.


## Task 3: Associate the SQL Firewall violations alert policy with your target database

1. In the breadcrumb at the top of the page, click **Security center**.

2. Click **Alerts**.

3. Under **Related resources**, click **Target-policy associations**.

4. Click **Apply policy**. 

    The **Apply and enable alert policy to target databases** panel is displayed.

5. Select **Selected targets only (up to 10)** and select your 23ai target.

6. Select **Selected policies only** and select **SQL Firewall violations**.

7. Click **Apply policy**.

8. When ok, click **Close**.


## Task 4: Obtain the OCID for SQL Firewall violations

1. Navigate to the list of predefined Data Safe alerts. 

2. Click **SQL Firewall violations**.

3. Copy the OCID to the clipboard. Keep this handy because you need it in the next task.


## Task 5: Create a notification

1. In breadcrumb at the top of the page, click **Target-policy associations**. 

2. Click the **Notifications** tab.

3. Click **Create notification**.

    The **Create notification** panel is displayed.

4. Click **Advanced event notificaiton**.

5. For rule name, enter **SQLFWViolationAlert**. 

6. For event type, select **Alert Generated**.

7. Click **+ Another condition**.

8. For condition, select **Attribute**. 

9. For attribute name, select **policyId**.

10. For attribute values, paste the OCID for SQL Firewall violations. You copied this OCID to the clipboard in the previous task. It should look similar to ocid1.datasafealertpolicy.oc1.iad...). Press **Enter**.

11. For the topic name, enter **SQLFWViolationAlert**.

12. For protocol, select **Email**.

13. For subscription, enter your email address.

14. Click **Create notification**.

    An event called **SQLFWViolationAlert** is added to the **Notifications** tab.

15. In your email application, open the email from Oracle and then click the confirmation link to confirm your email address.

16. (Optional) Click the name of the event on the **Notifications** tab. Notice that you are brought to the Events Service in Oracle Cloud Infrastructure. If you need to edit the event, you can click **Edit Rule**. Click the browser's back button to return to Data Safe.


## Task 6: Test the alert and notification

1. Return to the terminal window on your remote desktop (host #1).

2. In the terminal window, rerun the following script that uses SQL*Plus to query sensitive columns in the `EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES` table.

    ```text
    <copy>./sqlfw_select_sensitive_data.sh</copy>
    ```

3. On the SQL Firewall landing page in Data Safe, verify that a context violation is raised because SQL*Plus is not in the allowed OS program allowlist.

4. On the Alerts page in Data Safe, verify that an alert is generated.

5. In your email application, verify that you received a notification.


