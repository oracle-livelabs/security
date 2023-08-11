# Integrate Oracle Access Governance with OCI IAM 

## Introduction

As **Access Governance Administrators** they can learn to integrate Oracle Access Governance with OCI IAM. 


* Persona: Access Governance Administrator

*Estimated Time*: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Oracle Video Hub video with no sizing](videohub:1_cupvwe5w)

### Objectives

In this lab, you will:

* Configure a new OCI IAM Cloud Service Connection in Oracle Access Governance Console


## Task 1: Configure a new OCI IAM Cloud Service Connection in Oracle Access Governance Console


1.  In a browser, navigate to the Oracle Access Governance service home page using the URL noted down in *Lab 3: Task 1* and log in as a user with the **Access Governance Administrator** application role. 

  Enter Oracle Access Governance Campaign Administrator username and password (Pamela Green)

    **Username:**
    ```
    <copy>pamela.green</copy>
    ```

    **Password:**
    ```
    <copy>Oracl@123456</copy>
    ```

2.  On the Oracle Access Governance service home page, click on the Navigation Menu icon, and select **Service Administration → Connected Systems**

3. Select the **Add a connected system** button from the Connected Systems page.

      ![Select cloud service provider](images/add-system.png)

4.  Select the **Would you like to connect to a cloud service provider?** tile by clicking the Add button.
 
  ![Select cloud service provider](images/select-cloud-provider.png)

    

5. In the **Select system** step, select the **Oracle Cloud Infrastructure** tile and then click **Next.**

  ![Select cloud service provider](images/select-oci.png)

6. Enter name  and description of the connected system, and then click **Next.**

  Name: OCI-IAM
  
  Description: OCI-IAM

  ![OCI Enter details](images/enter-oci-system-name.png)


  ![OCI Enter details](images/enter-data.png)


7. To obtain the fingerprint of OCI user (agcs-user). Open a **new private browser window** and login to the OCI console **Default Domain** as the **Domain Administrator** . 


8. In the OCI console, click the Navigation Menu icon in the top left corner to display the *Navigation menu.* Click *Identity and Security* in the *Navigation menu*. Select *Domains* from the list of products.

    ![Navigate to Domains](images/navigate-domains.png)

9. On the Domains page, Click on *Default domain* 
   Ensure the **root compartment** is selected. 

    ![Navigate to Domains](images/default-domain.png)

10. Select *Users*. Click on *agcs-user*

  ![Create User](images/select-users.png)
  
11. Scroll down , click on **API keys**

  ![OCI Enter details](images/api.png)

12. Click on **Add API key** . Click on **Generate API key pair**. 
  
    ![OCI Enter details](images/add-api-key.png)
  
13. Click on **Download private key** and **Download public key**. 

  ![OCI Enter details](images/click-add.png)
  
14. Click on **Add**. 

15. Notedown the **Downloaded private key** in a text editor. This is required for the next step. 


16. Under **Configuration file preview**, note down the following details which is required for the next step. 

    - User OCID
    - Fingerprint 
    - Tenancy OCID 
    - Region 

    ![OCI Enter details](images/config-file.png)

17. Go back to the browser with Oracle Access Governance and continue to  enter the following details mentioned below: 

    **What is the OCI user's OCID?**: Enter the Oracle Cloud Identifier (OCID) for the OCI user (agcs-user) noted down from the previous step. 

    **What is the OCI user's fingerprint?**: Enter the fingerprint of the public key of the API   Signing Key  noted down from the previous step.

    **What is the OCI user's private SSH key?**: Enter the downloaded private SSH key (.pem file) from previous step for the API Signing Key. 


    **What is the OCI tenancy OCID?**: Enter the OCID for the target tenancy  noted down from the previous step.

    **What is the OCI tenancy's home region?**: Enter the home region for the target OCI tenancy, using the region identifier noted down from the previous step.

    ![OCI Enter details](images/details-entered.png)

18. Click **Add.** Click on Manage to see the status. If the connection details are successfully validated, you will see the **Success** status for the **Validate** operation. The Full Data Load operation may take upto a few minutes, depending upon the data available in your OCI tenancy. The incremental data load is run every four hours for this connected system to sync the data.

  ![OCI Connection status](images/oci-connection-status.png)


  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 