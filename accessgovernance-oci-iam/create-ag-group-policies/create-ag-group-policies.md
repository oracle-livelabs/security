# Create Groups and Policies for Access Governance

## Introduction

Create policies for Access Governance. 

* Estimated Time: 15 minutes
* Persona: Default Domain Administrator


### Objectives

In this lab, you will:
* Setup **groups** for Access Governance 
* Setup **policies** for Access Governance 
* Setup **policy** to allow Oracle Access Governance to connect OCI


## Task 1: Create AG Group 

1. Login to the OCI console Identity Domain: ag-domain as the Identity Domain Administrator. 

1. In the OCI console, click the Navigation Menu icon in the top left corner to display the *Navigation menu.* Click *Identity and Security* in the *Navigation menu*. Select *Domains* from the list of products.

    ![Navigate to Domains](images/navigate-select-domain.png)

2. On the Domains page, Click on *ag-domain* which is the identity domain you have created. Select *Groups*. Click on *Create Group*

    ![Select the Identity Domain](images/select-identity-domain.png)

    ![Select Groups](images/select-groups.png)

    Enter the following details to create the *agcs-group* and Assign **Pamela Green** user to the group
    ```
    Name: agcs-group
    Description: Access governance group to manage users 
    Users: Select the user Pamela Green from the list of users. 
    ```
    Click *Create*

    ![Create AG Group](images/agcs-group.png)

    The *Group* has been created succesfully. 


## Task 2 : Create AG Policies 


1. In the OCI console, click the Navigation Menu icon in the top left corner to display the *Navigation menu.* Click *Identity and Security* in the *Navigation menu*. Select *Policies* from the list of products.

2. On the Policies page, Click on *Create Policy* to create the policy : ag-access-policy in the root compartment. 


    ```
    Name: ag-access-policy
    Description: IAM policy for granting ag-group access to manage access governance instances
    Compartment: Ensure your  root compartment is selected
    Policy Builder: Select the show manual editor checkbox
    Statement :
    ```
     ```
    <copy>Allow group ag-domain/Domain-Administrators to manage agcs-instance in compartment ag-compartment
    Allow group ag-domain/Domain-Administrators to read objectstorage-namespace in tenancy</copy>
      ```  

    Click *Create*

    On the Policies page, In the root compartment click on Create Policy to create a policy : oci-iam-policy

    ```
    Name: oci-iam-policy
    Description: Allow Oracle Access Governance to connect OCI in tenancy
    Compartment: Ensure your root compartment is selected
    Policy Builder: Select the show manual editor checkbox
    ```
    ```
    <copy>allow resource accessgov-agent resource-scanner to read all-resources in tenancy
    allow resource accessgov-agent resource-manager to manage domains in tenancy
    allow resource accessgov-agent resource-manager to manage policies in tenancy
    </copy>
    ```
 
    Click Create

    On the Policies page, In the root compartment click on Create Policy to create a policy : agcs-policy

    ```
    Name: agcs-policy
    Description: Oracle Access Governance policy 
    Compartment: Ensure your root compartment is selected
    Policy Builder: Select the show manual editor checkbox
    ```
    ```
    <copy>ALLOW GROUP agcs-group to read all-resources IN TENANCY
    ALLOW GROUP agcs-group to manage policies IN TENANCY
    ALLOW GROUP agcs-group to manage domains IN TENANCY
    </copy>
    ```
 
    Click Create

  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, May 2023
