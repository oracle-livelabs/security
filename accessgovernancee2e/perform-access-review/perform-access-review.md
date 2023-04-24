# Perform access review task

## Introduction

**Access reviews** can be carried out from the **Oracle Access Governance** console by users with the following roles, which are based on data attributes derived from the connected system:

* **User** (review access assigned to me/self)
* **Manager** (review access assigned to users in my team)
* **Owner** (review access assigned to users over resources I own)

Based on the workflow setup in the first lab **Create Access Review Campaign**, **Oracle Access Governance** distributes access reviews to corresponding reviewers across the selected organization. In this lab, **employee user** is the first-level reviewer, and **user manager** is the second-level reviewer. By leveraging the **prescriptive analytics** and **insights** embedded in access reviews, employees and user managers can make informed decisions about access entitlements. Users can also bulk approve low-risk items based on **AI/ML recommendations** from the system. 
* Estimated Time: 20 minutes
* Persona: Employee and User Manager

Watch the video below for a quick walk-through of the lab.
[Perform Access Review](videohub:1_jteb4r9y)

### Objectives

In this lab, you will:
* Accept or revoke the **access review task** assigned to me from the **certification campaign** as an **employee user**
* Accept or revoke the **access review task** assigned to me from the **certification campaign** as a **user manager**

## Task 1: Login Oracle Access Governance as Employee User

1. If you are still login as a user from the previous lab, please make sure you log out and log in again. Ensure you have **default** identity domain selected.
2. Log in to **Oracle Access Governance** as an **employee user - Mark Hernandez** with the username and password mentioned below.

    **Username:**
    ```
    <copy>mhernandez</copy>
    ```

    **Password:**
    ```
    <copy>Oracl@123456</copy>
    ```

	![Access Governance Login](images/user-ag-logon.png)
3. You should see the **Oracle Access Governance** main dashboard. **Please note data on Oracle Access Governance main dashboard in your assigned system might be different from LiveLabs step screenshot.**
  ![Access Governance Homepage](images/user-ag-homepage.png)

## Task 2: Perform access review task (Employee User Review)

1. Select one of the Access Reviews Tasks tiles. For this lab, click on the **Select** button of the tile **I'm feeling ambitious, let's review all...**
  ![Access Review Tasks](images/user-ag-homepage.png)
2. You will see a list of **access review tasks** assigned to you from the **access review campaigns** scheduled from the first lab. You may do a search for the access review tasks created from the first lab based on the **Review source** aka **Campaign name** value in the middle column of the table, which you note down in **Lab 1**. In case the **campaign** from the first lab has not been started yet, you can also pick a **review task** from a pre-configured campaign. In that case, select the access review tasks with **Review source** as **...Organization Review Example**, for example, **Organization Access Review Example**. To review the access, please follow the below steps:
    
    - Check review task information such as **Identity name**, **Assignment name**, **Manager name**, **Assignment type**, and **Due days** for which the task is raised.
    - Filter the review tasks list by selecting **Recommend Accept** or **Recommend Review**. Based on **Prescriptive Analytics** powered by ML algorithm, **Oracle Access Governance** recommends action for each review item based on calculated risk scores and analytics. 
    - You may choose to accept the review item by clicking on **Accept** in the **Actions** column. This action is suggested for **Recommend Accept** items only. 
    - In case you want to view the analytic insights, especially for items flagged as **Recommend Review**, you may click on the **View** in **Insights** column to review a task.
   ![Access Review Tasks Select Review](images/user-select-review-recommended.png)
  Insights include:
    - AI/ ML driven insights with **alignment score** uses AI/ML **peer group analysis** conducted by **Oracle Access Governance** to recommend this item for **Review** or **Accept** 
    - Description of the review task
    - Access review trail
    - Recent changes in user’s profile
    ![Access Review Tasks Insights AI/ML](images/user-review-insight-analytics.png)
3. Decide (Accept or Revoke):  Select all the access reviews. Click on the **Accept** button under **Actions** column. Enter **justification** for why you accept all the access review items and then click on **Submit**. 

  **Note:** In this lab example, we accept all the *Access Review* taks. However you can review all insights and select to **accept** or **revoke** this access privilege.  **Accept** the review task item will trigger the **current review task** assigned to the second-level reviewer, which is the **user manager** in the next task. On the contrary, **revoke** access by an **employee user** will not trigger next-level access review by the **manager user**.  

  ![User select review recommend](images/user-select-review-recommended.png)
 
  ![Bulk accept justification](images/user-bulk-accept-justification.png)

## Task 3: Login Oracle Access Governance as User Manager

1. If you are still login as a user from the previous lab, please make sure you log out and log in again. Ensure you have **Default** identity domain selected.
2. Log in to **Oracle Access Governance** as a **Manager User - Harlan Bullard** with the username and password mentioned below.

  **Username:**
    ```
    <copy>harlan.bullard</copy>
    ```

  **Password:**
    ```
    <copy>Oracl@123456</copy>
    ```

	![Manager Access Governance Login](images/manager-ag-logon.png)

3. You should see the **Oracle Access Governance** main dashboard. **Please note data on Oracle Access Governance main dashboard in your assigned system might be different from LiveLabs step screenshot.**
  ![Manager Access Governance Homepage](images/manager-ag-homepage.png)

## Task 4: Perform access review task (User Manager Review)

1. In this lab, the user manager is the second-level reviewer. As user manager, you see the access review items your employee users accepted in the previous task. Click on the **Select** button of the tile **I'm feeling ambitious, let's review all...**. As an alternative, you can also click the **Select** button for the tile **I am busy, let's just review...** to review **high risk** items only. 
  ![Manager open menu review](images/manager-open-menu-manager-review.png)
2. You will see a list of access review tasks assigned to you from access review campaigns or from your employee's access review results which you are the second-level reviewer as manager. Search the review task triggered by **Task 2: Perform access review task (Employee User Review)** by **Identity name** and **Assignment name**. You may also narrow down the list by searching the access review tasks based on the **Review source** aka **Campaign name** value in the middle column of the table. For review tasks:
    
    - Check review task information such as **Identity name**, **Assignment name**, **Manager name**, **Assignment type**, and **Due days** for which the task is raised.
    - Filter the review tasks list by selecting **Recommend Accept** or **Recommend Review**. Based on **Prescriptive Analytics** powered by **AI/ML algorithm**, **Oracle Access Governance** recommends action for each review item based on calculated risk scores and analytics.
    - You may choose to accept or revoke the review item by clicking on **Accept** or **Revoke** in the **Actions** column. The **Accept** action is suggested for **Recommend Accept** items only.
    - In case you want to view the analytic insights, especially for item flagged as **Recommend Review**, you may click on the **View** in **Insights** column to review a task.
  ![Access Review Manager](images/manager-access-review-manager.png)
  Insights include:
    - AI/ ML driven insights with **alignment score** uses AI/ML **peer group analysis** conducted by **Oracle Access Governance** to recommend this item for **Review** or **Accept** 
    - Description of the review task
    - Access review trail, you should see the **justification** entered by your employee self-reviewer in the previous task. 
    - Recent changes in user’s profile
  ![AI/ML Insights](images/manager-access-review-insights-manager.png)
3. Decide (Accept or Revoke): Select the *Access Review* for the user - *Mark Hernandez* with *Assignment Type* as *Account* and **Revoke** this access privilege. In this lab, you may pick one access review with **Recommend Review**, view the detail, and **Revoke** it, which will trigger the auto-remediation process in the **Oracle Access Governance** system. 

4. During this lab, you have navigated the **Oracle Access Governance** console to select **access review tasks** assigned to you as an **employee** and **manager user**, view **prescriptive analytics** and **recommendation** proposed by **Oracle Access Governance**, and make informed decisions **Accept** or **Revoke** for review tasks based on **peer group analysis** and **insights**. 

## Task 5: Login Oracle Identity Governance as System Administrator 

1. Sign in to Identity Self Service console. Open a browser tab using the below URL to access OIG Identity Console.

   **URL:**
    ```
      <copy>http://oimhost.us.oracle.com:14000/identity</copy>
     ```
   **Username:**
     ```
      <copy>xelsysadm</copy>
     ```
   **Password:**
     ```
      <copy>Welcome1</copy>
      ```

  ![OIG Login Page](images/oig-logon.png)
2. You should see the **Oracle Identity Governance** main dashboard. Click on **Manage -> Users**
  ![OIG Homepage](images/oig-homepage.png)

3. Click Users. Search for User **Mark Hernandez**.Note **Figma** application entitlements present for the user. 

![Access Governance Homepage](images/initial-user-details.png)

4. Click on **Self Service -> Provisioning Tasks -> Manual Fulfillment** . The Manual Fulfillment page is displayed. Notice that the Manual Fulfillment request for the user is displayed is displayed.
![Provisioning tasks list](images/provisioning-tasks.png)
5. Click on the  request. The request details page displays a detailed view of the request in the Details section, Content section and the Cart Items section. It allows complete management of the listed task. Click on Complete.
![Manual Fulfillment requests](images/manual-fulfillment.png)
Now remediation is completed with approval and manual provisioning.
![Complete Manual Fulfillment request](images/complete-manual-fulfillment.png)
6. Go back to Self Service. Click Manage -> Users. Search for user **Mark Hernandez** similar to **Task 5: Step 2**
7. Notice the **Figma** application entitlements have been removed for the user **Mark Hernandez** 
![User Details OIG](images/user-details.png)

    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Perform Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/aarrs/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Author** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Contributors** - Edward Lu 
* **Last Updated By/Date** - Anbu Anbarasu, Cloud Platform COE, January 2023
