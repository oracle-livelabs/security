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

2. This takes you to the Endpoints page
    ![Key Vault](./images/image-2025-09-11-18.13.52.png "This takes you to the Endpoints page")

## Task 3: Virtual wallets for database keys 

To simplify management of database keys, Oracle Key Vault offers virtual wallets which act as a sorting mechanism to identify keys that belong to a specific database. Each virtual wallet can be mapped to a specific endpoint so that all keys uploaded by an endpoint become a part of this wallet by default. The key administrator is responsible for creating and managing virtual wallets.

1. Click the **Keys & Wallets** tab
    ![Key Vault](./images/Screenshot_2025-10-04_15.43.07.png "Click the Keys & Wallets tab")

2. This takes you to the Wallets page

    ![Key Vault](./images/image-2025-09-11-18.20.43.png "This takes you to the Wallets page")

## Task 4: Inventory of database encryption keys

1. Click the **Reports** tab

    ![Key Vault](./images/Screenshot_2025-10-04_15.46.44.png "Click the Reports Tab")

2. DB Activated TDE Master Encryption Key Report

    ![Key Vault](./images/image-2025-09-11-18.09.03.png "Click the Endpoints Tab")

## Task 5: Track database key and certificate lifetimes

1. Key Management Report

    ![Key Vault](./images/image-2025-09-11-17.53.46.png "Certficates are listed and grouped by their length and remaining life time")

## Task 6: Receive notifications for urgent tasks

1. Click the **Alerts** tab

    ![Key Vault](./images/Screenshot_2025-10-04_15.49.25.png "Click the Alerts Tab")

2. Alerts that required immediate attention

    ![Key Vault](./images/image-2025-09-11-18.27.41.png "Alerts that required immediate attention")

## Task 7: Ensure accountability with audit records

To support security and compliance requirements, Oracle Key Vault reporting includes a complete audit trail, enabling thorough tracking and review of all actions and events. This is available to all administrators.

1. Click the **Reports** tab

2. Click the **Audit Trail** tab on the left hand side

## Task 8: Enforce separation of duties

The role of account management is undertaken by the system administrator. To perform these tasks

1. Click the **Users** tab

    ![Key Vault](./images/Screenshot_2025-10-04_15.54.38.png "Click the Users tab")

2. This takes you to the **Manager Users** page

    ![Key Vault](./images/image-2025-09-11-18.29.46.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

2. To change the user password, click Change user password

    ![Key Vault](./images/image-2025-09-11-18.42.01.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")


3. Empty LDAP Group Mappings

    ![Key Vault](./images/image-2025-09-11-18.33.10.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

## Task 9: Assess system health

1. Settings page

    ![Key Vault](./images/image-2025-09-11-18.48.38-CUSTOM.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

## Task 10: Monitor performance for optimal operations

1. CPU and memory metrics

    ![Key Vault](./images/image-2025-09-11-18.46.22.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

## Task 11: Administer Oracle Key Vault

## Task 12: A quick look at the cluster

1. Click the **Cluster** tab

2. Configure the server as a Candidate Node

    ![Key Vault](./images/image-2025-09-11-18.50.51.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

3. Once the server has been configured as a cluster node, the Cluster page is updated to show the status of all nodes that are part of this cluster

    ![Key Vault](./images/image-2025-09-11-18.58.43.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")

4. On the Home page, the System Overview section at the bottom is updated (identifying the deployment mode as Cluster)

    ![Key Vault](./images/image-2025-09-11-19.02.06.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report")
