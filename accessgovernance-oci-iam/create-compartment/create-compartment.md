# Creation of Compartment

## Introduction

Creation of Compartment 

*Estimated Lab Time*: 15 minutes
* Persona: Default Domain Administrator


### Objectives

In this lab, you will:
 * Create a **Compartment**


### Prerequisites
This lab assumes you have:
- A valid Oracle OCI tenancy, with OCI administrator privileges.


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



## Task 2 : Create Domain Admin Policies 


1. In the OCI console, click the Navigation Menu icon in the top left corner to display the *Navigation menu.* Click *Identity and Security* in the *Navigation menu*. Select *Policies* from the list of products.

2. On the Policies page, Click on *Create Policy* to create the policy : ag-access-policy


    ```
    Name: domain-admin-policy
    Description: IAM policy (domain-admin-policy) in the COMPARTMENT to give access to the Identity Domain admin for the compartment created
    Compartment: Ensure your root compartment is selected
    Policy Builder: Select the show manual editor checkbox
    Statement :
    ```

    ```
    <copy>Allow group ag-domain/ag-group to manage all-resources in compartment ag-compartment</copy>
    ```

    Click *Create* 



    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu
* **Last Updated By/Date** - Anbu Anbarasu, May 2023