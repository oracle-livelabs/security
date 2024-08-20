# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

Estimated Time: 10 Minutes.

### Objectives
- Initialize the workshop environment.

### Prerequisites
This lab assumes you have:
- An Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup 
    - Lab: Environment Setup

## Task 1: Validate That Required Processes are Up and Running.

**Note:** All screenshots for SSH terminal type tasks featured throughout this workshop were captured using the *MobaXterm* SSH Client as described in this step. As a result when executing such tasks from within the graphical remote desktop session, skip steps requiring you to login as user *oracle* using *sudo su - oracle*, the reason being that the remote desktop session is under user *oracle*.

1. Now with access to your remote desktop session, proceed as indicated below to validate your environment before you start executing the subsequent labs. The following Processes should be up and running:

    - Database Listener
    - Database Servers (emcdb and cdb1)
    - Enterprise Manager - Management server (OMS)
    - Enterprise Manager - Management Agent (emagent)
    - My HR Applications on Glassfish

2. On the web browser window on the right is a tab preloaded with *Enterprise Manager*, login with the credentials below to validate that it's operational. If the login page is not displayed on first login to the remote desktop, refresh to reload. It takes ~15 minutes for all processes to fully start.

    ```
    Username: <copy>sysman</copy>
    ```

    ```
    Password: <copy>Oracle123</copy>
    ```

    ![Enterprise Manager Login](images/em-login.png "Enterprise Manager Login")

3. Open new browser tabs and confirm successful rendering of *My HR Applications* listed below.

    - PDB1

    ```
    Prod: <copy>http://dbsec-lab:8080/hr_prod_pdb1</copy>
    ```

    ```
    Dev: <copy>http://dbsec-lab:8080/hr_dev_pdb1</copy>
    ```

    - PDB2

    ```
    Prod: <copy>http://dbsec-lab:8080/hr_prod_pdb2</copy>
    ```

    ```
    Dev: <copy>http://dbsec-lab:8080/hr_dev_pdb2</copy>
    ```

    If all are successful, then your environment is ready.  

4. If you are still unable to get all *Enterprise Manager* and all links above to render successfully, open a terminal session and proceed as indicated below to validate the services.

    - Database services (All databases and Standard Listener)

        ```
        <copy>
        sudo systemctl status oracle-database
        </copy>
        ```

        ![DB Service Status](images/db-service-status.png "DB Service Status")

    - DBSec-lab Service (Enterprise Manager 13c and My HR Applications on Glassfish)

        ```
        <copy>
        sudo systemctl status oracle-dbsec-lab
        </copy>
        ```

        ![DBSecLab Service Status](images/dbsec-lab-service-status.png "DBSecLab Service Status")

5. If you see questionable output(s), failure or down component(s), restart the corresponding service(s) accordingly

    - Database and Listener

        ```
        <copy>
        sudo systemctl restart oracle-database
        </copy>
        ```

    - DBSec-lab Service

        ```
        <copy>
        sudo systemctl restart oracle-dbsec-lab
        </copy>
        ```

You may now **proceed to the next lab**.

<!--
## Task 2 - Set Glassfish to use pdb1 database in the dbseclab VM

Here, we will modify the default Glassfish connection to target an Oracle Database 19c, so we can monitor, and block, SQL commands

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ```
    <copy>sudo su - oracle</copy>
    ```

    **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

2. Go to the scripts directory

    ```
    <copy>cd $DBSEC_LABS/sqlfw</copy>
    ```

3. Migrate the Glassfish Application connection string in order to target the 19c database

    ```
    <copy>./sqlfw_glassfish_stop_db23c.sh</copy>
    ```

    **Note**: Here, we connect Glassfish to the database **`PDB1`** on **`dbsec-lab`** VM

4. Next, verify the application functions as expected

    - Open a Web Browser at the URL *`http://dbsec-lab:8080/hr_prod_pdb1`* to access to **your Glassfish App**

        **Notes:** If you are not using the remote desktop you can also access this page by going to *`http://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:8080/hr_prod_pdb1`*
    
    - Login to the application as *`hradmin`* with the password "*`Oracle123`*"

        ```
        <copy>hradmin</copy>
        ```

        ```
        <copy>Oracle123</copy>
        ```

        ![SQLFW](./images/init-start-env-sqlfw-002.png "HR App - Login")

        ![SQLFW](./images/init-start-env-sqlfw-003.png "HR App - Login")

    - In the top right hand corner of the App, click on the **Welcome HR Administrator** link and you will be sent to a page with session data

        ![SQLFW](./images/init-start-env-sqlfw-004.png "HR App - Settings")

    - On the **Session Details** screen, you will see how the application is connected to the database. This information is taken from the **userenv** namespace by executing the `SYS_CONTEXT` function.

        ![SQLFW](./images/init-start-env-sqlfw-005.png "HR App - Session details")

    - Now, you should see **PDB1** as the **`DB_NAME`** and **dbsec-lab** as the **HOST**

You may now **proceed to the next lab**.

## Appendix 1: Managing Startup Services

1. Database services (All databases and Standard Listener)

    - Start

    ```
    <copy>sudo systemctl start oracle-database</copy>
    ```
    - Stop

    ```
    <copy>sudo systemctl stop oracle-database</copy>
    ```

    - Status

    ```
    <copy>sudo systemctl status oracle-database</copy>
    ```

    - Restart

    ```
    <copy>sudo systemctl restart oracle-database</copy>
    ```

2. DBSec-lab Service (Enterprise Manager 13c and My HR Applications on Glassfish)

    - Start

    ```
    <copy>sudo systemctl start oracle-dbsec-lab</copy>
    ```

    - Stop

    ```
    <copy>sudo systemctl stop oracle-dbsec-lab</copy>
    ```

    - Status

    ```
    <copy>sudo systemctl status oracle-dbsec-lab</copy>
    ```

    - Restart

    ```
    <copy>sudo systemctl restart oracle-dbsec-lab</copy>
    ```
-->

## Appendix 2: External Web Access

If for any reason you want to login from a location that is external to your remote desktop session such as your workstation/laptop, then refer to the details below.

1.  Enterprise Manager 13c Console

    ```
    Username: <copy>sysman</copy>
    ```

    ```
    Password: <copy>Oracle123</copy>
    ```

    ```
    URL: <copy>https://<Your Instance public_ip>:7803/em</copy>
    ```

    - *Note:* You may see an error on the browser while accessing the Web Console - “*Your connection is not private*” as shown below. Ignore and add the exception to proceed.

    ![Enterprise Manager External Login](images/login-em-external-1.png "Enterprise Manager External Login")
    ![Enterprise Manager External Login](images/login-em-external-2.png "Enterprise Manager External Login")

2. My HR Applications on Glassfish

    - PDB1
      - Prod        : `http://<YOUR_DBSECLAB-VM_PUBLIC-IP>:8080/hr_prod_pdb1`
      - Dev         : `http://<YOUR_DBSECLAB-VM_PUBLIC-IP>:8080/hr_dev_pdb1`   (bg: red)
    - PDB2
      - Prod        : `http://<YOUR_DBSECLAB-VM_PUBLIC-IP>:8080/hr_prod_pdb2`  (menu: red)
      - Dev         : `http://<YOUR_DBSECLAB-VM_PUBLIC-IP>:8080/hr_dev_pdb2`   (bg: red & menu: red)


## Acknowledgements
- **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
- **Contributors** - Marion Smith, Hakim Loumi
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - April 2024