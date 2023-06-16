# Creation of Identity Domain

## Introduction

Creation of Identity Domain. 

*Estimated Lab Time*: 15 minutes

*Persona*: Default Domain Administrator


### Objectives

In this lab, you will:
 * Create an **Identity Domain**
 * Activate you **Account**

### Prerequisites
This lab assumes you have:
- A valid Oracle OCI tenancy, with OCI administrator privileges.


## Task 1: Create Identity Domain 

1. Login to OCI console as **Default Domain Administrator**. Open up the hamburger menu in the top left corner. Click Identity and Security, and choose Identity > Domains. 

    ![Navigate to domains](images/navigate-to-domains.png)

2. Select the *ag-compartment* in which you will create the identity domain. Click *Create Domain*

    ![Select Create Identity Domain](images/create-domains.png)

3. Enter the details of the Identity Domain to be created. Click *Create*  
    
    ```
    Display Name: ag-domain
    Description: Oracle Access Governance Identity Domain
    Domaintype: Free
    Domain Administrator: Select the checkbox for Create an administrative user for this domain 
    Administrator first name: Enter administrator  first name 
    Administrator last name: Enter administrator last name 
    Administrator username/email: Enter the administrator email id
    Compartment: Ensure ag-compartment compartment is selected
    ```


    ![Click Create Identity Domain](images/click-create-domain.png) 

    ![Complete Create of Identity Domain](images/complete-creation-domain.png)

     
4. You have now created the Identity Domain. 


    ![Active Identity Domain](images/active-identity-domain.png) 

5. Logout of your Cloud Account by clicking on the *User icon* in the top right corner. Click on *Sign out* option. 

## Task 2: Activate your Account 

1. Go to your Administrator email and click **Activate Your Account**

    ![Activate Email](images/activate-email.png)

2. Enter the password in the next screen and submit



    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu
* **Last Updated By/Date** - Anbu Anbarasu, May 2023