# Explore Key Vault in a typical customer deployment

## Introduction
Oracle Key Vault offers continuously available, fault-tolerant, and highly scalable centralized management of encryption keys and secrets for all Oracle Database deployment models, addressing diverse organizational requirements. It securely stores and manages sensitive cryptographic material, including TDE master encryption keys, Oracle GoldenGate keys, SSH keys, public and private keys, digital certificates, and more.

Key Vault is purpose-built to manage TDE master encryption keys for standalone, multitenant, RAC, and sharded databases deployed on Exadata, Cloud, Cloud@Customer, and on Oracle Database Appliance. It also operates seamlessly across diverse infrastructure architectures, including multi-cloud and hybrid environments, as well as traditional on-premises and fully cloud-based deployments.

As a critical system component, proper Key Vault operation is essential to maintaining operational continuity. To support this, Key Vault provides comprehensive reporting and notifications, including inventory, activity, security, operational, and audit reports, with notifications delivered via email alerts, remote syslog, or SNMP.

Estimated Lab Time: 5 minutes

### Objectives
In this lab, you will explore Oracle Key Vault's actionable reports and how to interpret them - for example identifying which TDE master encryption keys need to be re-keyed, which certificates are nearing expiration or no longer satisfy stricter compliance requirements.

### Prerequisites
This lab assumes you have completed lab 11.



## Task 1: Oracle Key Vault Home page 

1. Login to Key Vault as user **KVRESTADMIN**

    ![Key Vault](./images/image-2025-09-03_13-29-46.png "Login to Key Vault as user KVRESTADMIN")

2. On the home page, observe the following:

    - The **Alerts** banner summarizes critical items that need immediate attention which may impact operational continuity.
    - The **Managed Entities** provides a quick overview of the databases (endpoints) and the wallets (database).
    - The **Managed Keys & Secrets** gives a quick glance of all the managed cryptographic objects.

    ![Key Vault](./images/Screenshot_2025-10-04_15.32.37.png "On the home page, observe Alerts, Managed Entities, and Managed Keys & Secrets")

2. The System Overview section at the bottom identifies the system.

    At this time, the system is deployed as a standalone server.

    ![Key Vault](./images/image-2025-09-11-17.41.21.png "The System Overview section at the bottom identifies the system")

## Task 2: Manage Primary-Standby, Sharded DBs, Multi-Tennant and RAC databses

Oracle Key Vault can manage databases of various deployments by deploying database clients called **endpoints** on the database host. The system administrator is tasked with creating, and overseeing endpoints on the Key Vault server.

1. Click the **Endpoints** tab
    ![Key Vault](./images/image-2025-7-24_12-11-54.png "Click the Endpoints tab")

2. This takes you to the Endpoints page - where the system administrator can see information about the endpoints that are registered or enrolled with Key Vault
    ![Key Vault](./images/image-2025-09-11-18.13.52.png "This takes you to the Endpoints page")

## Task 3: Virtual wallets for database keys 

To simplify management of database keys, Oracle Key Vault offers virtual wallets which act as a sorting mechanism to identify keys that belong to a specific database. Each virtual wallet can be mapped to a specific endpoint so that all keys uploaded by an endpoint become a part of this wallet by default. The key administrator is responsible for creating and managing virtual wallets.

1. Click the **Keys & Wallets** tab
    ![Key Vault](./images/Screenshot_2025-10-04_15.43.07.png "Click the Keys & Wallets tab")

2. This takes you to the Wallets page - where the key administrator can manage these

    ![Key Vault](./images/image-2025-09-11-18.20.43.png "This takes you to the Wallets page")

## Task 4: Inventory of database encryption keys

1. Click the **Reports** tab

    ![Key Vault](./images/Screenshot_2025-10-04_15.46.44.png "Click the Reports Tab")

2. Expand the **Key Management Reports for Oracle Endpoints**

    ![Key Vault](./images/image-2025-09-11-17.53.46.png "Key Management Report")

3. Select **DB Activated TDE Master Encryption Key Report**  - to see an example of a report with the inventory of database encryption keys

    ![Key Vault](./images/image-2025-09-11-18.09.03.png "Select DB Activated TDE Master Encryption Key Report")

## Task 5: Track database key and certificate lifetimes

1. Click the **Reports** tab

    ![Key Vault](./images/Screenshot_2025-10-04_15.46.44.png "Click the Reports Tab")

2. Expand the **Keys and Wallets Report**

    ![Key Vault](./images/Screenshot_2025-10-05_10.06.42.png "Keys and Wallets Report")

3. Select **Certificate Awareness Report**  - to see an example of a report to track certificate lifetimes

    ![Key Vault](./images/Screenshot_2025-10-05_10.08.23.png "Select Certificate Awareness Report")

## Task 6: Receive notifications for urgent tasks

1. Click the **Reports** tab

    ![Key Vault](./images/Screenshot_2025-10-04_15.46.44.png "Click the Reports Tab")

2. Click the **Alerts** tab on the left-side panel 

    ![Key Vault](./images/Screenshot_2025-10-04_15.49.25.png "Click the Alerts Tab")

3. Alerts that required immediate attention - **NEED TO UPDATE PHOTO TO SHOW EXPIRING KEYS ALSO**

    ![Key Vault](./images/image-2025-09-11-18.27.41.png "Alerts that required immediate attention")

## Task 7: Ensure accountability with audit records

To support security and compliance requirements, Oracle Key Vault reporting includes a complete audit trail, enabling thorough tracking and review of all actions and events. This is available to all administrators.

1. Click the **Reports** tab

    ![Key Vault](./images/Screenshot_2025-10-04_15.46.44.png "Click the Reports Tab")

2. Click the **Audit Trail** tab on the left-side panel 

    ![Key Vault](./images/Screenshot_2025-10-05_10.41.36.png "Click the Audit Trail Tab")

## Task 8: Enforce separation of duties

The role of account management is undertaken by the system administrator. To perform these tasks

1. Click the **Users** tab

    ![Key Vault](./images/Screenshot_2025-10-04_15.54.38.png "Click the Users tab")

2. This takes you to the **Manager Users** page

    ![Key Vault](./images/image-2025-09-11-18.29.46.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

3. To change the Key Vault user password, click the **Change Password** tab on the left-side panel

    ![Key Vault](./images/Screenshot_2025-10-05_10.49.21.png "To change the Key Vault user password, click the Change Password tab on the left-side panel")

4. The **Change Password for &lt;Key Vault User&gt;** page is where the user can change the password

    ![Key Vault](./images/image-2025-09-11-18.42.01.png "The Change Password for <Key Vault User> page is where the user can change the password")

5. For deployments using LDAP, key administrators can manage access for users to specific wallets by setting up LDAP group mappings. Click **Manage LDAP Mappings** on the left-side panel.

    ![Key Vault](./images/Screenshot_2025-10-05_10.54.01.png "Click Manage LDAP Mappings on the left-side panel")

6. The **LDAP Group Mappings** page shows which mappings are setup to which roles and privileges in Key Vault

    ![Key Vault](./images/image-2025-09-11-18.33.10.png "The LDAP Group Mappings page shows which mappings are setup to which roles and privileges in Key Vault")

## Task 9: Assess system health

1. To assess the health of the Key Vault server, click the **System** tab

    ![Key Vault](./images/Screenshot_2025-10-05_11.10.42.png "To assess the health of the Key Vault server, click the System tab")

2. This page shows the system health

    ![Key Vault](./images/Screenshot_2025-10-05_11.07.08.png "This page shows the system health")

## Task 10: Monitor performance for optimal operations

1. Click the **System** tab

    ![Key Vault](./images/Screenshot_2025-10-05_11.10.42.png "Click the System tab")

2. Click the **System Metrics** button

    ![Key Vault](./images/Screenshot_2025-10-05_11.25.42.png "Click the System Metrics button")

3. To monitor system performance, expand the **CPU & Memory Metrics** section

    ![Key Vault](./images/image-2025-09-11-18.46.22.png "To monitor system performance, expand the CPU & Memory Metrics section")

## Task 11: Administer Oracle Key Vault

1. Click the **System** tab

    ![Key Vault](./images/Screenshot_2025-10-05_11.10.42.png "Click the System tab")

2. Click the **Settings** tab on the left-side panel

    ![Key Vault](./images/Screenshot_2025-10-05_11.12.24.png "Click the Settings tab on the left-side panel")

3. This takes you to the page from where the system administrator can administer the Key Vault server

    ![Key Vault](./images/image-2025-09-11-18.48.38-CUSTOM.png "This takes you to the page from where the system administrator can administer the Key Vault server")

## Task 12: A quick look at the cluster

1. Click the **Cluster** tab

    ![Key Vault](./images/Screenshot_2025-10-05_11.33.32.png "Click the Cluster tab")

2. Configure the server as a Candidate Node

    ![Key Vault](./images/image-2025-09-11-18.50.51.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

3. Once the server has been configured as a cluster node, the Cluster page is updated to show the status of all nodes that are part of this cluster

    ![Key Vault](./images/image-2025-09-11-18.58.43.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

4. On the Home page, the System Overview section at the bottom is updated (identifying the deployment mode as Cluster)

    ![Key Vault](./images/image-2025-09-11-19.02.06.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")
