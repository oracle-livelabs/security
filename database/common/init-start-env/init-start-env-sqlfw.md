# Initialize Environment

## Introduction

In this lab we will review and startup all components required to successfully run this workshop.

Estimated Time: 10 Minutes.

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

## Task 1 - Set Glassfish to use freepdb1 database in the DB23ai VM

**Note:** All screenshots for SSH terminal type tasks featured throughout this workshop were captured using the *MobaXterm* SSH Client as described in this step. As a result when executing such tasks from within the graphical remote desktop session, skip steps requiring you to login as user *oracle* using *sudo su - oracle*, the reason being that the remote desktop session is under user *oracle*.

Here, we will modify the default Glassfish connection to target an Oracle Database 23ai, so we can monitor, and block, SQL commands

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ```
    <copy>sudo su - oracle</copy>
    ```

    **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

2. Go to the scripts directory

    ```
    <copy>cd $DBSEC_LABS/sqlfw</copy>
    ```

3. Migrate the Glassfish Application connection string in order to target the 23ai database

    ```
    <copy>./sqlfw_glassfish_start_db23ai.sh</copy>
    ```

    ![SQLFW](./images/init-start-env-sqlfw-001.png "Set HR App with DB23ai")

    **Note**:
    - Here, we connect Glassfish to the database **`FREEPDB1`** (installed on the DB23ai VM) from the **`dbsec-lab`** VM
    - For this lab, **we only use the URL `hr_prod_pdb1` that is connected to `FREEPDB1`**!

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

    - In the top right hand corner of the App, **click** on the **Welcome HR Administrator** link and you will be sent to a page with session data

        ![SQLFW](./images/init-start-env-sqlfw-004.png "HR App - Settings")

    - On the **Session Details** screen, you will see how the application is connected to the database. This information is taken from the **userenv** namespace by executing the `SYS_CONTEXT` function.

        ![SQLFW](./images/init-start-env-sqlfw-005.png "HR App - Session details")

    - Now, you should see **FREEPDB1** as the **`DB_NAME`** and **dbsec-lab** as the **HOST**

        ![SQLFW](./images/init-start-env-sqlfw-006.png "HR App - Check the targetted database")

You may now **proceed to the next lab**.

## Appendix: Managing Startup Services

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

2. DBSec-lab Service (My HR Applications on Glassfish and other components)

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

## Acknowledgements
- **Author** - Rene Fontcha, LiveLabs Platform Lead, NA Technology
- **Contributors** - Marion Smith, Technical Program Manager
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - May 2024
