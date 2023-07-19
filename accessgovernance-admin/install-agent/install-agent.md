# Install Agent 

## Introduction

Install Oracle Access Governance Agent 

* Estimated Time: 15 minutes
* Persona: Identity Domain Administrator


### Objectives

In this lab, you will:
* Install Oracle Access Governance Agent 


## Task 1 : Install Agent on Target System


1. Open the terminal.

2. Move the downloaded zip file (oag.zip) present in the /home/opc/Downloads folder to /home/opc/zip_oag_db folder.

    ```
    <copy>mv /home/opc/Downloads/OAG-DB.zip /home/opc/zip_oag_db</copy>
     ``` 

  


3. Verify the Agent zip (OAG-DB.zip) is present inside folder zip_oag_db.

    ```
    <copy> cd /home/opc/zip_oag_db
    ls</copy>
     ``` 

  

4. Setting the Environment variables using the below command:

    ```
    <copy> cd ~
    source oag_agent.env</copy>
     ``` 
 

2. Install the agent using the below commands:


     ```
    <copy>curl https://raw.githubusercontent.com/oracle/docker-images/main/OracleIdentityGovernance/samples/scripts/agentManagement.sh -o agentManagement.sh ; 
  </copy>
     ```  
     ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag_db --agentpackage /home/opc/zip_oag_db/OAG-DB.zip --install 
  </copy>
     ``` 
3. Start the agent with the following command: 

   ```
  <copy>curl https://raw.githubusercontent.com/oracle/docker-images/main/OracleIdentityGovernance/samples/scripts/agentManagement.sh -o agentManagement.sh ;
  </copy>
     ```  
     ```
    <copy>sh agentManagement.sh --volume /home/opc/vol_oag_db --start</copy>
     ``` 

## Task 2 : Verify Agent Installation 

1. Login to the Oracle Access Governance Console, select the Navigation Menuicon to display the navigation menu. 
2. In the Oracle Access Governance Console, select Service Administration → Connected Systems from the navigation menu.
3. On the Connected Systems screen, the tile showing the Identity Data Orchestrator created in Install Agent on Target System shows a status of Waiting for initial connection. Click on Manage → Troubleshooting Checklist.
4. The Activity Log at the bottom of the page will show the status of the Validate operation, Pending while the agent comes up. If the agent does not come up, check the agent install and operation logs for any issues.
5. Once the agent has come up, the status of the Validate operation will show as Success.


  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgments
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
* **Last Updated By/Date** - Anbu Anbarasu, June 2023
