# Oracle Database Security Central (Security Central)

## Introduction
This workshop introduced the key features and capabilities of Security Central. If you would like to repeat the exercises or start fresh, you can reset the lab environment and begin again from the beginning.

*Estimated Lab Time:* 5 minutes

*Version tested in this lab:* Oracle Database Security Central

### Video Preview

Watch a preview of "*LiveLabs - Oracle Database Security Central*" [](youtube:eLEeOLMAEec)


### Objectives
- Rest the lab environment

## Task: Reset the Security Central Lab Config

1. Reset **Golden Gate** configuration for **Customer_orders** only!

    - Go back to Security Central Console as *`AVADMIN`*"

    - Click the **Targets** tab

    - Click the Target Name **Customer_orders**

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

    - Delete the "**Credentials**" for **cust1** only by clicking on the "**Delete**" button

        ![AVDF](./images/avdf-257.png "Delete credentials")

    - Click [**Delete**] to confirm the deletion

        ![AVDF](./images/avdf-258.png "Confirm the deletion")

    - In the top left corner, open the **Burger menu** and select **Overview**

        ![AVDF](./images/avdf-033a.png "Select Overview")

    - Stop the "**Extracts**" service for **cust1** only by clicking on the "**Actions**" button and selecting "**Force Stop**"

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

2. **Now, the Security Central configuration is correctly reset!**

## Acknowledgements
- **Author** - Nazia Zaidi, Database Security - Product Manager
- **Contributors** - Angeline Dhanarani, Database Security - Product Manager
- **Last Updated By/Date** - Angeline Dhanarani, Database Security - Product Manager - Product Manager - April 2026
