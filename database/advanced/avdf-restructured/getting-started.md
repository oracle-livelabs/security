# Oracle Audit Vault and DB Firewall (AVDF)

## Introduction
As a security administrator, your mission is to protect and monitor a growing fleet of Oracle databases—ensuring both operational efficiency and data security. This workshop introduces you to multiple pre-seeded Pluggable Databases (PDBs), including **`Employees_search`** and **`Customer_orders`**, and demonstrates how AVDF empowers you to manage and secure a database fleet at scale.

- **Employees_search PDB** powers the company’s in-house self-service HR application, giving employees access to sensitive personal and salary information. Its integrity, availability, and security are critical to maintaining trust and operational continuity.

- **Customer_orders PDB** supports the company’s client-facing order management application, containing sensitive customer data such as order, billing, shipping, and payment information. Ensuring its accuracy, availability, and security is essential for customer satisfaction, business continuity, and commercial success.

Through this workshop, you’ll gain hands-on experience in using AVDF to monitor, protect, and manage these databases, arming you with the tools and insights to secure a real-world database fleet efficiently and confidently.

*Estimated Lab Time:* 60 minutes

*Version tested in this lab:* Oracle AVDF NextGen

### Video Preview

Watch a preview of "*LiveLabs - Oracle Audit Vault and Database Firewall*" [](youtube:eLEeOLMAEec)


### Objectives
- Assess your database: risks, users, and data of the registered Oracle database targets
- Establish visibility first: audit and monitor
- Protect and Prevent: enforce controls
- Continuous vigilance: report and alert

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
|04| Access AVDF console | <5 minutes|
|05| Assess your database: risks, users, and data | 10 minutes|
|06| Establish visibility first: audit and monitor | 10 minutes|
|07| Protect and Prevent: enforce controls | 30 minutes|
|08| Continuous vigilance: report and alert | 5 minutes|
|| **Optional**||
|09| Reset the AVDF labs config | <5 minutes|

## Lab 4: Access AVDF console

You have been given a randomly generated password for the *`AVADMIN`* and *`AVAUDITOR`* user login for the AV console. When you log into the AV console for the first time using these users, you will be asked to change the password.

1. Where to find the randomly generated password

    - Open a terminal session on your **DBSec-Lab** VM as OS user *oracle*

        ````
        <copy>sudo su - oracle</copy>
        ````

        **Note**: Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle, so, in that case **you don't need to execute this command**!

    - Go to the scripts directory

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

2. Open a web browser window to *`https://av`* to access to the Audit Vault Web Console

    **Note**: If you are not using the remote desktop you can also access this page by going to *`https://<AVS-VM_@IP-Public>`*

3. Login to Audit Vault Web Console as *`AVADMIN`* (use the password randomly generated)

    ````
    <copy>AVADMIN</copy>
    ````

    ![AVDF](./images/avdf-400.png "AVDF - Login")

4. Reset the password

    - Set your new password
    
        ![AVDF](./images/avdf-401.png "AVDF - Login")
    
    - Click [**Submit**]

5. Login to Audit Vault Web Console as *`AVAUDITOR`* (use the new password randomly generated)

    ````
    <copy>AVAUDITOR</copy>
    ````

    ![AVDF](./images/avdf-300.png "AVDF - Login")

6. Reset the password

    - Set your new password
    
        ![AVDF](./images/avdf-301.png "AVDF - Login")
    
    - Click [**Submit**]

You may now **proceed to the next lab**.

## Acknowledgements
- **Author** - Nazia Zaidi, Audit Vault and Databse Firewall - Product Manager
- **Contributors** - Angeline Dhanarani, Database Security - Product Manager
- **Last Updated By/Date** - Angeline Dhanarani, Database Security - Product Manager - April 2026
