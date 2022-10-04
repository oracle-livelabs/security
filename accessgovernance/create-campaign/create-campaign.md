# Create Access Review campaign – Self and User Manager review

## Introduction

As a user with a **campaign administrator** role, you can create access review campaigns from the **Oracle Access Governance** console. You can define selection criteria for access reviews based on **users** (who has access), **applications** (what are they accessing), **permissions** (which permissions), and **roles** (which roles).

* Estimated Time: 15 minutes
* Persona: Campaign Administrator

### Objectives

In this lab, you will:
* Create **access review campaign** for self and user manager review
* Define **reviewers' workflow**
* Run now or schedule an **access review campaign**


## Task 1: Login Oracle Access Governance as Access Review Campaign Administrator

1. Open Chrome browser and go to **Oracle Access Governance** URL based on your **group** assignment. 
    - [Oracle Access Governance LiveLabs Group 1](https://accessgov-ocw-01-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
    - [Oracle Access Governance LiveLabs Group 2](https://accessgov-ocw-002-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
    - [Oracle Access Governance LiveLabs Group 3](https://accessgov-ocw-03-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
    - [Oracle Access Governance LiveLabs Group 4](https://accessgov-ocw04-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
2. Ensure you have **accessgov_iam** identity domain selected.
3. Log in to **Oracle Access Governance** as a **campaign administrator** with a username and password provided by Hands-on Lab instructors. **Please note username on LiveLabs step screenshot might be different from the username you received.** 
	![Access Governance Login](images/ag-logon.png)
4. You should see the **Oracle Access Governance** main dashboard. **Please note data on Oracle Access Governance main dashboard in your assigned system might be different from LiveLabs step screenshot.** 
  ![Access Governance Homepage](images/ag-homepage.png)

## Task 2: Create Access Review Campaign as Campaign Administrator  
1. Scroll to the bottom and select **Let's create some work and define a new campaign** or from the drop-down menu and select **Create a New Campaign**.
  ![Select Criteria](images/create-campaign.png)
2. You may select any one of the 4 dimensions **Who has access?** (Users), **What are they accessing** (Applications), **Which permissions** (Permission), and **Which Roles** (Roles). For this lab, you can select **Who has access?** (Users) tile first. 
  ![Select Users](images/select-dimensions.png)
3. You may select users by **organization**, **location**, or **job code**. For this lab, you should select the **organization** your users are under based on the lab assignment.  For example, select **Support** organization. Other **organizations** in lab assignments include **Human Resources**, **Software Engineering**, **Product Management**, and **Finance**. After that, click on **Apply my selections**, which will bring you back to **Create a new access review campaign** wizard. 
  ![Select Organizations](images/select-users.png)
4. You may select any one of the remaining 3 dimensions **What are they accessing** (Applications), **Which permissions** (Permission), or **Which Roles** (Roles). For this lab, you can select **What are they accessing** (Applications) tile.
  ![Select Next Criteria](images/select-next.png)
5. You may select **Applications** by name. For this lab, you can select **Central Confluence** and **Corporate Badge** and **Corporate Laptop** applications, then click on **Apply my selections**, which will bring you back to **Create a new access review campaign** wizard.
  ![Select Applications](images/select-applications.png)
6. In the pie charts on the top right corner, you can review the scope of selected **Users**, **Applications**, **Permissions**, and **Roles** in **What I’ve selected** selection, review the selections made by you. For this lab, you can click on the button **I’m good, go to workflows**.
 ![View Charts](images/view-charts.png)
7. Review the auto-selected workflow and reviewers. You can change those if required. For example, clicking on **I'll choose my own workflow** will open up **configure workflow** menu. For this lab, you may not need to change workflow and reviewers. Accept the default and click on **Next**. With this setup, access reviews go to **employee user** first, after the employee self review, it will go to the second reviewer **user manager** for approval.
 ![Default Workflow](images/configure-workflow.png)
 ![Default Workflow](images/default-workflow.png)
8. You may provide a campaign name and description of your choice. For example, enter the campaign name such as **Support Org Corporate Access Review**, enter the description you prefer, select **Run now** and click on the **Next** button to schedule the campaign.
 ![Name Campaign](images/name-campaign.png)
9. You may review the selected campaign criteria, workflow, reviewers, and the run schedule. For this lab, click on the **Create** button to create and schedule a campaign. The campaign will start approximately **10 minutes** from creation. Note the **campaign name** for reference in the next lab to search for your newly created access review campaign. 
 ![View Charts](images/summary.png)
10. A newly created campaign **Support Org Corporate Access Review** is scheduled in **My upcoming campaigns** section.
 ![View Charts](images/view-created-campaign.png)
 11. During this lab, you have navigated the **Oracle Access Governance** console and created a **User Access Review campaign** as a **campaign administrator**.
 12. You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Author** - Edward Lu, Abhishek Juneja, Oracle IAM Product Management
* **Last Updated By/Date** - Edward Lu, Abhishek Juneja, Oracle IAM Product Management, August 2022
