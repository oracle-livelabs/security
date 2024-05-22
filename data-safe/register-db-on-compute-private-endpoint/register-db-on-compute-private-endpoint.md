# Register Oracle Database 23ai on a compute instance using a Data Safe private endpoint

## Introduction

In this lab, you use the Data Safe registration wizard to register an Oracle Database 23ai on a compute instance with Data Safe. Oracle recommends that you use a Data Safe private endpoint when registering an Oracle database on a compute instance in Oracle Cloud Infrastructure.

Note: For Oracle databases on compute instances outside of Oracle Cloud Infrastructure, Oracle recommends that you use an on-premises connector during registration instead of a private endpoint.

Estimated Lab Time: 10 minutes

### Objectives

In this lab, you will:

- Copy the datasafe_privileges.sql script to your compute instance
- Create a Data Safe service account in Oracle Database 23ai
- Grant the Data Safe service account permissions to use all Data Safe features
- Register Oracle Database 23ai with Data Safe using a Data Safe private endpoint


### Prerequisites

This lab assumes you have:

- Obtained an Oracle Cloud account and signed in to the Oracle Cloud Infrastructure Console at `https://cloud.oracle.com`
- Permission in IAM to register a target database with Data Safe.
- You created a private key on your Cloud Shell machine


## Task 1: Copy the datasafe_privileges.sql script to your compute instance with Oracle Database 23ai

1. Navigate to the Data Safe **Overview** page in Oracle Cloud Infrastructure. To do this, from the navigation menu, select **Oracle Database**, and then **Data Safe - Database Security**.

2. Click the **Start wizard** button in the **Oracle databases on compute** tile.

3. Scroll down and click **Download privilege script** and save the script (`datasafe_privileges.sql`) to a location on your local computer.

4. Click **Cancel** to exit the wizard.

5. Open the script and copy all of its content to the clipboard.

6. In Cloud Shell, enter the following command to connect to the compute instance that hosts Oracle Database 23ai. Substitute `private-ip-address` with your private IP address. Enter **yes** when prompted.

    ```text
    <copy>ssh -i ~/.ssh/cloudshellkey opc@private-ip-address</copy>
    [opc@dbsec-lab:~]$
    ```

7. Switch to the `oracle` user.

    ```text
    <copy>sudo su - oracle</copy>
    [oracle@dbsec-lab:~$]
    ```

8. In Cloud Shell, in the `oracle` home directory, enter the following command to create a `datasafe_privileges.sql` file using the vi editor. 

    ```text
    [oracle@dbsec-lab:~$] <copy>vi datasafe_privileges.sql</copy>
    ```
9. Press `Escape` and then **i** to insert content. Paste the content of the script into the file, and then press **Escape** and **:wq!** to save and close the file. 



## Task 2: Create a Data Safe service account in Oracle Database 23ai

1. Run the `set-env-db.sh` script to set the environment variable to the container database (`FREE`) that contains the `FREEPDB1` pluggable database. When prompted, enter **1**.

    ```text
    <copy>source /usr/local/bin/.set-env-db.sh</copy>

    ENV VARIABLES                                            
    --------------------------------------------------------------------------------
    . ORACLE_BASE         = /opt/oracle
    . ORACLE_BASE_HOME    = /opt/oracle/product/23c/dbhomeFree
    . ORACLE_HOME         = /opt/oracle/product/23c/dbhomeFree
    . ORACLE_SID          = FREE
    . PRIVATE_IP          = 10.0.0.150
    . PUBLIC_IP          = 129.213.106.248
    . HOSTNAME            = dbsec-lab
    --------------------------------------------------------------------------------
                       Database ENV set for FREE 

    [oracle@dbsec-lab:~$]
    ```


2. Connect to the `FREE` container database as the `SYS` user using SQL*Plus.

    ```text
    <copy>sqlplus / as sysdba</copy>

    SQL*Plus: Release 23.0.0.0.0 - Developer-Release on Fri Feb 16 21:35:59 2024
    Version 23.2.0.0.0

    Copyright (c) 1982, 2023, Oracle.  All rights reserved.


    Connected to:
    Oracle Database 23ai Free, Release 23.0.0.0.0 - Developer-Release
    Version 23.2.0.0.0
    ```

3. Switch to FREEPDB1.

    ```sql
    SQL> <copy>ALTER SESSION SET CONTAINER = FREEPDB1;
    ```

4. Create the Data Safe service account named `DATASAFE$ADMIN`.

    ```sql
    SQL> <copy>CREATE USER DATASAFE$ADMIN identified by Oracle123_Oracle123</copy>
    SQL> <copy>GRANT CONNECT, RESOURCE TO DS_ADMIN;</copy>
    ```

## Task 3: Grant the Data Safe service account permissions to use all Data Safe features

1. Run the `datasafe_privileges.sql` script to grant all Data Safe permissions to `DATASAFE$ADMIN`. The following command assumes that the `datasafe_privileges.sql` script is located in the `oracle` home directory. The `ALL` permission includes the `SQL_FIREWALL` permission.

    ```sql
    SQL> <copy>@datasafe_privileges.sql DS_ADMIN GRANT ALL</copy>
    ```

2. Review the output. Notice all of the Data Safe roles that are now granted to the Data Safe service account on the database.

    ```sql
    <copy>Enter value for USERNAME (case sensitive matching the username from dba_users)
    Setting USERNAME to DATASAFE$ADMIN
    Enter value for TYPE (grant/revoke)
    Setting TYPE to GRANT
    Enter value for MODE (audit_collection/audit_setting/data_discovery/masking/assessment/sql_firewall/all)
    Setting MODE to ALL

    Granting AUDIT_COLLECTION privileges to "DATASAFE$ADMIN" ...

    Granting AUDIT_SETTING privileges to "DATASAFE$ADMIN" ...
    Granting SQL_FIREWALL privileges to "DATASAFE$ADMIN" ...

    Granting DATA_DISCOVERY role to "DATASAFE$ADMIN" ...

    Granting MASKING role to "DATASAFE$ADMIN" ...

    Granting ASSESSMENT role to "DATASAFE$ADMIN" ...
    Disconnected from Oracle Database 23ai Free, Release 23.0.0.0.0 - Developer-Release
    Version 23.2.0.0.0</copy>
    ```


## Task 4: Register Oracle Database 23ai with Data Safe using a Data Safe private endpoint

When you register the database, choose to create an Oracle Data Safe private endpoint. You need the following details about your compute instance that hosts Oracle Database 23ai during registration:

- Host name: This name is similar to **db23c-hol-2024-02-16-205833**
- Private IPv4 address: **10.0.0.155**
- VCN: **LLW Network Security Group** (unless you are using your own VCN)
- Subnet: **LLW Public Subnet** (unless you are using your own subnet)
- Network security group: **LLW Network Security Group** (unless you are using your own security group)


1. Navigate to the Data Safe **Overview** page in Oracle Cloud Infrastructure. To do this, from the navigation menu, select **Oracle Database**, and then **Data Safe - Database Security**.

2. Click the **Start wizard** button in the **Oracle databases on compute** tile.

3. For **Select database**, do the following and then click **Next**:

    - Leave **Oracle Cloud Infrastructure** selected. 
    - Select the name of host #2, which begins with **db23c-hol-**. 
    - Enter **db23ai** for the Data Safe target display name. 
    - Select your compartment.
    - Enter **FREEPDB1** as the database service name.
    - Enter **DATASAFE$ADMIN** as the Data Safe service account.
    - Enter **Oracle123_Oracle123** for the password.

4. For **Connectivity option**, do the following and then click **Next**:

    - Select **Private endpoint - Access Oracle database on compute connected via FastConnect or VPN connect**.
    - Select  Select **TCP**.
    - For **Do you want to use an existing private endpoint**, select **No**. 
    - Enter **PE1** for the private endpoint name.
    - Select your compartment.
    - Select **LLW Network Security Group** for the VCN (or select your own VCN).
    - Select **LLW Public Subnet** for the subnet (or select your own subnet).

5. For **Add security rule**, do the following and then click **Next**:

    - Select **Yes, I want to add security rules now**.
    - For **Add ingress/egress security rule to**, select **Network security group**, and then select **LLW Network Security Group**.
    
6. For **Review and Submit**, look over the details and if the configuration is correct, click **Submit**.

7. Wait for the registration process to be completed.

You may now proceed to the next lab.
