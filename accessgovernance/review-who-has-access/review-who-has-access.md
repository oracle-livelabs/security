# Check Who has Access to What for Myself or My Direct Reports

## Introduction

Users can check what access they have for themselves or for their direct reports. Managers can view details of the application, permissions, and roles assigned to their direct reports. Users can view details of the application, permissions, and roles assigned to themselves.

Estimated Time: 15 minutes

### Objectives

In this lab, you will:
* View details of the application, permissions, and roles assigned to my direct reports
* View details of the application, permissions, and roles assigned to myself

## Task 1: Login Oracle Access Governance as User Manager

1. Open Chrome browser and go to Oracle Access Governance URL based on your group assignment. 
- [Oracle Access Governance LiveLabs Group 1](https://accessgov-eap1-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
- [Oracle Access Governance LiveLabs Group 2](https://accessgov-outreach02-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
- [Oracle Access Governance LiveLabs Group 3](https://accessgov-outreach03-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
- [Oracle Access Governance LiveLabs Group 4](https://accessgov-outreach04-yzukikevdw6w.access-governance.us-ashburn-1.oci.oraclecloud.com/ui/)
2. Ensure you have **accessgov_iam** identity domain selected.
3. Login Oracle Access Governance as **user manager** with username and password provided by Hands-on Lab instructors.
	![Access Governance Login](images/ag-logon.png)
4. You should see the **Oracle Access Governance** main dashboard.
  ![Access Governance Homepage](images/ag-homepage.png)

## Task 2: Review My Direct Report's Access

1. Click on **Oracle Access Governance** menu, go to **Who has access to what**, then select **My Direct’s Access**.
  ![My Direct Menu](images/open-menu-direct.png)
2. You will see a list of users reporting to the current user manager. You may select one user. For example, Select **George Jimenez**.
  ![Review Direct List](images/review-direct-list.png)
3. List of applications in which **George Jimenez** has access is listed. You can select each application and review the privileges assigned to user in selected application. Review what **applications** your employee has, **Permission**, **Grant Type**, and **Date Granted** etc. 
  ![Review Application](images/review-individual-app.png)
4. Select **Roles** from **Group-by** drop-down menu to see list of roles assigned to user.
  ![Review Role](images/review-individual-role.png)
5. Review **Roles** assigned to users and the detail for each role. 
  ![Review Role](images/user-roles.png)

## Task 3: Review my access

1. Click on **Oracle Access Governance** menu, go to **Who has access to what**, then select **My Access**.
  ![My Direct Menu](images/open-menu-direct.png)
2. You can review list of **applications** in which the signed in user has access to. You can select each application and review the privileges assigned to user.
  ![Review My Access](images/review-my-access.png)
3. Select **Roles** from **Group-by** drop-down menu to see list of roles assigned to user. You can also click on each **Role** to view details.
  ![Review My Role](images/review-my-access-role.png)
4. During this lab, you have navigated **Oracle Access Governance** console to list your direct report employee and your own access privileges. This is a security good practice, and part of the employees' **Due Care / Due Dilegence**.
5. Congratulations! You now finish **Oracle Access Governance Hands-on Lab**. In this workshop, you have learned how to:
- Create access review campaigns as administrator
- Perform access review tasks as users and user manager
- Monitor and manage access review campaigns as administrator
- Review user privileges for yourself and your direct reports

## Learn More

* [Oracle Access Governance Who Has Access To What](https://docs.oracle.com/en/cloud/paas/access-governance/yhaty/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements
* **Author** - Edward Lu, Abhishek Juneja, Oracle IAM Product Management
* **Last Updated By/Date** - Edward Lu, Abhishek Juneja, Oracle IAM Product Management, August 2022
