#  Perform AG data load and create IAM users (OIG)

## Introduction

To initiate a data load from the target connected system instance, perform the following tasks.

*Estimated Lab Time*: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Perform Data and Create OCI IAM Users](videohub:1_009fisy0)

### Objectives

In this lab, you will:
 * Perform Access Governance Data Load
 * Create IAM users 

### Prerequisites
This lab assumes you have:
- A valid Oracle OCI tenancy, with OCI administrator privileges.


## Task 1: Perform Data load in OAG console

1.  Log in to Oracle Access Governance console. Refer to *Lab 4: Task 1.4* for the Oracle Access Governance service instance URL. In the Oracle Access Governance Console, access the navigation menu by selecting the Navigation Menu icon. Select **Service Administration → Connected Systems.**

    ![Naviagte to Service Administration → Connected Systems](images/connected-systems.png) 
    
    
2. In the **Connected Systems** screen, select the **Manage** button for the Oracle Access Governance connected system you want to manage.

    ![Select Manage](images/manage.png) 

3. Select the **Load data now** option from the **Actions** drop-down menu in the top right-hand corner. This will initiate a data load which you can track the status of in the **Activity Log.** Refresh screen and wait for the status to be **Successful**

    ![Select Load Data now](images/select-actions.png) 

    ![Data Load successful](images/load-data.png) 

## Task 2: Create Users in OCI IAM

Create users in OCI IAM and assign them to Application roles.

1. Launch a browser window. Login to OCI console , identity domain : *ag-domain* using the URL mentioned below. The OCI account sign in page appears. Enter the username and password provided during signup. 
     
    ```
    <copy>https://console.us-ashburn-1.oraclecloud.com/</copy>
    ```
    ![Login OCI console](images/oci-login-console.png)


2. Click the Navigation Menu icon in the top left corner to display the Navigation menu. Click Identity and Security in the Navigation menu. Select Domains from the list of products.

    ![Navigate to Domains](images/navigate-select-domain.png)


3. On the Domains page, Click on Identity-domain : *ag-domain* you have created. 

    ![Navigate to Identity Domains](images/open-domains.png)

   Select *Users*. Click on *Create User*

     ![Navigate to Users](images/navigate-to-users.png)

4. Enter the following details to create 3 users - Pamela Green (Campaign Administrator), Harlan Bullard (Manager), Mark Hernandez (Employee User) in IAM.


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

4. For each user created, an activation mail will be sent to the email-id provided in the *Task 2: Step 4* . Reset the password for the 3 users using the *Activation mail* recieved for each of them. 
    Reset password to the below mentioned password:

    **Password:**
     ```
    <copy>Oracl@123456</copy>
    ```
5. Assign Administrator Application Role to User Pamela Green

    * In the OCI console, navigate to Identity -> Domains -> Default Domain -> Oracle Cloud Services -> AG-service-instance -> Application Role. 

    * Notice the *AG Administrator* Role listed. Click on the Downward arrow on the right corner. 

    ![OIG Identity Roles and Access Policies](images/user-approle.png)

    * Click on *Assigned Users -> Manage*. Select *Pamela Green* in *Available Users.* Click on *Assign*

    ![OIG Identity Roles and Access Policies](images/user-approle-list.png)

    * The user Pamela Green is now visible under *Assigned Users*.

    ![OIG Identity Roles and Access Policies](images/user-approle-assign.png)

    * Pamela Green has been assigned with the *Administrator* application role. You can now close the window.


    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu
* **Contributors** - Edward Lu  
* **Last Updated By/Date** - Anbu Anbarasu, Cloud Platform COE, January 2023