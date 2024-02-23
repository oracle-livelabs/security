# Create access review campaign – self and user manager review

## Introduction

As a user with a **campaign administrator** role, you can create access review campaigns from the **Oracle Access Governance** console. You can define selection criteria for access reviews based on **users** (who has access), **applications** (what are they accessing), **permissions** (which permissions), and **roles** (which roles).

* Estimated Time: 15 minutes
* Persona: Campaign Administrator

Watch the video below for a quick walk-through of the lab.
[Create Access Review Campaign](videohub:1_9s3mt0qx)

### Objectives

In this lab, you will:
* Create **access review campaign** for self and user manager review
* Define **reviewers' workflow**
* Run now or schedule an **access review campaign**


### Prerequisites
This lab assumes you have:
- A valid Oracle OCI tenancy, with OCI administrator privileges.


## Task 1: Create One-Level Approval Workflow


1. From your browser, navigate to the Oracle Access Governance Console using the URL specified in *Lab 5: Task 1: Step 4*


2. Enter **Oracle Access Governance Administrator** username and password (Pamela Green)

    **Username:**
    ```
    <copy>pamela.green</copy>
    ```

    **Password:**
    
    The password you have set for the user in *Lab 1: Task 2: Step 5*


  You will be navigated to the home page of your Oracle Access Governance Console.

3. Navigate to **Access Controls -> Approval Workflow**

  ![Access Governance Homepage](images/navigate-to-approval-workflow.png)

4. Click on **Create Approval Workflow**

  ![Access Governance Homepage](images/create-workflow.png)

5. Click **Add**

   ![Access Governance Homepage](images/click-add.png)
  

6. Under **Add a new approval** 
    - Which type of approval? : select Custom User 
    - Which user? : Pamela Green 
    
   Select **Add**


7. Click on **Next**

  ![Access Governance Homepage](images/one-approval.png)

8. Enter the following details:
    - What do you want to call this approval process: **One-level-approval**
    - How do you want to describe this approval process: **One-level-approval**
    
    Click Next


9. Click **Publish** and **Approval Workflow** - **One-level-approval** workflow has been created


## Task 2: Create Two Level Approval Workflow


1. Click on **Create Approval Workflow**

  ![Access Governance Homepage](images/create-workflow.png)

2. Click **Add**

   ![Access Governance Homepage](images/click-add.png)
  

3. Under **Add a new approval** 
    - Which type of approval? : select Custom User 
    - Which user? : Mark Hernandez
    
  Select **Add**

  ![Access Governance Homepage](images/custom-user-mark.png)

4. Under **Add Next**

  - Which type of approval? : select Custom User 
  - Which user? : Harlan Bullard 

  ![Access Governance Homepage](images/add-next.png)

  ![Access Governance Homepage](images/custom-user-harlan.png)

  
  Click on **Next**

  ![Access Governance Homepage](images/workflow-complete.png)
  
  Enter the following details:
   - What do you want to call this approval process: **Two-level-approval**
   - How do you want to describe this approval process: **Two-level-approval**
    
    Click Next

  ![Access Governance Homepage](images/two-level-approval.png)

  Click **Publish** and **Approval Workflow** - **Two-level-approval** workflow has been created

  ![Access Governance Homepage](images/click-publish.png)


## Task 3: Login Oracle Access Governance as Access Review Campaign Administrator

1. From your browser, navigate to the Oracle Access Governance Console using the URL specified in *Lab 5: Task 1: Step 4*


2. Enter **Oracle Access Governance Administrator** username and password (Pamela Green)

    **Username:**
    ```
    <copy>pamela.green</copy>
    ```

    **Password:**
    
    The password you have set for the user in *Lab 1: Task 2: Step 5*


  You will be navigated to the home page of your Oracle Access Governance Console.

4. You should see the **Oracle Access Governance** main dashboard. **Please note data on Oracle Access Governance main dashboard in your assigned system might be different from LiveLabs step screenshot.** 
  ![Access Governance Homepage](images/admin-home.png)

## Task 4: Create Access Review Campaign as Campaign Administrator 

1. Click on the hamburger menu icon on the top left corner. From the drop-down menu select **Campaigns**.
  ![Select Criteria](images/admin-campaign.png)
2. Click on **Create a campaign**
  ![Select Criteria](images/admin-create-campaign.png)
3. You may select any one of the 4 dimensions **Who has access?** (Users), **What are they accessing** (Applications), **Which permissions** (Permission), and **Which Roles** (Roles). For this lab, you can select **Who has access?** (Users) tile first. 
  ![Select Users](images/admin-select-dimensions.png)
4. You may select users by **organization**, **job code**, or **location**. For this lab, you should select the **organization - Quality Assurance and Operations** your users are under review based on the lab assignment.After that, click on **Apply my selections**, which will bring you back to **Create a new access review campaign** wizard. 
  ![Select Organizations](images/select-org.png)
  ![Select Next Criteria](images/admin-select-next.png)
5. In the pie charts on the top right corner, you can review the scope of selected **Users**, **Applications**, **Permissions**, and **Roles** in **What I’ve selected** selection, review the selections made by you. For this lab, you can click on the button **I’m good, go to workflows**.
  ![Select the workflow](images/admin-select-next.png)
6. Select **Two-level-approval** workflow. You can change those if required. For example, clicking on **I'll choose my own workflow** will open up **configure workflow** menu. For this lab, you may not need to change workflow and reviewers. Accept the default and click on **Next**. With this setup, access reviews go to **employee user** first, after the employee self review, it will go to the second reviewer **user manager** for approval.
  ![Default Workflow](images/admin-configure-workflow-update.png)
7. Accept default value **One time** for the field **How often do you want this to run?**. You may provide a campaign name and description of your choice. For example, enter the campaign name as **Organization Access Review**, enter the description you prefer, select **Run now** and click on the **Next** button to schedule the campaign. Note the **campaign name** for reference in the next lab to search for your newly created access review campaign. For reviewers, the **campaign name** is referred to as **Review source** in the review tasks dashboard. 
  ![Default Workflow - One time run](images/admin-default-workflow.png)
8. You may review the selected campaign criteria, workflow, reviewers, and the run schedule. For this lab, click on the **Create** button to create and schedule a campaign. The campaign will start approximately **10 minutes** from creation.  
  ![View Charts - Create](images/admin-summary.png)
9. A newly created campaign **Organization Access Review** is scheduled in **My upcoming campaigns** section. It takes approximately 10 minutes for **the newly created campaign** to move to **in progress** status. 
  ![View Charts - created campaign](images/admin-view-created-campaign.png)
10. During this lab, you have navigated the **Oracle Access Governance** console and created a **user access review campaign** as a **campaign administrator**.

  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Contributors** - Edward Lu 
* **Last Updated By/Date** - Anbu Anbarasu, Cloud Platform COE, January 2023
