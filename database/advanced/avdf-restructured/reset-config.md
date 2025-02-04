# Oracle Audit Vault and DB Firewall (AVDF)

## Introduction
This workshop introduces the various features and functionality of Oracle Audit Vault and DB Firewall (AVDF). It gives the user an opportunity to learn how to configure those appliances in order to audit, monitor and protect access to sensitive data.

*Estimated Lab Time:* 110 minutes

*Version tested in this lab:* Oracle AVDF 20.13

### Video Preview

Watch a preview of "*LiveLabs - Oracle Audit Vault and Database Firewall*" [](youtube:eLEeOLMAEec)


### Objectives
- Assess the security posture of the registered Oracle database targets
- Set a baseline and detect drift of the security configuration
- Discover sensitive data
- Configure the auditing for the Oracle database
- Explore the interactive reporting capabilities, including user entitlement
- Simply compliance with pre-defined reports, including activity on sensitive data
- Train the DBFW for the authorized application query and prevent the SQL injection


### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

### Lab Timing (estimated)


| Step No. | Feature | Approx. Time |
|--|------------------------------------------------------------|-------------|
|| **AVDF Labs**||
|04| Reset the password | <5 minutes|
|05| Assess and Discover | 20 minutes|
|06| Audit and Monitor | 20 minutes|
|07| Report and Alert | 20 minutes|
|08| Protect and Prevent | 20 minutes|
|| **Optional**||
|09| Advanced features configuration | 25 minutes|
|10| Reset the AVDF labs config | <5 minutes|

## Lab 10: Reset the AVDF Lab Config

1. Reset **Golden Gate** configuration for **pdb1** only!

    - Go back to Audit Vault Web Console as *`AVADMIN`*"

        ![AVDF](./images/avdf-400.png "AVDF - Login")

    - Click the **Targets** tab

    - Click the Target Name **pdb1**

        ![AVDF](./images/avdf-250.png "Select the Target Name")

    - In the section **Audit Data Collection**, select "**/u01/app/oracle/product/ogg/var/lib/data**" and click [**Stop**]

        ![AVDF](./images/avdf-254.png "Stop the Golden Gate Audit Data Collection")

    - Refresh the page to be sure that the service is stopped

        ![AVDF](./images/avdf-255.png "Check that the service is stopped")

    - Select "**/u01/app/oracle/product/ogg/var/lib/data**" Audit Trail and click [**Delete**]

        ![AVDF](./images/avdf-256.png "Delete the Golden Gate Audit Data Collection")

    - Login to your GoldenGate Web Console

        - Open a web browser window to *`https://dbsec-lab:50002`*

            **Note**:If you are not using the remote desktop you can also access this page by going to *`https://<DBSecLab-VM_@IP-Public>:50002`*

        - Login to Golden Gate Web Console as *`OGGADMIN`* with the password "*`Oracle123`*"

            ````
            <copy>oggadmin</copy>
            ````

            ````
            <copy>Oracle123</copy>
            ````

            ![AVDF](./images/avdf-029.png "Golden Gate - Login")

    - In the top left corner, open the **Burger menu** and select **Configuration**

        ![AVDF](./images/avdf-030a.png "Golden Gate - Configuration")

    - Delete the "**Credentials**" for **pdb1** only by clicking on the "**Delete**" button

        ![AVDF](./images/avdf-257.png "Delete credentials")

    - Click [**Delete**] to confirm the deletion

        ![AVDF](./images/avdf-258.png "Confirm the deletion")

    - In the top left corner, open the **Burger menu** and select **Overview**

        ![AVDF](./images/avdf-033a.png "Select Overview")

    - Stop the "**Extracts**" service for **pdb1** only by clicking on the "**Actions**" button and selecting "**Force Stop**"

        ![AVDF](./images/avdf-259.png "Force Stop the service")

    - Click [**OK**] to confirm the action

        ![AVDF](./images/avdf-260.png "Confirm the action")

    - Delete the "**Extracts**" service by clicking on the "**Actions**" button and selecting "**Delete**"

        ![AVDF](./images/avdf-261.png "Delete the Extracts service")

    - Click [**OK**] to confirm the deletion

        ![AVDF](./images/avdf-262.png "Confirm the deletion")

<!--
    - Go back to your terminal session to reset Golden Gate

        ````
        <copy>$DBSEC_LABS/avdf/avs/avs_reset_ogg.sh pdb1</copy>
        ````

        ![AVDF](./images/avdf-263.png "Reset the Golden Gate configuration")

2. Delete the **Unified Audit Trail** configuration

    - Go back to Audit Vault Web Console as *`AVADMIN`*"

        ![AVDF](./images/avdf-400.png "AVDF - Login")

    - Click the **Targets** tab

    - Click the Target Name **pdb1**

    - In the section **Audit Data Collection**, select "**`UNIFIED_AUDIT_TRAIL`**" and click [**Stop**]

        ![AVDF](./images/avdf-264.png "Stop the Audit Data Collection")

    - Check that the service is stopped

        ![AVDF](./images/avdf-265.png "Check that the service is stopped")

    - Select "**`UNIFIED_AUDIT_TRAIL`**" and click [**Delete**]

        ![AVDF](./images/avdf-266.png "Delete the Audit Data Collection")

3. Then, delete the Audit Vault **Agent**

    - Click the **Agents** tab

    - Select the Agent Name **dbseclab** and click [**Deactivate**]

        ![AVDF](./images/avdf-269.png "Deactivate the Audit Vault Agent")

    - Now, the agent should be "**Not Activated**"

        ![AVDF](./images/avdf-270.png "Check that the Audit Vault Agent is deactivated")

    - Select the Agent Name **dbseclab** and click [**Delete**]

        ![AVDF](./images/avdf-271.png "delete the Audit Vault Agent")

    - Now, the agent is deleted

        ![AVDF](./images/avdf-272.png "Check that the Audit Vault Agent is deleted")

4. Finally, reset **AVDF binaries**

    ````
    <copy>
    rm -Rf $AV_HOME/*
    ll $AV_HOME

    rm -Rf $AVCLI_HOME/*
    ll $AVCLI_HOME
    </copy>
    ````

    ![AVDF](./images/avdf-273.png "Reset AVDF binaries")
-->

2. **Now, the AVDF configuration is correctly reset!**

## Acknowledgements
- **Author** - Nazia Zaidi, Audit Vault and Databse Firewall - Product Manager
- **Contributors** - Hakim Loumi - Hakim Loumi, Database Security - Product Manager
- **Last Updated By/Date** - Nazia Zaidi, Audit Vault and Databse Firewall - Product Manager - November 2024
