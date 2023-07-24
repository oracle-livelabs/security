# Create an Access Bundle

## Introduction

In this lab we will create an Access Bundle

*Estimated Lab Time*: 15 minutes


### Objectives

In this lab, you will:
 * Create an Access Bundle



## Task 1: Create an Access Bundle

1. On the Access Governance console home page, click the Access Controls tab. Then, click Select on the Access Bundles tile. 

    ![Create Access Bundle](images/navigate-access-bundle.png)
   

2. Click on Create an access bundle. 

     ![Create Access Bundle](images/create-access-bundle.png)
  

3. For your bundle settings, configure your bundle to match the following:
    •	Which target is this bundle for?: OAG-DB
    •	Who can request this bundle?: Anyone
    •	Which approval workflow should be used?: Approval-Workflow-IT-Management
    i.	You created this approval workflow earlier in this lab
    Then, Click Next. 


    ![Create Access Bundle](images/click-next.png)

4. Select the permissions to be included in the access bundle. 

    Which permissions are included in this bundle? : Select 20-30 permissions to be included in the access bundle from the list. 

     ![Create Access Bundle](images/select-permissions.png)

    Click Next. 

5. In the Add Details step, configure the following:

    •	What is the name of this bundle?: Access-Bundle-IT-Management
    •	How do you want to describe this bundle?: Type anything
    •	Authentication Type: PASSWORD
    •	Default Tablespace: USERS
    •	Leave all other options as default

     ![Create Access Bundle](images/bundle-details.png)

    Then, Click Next.

6. Review your configurations made until this point. It should look like the configurations depicted below, except for the name. Then, click Create. 

     ![Create Access Bundle](images/click-create.png)


    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 