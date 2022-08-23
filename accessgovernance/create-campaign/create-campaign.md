# Create Access Review campaign – Self and User Manager review

## Introduction

As a user with the Administrator or Campaign Administrator application role, you can create access review campaigns from the Oracle Access Governance Console. You can define selection criteria for access reviews based on users (who has access), applications (what are they accessing), permissions (which permissions), and roles (which roles).

Estimated Time: 15 minutes

### Objectives

In this lab, you will:
* Create access review campaign for self and user manager review
* Define reviewers workflow
* Run now or schedule acess review campaign


## Task 1: Login Oracle Access Governance as Access Review Campaign Administrator

1. Open Chrome browser and go to [Oracle Access Governance Oracle LiveLabs Tenancy](https://accessgov-si-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
2. Ensure you have accessgov_iam domain selected.
3. Login Access Governance URL campaign administrator with user and password provided by Hands-on Lab instructors.
	![Access Governance Login](images/ag-logon.png)
4. You should see the Oracle Access Governance main dashboard.
  ![Access Governance Homepage](images/ag-homepage.png)

## Task 2: Create Access Review Campaign as Campaign Administrator  
1. Scroll to the bottom and select "Let's create some work and define a new campaign".
  ![Select Criteria](images/create-campaign.png)
2. You may select any one of the 4 dimensions Users, Applications, Permission and Roles. For this use-case, you can select Users or Who has access tile first. 
  ![Select Users](images/select-dimensions.png)
3. You may select users by organization, location or job code. For this use-case, you can select Sales organization. Select Apply my selections.
  ![Select Organizations](images/select-users.png)
4. You may select any one of the remaining 3 dimensions Applications, Permission, and Roles. For this use-case, you can select Applications or What are they accessing tile.
  ![Select Next Criteria](images/select-next.png)
5. You may select Applications by name. For this use-case, you can select Corporate SSO and Corporate ERP applications Select Apply my selections.
  ![Select Applications](images/select-applications.png)
6. In pie-charts on right-top corner, you can review the scope of Selected Users, Applications, Permissions and Roles In What I’ve selected selection, review the selections made by you. For this use-case, you can select I’m good, go to workflows.
 ![View Charts](images/view-charts.png)
7. Review the auto-selected workflow and Reviewers; You can change those, if required. For this use-case, you may select Not to change workflow and reviewers. Select Next.
 ![Default Workflow](images/default-workflow.png)
8. You may provide campaign name and description. For this use-case, select Run now to schedule the campaign.
 ![Name Campaign](images/name-campaign.png)
9. You may review the selected campaign criteria, workflow, reviewers, schedule. For this use-case, select Create to create and schedule the campaign.
 ![View Charts](images/summary.png)
10. Newly created campaign is scheduled in My upcoming campaigns section.
 ![View Charts](images/view-created-campaign.png)
 11. During this lab, you have navigated **Oracle Access Governance** console, and created an **User Access Review campaign**.
 12. You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements
* **Author** - Edward Lu, Abhishek Juneja, Oracle IAM Product Management
* **Last Updated By/Date** - Edward Lu, Abhishek Juneja, Oracle IAM Product Management, August 2022
