# Create  OCI Policies, Groups and Compartments

## Introduction

As a user with a **Administrator** role in the identity domain, you can create OCI policies, groups and compartments from the **OCI** console.This lab will show you how to download the stack zip file needed to set up the OCI policies,groups and compartments needed to run this OCI-IAM Policy reviews. 

 

* Estimated Time: 15 minutes
* Persona: Identity Domain Administrator



### Objectives

In this lab, you will:
* Download the stack zip file 
* Create  OCI Policies, Groups and Compartments using the stack

## Task 1: Download the Policy stack zip file

1. Click on the link below to download the Resource Manager zip file you need to build your environment:

   [Test-IAM-Policies-Active.zip](https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/IAM-Policies-Sample.zip)

2. Save in your downloads folder.


## Task 2: Create Stack


1. Identify the Policy stack zip file downloaded in previous task of the Lab. 

2. Log in to the Identity Domain: ag-domain of Oracle Cloud as the Identity Domain Administrator.  

3. Navigate to Identity -> Domains -> ag-domain. Copy the domain url as it will be required in the further steps. 

   ![Obtain the domain url](images/domain-url.png)

4. Open up the hamburger menu in the top left corner. Click Developer Services, and choose Resource Manager > Stacks. Choose the compartment in which you would like to install the stack. Click Create Stack.

  ![Navigate to Stack](images/navigate-to-stack.png)

5. Select My Configuration, choose the .Zip file button, click the Browse link, and select the zip file that you downloaded or drag-n-drop for the file explorer.

  ![Click Create Stack](images/click-create-stack.png)

6. Click Next

  ![Click Next](images/click-next.png)

7. Under Configure variables, enter the domain url. 

  ![Configure Variables](images/configure-variables.png)

8. Click Create.

  ![Click Create](images/stack-created.png)


  ![Policy stack created](images/policy-stack-created.png)

9. Click on Plan. Once the job has succeeded , click on Apply.

  ![Policy stack Plan and Apply](images/plan-apply.png)

10. Your stack has now been created and the Apply action triggered is running to deploy your environment


  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Indira Balasundaram , Sept 2024
