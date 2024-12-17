# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

Estimated Time: 10 minutes maximum.

### Objectives
- Initialize the workshop environment.

### Prerequisites
This lab assumes you have:
<if type="brown">
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
</if>
<if type="green">
- An Oracle Cloud account
- You have completed:
    - Introduction Tasks
</if>

**Note:** All screenshots for SSH terminal type tasks featured throughout this workshop were captured using the *MobaXterm* SSH Client as described in this step. As a result when executing such tasks from within the graphical remote desktop session, skip steps requiring you to login as user *oracle* using *sudo su - oracle*, the reason being that the remote desktop session is under user *oracle*.

## Task 1: Validate That Required Processes are up and running

1. Now with access to your remote desktop session, proceed as indicated below to validate your environment before you start executing the subsequent labs. The following Processes should be up and running:

    - Database Listener
    - Database Servers (emcdb and cdb1)
    - Enterprise Manager - Management server (OMS)
    - Enterprise Manager - Management Agent (emagent)
    - My HR Applications on Glassfish
    - AVDF Web Console

2. On the web browser window on the right is a tab preloaded with *Enterprise Manager*, login with the credentials below to validate that it's operational

    ```
    Username: <copy>sysman</copy>
    ```

    ```
    Password: <copy>Oracle123</copy>
    ```

    ![Enterprise Manager Login](images/em-login.png "Enterprise Manager Login")

    **Note**:
    - If the login page is not displayed on first login to the remote desktop, refresh to reload.
    - It takes ~15 minutes for all processes to fully start.

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

4. If you are still unable to get all *Enterprise Manager* and all links above to render successfully, proceed as indicated below to validate the services:

    <if type="brown">
    - Open a terminal session with your SSH client on **DBSec-Lab** VM as OS user *oracle*

        ````
        <copy>sudo su - oracle</copy>
        ````

        **Note**:
        - Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle.
        - So, in that case **you don't need to execute this command**!
    </if>

    <if type="green">
    - Open a terminal session on **DBSec-Lab** VM as OS user *oracle*

        **Note**: Just double-click on the Terminal icon on the desktop to launch a session directly as oracle!
    </if>

    - Check the Database services status (All databases and Standard Listener)

        ```
        <copy>
        sudo systemctl status oracle-database
        </copy>
        ```

        ![DB Service Status](images/db-service-status.png "DB Service Status")

    - Check the DBSec-lab Service status (Enterprise Manager 13c and My HR Applications on Glassfish)

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

6. Set the AVDF Console password

    - Go to the AVDF scripts directory

        ````
        <copy>cd $DBSEC_LABS/avdf/avs</copy>
        ````

    - Learn the AVDF password you will need for the duration of the lab

        ````
        <copy>echo $AVUSR_PWD</copy>
        ````

        **Note**:
        - This new password for **AVADMIN** and **AVAUDITOR** users is randomly generated during the deployment of the Livelabs
        - At the first login on the AV Console, it will ask you to change this randomly generated password

    - Open a web browser window to *`https://av`* to access to the Audit Vault Web Console

        **Note**: If you are not using the remote desktop you can also access this page by going to *`https://<AVS-VM_@IP-Public>`*

    - Login to Audit Vault Web Console as *`AVADMIN`* (use the password randomly generated)

        ````
        <copy>AVADMIN</copy>
        ````

        ![AVDF](./images/init-start-env-avdf-001.png "AVDF - Login")

    - Reset the password

        - Set your new password
    
            ![AVDF](./images/init-start-env-avdf-002.png "AVDF - Login")
    
        - Click [**Submit**]

    - Login to Audit Vault Web Console as *`AVAUDITOR`* (use the new password randomly generated)

        ````
        <copy>AVAUDITOR</copy>
        ````

        ![AVDF](./images/init-start-env-avdf-003.png "AVDF - Login")

    - Reset the password

        - Set your new password
    
            ![AVDF](./images/init-start-env-avdf-004.png "AVDF - Login")
    
        - Click [**Submit**]

7. Login to Audit Vault Web Console as *`AVAUDITOR`* (use the newly reset password)

    ![AVDF](./images/avdf-300.png "AVDF - Login")

    **Note**: If all are successful, then your environment is ready.  

You may now **proceed to the next lab**.

<if type="brown">
## Appendix: External access
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
</if>

## Acknowledgements
- **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
- **Contributors** - Marion Smith, Hakim Loumi
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - December 2024