# Create Compartment and Identity Domain

## Introduction

Creation of Compartment

* Persona: Default Domain Administrator

*Estimated Time*: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Oracle Video Hub video with no sizing](videohub:1_8rvbi8pv)

### Objectives

In this lab, you will:

* Create a **Compartment**
* Create an **Identity Domain**
* Activate you Account

### Prerequisites

This lab assumes you have:

* A valid Oracle OCI tenancy, with OCI administrator privileges.

## Task 1: Create Compartment

1. Login to OCI as **Default Domain Administrator**.Open up the hamburger menu in the top left corner. Click Identity and Security, and choose Identity > Compartments.

    ![Navigate to Compartments](images/navigate-comp.png)

2. Click *Create Compartment*

    ![Select Create Compartment](images/create-compartment.png)

3. Enter the details of the Identity Domain to be created. Click *Create Compartment*  

    ```
    Name: ag-compartment
    Description: Oracle Access Governance Compartment
    Parent Compartment: Ensure your root compartment is selected
    ```

    ![Create new compartment](images/new-compartment.png)

4. You have now created the Compartment **ag-compartment**

## Task 2: Create Identity Domain

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

## Task 3: Activate your Account

1. Go to your Administrator email and click **Activate Your Account**

    ![Activate Email](images/activate-email.png)

2. Enter the password in the next screen and submit

    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements

* **Authors** - Anuj Tripathi, Anbu Anbarasu
* **Last Updated By/Date** - Anuj Tripathi, October 2023
