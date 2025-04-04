# Define Access Controls for OCI IAM 

## Introduction

In this lab we will review Access-Control of Access Governance

*Estimated Time*: 15 minutes


### Objectives

In this lab, you will:

* Create Identity Collections
* Create an Approval Workflow with parallel escalation rules
* Create Access Bundles
* Create centralized policies to provision access privileges
* Create a role to provision access privileges


### Prerequisites

This lab assumes you have:

A valid Oracle OCI tenancy, with OCI administrator privileges.

## Task 1: Create Identity Collections : IT-Team, Network-Team, OCI-Administration

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Identity Collections tile.

     ![Identity Collection creation](images/identity-collection-navigate.png)

   

2. On the Identity Collections page, your created Identity Collections will be listed here. Click Create identity collection to Create an Identity Collection.


3. Enter the below mentioned details Under Add Details tab:

    Name: IT-Team

    Description: IT-Team

    Tags: it-team

    Click on *Next*

      ![Identity Collection creation](images/it-team-collection.png)

4. Under select a primary owner and add any additional owners, select the below mentioned option.

    Who is the primary owner: Pamela Green

    Click on *Next* 

    ![Identity Collection creation](images/it-team-owner.png)

5. Under Add identities to your collection by building a membership rule and/or selecting names , select **Included named identities**

    Select users **John Smith and Harlan Bullard**

    Click on *Next* and Click on *Create*. 

    ![Identity Collection creation](images/it-team-add-identities.png)

     ![Identity Collection creation](images/create-it-team.png)

6. On the Identity Collections page, your created Identity Collections will be listed here. Click Create identity collection to Create an Identity Collection. Enter the below mentioned details Under Add Details tab:

    Name: Network-Team

    Description: Network-Team

    Tags: network-team

    Click on *Next*

   ![Identity Collection creation](images/network-team-collection.png)

7. Under select a primary owner and add any additional owners, select the below mentioned option.

    Who is the primary owner: Pamela Green

    Click on *Next* 

     ![Identity Collection creation](images/network-team-owner.png)

8. Under Add identities to your collection by building a membership rule and/or selecting names , select **Included named identities**

    Select users **Jose Walker, Jerry Poland and David Brown**

    Click on *Next* and Click on *Create*.

    ![Identity Collection creation](images/network-team-identities.png)

    ![Identity Collection creation](images/network-team-create.png)
    
9. On the Identity Collections page, your created Identity Collections will be listed here. Click Create identity collection to Create an Identity Collection. Enter the below mentioned details Under Add Details tab:

    Name: OCI-Administration

    Description: OCI-Administration

    Tags: oci-administration

    Click on *Next*

   ![Identity Collection creation](images/click-create-collection.png)

   ![Identity Collection creation](images/oci-administration.png)

7. Under select a primary owner and add any additional owners, select the below mentioned option.

    Who is the primary owner: Pamela Green

    Click on *Next* 

     ![Identity Collection creation](images/primary-owner.png)

8. Under Add identities to your collection by building a membership rule and/or selecting names , select **Included named identities**

    Select users **Pamela Green**

    Click on *Next* and Click on *Create*.

    ![Identity Collection creation](images/user-pamela.png)

    ![Identity Collection creation](images/create-oci-collection.png)

9. The below Identity Collections have been created.

    ![Identity Collection creation](images/identity-list.png)


## Task 2: Create an Approval Workflow : One-level-approval 

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Manage Approval Workflows tile.

   ![Approval Workflow](images/approval-workflow-navigate.png)

2. On the Approval Workflows page, your created approval workflows will be listed here. Click Create approval workflow to create your one-level-approval Workflow.

    ![Approval Workflow](images/click-create-workflow.png)


3. Let’s build your approval workflow now. Click the “+” button and configure your approval workflow based on the following:

    • Which type of approval?: select Custom User

    • Which user? Pamela Green 

    • Click Add

    ![Approval Workflow](images/click-add-workflow.png)

    ![Approval Workflow](images/add-workflow.png)


     After confirming your configuration matches the following, click Next

      ![Approval Workflow](images/click-next-workflow.png)

5. On the Add Details page, name your Approval Workflow: One-level-approval. Then, provide any description. Click Next

    ![Approval Workflow](images/select-approval.png)

6. Enter the following details:

    Who is the primary owner: Pamela Green

    ![Approval Workflow](images/select-approval-owner.png)

    Click Next and Publish. 

    ![Approval Workflow](images/publish-workflow.png)


## Task 3: Create Access Bundles: Network Admin Access, Audit Access, ServiceDesk Admin Access, Security Admin Access
 
1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Access Bundles tile.

    ![Create Access Bundle](images/select-access-bundles.png)

2. Click on Create an access bundle - Network Admin Access

     ![Create Access Bundle](images/click-create-bundle.png)
  
3. For your bundle settings, configure your bundle to match the following:

    • Which system is this bundle for?: OCI-IAM

    • Which domain?: ag-domain

    • Which type of permission?: Group access

    • Who can request this bundle?: Anyone

    • Which approval workflow should be used?: One-level-approval

    • Tags: network-admin-access-bundle

     Click Next.

     ![Create Access Bundle](images/bundle-settings.png)

     ![Create Access Bundle](images/bundle-settings-next.png)

4. Select the permissions to be included in the access bundle.

    Which permissions are included in this bundle? : Select the below to be included in the access bundle from the list.

    * All Domain Users

    * NetworkAdmins

     ![Create Access Bundle](images/select-permissions-bundle.png)

    Click Next.

5. Select a primary owner and add any additional owners. 

    Who is the primary owner? Pamela Green 

    Click *Next*

     ![Create Access Bundle](images/select-bundle-owner.png)

5. In the Add Details step, configure the following:

    • Name: Network Admin Access

    • Description: Network Admin Access

     ![Create Access Bundle](images/network-access-bundle.png)

    Then, Click Next. 

6. Review your configurations made until this point. It should look like the configurations depicted below, except for the name. Then, click Create.

     ![Create Access Bundle](images/create-network-bundle.png)

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Access Bundles tile.


2. Click on Create an access bundle - Audit Access

     ![Create Access Bundle](images/click-create-bundle.png)
  
3. For your bundle settings, configure your bundle to match the following:

    • Which system is this bundle for?: OCI-IAM

    • Which domain?: ag-domain

    • Which type of permission?: Group access

    • Who can request this bundle?: Anyone

    • Which approval workflow should be used?: One-level-approval

    • Tags: audit-access-bundle

     Click Next.

    ![Create Access Bundle](images/audit-bundle-settings.png)

    ![Create Access Bundle](images/audit-settings-bundle.png)

4. Select the permissions to be included in the access bundle.

    Which permissions are included in this bundle? : Select the below to be included in the access bundle from the list.

    * Auditors


     ![Create Access Bundle](images/select-auditor.png)

    Click Next.

5. Select a primary owner and add any additional owners. 

    Who is the primary owner? Pamela Green 

    Click *Next*

    ![Create Access Bundle](images/audit-owner.png)

5. In the Add Details step, configure the following:

    • Name: Audit Access

    • Description: Audit Access

     ![Create Access Bundle](images/audit-access.png)

    Then, Click Next. 

6. Review your configurations made until this point. It should look like the configurations depicted below, except for the name. Then, click Create.

     ![Create Access Bundle](images/audit-bundle-create.png)

7. Click on Create an access bundle - Service Desk Admin Access

      ![Create Access Bundle](images/click-create-bundle.png)

8. For your bundle settings, configure your bundle to match the following:

    • Which system is this bundle for?: OCI-IAM

    • Which domain?: ag-domain

    • Which type of permission?: Application Role

    • Who can request this bundle?: Anyone

    • Which approval workflow should be used?: One-level-approval

    • Tags: service-desk-admin-access-bundle

     Click Next.

      ![Create Access Bundle](images/service-bundle-create.png)

9. Select the permissions to be included in the access bundle.

    Which permissions are included in this bundle? : Select the below to be included in the access bundle from the list.

    * AG ServiceDesk Admin


     ![Create Access Bundle](images/service-desk-admin-select.png)

    Click Next.

10. Select a primary owner and add any additional owners. 

    Who is the primary owner? Pamela Green 

    Click *Next*

    ![Create Access Bundle](images/service-owner-select.png)

11. In the Add Details step, configure the following:

    • Name: Service Desk Admin Access

    • Description: Service Desk Admin Access

     ![Create Access Bundle](images/service-admin-next.png)

    Then, click Next and click Create. 

    ![Create Access Bundle](images/service-create-admin.png)

13. Similarly create another Access Bundle - Security Admin.Click on Create an access bundle - Security Admin Access

    ![Create Access Bundle](images/service-create-admin.png)


14. For your bundle settings, configure your bundle to match the following:

    • Which system is this bundle for?: OCI-IAM

    • Which domain?: ag-domain

    • Which type of permission?: Group Access

    • Who can request this bundle?: Anyone

    • Which approval workflow should be used?: One-level-approval

    • Tags: security-admin-access-bundle

     Click Next.

    ![Create Access Bundle](images/security-create.png)


15. Select the permissions to be included in the access bundle.

    Which permissions are included in this bundle? : Select the below to be included in the access bundle from the list.

    * SecurityAdmins

    ![Create Access Bundle](images/security-permission.png)

    ![Create Access Bundle](images/owner-security.png)

    ![Create Access Bundle](images/security-next.png)

    Click Next and Click Create

     ![Create Access Bundle](images/security-bundle-create.png)


16. Review your configurations made until this point. It should look like the configurations depicted below.    

    ![Create Access Bundle](images/bundle-list.png)


## Task 4: Create Policies: Service-Desk-Admin-Policy and Network-Admin-Policy (Group Provisioning)

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Policies tile.

    ![Create Policy](images/navigate-policy.png)

2. On the Policies page, you will see a list of your created policies. Click Create a policy.

   ![Create Policy](images/click-policy-create.png)

3. Give your policy a name and description like the following:

    • Name: Service-Desk-Admin-Policy

    • Description: Service-Desk-Admin-Policy

    • Tags: service-desk-admin-policy

    • Who is the primary owner: Pamela Green

     ![Create Policy](images/service-policy.png)

4. Now on this same page, let’s add an Access Bundle Association. Lower on the page, click the “+” button and select Access Bundle Association.

     ![Create Policy](images/service-policy-association.png)

5. Search for which identity collection you want to allow access : IT-Team. Your selection will be marked with a green checkmark. Click Next

     ![Create Policy](images/select-it-team-service.png)

6. Search for which access bundle you want to assign : Service Desk Admin Access. Your selection will be marked with a green checkmark.

     ![Create Policy](images/access-bundle-select.png)

    Then, click Next.

7. On the Review and submit page, you may click Preview policy association in the bottom right corner before your create it. After, close that sidebar and click Add association.


     ![Create Policy](images/click-add.png)

8. On the Policies page, you will see a list of your created policies. Click Create a policy.

   ![Create Policy](images/create-service.png)

9. Give your policy a name and description like the following:

    • Name: Network-Admin-Policy

    • Description: Network-Admin-Policy

    • Tags: network-admin-policy

    • Who is the primary owner: Pamela Green

     ![Create Policy](images/network-policy-setting.png)

10. Now on this same page, let’s add an Access Bundle Association. Lower on the page, click the “+” button and select Access Bundle Association.

     ![Create Policy](images/network-bundle-association.png)

11. Search for which identity collection you want to allow access : Network-Team. Your selection will be marked with a green checkmark. Click Next

     ![Create Policy](images/select-network-collection.png)

12. Search for which access bundle you want to assign : Network Admin Access. Your selection will be marked with a green checkmark.

     ![Create Policy](images/select-network-bundle.png)

    Then, click Next.

13. On the Review and submit page, you may click Preview policy association in the bottom right corner before your create it. After, close that sidebar and click Add association.

    ![Create Policy](images/add-network-association.png)

    Click on Create

    ![Create Policy](images/create-network-policy.png)

## Task 5: Create a Role: OCI-Admin-Role

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Roles tile.

    ![Create Policy](images/navigate-roles.png)

2. Click on Create a new role and configure the following:

    Who can request this role? : Anyone

    Which approval workflow?: One-level-approval workflow

    Click on *Next*

    ![Create Policy](images/create-role.png)

    ![Create Policy](images/role-setting.png)

3. Select the access bundle to include in the role:

    - Security Admin Access
    - Network Admin Access

    ![Create Policy](images/select-role-bundle.png)

     Click on *Next*

4. Provide the primary owner and add any additional owners. 

    Who is the primary owner? : Pamela Green 

    Click on *Next*

    ![Create Policy](images/select-role-owner.png)

     

5. Provide the name and description.

    Name: OCI-Admin-Role

    Description: OCI-Admin-Role

     ![Create Policy](images/oci-admin-role-name.png)

    Click on *Next*. Review the details and click on *Create role and assign*

     ![Create Policy](images/create-oci-role.png)

6. Under do you want to assign the role through an existing policy or create a new one? 

    Select *Create a new policy* 

    Provide the name and description:

    Name : OCI-Admin-Role

    Description: OCI-Admin-Role

    Who is the primary owner: Pamela Green

    Select the Identity Collection : OCI-Administration

      ![Create Policy](images/create-policy-role.png)


7. Click on *Add assignment*

      ![Create Policy](images/select-oci-administration-assignment.png)

8. The role has been created. 

     ![Create Policy](images/role-added.png)


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
