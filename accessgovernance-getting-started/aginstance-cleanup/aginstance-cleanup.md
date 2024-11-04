# Cleanup the Environment 

## Introduction

Upon completing your labs, we recommend that you perform a cleanup to dispose the Access Governance service instance. This lab will guide you to properly destroy the resource.


*Estimated Lab Time*: 5 minutes


### Objectives

In this lab, you will:

 * Delete the Access Governance service instance, OCI Identity domain and OCI Resources


### Prerequisites

This lab assumes you have:

A valid Oracle OCI tenancy, with OCI administrator privileges.



## Task 1: Delete the Access Governance service instance

1. Log in to Oracle Cloud as the **Default Domain Administrator**

   ![Open OCI console](images/open-oci-console.png)

2. Click the Navigation Menu icon in the top left corner to display the Navigation menu. Click Identity and Security in the Navigation menu. Select Access Governance from the list of products.

   
    ![Navigate to Access Governance](images/access-governance.png)

    
3. On the Access Governance page, select Service Instances. Click on the Service Instance **service-instance** you created in *Lab 2: Task 1* 
 

    ![Validate the status of docker](images/service-instance.png) 

4. Click on *Delete*. Prompt appears, confirm the *Delete* option. 

    ![Validate the status of docker](images/delete-service-instance.png) 

5. Now the Access Governance service instance has been successfully deleted. 


## Task 2: Run the Destroy Job  

1. Navigate to **Resource Manager -> Stacks -> Stack details** 

    ![Open OCI console](images/destroy-job.png)

2. Click on **Destroy** job. 

## Task 3: Deactivate Identity Domain


1. Navigate to **Identity -> Domain -> ag-domain**. Click on **More actions -> Deactivate**

    ![Open OCI console](images/deactivate-domain.png)

2. Click on **Deactivate domain**

    ![Open OCI console](images/confirm-deactivate.png)

## Task 4: Destroy Terraform Stack that was used to create resources - Compartment, Identity Domain, AG Users and Policies for Access Governance 

1. Navigate to **Resource Manager -> Stacks -> Stack details** 

    ![Open OCI console](images/destroy-job.png)

2. Click on **Destroy** job. Once it has completed, Under **More Actions** select **Delete stack**

    ![Open OCI console](images/delete-stack.png)


    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, May 2023