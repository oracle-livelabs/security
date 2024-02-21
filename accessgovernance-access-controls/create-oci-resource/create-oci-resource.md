# Create  OCI Policies, VCN, Groups and Compartments

## Introduction

As a user with a **Identity Domain Administrator** role in the identity domain, you can create OCI policies, groups and compartments, oci iam users from the **OCI** console.This lab will show you how to set up the OCI policies,VCN,groups and compartments needed to run this OCI-IAM Policy reviews.

* Persona: Identity Domain Administrator

*Estimated Time*: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Oracle Video Hub video with no sizing](videohub:1_wabc1y93)

### Objectives

In this lab, you will:

* Create OCI Policies, VCN, Groups and Compartments, OCI IAM Users manually
* Note: All the resources we create in this lab are supposed to be created in the **ag-compartment**
* We create the following resources in this lab:

| Resource Type           | Resource    | Description |
| :-----------   |   :--------:   |  :--------: |
| Compartment      | Development           | Development   |
|      | Quality-Assurance           | Quality-Assurance   |
|      | Testing             | Testing   |
| Users        | demouser1           | demouser1 belongs to groups - SecurityAdmins   |
|       | demouser2            | demouser2 belongs to groups -  SecurityAdmins and NetworkAdmins  |
|        | demouser3           | demouser3 belongs to groups - SecurityAdmins and Auditors   |
| Groups         | SecurityAdmins           | SecurityAdmins         |
|          | NetworkAdmins             | NetworkAdmins        |
|          | Auditors            | Auditors        |
| Policies         | auditors-policy            | Access Policy for Auditors         |
|         |  network-admins-policy            | Access Policy for Network Administrators        |
|          | security-admins-policy           | Access Policy for Security Admins         |
| Virtual Cloud Network    | ag-vcn           | AG Test Virtual Cloud Network       |

## Task 1: Create Users in OCI IAM

1. Click the Navigation Menu icon in the top left corner to display the Navigation menu. Click Identity and Security in the Navigation menu. Select Domains from the list of products.

    ![Navigate to Domains](images/navigate-select-domain.png)

2. On the Domains page, Click on Identity-domain : *ag-domain* you have created.

    ![Navigate to Identity Domains](images/open-domains.png)

   Select *Users*. Click on *Create User*

     ![Navigate to Users](images/navigate-to-users.png)

3. Uncheck "Use the email address as the username"

4. Enter the following details to create 3 users - Pamela Green (Campaign Administrator), Harlan Bullard (Manager), Mark Hernandez (Employee User) in IAM. Be sure to use different email IDs for different users.

    ```
    First Name: Pamela
    Last Name: Green
    Username: pamela.green
    Email: Specify unique email-id to which you will be receiving activation mail for password reset for the user. 
    ```

    ![Create User](images/user-create-pamela.png)

    Click *Create*

    ```
    First Name: Harlan
    Last Name: Bullard
    Username: harlan.bullard
    Email: Specify unique email-id to which you will be receiving activation mail for password reset for the user. 
    ```

    ![Create User](images/user-create-harlan.png)

    Click *Create*

    ```
    First Name: Mark
    Last Name: Hernandez
    Username: mhernandez
    Email: Specify unique email-id to which you will be receiving activation mail for password reset for the user. 
    ```

    ![Create User](images/user-create-mark.png)

    Click *Create*

    ```
    First Name: Jerry
    Last Name: Poland
    Username: jerry.poland
    Email: Specify unique email-id to which you will be receiving activation mail for password reset for the user. 
    ```

    Click *Create*

5. Sign out from the cloud console.

6. For each user created, an activation mail will be sent to the email-id provided in the *Task 3: Step 4* . Reset the password for the 3 users using the *Activation mail* recieved for each of them.
    Reset password to the below mentioned password:

    **Password:**

     ```
    <copy>Oracl@123456</copy>
    ```

  You may now **proceed to the next lab**.

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements

* **Authors** - Anuj Tripathi, Anbu Anbarasu
* **Last Updated By/Date** - Anuj Tripathi, October 2023
