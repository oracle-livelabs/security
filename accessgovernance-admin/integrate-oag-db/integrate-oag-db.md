# To Establish Connection to Oracle Database and Oracle Identity Governance 

## Introduction

Establish Connection to Oracle Database and Oracle Identity Governance 

* Persona: Identity Domain Administrator

*Estimated Time*: 15 minutes

### Objectives

In this lab, you will:
* To Establish Connection to Oracle Database and Oracle Identity Governance 



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




  You may now **proceed to the next lab**. 

## Learn More

* [Oracle Access Governance Create Access Review Campaign](https://docs.oracle.com/en/cloud/paas/access-governance/pdapg/index.html)
* [Oracle Access Governance Product Page](https://www.oracle.com/security/cloud-security/access-governance/)
* [Oracle Access Governance Product tour](https://www.oracle.com/webfolder/s/quicktours/paas/pt-sec-access-governance/index.html)
* [Oracle Access Governance FAQ](https://www.oracle.com/security/cloud-security/access-governance/faq/)

## Acknowledgements
* **Authors** - Anuj Tripathi, Indira Balasundaram, Anbu Anbarasu 
