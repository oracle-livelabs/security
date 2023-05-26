# Create Group for Access Governance

## Introduction

Create group for Access Governance. 

* Estimated Time: 15 minutes
* Persona: Campaign Administrator


### Objectives

In this lab, you will:
* Create **group** for Access Governance


## Task 1: Create AG Group 

1. In the OCI console, click the Navigation Menu icon in the top left corner to display the *Navigation menu.* Click *Identity and Security* in the *Navigation menu*. Select *Domains* from the list of products.

    ![Navigate to Domains](images/navigate-select-domain.png)

2. On the Domains page, Click on *ag-domain* which is the identity domain you have created. Select *Groups*. Click on *Create Group*

    ![Select the Identity Domain](images/select-identity-domain.png)

    ![Select Groups](images/select-groups.png)

    Enter the following details to create the *ag-group*
    ```
    Name: ag-group
    Description: Access governance group to manage users 
    Users: Select the Admin user from the list of users. 
    ```
    Click *Create*

    ![Create AG Group](images/create-ag-group.png)

    The *Group* has been created succesfully. 

  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, May 2023
