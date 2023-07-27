# Establish Connection between Oracle Database and Oracle Access Governance 

## Introduction

Integrate with Database User Management (Oracle)

*Estimated Time*: 15 minutes
* Persona: Identity Domain Administrator


### Objectives

In this lab, you will:
* To Establish Connection between Oracle Database and Oracle Access Governance 

### Prerequisites

This lab assumes, you have:

  Before you install and configure a Database User Management (Oracle) connected system, you
  should consider the following pre-requisites and tasks.

* Certified Components:
  The target system can be any one of the following:
  
  Oracle Database 12c as single database, pluggable database (PDB), or Oracle RAC implementation.


* Supported Connector Operations

  The Database User Management (Oracle) connected system supports the following connector operations:

    - User Management
    - Create user
    - Reset password
    - Entitlement Grant Management
    - Add roles
    - Revoke Roles
    - Add privileges
    - Revoke privileges


## Task 1 : Verify Docker is up and Running 

1. Open a terminal session. 


2. Check the version of the docker.

    ```
    <copy>docker -v</copy>
    ```

    ```
    Expected output: Docker version 23.0.0, build e92dd87
    ```
    

3. Validate the status to verify if docker service is up/running

    ```
    <copy>systemctl status docker</copy>
    ```


     Enter **Ctrl+C** to return to the command prompt

## Task 2: Start the Oracle Identity Governance (OIG) DB Service

1. Move to the directory where the script files are located.
     
    ```
    <copy>cd /scratch/idmqa/scripts</copy>
    ```


2. List the files inside the directory.

    ```
    <copy>ls</copy>
    ```


3. Start DB and all servers manually,using below scripts.

    ```
    <copy>./start_db.sh</copy>
    ```
    Wait till DB gets started.

4. Now start the OIG services, using the below command.

    ```
    <copy>./start_all_servers.sh</copy>
    ```


## Task 3: Download the Agent

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


  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
