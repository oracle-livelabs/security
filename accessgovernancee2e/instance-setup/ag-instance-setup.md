# Setup and configure Oracle Access Governance service instance

## Introduction

In this lab we will setup the OAG service instance and make configurations required to successfully run this workshop.

*Estimated Lab Time*: 15 minutes

### Objectives

In this lab, you will:
 * Create AG Service Instance
 * Access the AG console url
 * Download the Agent to perform the integration with OIG

### Prerequisites
This lab assumes you have:
- A valid Oracle OCI tenancy, with OCI administrator privileges. 

## Task 1: Create AG Service instance 

1. Launch a browser window. Login to OCI console using the URL mentioned below. The OCI account sign in page appears. Enter the username and password.
     
    ```
    <copy>URL: https://console.us-ashburn-1.oraclecloud.com/</copy>
    ```
    ![Create Service Instance](images/oci-login-console.png)

2. Click the Navigation Menu icon in the top left corner to display the *Navigation menu.* Click *Identity and Security* in the *Navigation menu*. Select *Access Governance* from the list of products.
    ![Create Service Instance](images/oci-console.png)

3. On the Access Governance page, select *Service Instances.*Click on *Create Service Instance*


    ```
    Name: Service-Instance
    Description: Compartment
    Compartment: Ensure your compartment is selected
    ```
    ![Create Service Instance](images/create-service-instance.png)
    ![Service Instance details](images/service-instance.png)

4. Wait for the service instance to have the *Active* status 

    ![Service Instance is Active](images/ag-url.png)

5. Click on the Serivce Instance to access the URL. 

    ![Access Governance console](images/ag-console.png)

## Task 2: Integrate with Oracle Identity Governance

1. On the Oracle Access Governance service home page, click on the Navigation Menu icon and select **Service Administration** and then **Connected Systems.**

    ![Access Governance console - Connected Systems](images/connected-systems.png)

2. On the tile labeled **Would you like to connect to an Identity Governance System** select the **Add** button.
    ![Access Governance console - Connected Systems-Add](images/connected-system-page.png)

3. Click **Close** on the information pop-up to navigate to the **Add an Identity Governance System** page and begin the configuration.

    ![Close the Pop-up window](images/pop-up.png)


4. On the **Select System** step, select the tile for **Oracle Identity Governance** to configure the agent for a target Oracle Identity Governance connected system, and then click **Next.**


    ![Access Governance console - Connected Systems-Next](images/select-oig.png)


5. On the **Enter Details** step, enter the following details:

    * **Name:** OIG
    * **Description:** OIG
    * **Click Next.**

    ![Access Governance console - Connected Systems-OIG](images/select-system.png)

   

6. On the **Configure** step, enter connection details for the target system:

    * **JDBC URL:** jdbc:oracle:thin:@//<--privateipofyourcomputeinstance-->:1521/ORCL.NETWORKSPEOSUBN.IDMOCICLOU02PHX.ORACLEVCN.COM
    * **OIG Database User Name:** DEV_OIM
    * **Password:** Welcome1
    * **Confirm Password:** Welcome1
    * **OIG Server URL:** http://<--privateipofyourcomputeinstance-->:14000
    * **OIG Server User Name:** xelsysadm
    * **OIG Server Password:** Welcome1
    * **OIG Server Confirm Password:** Welcome1

     ![Configure Details](images/connection-details.png)

7. On the Download Agent step, select the *Download link* and download the agent zip file. The zip file is present in: /home/opc/Downloads


    ![Download the agent](images/download-link.png)
You may now **proceed to the next lab**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Author** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, Cloud Platform COE, January 2023