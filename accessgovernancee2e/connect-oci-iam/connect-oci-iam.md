# Integrate Oracle Access Governance with OCI IAM 

## Introduction

As OCI Tenancy Administrators and Access Governance Administrators they can learn to integrate Oracle Access Governance with OCI IAM. 

* Estimated Time: 15 minutes
* Persona: Administrator

### Objectives

In this lab, you will:
* Setup Policy to allow Oracle Access Governance to connect OCI
* Configure a new OCI IAM Cloud Service Connection in Oracle Access Governance Console

## Task 1: Setup Policy to allow Oracle Access Governance to connect OCI

1. Login to the OCI console Identity Domain: ag-domain as the Identity Domain Administrator. 

1. In the OCI console, click the Navigation Menu icon in the top left corner to display the Navigation menu. Click Identity and Security in the Navigation menu. Select Policies from the list of products.

2. On the Policies page, In the root compartment click on Create Policy to create a policy : oci-iam-policy

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


## Task 2: Configure a new OCI IAM Cloud Service Connection in Oracle Access Governance Console


1.  In a browser, navigate to the Oracle Access Governance service home page and log in as a user with the Administrator application role.

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

      ![Select cloud service provider](images/cloud-service-provider.png)

4.  Select the **Would you like to connect to a cloud service provider?** tile by clicking the Add button.
    

5. In the **Select system** step, select the **Oracle Cloud Infrastructure** tile and then click **Next.**

  ![Select cloud service provider](images/select-oci.png)

6. Enter name  and description of the connected system, and then click **Next.**

  Name: OCI-IAM
  
  Description: OCI-IAM

  ![OCI Enter details](images/enter-oci-system-name.png)

7. Enter the Tenancy OCID and Region Identifier. 

  To obtain the Tenancy OCID, navigate to user profile on the top right corner and click on Tenancy. Note the Tenancy OCID for further use. 

  ![OCI Enter details](images/navigate-tenancy.png)

  ![OCI Enter details](images/tenancy-ocid.png)

  To obtain the Region Identifier, refer to the below mentioned link.

  https://docs.oracle.com/en/cloud/paas/access-governance/cagsi

  ![OCI Enter details](images/oci-iam-details.png)

8. Click **Add.** Click on Manage to see the status. If the connection details are successfully validated, you will see the **Success** status for the **Validate** operation. The Full Data Load operation may take upto a few minutes, depending upon the data available in your OCI tenancy. The incremental data load is run every four hours for this connected system to sync the data.

  ![OCI Connection status](images/oci-connection-status.png)


  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, May 2023