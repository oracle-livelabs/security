# Create a Centralized Policy to Provision Access Privileges

## Introduction

In this lab we will create a centralized policy to provision access privileges

*Estimated Lab Time*: 15 minutes


### Objectives

In this lab, you will:
 * Create a centralized policy to provision access privileges



## Task 1: Create a Centralized Policy to provision Access Privileges

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Policies tile. 

   ![Create Policy](images/ag-homepage.png)

    ![Create Policy](images/navigate-policies.png)


2. On the Policies page, you will see a list of your created policies. Click Create a policy. 

   ![Create Policy](images/create-policy.png)

  

3. Give your policy a name and description like the following:

    •	What do you want to call this policy?:DB Policy
    •	How would you describe this policy?: type anything

     ![Create Policy](images/build-policy.png)

4. Now on this same page, let’s add a Role Association. Lower on the page, click the “+” button and select Role association. 

     ![Create Policy](images/role-association.png)

5. Search for the Identity Collection : IT-Operations. Your selection will be marked with a green checkmark.

     ![Create Policy](images/id-collection.png)

    Then, click Next. 


6. Select the Role you want to assign. Select AG-Role and Click Next.

     ![Create Policy](images/ag-role.png)

7. On the Review and submit page, you may click Preview policy association in the bottom right corner before your create it. After, close that sidebar and click Add association. 

     ![Create Policy](images/add-association.png)

8. Finally, click Create.

     ![Create Policy](images/click-create.png)



    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 