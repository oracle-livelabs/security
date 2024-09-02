# Oracle Data Safe for on-premises database

## Introduction
This workshop introduces the various features and functionality of Oracle Data Safe. It gives the user an opportunity to learn how to register an on-premise Oracle Database with Oracle Data Safe, provision audit and alert policies on your database, analyze alerts and audit reports, assess the security of your database configurations and users, and discover and mask sensitive data.

*Estimated Lab Time:* 25 minutes

*Version tested in this lab:* Oracle Data Safe on OCI and Oracle DBEE 19.23

### Video Preview

Watch a preview of "*Introduction to Oracle Data Safe (June 2022)*" [](youtube:UUc26bpdFnc)

### Objectives
- Register an on-premise Oracle Database into Oracle Data Safe with a Private endpoint
- Register an on-premise Oracle Database into Oracle Data Safe with an on-premises connector (**On your own tenany only!**)

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

### Lab Timing (estimated)

| Step No. | Feature                                                               | Approx. Time |
| -------- | --------------------------------------------------------------------- | ------------ |
| 01       | Register an on-premises Oracle Database with a Private endpoint       | 20 minutes   |
| 02       | Register an on-premises Oracle Database with an on-premises connector | 20 minutes   |
| 03       | Reset Oracle Data Safe configuration                                  | 5 minutes    |

## Task 1: Register an on-premise Oracle Database with a Private endpoint

To use a database with Oracle Data Safe, you first need to register it into Oracle Data Safe.

Two options are available:
- with a Private endpoint
- with an on-premises connector

In this lab, let's see how to register the dabase with a private endpoint

1. Open a web browser window to your OCI console and login with your OCI account

2. On the Burger menu, click on **Oracle Database**, then on "**Data Safe - Database Security**"

    ![Data Safe](./images/ds-001.png "Open Data Safe")
 
3. Click on "**Target databases**"

    ![Data Safe](./images/ds-002.png "Add Target Database")

4. On **Connectivity Options** sub-menu, click  on **Private endpoints**

    ![Data Safe](./images/ds-003.png "Private endpoints")

5. Click [**Create private endpoint**]

    ![Data Safe](./images/ds-004.png "Create private endpoint")

6. Fill out as following:

    - Name: `<Your Private Endpoint Name>` (here "*`DBSeclabs_PE-DBs`*")
    - Compartment: Select your Compartment
    - Virtual cloud network: Select your VCN
    - Subnet: Select your Subnet

       ![Data Safe](./images/ds-005.png "Set Private endpoint")

7. Click [**Create private endpoint**]

8. Once is created, the Private endpoint is "**ACTIVE**"

       ![Data Safe](./images/ds-006.png "the Private endpoint is ACTIVE")
    
    **Note**:
    - A Private IP is assigned to this Private endpoint (here '10.0.0.140')
    - There's no target database register by default

9. Now, configure your target database to be registered into Data Safe

    - Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

        ```
        <copy>sudo su - oracle</copy>
        ```

        **Note**: Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle, so, in that case **you don't need to execute this command**!

    - Go to the scripts directory

        ```
        <copy>cd $DBSEC_LABS/data-safe</copy>
        ```

    - Create the Data Safe **`DS_ADMIN`** user on **`pdb1`**

        ```
        <copy>
        ./ds_create_user.sh pdb1
        </copy>
        ```

        ![Data Safe](./images/ds-007.png "Create the Data Safe DS_ADMIN user")

        **Note**:
        - The user `DS_ADMIN` is created into your target database with `ALL` the Data Safe admin roles
        - SQL Firewall is not supported for an Oracle Database version 19c

10. Go back to the Data Safe Console to register the Target database **pdb1**

    - Click on the **Private endpoints** link
    
    ![Data Safe](./images/ds-008.png "Click on the Private endpoints link")
    
    - Click on **Target Databases** sub-menu

    ![Data Safe](./images/ds-009.png "Click on Target Databases sub-menu")

    - Click [**Register Database**]

    ![Data Safe](./images/ds-010.png "Click Register Database")

    - Fill out the "Register Target Database" as following

        - Database Type: Select *`Oracle On-Premises Database`*
        - Data Safe Target Display Name: *`DBSeclabs_PE-DBs-pdb1`*
        - Description: *`On-Premises pluggable database of dbseclab VM (pdb1)`*
        - Compartment: Select your own Compartment

            ![Data Safe](./images/ds-011.png "Fill out the Register Target Database parameters")

        - Choose a connectivity option: *`Private endpoint`*
        - Select private endpoint: Select *`DBSeclabs_PE-DBs`*
        - TCP/TLS: *`TCP`*
        - Database Service Name: *`pdb1`*
        - Database IP Address: *`10.0.0.150`*
        - Database Port Number: *`1521`*
        - Database User Name: *`DS_ADMIN`* (in uppercase)
        - Database Password: *`Oracle123Oracle123!`*
    
            ![Data Safe](./images/ds-012.png "Fill out the Register Target Database parameters")

    - Click [**Register**] to launch the registration process

    - Once is registered, the target database must be "**ACTIVE**"

        ![Data Safe](./images/ds-013.png "Target Database registered")

        **Note:**
        - On the **Target database information** tab, you can view the target database name and description, OCID, when the target database was registered and the compartment to where the target database was registered.
        - You can also view connection information, such as database type, database service name, and connection protocol (TCP or TLS). The connection information varies depending on the target database type.
        - The **Target database information** page provides options to edit the target database name and description, edit connection details, update the Oracle Data Safe service account and password on the target database (applicable to non-Autonomous Databases), and download a SQL privilege script that enables features on your target database.
        - From the **More Actions** menu, you can choose to move the target database to a different compartment, add tags, deactivate your target database, and deregister your target database.

11. Click on the **Target Databases** link to view the list of registered target databases to which you have access

    ![Data Safe](./images/ds-014.png "View the list of registered target databases")

    **Note:** All your registered target databases are listed on the right

    ![Data Safe](./images/ds-015.png "List of registered target databases")

12. Now, your target database is registered in Data Safe!

13. Let's have a look on a quick overview of the Security Center

    - Click on **Overview** sub-menu

        ![Data Safe](./images/ds-016.png "Click on Overview sub-menu")

        **Note**: In Security Center, you can access all the Oracle Data Safe features, including the dashboard, Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, Alerts, and Settings

    - Click on **Dashboard**
    
        ![Data Safe](./images/ds-017.png "Data Safe dashboard")

        **Note**:
        - Make sure your compartment is still selected under **List Scope**
        - When you register a target database, Oracle Data Safe automatically creates a security assessment and user assessment for you
        - Therefore, the Security Assessment, User Assessment, Feature Usage, and Operations Summary charts in the dashboard already have data
        - It can take several minutes to assess all the components, so if you don't see any data, please refresh the page
        - During registration, Oracle Data Safe also discovers audit trails on your target database
        - That is why the Audit Trails chart in the dashboard shows one audit trail with the status In Transition for your Autonomous Database
        - Later you start this audit trail to collect audit data into Oracle Data Safe

            ![Data Safe](./images/ds-018.png "Data Safe dashboard")

14. Now, if you want to know more about the Oracle Data Safe features, please perform the dedicated Livelabs [Get Started with Oracle Data Safe Fundamentals](https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=598)

## Task 2: Register an on-premise Oracle Database with an on-premises connector

Now, let's see the second option to register the dabase with an on-premises connector.

**Attention: In this Livelabs env, this option is only available if you are using your own OCI tenancy!**

1. Open a web browser window to your OCI console and login with your OCI account

2. On the Burger menu, click on **Oracle Database**, then on "**Data Safe - Database Security**"

    ![Data Safe](./images/ds-101.png "Open Data Safe")
 
3. Click on "**Target databases**"

    ![Data Safe](./images/ds-102.png "Add Target Database")

4. On **Connectivity Options** sub-menu, click  on **On-Premises Connectors**

    ![Data Safe](./images/ds-103.png "On-Premises Connectors")

5. Click [**Create On-Premises Connectors**]

    ![Data Safe](./images/ds-103b.png "Create On-Premises Connectors")

6. Select your Compartment and fill out as following

    - Name: `<Your On-Premises Connectors Name>` (here "*`DBSeclabs_DBs`*")
    - Decription: *`On-Premises connector for DBSec Livelabs databases`*

       ![Data Safe](./images/ds-104.png "Set OCI")

7. Click [**Create On-Premises Connectors**]

8. Once is created, the On-Premises connector is "**INACTIVE**"

       ![Data Safe](./images/ds-105.png "the On-Premises connector is INACTIVE")

9. Now, let's active it

    - Click [**Download install Bundle**] to download the zip file and enter a password of at least 15 characters (here *`Oracle123Oracle123!`*)

        ```
        <copy>Oracle123Oracle123!</copy>
        ```

       ![Data Safe](./images/ds-106.png "Download install Bundle")

    - OCI Data Safe will generate a unique On-Premises connector and it can take up to one minute

       ![Data Safe](./images/ds-107.png "Generate a unique On-Premises connector")

    - Once is generated, select **Save File** and click [**OK**] to download it into *`home/opc`*

       ![Data Safe](./images/ds-108.png "Save the generated file")

    - Browse the location where you want to store the zip file and click [**Save**]

        **Note**: The file name proposed a default value (here "*`DBSeclabs_DBs.zip`*"), please keep going with it

    - Setup the Data Safe On-Premises connector

        - Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

            ```
            <copy>sudo su - oracle</copy>
            ```

            **Note**: Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle, so, in that case **you don't need to execute this command**!

        - Copy Data Safe on-premises connector uploaded to your Data Safe directory (here *`$DS_HOME`*)

            ```
            <copy>
            sudo mv /home/opc/DBSeclabs_DBs.zip $DS_HOME
            sudo chown -R oracle:oinstall $DS_HOME
            sudo chmod -R 775 $DS_HOME
            </copy>
            ```

               ![Data Safe](./images/ds-109.png "Copy Data Safe on-premises connector uploaded")

        - Install Data Safe On-Premises connector (enter the password defined for the zip file above - here *`Oracle123Oracle123!`*)

            ```
            <copy>
            cd $DS_HOME
            unzip DBSeclabs_DBs.zip
            python setup.py install --connector-port=1560
            </copy>
            ```

            ```
            <copy>Oracle123Oracle123!</copy>
            ```

               ![Data Safe](./images/ds-110.png "Install Data Safe On-Premises connector")

            **Note**: In case of trouble, you can stop or start the Data Safe On-Premises connector with the following command lines:

            ```
            <copy>
            python $DS_HOME/setup.py stop
            python $DS_HOME/setup.py start
            </copy>
            ```

    - Go back to the Data Safe console to verify the status of the Data Safe On-Premises connector

        ![Data Safe](./images/ds-111.png "Check the status of the Data Safe On-Premises connector")

        **Note**: It sould be "**ACTIVE**" now!

10. Go back to your terminal session to create the Data Safe **`DS_ADMIN`** user on **`pdb1`**

    - Go to the scripts directory

        ```
        <copy>cd $DBSEC_LABS/data-safe</copy>
        ```

    - Create the Data Safe **`DS_ADMIN`** user on **`pdb1`**

        ```
        <copy>
        sudo sed -i -e 's|${DBUSR_PWD2}|"${DBUSR_PWD2}"|g' ds_create_user.sh
        ./ds_create_user.sh pdb1
        </copy>
        ```

    ![Data Safe](./images/ds-112.png "Create the Data Safe DS_ADMIN user")

11. On Data Safe Console, register the Target database **pdb1**

    - Click on the **On-Premises Connectors** link
    
    ![Data Safe](./images/ds-113.png "Click on the On-Premises Connectors link")
    
    - Click on **Target Databases** sub-menu

    ![Data Safe](./images/ds-114.png "Click on Target Databases sub-menu")

    - Click [**Register Database**]

    ![Data Safe](./images/ds-115.png "Click Register Database")

    - Fill out the "Register Target Database" as following

        - Database Type: Select *`Oracle On-Premises Database`*
        - Data Safe Target Display Name: *`DBSec_Livelabs_pdb1`*
        - Description: *`On-Premises pluggable database of DBSeclab VM (pdb1)`*
        - Compartment: Select your own Compartment

            ![Data Safe](./images/ds-116.png "Fill out the Register Target Database parameters")

        - Choose a connectivity option: *`On-Premises Connector`*
        - Select On-Premises Connector: Select *`DBSeclabs_DBs`*
        - TCP/TLS: *`TCP`*
        - Database Service Name: *`pdb1`*
        - Database IP Address: *`10.0.0.150`*
        - Database Port Number: *`1521`*
        - Database User Name: *`DS_ADMIN`* (in uppercase)
        - Database Password: *`Oracle123Oracle123!`*
    
            ![Data Safe](./images/ds-117.png "Fill out the Register Target Database parameters")

    - Click [**Register**] to launch the registration process

        ![Data Safe](./images/ds-118.png "Click Register")

    - Once is created, the new target should be "**ACTIVE**"

        ![Data Safe](./images/ds-119.png "New target status")

        **Note:**
        - On the **Target Database Details** tab, you can view the target database name and description, OCID, when the target database was registered and the compartment to where the target database was registered.
        - You can also view connection information, such as database type, database service name, and connection protocol (TCP or TLS). The connection information varies depending on the target database type.
        - The **Target Database Details** page provides options to edit the target database name and description, edit connection details, update the Oracle Data Safe service account and password on the target database (applicable to non-Autonomous Databases), and download a SQL privilege script that enables features on your target database.
        - From the **More Actions** menu, you can choose to move the target database to a different compartment, add tags, deactivate your target database, and deregister your target database.

12. Click on the **Target Databases** link to view the list of registered target databases to which you have access

    ![Data Safe](./images/ds-120.png "View the list of registered target databases")

    **Note:** All your registered target databases are listed on the right

    ![Data Safe](./images/ds-121.png "List of registered target databases")

13. Let's have a look on a quick overview of the Security Center

    - Click on **Overview** sub-menu

        ![Data Safe](./images/ds-122.png "Click on Overview sub-menu")

        **Note**: In Security Center, you can access all the Oracle Data Safe features, including the dashboard, Security Assessment, User Assessment, Data Discovery, Data Masking, Activity Auditing, Alerts, and Settings

    - Click on **Dashboard**
    
        ![Data Safe](./images/ds-123.png "Data Safe dashboard")

        **Note**:
        - Make sure your compartment is still selected under **List Scope**
        - When you register a target database, Oracle Data Safe automatically creates a security assessment and user assessment for you
        - Therefore, the Security Assessment, User Assessment, Feature Usage, and Operations Summary charts in the dashboard already have data
        - It can take several minutes to assess all the components, so if you don't see any data, please refresh the page
        - During registration, Oracle Data Safe also discovers audit trails on your target database
        - That is why the Audit Trails chart in the dashboard shows one audit trail with the status In Transition for your Autonomous Database
        - Later you start this audit trail to collect audit data into Oracle Data Safe

            ![Data Safe](./images/ds-124.png "Data Safe dashboard")

14. Now, if you want to know more about the Oracle Data Safe features, please perform the dedicated Livelabs [Get Started with Oracle Data Safe Fundamentals](https://livelabs.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=598)

## Task 3: Reset Oracle Data Safe configuration

### Task 3a: Reset the Private endpoint configuration

1. From the Data Safe console

    - Click on **Data Safe**

        ![Data Safe](./images/ds-201.png "Data Safe main page")

    - Click on **Target databases**

        ![Data Safe](./images/ds-202.png "Target databases")

    - Click on the target database **`DBSeclabs_PE-DBs-pdb1`**

        ![Data Safe](./images/ds-203.png "Target database to deregister")

    - Click on **More actions** and select **Deregister**

        ![Data Safe](./images/ds-204.png "Deregister the target database")

    - Click [**Deregister**] to confirm

        ![Data Safe](./images/ds-205.png "Confirm the deregistering")

    - Now the target database is deregistered

        ![Data Safe](./images/ds-206.png "The target database is deregistered")

2. Now, go back to your terminal session to drop the Data Safe **`DS_ADMIN`** user on **`pdb1`**

    ```
    <copy>
    ./ds_drop_user.sh pdb1
    </copy>
    ```

    ![Data Safe](./images/ds-207.png "Drop the Data Safe DS_ADMIN user")

3. **Now your Data Safe configuration is correctly reset!**

### Task 3b: Reset the on-premises connector configuration

1. From the Data Safe console

    - Deregister the target from Data Safe
        
        - On the Burger menu, click on **Oracle Database**, and then **Data Safe**

        - Click **Target Databases**

            ![Data Safe](./images/ds-250.png "Select the Target database")

        - Click on the **Target Name** to deregister (here "*`DBSec_Livelabs_pdb1`*")

            ![Data Safe](./images/ds-251.png "Select the Target database")

        - From the **More Actions** menu, click **Deregister**

            ![Data Safe](./images/ds-252.png "Deregister the Target database")

        - Click [**Deregister**] to confirm the deregistration

            ![Data Safe](./images/ds-253.png "Confirm the deregistration")
        
        - The target is deregistered when the status is "**DELETED**" 

            ![Data Safe](./images/ds-254.png "Check the target is deregistered")

    - Next, delete the On-Premises connector from Data Safe

        - In the "**Connectivity Options** sub-menu, click on "**On-Premises Connectors**" 

            ![Data Safe](./images/ds-255.png "Select On-Premises Connectors section")

        - Click on your **On-Premises Connector** (here "*`DBSec_Livelabs_DBs`*")

            ![Data Safe](./images/ds-256.png "Select On-Premises Connectors to delete")

        - Click [**Delete**]

            ![Data Safe](./images/ds-257.png "Delete the On-Premises Connectors")

        - Click [**Delete**] to confirm the deletion

            ![Data Safe](./images/ds-258.png "Confirm the deletion")
        
        - The On-Premises Connector should now have disappeared from the list!

2. Go back to your Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    - Delete the On-Premises connector from Database server

        ```
        <copy>
        python $DS_HOME/setup.py stop
        rm -Rf $DS_HOME/*
        </copy>
        ```

        ![Data Safe](./images/ds-259.png "Delete the On-Premises connector from Database server")

    - Drop the Data Safe **`DS_ADMIN`** user on **`pdb1`**

        ```
        <copy>
        ./ds_drop_user.sh pdb1
        </copy>
        ```

        ![Data Safe](./images/ds-260.png "Drop the Data Safe DS_ADMIN user")

3. **Now your Data Safe configuration is correctly reset!**

You may now proceed to the next lab!

## **Appendix**: About the Product
### **Overview**

Oracle Data Safe is Oracle’s platform for securing data in databases. As a native Oracle Cloud Infrastructure service, Oracle Data Safe lets you assess the security of your database configurations, find your sensitive data, mask that data in non-production environments, discover the risks associated with database users, and monitor database activity.

<!-- ![Data Safe](./images/data-safe-concept-01.png "Data Safe Concept") -->

## Want to Learn More?
Technical Documentation:
- [Oracle Data Safe website](https://www.oracle.com/database/technologies/security/data-safe.html)
- [Oracle Data Safe documentation on Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/data-safe/index.html)
- [Oracle Data Safe videos](https://docs.oracle.com/en/cloud/paas/data-safe/videos.html)
- [Oracle Data Safe data sheet](https://www.oracle.com/a/tech/docs/dbsec/data-safe/ds-security-data-safe.pdf)
- [Oracle Data Safe frequently asked questions](https://www.oracle.com/a/tech/docs/dbsec/data-safe/faq-security-data-safe.pdf)

Video:
- *Oracle Data Safe Update (May 2020)* [](youtube:SXJl-Ab_zIo)
- *Keeping your Data Safe - on-premises! (April 2021)* [](youtube:xq2gf2Gn63o)
- *Information Lifecycle Management in Data Safe (April 2021)* [](youtube:rPzumDNWBZs)
- *Advanced Data Masking scenarios in Data Safe (May 2021)* [](youtube:6h1dLzLS2p8)
- *Update on Data Safe target registration (July 2021)* [](youtube:5eMnM9mEcN0)
- *Oracle Data Safe Assessment: New features, new user interface (October 2021)* [](youtube:LzDLNUdn3hg)

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Bettina Schaeumer
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - May 2024