# Install and configure Oracle Access Governance agent

## Introduction

OAG Agent will be installed and configured. 

*Estimated Lab Time*: 15 minutes

Watch the video below for a quick walk-through of the lab.
[Oracle Access Governance Agent install](videohub:1_u4xrvpak)

### Objectives

In this lab, you will:

* Download the Agent to perform the integration with OIG
* Install and Configure **OAG Agent.**

### Prerequisites
This lab assumes you have:
- A valid Oracle OCI tenancy, with OCI administrator privileges.


## Task 1: Integrate with Oracle Identity Governance

1. On the Oracle Access Governance service home page, click on the Navigation Menu icon and select **Service Administration** and then **Connected Systems.**

    ![Access Governance console - Connected Systems](images/connected-systems.png)

2. Click on **Add a connected system**

    ![Add - Connected System](images/add-connected-system.png)

3. On the tile labeled **Would you like to connect to an Identity Governance System** select the **Add** button.
    ![Access Governance console - Connected Systems-Add](images/connected-system-page.png)

4. Click **Close** on the information pop-up to navigate to the **Add an Identity Governance System** page and begin the configuration.

    ![Close the Pop-up window](images/pop-up.png)


5. On the **Select System** step, select the tile for **Oracle Identity Governance** to configure the agent for a target Oracle Identity Governance connected system, and then click **Next.**


    ![Access Governance console - Connected Systems-Next](images/select-oig.png)


6. On the **Enter Details** step, enter the following details:

    * **Name:** oag
    * **Description:** oag
    * **Click Next.**

    ![Access Governance console - Connected Systems-OIG](images/oag-select-system.png)

   

7. On the **Configure** step, enter connection details for the target system:

    **JDBC URL:** 
    Replace the placeholder in the below url with the private ip of your compute instance. Refer to *Lab 3 : Task 3*  for the private ip of your compute instance. 
    ```
    <copy>jdbc:oracle:thin:@//<--privateipofyourcomputeinstance-->:1521/ORCL.NETWORKSPEOSUBN.IDMOCICLOU02PHX.ORACLEVCN.COM</copy>
    ```
    **OIG Database User Name:**
    ```
    <copy>DEV_OIM</copy>
    ```
    **Password:**
    ```
    <copy>Welcome1</copy>
    ```
    **Confirm Password:**
    ```
    <copy>Welcome1</copy>
    ```
    **OIG Server URL:** 
    Replace the placeholder in the below url with the private ip of your compute instance. Refer to *Lab 3 : Task 3*  for the private ip of your compute instance. 
    ```
    <copy>http://<--privateipofyourcomputeinstance-->:14000</copy>
    ```
    **OIG Server User Name:** 
    ```
    <copy>xelsysadm</copy>
    ```
     **OIG Server User Password:** 
    ```
    <copy>Welcome1</copy>
    ```
    **OIG Server Confirm Password:** 
    ```
    <copy>Welcome1</copy>
    ```

     ![Configure Details](images/oag-connection-details.png)

8. On the Download Agent step, select the *Download link* and download the agent zip file. The zip file is present in: /home/opc/Downloads


    ![Download the agent](images/oag-download-link.png)

9. You can verify the downloaded agent zip file.

     ![Navigate to file system](images/locate-zip.png)

     ![Verify the zip file](images/verify-zip.png)



## Task 2: Install OAG Agent on the Compute Instance and Configure

1. Open the terminal session.

    ![Open terminal session](images/open-terminal-window.png) 

2. Move the downloaded zip file (oag.zip) present in the /home/opc/Downloads folder to /home/opc/zip_oag folder.
    
    ```
    <copy>mv /home/opc/Downloads/oag.zip /home/opc/zip_oag</copy>
    ```
    ![Move the OAG Agent to zip_oag](images/move-oag-agent.png) 

    Verify the Agent zip (oag.zip) is present inside folder zip_oag.
    ```
    <copy>cd /home/opc/zip_oag</copy>
    <copy>ls</copy>
    ```
    ![Verify the Agent zip oag.zip](images/env_setup.png) 

     

    
3. Setting the Environment variables using the below command:

    ```
    <copy>cd ~</copy>
    <copy>source oag_agent.env</copy>
    ```
    ![Initialize the environment variable](images/terminal-oag.png) 
 

4. Install the agent

    ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag --agentpackage /home/opc/zip_oag/oag.zip --install</copy>
    ```
    ![Install the agent](images/agent-install.png) 

5. Start the agent
     ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag --start</copy>
    ```
    ![Start the agent](images/agent-start.png) 

6. Verify the agent

     ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag --status</copy>
    ```
    ![Verify the agent](images/agent-status.png) 



    You may now **proceed to the next lab.**

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu
* **Contributors** - Edward Lu 
* **Last Updated By/Date** - Anbu Anbarasu, Cloud Platform COE, January 2023