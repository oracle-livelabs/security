# Provision Application Role in OCI

## Introduction

In this lab we will review Access-Control of Access Governance

*Estimated Time*: 15 minutes


### Objectives

In this lab, you will:

* Create access request for Application Role Provisioning
* Approve access request for Application Role Provisioning


### Prerequisites

This lab assumes you have:

A valid Oracle OCI tenancy, with OCI administrator privileges.



## Task 1: Create Access Request


  1. On the Oracle Access Governance Console home page, from the navigation menu, select **My Stuff -> Request a new access**

     ![Access Review](images/request-access.png)

  2. Under **Select the kind of access you want to request** , select **Request a role** 

      ![Access Review](images/select-request-role.png)

  3. Under **Is this request for you?** , select **No** and choose the user **Mark Hernandez** for who this request is for. 

     ![Access Review](images/select-user.png)

     Click **Next**

  4. Under **Select the roles** you want to request, select the role **oci-admin-role**

    ![Access Review](images/oci-admin-role-request.png)

    Click on **Next**

  5. Under We need some additional information for this request -> Provide Justification.

     ![Access Review](images/provide-reason.png)

  6. Click on **Submit Request**

  ![Access Review](images/submit-admin-request.png)

  ![Access Review](images/request-admin-created.png)

## Task 2: Approve Access Requests


1. Navigate to MyStuff -> Approvals.You will see requests for the user Mark Hernandez for **oci-admin-role** .

   ![Access Review](images/navigate-approval.png)

2. Under Actions, click on approve and Approve the request for the user Mark Hernandez. 

   ![Access Review](images/admin-approval.png)

   ![Access Review](images/confirm-admin-approval.png)

## Task 3: Run the Data Load

1. On the Access Governance console home page, navigate to Service Administration -> Orchestrated Systems

2. On the Connected Systems page, select the **OCI-IAM** orchestrated system.

3. Click on  Actions -> Load Data Now. This will perform a manual data load.

4. Once the data load is complete, the status will be shown as Success.

    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Documentation](https://www.oracle.com/security/cloud-security/access-governance/#documentation)
* [Oracle Access Governance Product Demo](https://www.oracle.com/security/cloud-security/access-governance/?ytid=GJEPEJlQOmQ)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements

* **Authors** - Indiradarshni Balasundaram
* **Contributors** - Anbu Anbarasu, Anuj Tripathi 
* **Last Updated By/Date** - Indiradarshni Balasundaram , April 2025
