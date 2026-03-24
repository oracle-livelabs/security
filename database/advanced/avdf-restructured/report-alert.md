# Continuous vigilance: report and alert

## Introduction
Consider establishing a process of continuous monitoring to help meet the requirements of various regulations using the pre-defined reports of AVDF. Consider alerts to pro-actively notify you on actionable events that need to be prioritized for mitigation.

*Estimated Lab Time:* 30 minutes

*Version tested in this lab:* Oracle AVDF Next Gen

### Video Preview

Watch a preview of "*LiveLabs - Oracle Audit Vault and Database Firewall*" [](youtube:eLEeOLMAEec)


### Objectives
- Review the pre-defined reports like User access rights and activity on sensitive Data
- Tracking Data Changes (Auditing "Before-After" Values)


## Task 1: Review important pre-defined reports
### Step 1: User access rights and user activity on sensitive Data

1. Go back to Audit Vault Web Console as *`AVAUDITOR`*

    ![AVDF](./images/avdf-300.png "AVDF - Login")

2. View the Sensitive Data

    - Click the **Reports** tab

    - On the left side menu, select **Compliance Reports** and make sure "**Data Private Report (GDPR)**" is selected as "**Compliance Reports Category**"

    - Then, click [**Go**] to associate a pluggable database

        ![AVDF](./images/avdf-022a.png "Associate a database to the report")

        **Note**: You can check your compliance with the main regulations in force around the world

        ![AVDF](./images/avdf-022b.png "Compliance regulations")

    - Select **Customer_orders (Oracle Database)** to associate

        ![AVDF](./images/avdf-601.png "Associate a database to the report")

    - Click [**Save**]

    - Once you associate the target with the report, click on **Sensitive Data** report

        ![AVDF](./images/avdf-023a.png "Sensitive Data report")

        ![AVDF](./images/avdf-023b.png "Sensitive Data report")

        **Note:** Here you can see the Data Privacy report of the Schema, Objects, Object Types, and Column Name and Sensitive Types

2. If you want to see the associated global set, then on this report click **Actions** -> **Select Columns**

    - Select **"Sensitive Objects Sets"** and click on **Apply**

        ![AVDF](./images/avdf-602.png "Sensitive Data report")

    - You will see the global set associated with these sensitive objects

        ![AVDF](./images/avdf-603.png "Sensitive Data report")

3. You can also view additional **Compliance Reports** about Sensitive Data

    ![AVDF](./images/avdf-024.png "Compliance Reports")

### Step 2: Tracking Data Changes (Auditing "Before-After" Values)
In this section, we will only see the change report for **customer_orders**, where all the configuration has been already done during the deployment


1. Check if the registed transaction log trail for **customer_orders** is started

    - Click on "**Targets**"
    
    - Then click on **customer_orders**

        ![AVDF](./images/avdf-621.png "Start Audit Trail")

        **Note:**
        - You should see the status **COLLECTING** or **IDLE**
        - If not then login as **AVADMIN** and start the transaction log trail for **customer_orders**

2. Click on the sub-menu **Audit Trail** on the left to check that your page looks like this (from **AVAUDITOR** login)

    ![AVDF](./images/avdf-551.png "Status of the new Audit Trail")

    **Note:** Attention, don't go to next step if **`UNIFIED_AUDIT_TRAIL`** and **TRANSACTION LOG** for **customer_orders** is not in the **COLLECTING** or **IDLE** status!

3. Now, generate value changes in database and view the Data Modification Before-After Values Reports

    - By default, in the dbseclab VM, the Oracle GoldenGate software has been already installed and pre-configured
    
    - Go back to your terminal session to ensure the Golden Gate Administration Service is up and running

        ````
        <copy>./avs_start_ogg.sh</copy>
        ````

        ![AVDF](./images/avdf-028b.png "Start the Golden Gate Administration Service")

    - Login to your GoldenGate Web Console

        - Open a web browser window to *`http://dbsec-lab:50002`*

            **Note:** If you are not using the remote desktop you can also access this page by going to *`http://<DBSecLab-VM_@IP-Public>:50002`*

        - Login to Golden Gate Web Console as *`OGGADMIN`* with the password "*`Oracle123`*"

            ````
            <copy>oggadmin</copy>
            ````

            ````
            <copy>Oracle123</copy>
            ````

            ![AVDF](./images/avdf-029.png "Golden Gate - Login")

    - **Start OGG** (Oracle Golden Gate) extracts from the OGG Web Console, click [**Action**] for the *`cust1`* extract and start it

        ![AVDF](./images/avdf-622.png "Start OGG PDB2 extract Service")

    - Go back to your DBSecLab VM and generate data and object changes with 2 different privileged users for **customer_orders**

        ````
        This is a new script with some DML activity on Customer Orders (update,delete)
        <copy>./avs_generate_customer_order_prod_changes.sh cust1</copy>
        ````
        
        ![AVDF](./images/avdf-042.png "Generate data")

4. Go back to Audit Vault Web Console as *`AVAUDITOR`*"

    ![AVDF](./images/avdf-300.png "AVDF - Login")

5. Click the **Reports** tab

6. Under **Activity Reports**, in the **Data Access & Modification** section, click **Data Modification Before-After Values**

    ![AVDF](./images/avdf-043a.png "Data Modification Before-After Values")

7. You should see a "Before-After values" output similar to the following screenshot including the changes just generated previously:

    ![AVDF](./images/avdf-043b.png "See a Before-After values output")

    **Note:** If you are not seeing Before/After value changes in Audit Vault:
    - **Restart OGG** (Oracle Golden Gate) Extracts (from the Golden Gate Web Console, click [**Action**] for the `cust1` extract, stop and start it)
    - Ensure you properly executed the scripts in `Before_and_After_Changes` folder to create the "`C##GGAVADMIN`" user and setup the database
    - Check if the Timezone of your Audit Trail is correctly set to your VM Timezone
    - Check your Audit Trail is up and running

## Task 2: Review alerts generated

1. Go to Audit Vault Web Console as *`AVAUDITOR`*

2. Click the **Alerts** tab


3.  View the Alerts that have occurred 

    ![AVDF](./images/avdf-654.png "View the alerts")

    **Note**: If you don't see them, refresh the page because the system catch the alerts every minute

4. Click on the details of one of the alerts

    ![AVDF](./images/avdf-655.png "View an alert")



>**What did we learn in this lab**
>
>>- How to monitor and analyse user rights and activites sensitive objects
>>- Tracking "Before-After" value report for Oracle database for the compliance purpose
>>- How to get notified through AVDF powerful alert policy engine 


## Acknowledgements
- **Author** - Angeline Dhanarani, Database Security - Product Manager
- **Contributors** - Nazia Zaidi, Database Security - Product Manager
- **Last Updated By/Date** - Angeline Dhanarani, Database Security - Product Manager - April 2026
