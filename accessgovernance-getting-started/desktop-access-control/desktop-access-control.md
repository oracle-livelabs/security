# Define Access Controls for Database

## Introduction

In this lab we will review Access-Control of Access Governance

*Estimated Time*: 15 minutes


### Objectives

In this lab, you will:

* Create an Identity Collection
* Create an One-Level Approval Workflow 
* Create Access Bundles
* Create a centralized policy to provision access privileges


### Prerequisites

This lab assumes you have:

A valid Oracle OCI tenancy, with OCI administrator privileges.


## Task 1: Create an Identity Collection for Requestors

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Identity Collections tile.

2. On the Identity Collections page, your created Identity Collections will be listed here. Click Create identity collection to Create an Identity Collection.

    ![Identity Collection creation](images/create-identity-collection.png)

3. Enter the below mentioned details Under Add Details tab:

    What do you want to call this identity collection? : QA Team

    How would you describe this collection? : QA Team

    Who can manage this identity collection : Livelab user

    Would you like to add any tags? : DB, database, operations

    Click on *Next*

    ![Identity Collection creation](images/qa-collection.png)

4. Under Select Identities -> Membership rule , select the below mentioned option.

    Select the *All* checkbox.

    Select attribute: Source Organization

    Condition: Equals

    Attribute field: Quality Assurance

    ![Identity Collection creation](images/source-organization.png)

5. Click on *Create*



## Task 2: Create an Approval Workflow - One-level-approval 

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Manage Approval Workflows tile.

   ![Approval Workflow](images/ag-homepage.png)

2. On the Approval Workflows page, your created approval workflows will be listed here. Click Create approval workflow to create your one-level-approval Workflow.


3. Let’s build your approval workflow now. Click the “+” button and configure your approval workflow based on the following:

    • Which type of approval?: select Custom User

    • Which user? Livelab user

    • Click Add

      ![Approval Workflow](images/livelab-user.png)


     After confirming your configuration matches the following, click Next

5. On the Add Details page, name your Approval Workflow: One-level-approval. Then, provide any description. Click Next to review your configurations so far, then click Publish and Approval workflow - **One-level-approval** has been created. 

  

6. Enter the following details:

    What do you want to call this approval process: One-level-approval

    How do you want to describe this approval process: One-level-approval

    ![Approval Workflow](images/create-one-level.png)

    Click Next and Publish. 


## Task 3: Create an Access Bundle

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Access Bundles tile.

    ![Create Access Bundle](images/navigate-access-bundle.png)

2. Click on Create an access bundle - DB Read Access

     ![Create Access Bundle](images/create-access-bundle.png)
  
3. For your bundle settings, configure your bundle to match the following:

    • Which target is this bundle for?: OAG-DB

    • Who can request this bundle?: Anyone

    • Which approval workflow should be used?: One-level-approval workflow

     Click Next.

    ![Create Access Bundle](images/select-approval.png)

4. Select the permissions to be included in the access bundle.

    Which permissions are included in this bundle? : Select the below to be included in the access bundle from the list.

    * READ ANY FILE GROUP

    * READ ANY TABLE

     ![Create Access Bundle](images/read-permissions.png)

    Click Next.

5. In the Add Details step, configure the following:

    • What is the name of this bundle?: DB Read Access

    • How do you want to describe this bundle?: DB Read Access

    • Authentication Type: PASSWORD

    • Default Tablespace: USERS

    • TemporaryTablespace: TEMP

    • Profile Name: DEFAULT

    • Leave all other options as default

     ![Create Access Bundle](images/db-read.png)

    Then, Click Next.

6. Review your configurations made until this point. It should look like the configurations depicted below, except for the name. Then, click Create.


7. Click on Create an access bundle - DB Manage Access

     ![Create Access Bundle](images/create-access-bundle.png)
  
8. For your bundle settings, configure your bundle to match the following:

    • Which target is this bundle for?: OAG-DB

    • Who can request this bundle?: Anyone

    • Which approval workflow should be used?: One-level-approval-workflow

   Click Next.

   ![Create Access Bundle](images/select-approval.png)

9. Select the permissions to be included in the access bundle.

    Which permissions are included in this bundle? : Select the below to be included in the access bundle from the list.

    * ADMINISTER ANY SQL TUNING SET

    * ADMINISTER DATABASE TRIGGER

    * ADMINISTER KEY MANAGEMENT

    * ADMINISTER RESOURCE MANAGER

    * ADMINISTER SQL MANAGEMENT OBJECT

    * ADMINISTER SQL TUNING SET

     ![Create Access Bundle](images/administer-permission.png)

    Click Next.

10. In the Add Details step, configure the following:

    • What is the name of this bundle?: DB Manage Access

    • How do you want to describe this bundle?: DB Manage Access

    • Authentication Type: PASSWORD

    • Default Tablespace: USERS

    • TemporaryTablespace: TEMP

    • Profile Name: DEFAULT

    • Leave all other options as default

     ![Create Access Bundle](images/db-manage-access.png)

    Then, Click Next.

11. Review your configurations made until this point. It should look like the configurations depicted below, except for the name. Then, click Create.


## Task 4: Create a Policy

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Policies tile.

   ![Create Policy](images/ag-homepage.png)

    ![Create Policy](images/navigate-policies.png)

2. On the Policies page, you will see a list of your created policies. Click Create a policy.

   ![Create Policy](images/create-policy.png)

3. Give your policy a name and description like the following:

    • What do you want to call this policy?:DB Policy

    • How would you describe this policy?: DB Policy

     ![Create Policy](images/build-policy.png)

4. Now on this same page, let’s add an Access Bundle Association. Lower on the page, click the “+” button and select Access Bundle Association.

     ![Create Policy](images/policy-access-bundle-association.png)

5. Search for which identity collection you want to allow access : QA Team. Your selection will be marked with a green checkmark. Click Next

     ![Create Policy](images/select-qa.png)

6. Search for which access bundle you want to assign : DB Read Access. Your selection will be marked with a green checkmark.

     ![Create Policy](images/selet-db-read-access.png)

    Then, click Next.

7. On the Review and submit page, you may click Preview policy association in the bottom right corner before your create it. After, close that sidebar and click Add association.

     ![Create Policy](images/click-add-association.png)

8. Finally, click Create.

## Task 5: Create Access Requests

  1. Log in to Oracle Access Governance as the *Livelab* user. You will be navigated to the home page of your Oracle Access Governance Console.


  3. On the Oracle Access Governance Console home page, from the navigation menu, select **My Stuff -> Request a new access**

     ![Access Review](images/navigate-access.png)

  4. Under **What access are you requesting?** select **Which access would like?**.

     ![Access review](images/which-access.png)

  5. Request a new access -> Select "No" . 

     ![Access Review](images/select-request-others.png)

  6. Select Users **Mark Hernandez, Harlan Bullard and Jerry Poland** for whom you will be requesting the access for. 
    
    ![Access Review](images/select-mark.png)

    ![Access Review](images/select-harlan.png)

    ![Access Review](images/select-jerry.png)

  6. Under What would you like access to -> Select **DB-Manage-Access** -> Click **Next**

    ![Access Review](images/select-db-bundle.png)

  7. Under We need some additional information for this request -> Provide Justification.

     ![Access Review](images/justification-access.png)

  8. Click on **Submit Request**

    ![Access Review](images/submit-request.png)

  

## Task 6: Approve Access Requests

1. Log in to Oracle Access Governance as an employee user - *Livelab* user with the username and password. You will be navigated to the home page of your Oracle Access Governance Console.

2. Navigate to MyStuff -> Approvals.

    ![Access Review](images/navigate-approval.png)

3. You will see requests from **Livelab** user for **DB-Manage-Access** for users **Mark Hernandez, Harlan Bullard and Jerry Poland**

     ![Access Review](images/approval-pending.png)

4. Under Actions, click on approve and approve the requests. 

     ![Access Review](images/confirm-request.png)

## Task 7: Run the Data Load

1. On the Access Governance console home page, navigate to Service Administration -> Connected System.

   ![Create Policy](images/connected-system.png)

2. On the Connected Systems page, select the **OAG-DB** connected system.

   ![Create Policy](images/select-system.png)

3. Click on  Actions -> Load Data Now. This will perform a manual data load.

    ![Create Policy](images/load-date.png)

4. Once the data load is complete, the status will be shown as Success.

    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements

* **Authors** - Anuj Tripathi
* **Contributors** - Anbu Anbarasu
* **Last Updated By/Date** - Anuj Tripathi, October 2023
