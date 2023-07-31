# Install Oracle Access Governance Agents for OIG and Oracle DB

## Introduction

Install Oracle Access Governance Agent 


* Persona: Identity Domain Administrator


*Estimated Time*: 15 minutes


### Objectives

In this lab, you will:
* Establish Connection between Oracle Database and Oracle Access Governance 
* Install Oracle Access Governance Agents for OIG and Oracle DB



## Task 1: Download the Agent

1. Navigate to the Connected Systems page of the Oracle Access Governance Console, by following these steps:
  From the Oracle Access Governance navigation menu icon Navigation menu, select Service Administration → Connected Systems.
  Click the Add a connected system button to start the workflow.

2. From the Add a Connected System page, Select the Add button on the Would you like to connect to a database management system? tile.

3. On the Select system step of the workflow, Select Database User Management (Oracle DB) and click Next.

  4. On the Enter Details step of the workflow, enter the details for the connected system:

          * What do you want to call your database : OAG-DB
          * How do you want to describe this database: OAG-DB

      Click Next

  5. On the Configure step of the workflow, enter the configuration details required to allow Oracle Access Governance to connect to the target database.

          * Easy Connect URL for Database: jdbc:oracle:thin:@//<—privateipaddressofcomputeinstance-->/ORCL.NETWORKSPEOSUBN.IDMOCICLOU02PHX.ORACLEVCN.COM

          * User Name: sys as sysdba

          * Password: Welcome1

          * Confirm password: Welcome1


  6. Check the right hand pane to view What I've selected. If you are happy with the details entered, select Add to create the connected system.

  7. On the Finish Up step of the workflow, you are asked to download the agent you will use to interface between Oracle Access Governance and Oracle Database. Select the Download link to download the agent zip file to the environment in which the agent will run.

## Task 2: Install Agent on Target System


1. Open the terminal.

2. Create the volume.

    ```
    <copy>mkdir  /home/opc/vol_oag_db</copy>
     ``` 

  


3. Verify the Agent zip (OAG-DB.zip) is present inside folder Downloads.

    ```
    <copy> cd /home/opc/Downloads
    ls</copy>
     ``` 

  

4. Setting the Environment variables using the below command:

    ```
    <copy> cd ~
    source oag_agent.env</copy>
     ``` 
 

2. Install the agent using the below commands:


     ```
    <copy>curl https://raw.githubusercontent.com/oracle/docker-images/main/OracleIdentityGovernance/samples/scripts/agentManagement.sh -o agentManagement.sh; 
  </copy>
     ```  
     ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag_db --agentpackage /home/opc/Downloads/OAG-DB.zip --install 
  </copy>
     ``` 
3. Start the agent with the following command: 

      ```
      <copy>sh agentManagement.sh --volume /home/opc/vol_oag_db --start</copy>
      ``` 

## Task 3 : Verify Agent Installation 

1. Login to the Oracle Access Governance Console, select the Navigation Menuicon to display the navigation menu. 
2. In the Oracle Access Governance Console, select Service Administration → Connected Systems from the navigation menu.
3. On the Connected Systems screen, the tile showing the name of the connected system shows a status of Waiting for initial connection. Click on Manage Connection. 
4. The Activity Log at the bottom of the page will show the status of the Validate operation, Pending while the agent comes up. If the agent does not come up, check the agent install and operation logs for any issues.
5. Once the agent has come up, the status of the Validate operation will show as Success.


  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
