# Review Who Has Access To What

## Introduction

Access Governance Administrator (Pamela Green) can view who has access to what. 

* Estimated Time: 5 minutes
* Persona: Access Governance Administrator

### Objectives

In this lab, you will:

* Explore **My Access**
* Explore **Enterprise Wide Browser**


## Task 1: Review Who Has Access to What - MyAccess

  In this task, you will review **Who has Access to What - MyAccess**


1. From your browser, navigate to the Oracle Access Governance Console using the URL specified in *Lab 2: Task 1: Step 4* 


2. Enter **Oracle Access Governance Administrator** username and password (Pamela Green)

    **Username:**
    ```
    <copy>pamela.green</copy>
    ```

    **Password:**
    
    The password you have set for the user in *Lab 1: Task 2: Step 5*
    

     ![Access Governance Homepage](images/ag-home-page.png)

     
  You will be navigated to the home page of your Oracle Access Governance Console.

  3. On the Oracle Access Governance Console home page, from the navigation menu, select **My Stuff -> My Access** 

    ![Access Governance My Access](images/ag-myaccess.png)


  4. Click on **Permissions** to view the **Cloud Resources** the user **Pamela Green** has access to. 

  ![Access Governance My Access Page](images/pamela-green-permission.png)

  5. Click on the **Accounts** , to view the user's account details. 

  ![Access Governance Homepage](images/pamela-green-accounts.png)

  6.  Click on the **Identity Attributes** to view the user's identity attributes.

  ![Access Governance Homepage](images/pamela-identity-attributes.png)



## Task 2: Review Who Has Access to What -  Enterprise Wide Access

  1. On the Oracle Access Governance Console home page, from the navigation menu, select **Who has Access to What -> Enterprise-wide Browser** 


  ![Access Governance Enterprise Access](images/navigate-enterprise.png)


  2. Under **Select what you want to browse** , click on **Identities** to view the user identities that have access to particular resources. 


    ![Access Governance Enterprise Access](images/enterprise-identity.png)

  3. Click on **View details** for user **Mark Hernandez** to view individual user details.

    ![Access Governance Enterprise Access](images/enterprise-identity-mark.png)

  4. You can click on **View Resources details, View Account details,View Permission details** to view them. Clicking on **create access review** will proceed to create an access review campaign for the user. 

    ![Access Governance Enterprise Access](images/view-resource.png)

    ![Access Governance Enterprise Access](images/view-resource-detail.png)

    ![Access Governance Enterprise Access](images/view-account.png)

    ![Access Governance Enterprise Access](images/view-permission.png)

    ![Access Governance Enterprise Access](images/view-permission-detail.png)


  5. Under **Select what you want to browse** , click on **Identity Collections** to view Identity Collections that are present in the system. 

    ![Identity Collection creation](images/enterprise-identity-collection.png)

    Click on **View Details** 

    ![Identity Collection creation](images/enterprise-identity-collection-detail.png)

  6. Under **Select what you want to browse** , click on **Permissions** to view permissions of the user identities.  
   

    ![Identity Collection creation](images/enterprise-permission.png)


  7. Under **Select what you want to browse** , click on **Policies** to view Policies present in OCI IAM.  

    ![Identity Collection creation](images/enterprise-policy.png)

     Click on **View Details**

    ![Identity Collection creation](images/enterprise-policy-detail.png)

  6. Under **Select what you want to browse** , click on **Resources** to view the resources associated with the user identities. Click on **View Details** to view all the user identities that have access to the particular resource.  

    ![Identity Collection creation](images/enterprise-resources.png)

 
  7. Click on the **view all accesses** to view all the access of user. 

    ![Identity Collection creation](images/enterprise-resource-detail.png)



  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Indira Balasundaram , Sept 2024
