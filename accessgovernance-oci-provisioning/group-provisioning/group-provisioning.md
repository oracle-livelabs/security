# Provision Group Access

## Introduction

In this lab we will review Access-Control of Access Governance

*Estimated Time*: 15 minutes


### Objectives

In this lab, you will:

* Create access request for Group Provisioning
* Approve access request for Group Provisioning


### Prerequisites

This lab assumes you have:

A valid Oracle OCI tenancy, with OCI administrator privileges.

**Note:** For the sake of simplicity in this workshop, we are using the same persona for both request and approval actions. In a real-world scenario, the approver would typically be a different user or role.


## Task 1: Create Access Request


  1. On the Oracle Access Governance Console home page, from the navigation menu, select **My Stuff -> Request a new access**

     ![Access Review](images/request-access.png)

  2. Under **Select the kind of access you want to request** , select **Request an access** 

     ![Access review](images/request-access-select.png)

  3. Under **Is this request for you?** , select **No** and choose the user **Jerry Poland** for who this request is for. 

     ![Access Review](images/select-user.png)

     Click **Next**

  4. Under **Select the access** you want to request, select the access **Audit Access**

    ![Access Review](images/select-access-bundle.png)

    Click on **Next**

  5. Under We need some additional information for this request -> Provide Justification.

     ![Access Review](images/access-request-reason.png)

  6. Click on **Submit Request**

    ![Access Review](images/access-request-list.png)

## Task 2: Approve Access Requests


1. Navigate to MyStuff -> Approvals.You will see requests for the user Jerry Poland for **Audit Access** 

     ![Access Review](images/select-approval.png)

2. Under Actions, click on approve and Approve the request for the user Jerry Poland.  

    ![Access Review](images/approve-access-request.png)

    ![Access Review](images/provide-justification.png)

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
