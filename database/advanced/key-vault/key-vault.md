# Oracle Key Vault (OKV)

## Introduction
This workshop guides you through the process of migrating an encrypted Oracle database 19c from a local TDE wallet to centralized key management with Oracle Key Vault.

*Estimated Lab Time:* 60 minutes

*Version tested in this lab:* Oracle OKV 21.11 and DBEE 19.25

### Video Preview
Watch a preview of "*LiveLabs - Oracle Key Vault*" [](youtube:4VR1bbDpUIA)

### Objectives
- Review TDE setup in an encrypted database
- Migrate your encrypted database from TDE wallet to centralized key management with Oracle Key Vault
- Only OKV: "True migration": Upload pre-migration TDE keys from the TDE wallet to Oracle Key Vault
- Enable "hands-off" operations
- Become immune against network interruptions with a persistent cache
- Zero key caching for lower security environments
- Enable automated re-key operations
- "Bring your own key" into Oracle Key Vault
- Review OKV Console for regular TDE deployments

### Prerequisites
This lab assumes you have:
<if type="brown">
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment
</if>
<if type="green">
- An Oracle Cloud account
- You have completed:
    - Introduction Tasks
</if>

### Lab Timing (estimated)

<if type="brown">
| Task No. | Feature                                           | Approx. Time | Details                                                                    |
| -------- | ------------------------------------------------- | ------------ | -------------------------------------------------------------------------- |
| 1        | Review TDE setup in an encrypted database         | 2 minutes    |                                                                            |
| 2        | RMAN backup of encrypted tablespace               | 2 minutes    |                                                                            |
| 3        | Prepare OKV for the incoming database             | 2 minutes    |                                                                            |
| 4        | Download and install OKV client software          | 2 minutes    |                                                                            |
| 5        | Migrate database to use OKV                       | 2 minutes    |                                                                            |
| 6        | True migration (OKV only !)                       | 2 minutes    |                                                                            |
| 7        | Enable "hands-off" operation                      | 2 minutes    |                                                                            |
| 8        | Make database immune against connectivity issues  | 2 minutes    |                                                                            |
| 9        | Zero key caching for lower security environments  | 2 minutes    |                                                                            |
|10        | Automate re-key operations                        | 2 minutes    |                                                                            |
|11        | Bring your own key                                | 2 minutes    |                                                                            |
</if>
<if type="green">
| Task No. | Feature                                           | Approx. Time | Details                                                                    |
| -------- | ------------------------------------------------- | ------------ | -------------------------------------------------------------------------- |
| 1        | Review TDE setup in an encrypted database         | 2 minutes    |                                                                            |
| 2        | RMAN backup of encrypted tablespace               | 2 minutes    |                                                                            |
| 3        | Prepare OKV for the incoming database             | 2 minutes    |                                                                            |
| 4        | Download and install OKV client software          | 2 minutes    |                                                                            |
| 5        | Migrate database to use OKV                       | 2 minutes    |                                                                            |
| 6        | True migration (OKV only !)                       | 2 minutes    |                                                                            |
| 7        | Enable "hands-off" operation                      | 2 minutes    |                                                                            |
| 8        | Make database immune against connectivity issues  | 2 minutes    |                                                                            |
| 9        | Zero key caching for lower security environments  | 2 minutes    |                                                                            |
|10        | Automate re-key operations                        | 2 minutes    |                                                                            |
|11        | Bring your own key                                | 2 minutes    |                                                                            |</if>

## Task 1: Review TDE setup in an encrypted database

An ancrypted database has been prepared for you:

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

<if type="brown">
    ````
    <copy>sudo su - oracle</copy>
    ````
</if>
<if type="green">
    **Note**: Double-click on the Terminal icon on the desktop to launch a session directly as oracle
</if>

2. Go to the OKV LiveLab scripts directory

    ````
    <copy>cd $DBSEC_LABS/okv</copy>
    ````

3. Display the parameters that define how TDE is setup in your database:

    ````
    <copy>./01_tde_show_tde_parameters.sh</copy>
    ````

    ![Key Vault](./images/okv_2504_001.png "Display the parameters that define how TDE is setup in your database:")

4. Confirm the encryption status of the root database and PDB1:

    ````
    <copy>./02_tde_list_enc_tbs.sh</copy>
    ````

    ![Key Vault](./images/okv_2504_002.png "Confirm the encryption status of the root database and PDB1:")

5. See the TDE master encryption keys in the TDE wallet:

    ````
    <copy>./03_tde_show_TDE_keys.sh</copy>
    ````

    ![Key Vault](./images/okv_xxxxxxxxx.png "See the TDE master encryption in the TDE wallet:")

## Task 2: RMAN works transparently with migrated keystores:

1. Make an RMAN backup of an encrypted tablespace:
   (select from table; make RMAN backup; delete tablespace; select from table (fails))
    ````
    <copy>./03_tde_create_RMAN_backup.sh</copy>
    ````

    ![Key Vault](./images/okv_2504_003.png "Make an RMAN backup of an encrypted tablespace:")

## Task 3: Prepare OKV for the incoming database:

0. Display random password; go to OKV GUI, KVEPADMIN login with random one-time password and replace with self-defined permanent password; log in with new password; KVRESTADMIN is not needed in this demo, skip it.

1. Create endpoint in OKV GUI:

    ![Key Vault](./images/okv_2504_004.png "Create endpoint in OKV GUI:")

2. Create wallet in OKV GUI:

    ![Key Vault](./images/okv_2504_005.png "Create wallet in OKV GUI:")

3. Make the wallet the "default wallet" of the endpoint:

    ![Key Vault](./images/okv_2504_006.png "Make the wallet the 'default wallet' of the endpoint:")

4. Grab Token from GUI:

    ![Key Vault](./images/okv_2504_006.png "Grab Token from GUI:")

## Task 4: Download and install OKV client software:

1. Navigate to download page and use Token:

    ![Key Vault](./images/okv_2504_007.png "Navigate to download page and use Token:")

2. Download OKV endpoint software:

    ![Key Vault](./images/okv_2504_007.png "Download OKV endpoint software:")

3. Install OKV client software into <WALLET_ROOT>/okv:

    ````
    <copy>./08_java-jar-and-root.sh</copy>
    ````

    ![Key Vault](./images/okv_2504_008.png "Install OKV client software into <WALLET_ROOT>/okv:")

## Task 5: Migrate database to use OKV:

1. Change TDE_CONFIG from FILE to OKV|FILE:

    ````
    <copy>./08_change-TDE-config.sh</copy>
    ````
    
    ![Key Vault](./images/okv_2504_007.png "Change TDE_CONFIG from FILE to OKV|FILE:")

2. Basic migration of your database from TDE wallet to Oracle Key Vault:

    ````
    <copy>./08_migrate-to-OKV.sh</copy>
    ````
    
    ![Key Vault](./images/okv_2504_007.png "Migrate database from TDE wallet to Oracle Key Vault:")

3. Confirm new keys with 'okvutil list':

    ````
    <copy>./09-okvutil-list.sh</copy>
    ````

    ![Key Vault](./images/okv_2504_008.png "List new keys from OKV:")

4. Confirm new keys from v$encryption_keys:

    ````
    <copy>./10-show-keys.sh</copy>
    ````

    ![Key Vault](./images/okv_2504_008.png "List new keys from v$encryption_keys:")

## Task 6: True migration (OKV only):

1. Upload pre-migration keys to OKV:

    ````
    <copy>./09-okvutil-upload.sh</copy>
    ````
    ![Key Vault](./images/okv_2504_008.png "Upload pre-migration keys to OKV:")

2. Confirm un-interrupted chain of TDE keys in OKV:

    ````
    <copy>./09-okvutil-list.sh</copy>
    ````
    ![Key Vault](./images/okv_2504_008.png "Confirm un-interrupted chain of TDE keys in OKV:")

3. Only after true migration into OKV: Delete wallet (PCI compliance requirement):

    ````
    <copy>./12-delete-TDE-wallet.sh</copy>
    ````
    ![Key Vault](./images/okv_2504_008.png "Confirm un-interrupted chain of TDE keys in OKV:")

4. Restore RMAN backup to show that RMAN finds the key automatically

    ````
    <copy>./12-RMAN-restore-TBS.sh</copy>
    ````
    ![Key Vault](./images/okv_2504_008.png "Restore RMAN backup after migrating to OKV:")

## Task 7: Enable "hands-off" operation:

1. Add local auto-open wallet in <WALLET_ROOT>/tde which contains only OKV_PASSWORD; confirm by selecting from v$client_secrets.

    ````
    <copy>./13-create-auto-open-OKV.sh</copy>
    ````
    ![Key Vault](./images/okv_2504_008.png "Enable hands-off operations by creating 'auto-open OKV' setup:")

2. Validate by closing wallet and selecting from v$encryption_wallet; it should say "LOCAL AUTO_LOGIN"

    ````
    <copy>./14-validate-local-auto-open.sh</copy>

    ![Key Vault](./images/okv_2504_008.png "Confirm auto-open wallet enables auto-open OKV:")
    ````
3. Bounce DB, then select from encrypted table WITHOUT ever opening the keystore with a keystore password.

    ````
    <copy>./15-select-from-table-after-bounce.sh</copy>
    ````
    ![Key Vault](./images/okv_2504_008.png "Confirm TDE operations thanks to auto-open OKV:")

## Task 8: Make database immune against connectivity issues:

1. Show content of pCache (okvutil)

    ````
    <copy>./16-show-pCache-content.sh</copy>

    ![Key Vault](./images/okv_2504_008.png "Confirm keys in pCache match key in OKV:")
    ````

2. Cut connectivity with OKV and confirm with failed okvutil list command

    ````
    <copy>./17-cut-connect-OKV.sh</copy>
    ````
    ![Key Vault](./images/okv_2504_008.png "Confirm connection to OKV has been interrupted:")

3. Bounce database and add table to new encrypted tablespace; select from table

    ````
    <copy>./18-bounce-and-create-table-in-new-tablespace.sh</copy>
    ````
    ![Key Vault](./images/okv_xxxxx.png "Confirm continued TDE operation despite OKV being not reachable:")

4. Restore and confirm connectivity to OKV

    ````
    <copy>./19-restore-and-confirm-connectivity.sh</copy>
    ````
    ![Key Vault](./images/okv_xxxxx.png "Restore and confirm connectivity to OKV:")

## Task 9: Zero key caching for lower security environments

1. Go to OKV web console and make the endpoint non-extractable:

    ![Key Vault](./images/okv-xxx.png "Make the endpoint non-extractable")

2. Verify we have the new master encryption key in the virtual Wallet, note it says "FALSE" in the 'Extractable' column:

    ````
    <copy>./020-show-new-non-ext-key-with-okvutil-list-a.sh</copy>
    ````

    ![Key Vault](./images/okv-071.png "Check rekey")


3. Compare keys with "okvutil list -a" and "okvutil list pCache"; non-ext keys are missing from pCache.

4. Disable Endpoint

    ![Key Vault](./images/xxxxxxxxxx.png "Disable Endpoint")

5. Try crypto-operation and it should fail right away
 
    ![Key Vault](./images/okv-073.png "crypto-operations fail")

6. Re-enable endpoint 

    ![Key Vault](./images/okv-074.png "Re-enable endpoint")

7. Try crypto-operation and it will succeed.

    ![Key Vault](./images/okv-073.png "crypto-operations succeed")

## Task 10: Automate re-key operations

1. Create an IBES wallet:

    ![Key Vault](./images/okv-xxx.png "Add OKV password into IBES wallet")

2. Re-key without providing a keystore password:

    ![Key Vault](./images/okv-xxx.png "Re-key without providing a keystore password")

## Task 11: Bring Your Own Key

1. Create TDE key in OKV GUI:

    ![Key Vault](./images/okv-xxx.png "Create TDE key in OKV GUI")

2. Activate key in PDB:

    ![Key Vault](./images/okv-xxx.png "Activate key in PDB")

3. Show key and TAG in v$encryption_keys in PDB and with okvutil list


## **Appendix**: About the Product
### **Overview**

Oracle Key Vault is a full-stack, security-hardened software appliance built to centralize the management of keys and security objects within the enterprise.

Oracle Key Vault is a robust, secure, and standards-compliant key management platform, where you can store, manage, and share your security objects.

![Key Vault](./images/okv-concept.png "Key Vault Concept")

Security objects that you can manage with Oracle Key Vault include as encryption keys, Oracle wallets, Java keystores (JKS), Java Cryptography Extension keystores (JCEKS), and credential files.

Oracle Key Vault centralizes encryption key storage across your organization quickly and efficiently. Built on Oracle Linux, Oracle Database, Oracle Database security features like Oracle Transparent Data Encryption, Oracle Database Vault, Oracle Virtual Private Database, and Oracle GoldenGate technology, Oracle Key Vault's centralized, highly available, and scalable security solution helps to overcome the biggest key-management challenges facing organizations today. With Oracle Key Vault you can retain, back up, and restore your security objects, prevent their accidental loss, and manage their lifecycle in a protected environment.

Oracle Key Vault is optimized for the Oracle Stack (database, middleware, systems), and Advanced Security Transparent Data Encryption (TDE). In addition, it complies with the industry standard OASIS Key Management Interoperability Protocol (KMIP) for compatibility with KMIP-based clients.

You can use Oracle Key Vault to manage a variety of other endpoints, such as MySQL TDE encryption keys.

Starting with Oracle Key Vault release 18.1, a new multi-master cluster mode of operation is available to provide increased availability and support geographic distribution.

The multi-master cluster nodes provide high availability, disaster recovery, load distribution, and geographic distribution to an Oracle Key Vault environment.

An Oracle Key Vault multi-master cluster provides a mechanism to create pairs of Oracle Key Vault nodes for maximum availability and reliability.

![Key Vault](./images/okv-cluster-concept.png "Key Vault Multi-Master Concept")

Oracle Key Vault supports two types of mode for cluster nodes: read-only restricted mode or read-write mode.

- **Read-only restricted mode**

  In this mode, only non-critical data can be updated or added to the node. Critical data can be updated or added only through replication in this mode. There are two situations in which a node is in read-only restricted mode:
    - A node is read-only and does not yet have a read-write peer.
    - A node is part of a read-write pair but there has been a breakdown in communication with its read-write peer or if there is a node failure. When one of the two nodes is non-operational, then the remaining node is set to be in the read-only restricted mode. When a read-write node is again able to communicate with its read-write peer, then the node reverts back to read-write mode from read-only restricted mode.

- **Read-write mode**

This mode enables both critical and non-critical information to be written to a node. A read-write node should always operate in the read-write mode.

You can add read-only Oracle Key Vault nodes to the cluster to provide even greater availability to endpoints that need Oracle wallets, encryption keys, Java keystores, certificates, credential files, and other objects.

An Oracle Key Vault multi-master cluster is an interconnected group of Oracle Key Vault nodes. Each node in the cluster is automatically configured to connect with all the other nodes, in a fully connected network. The nodes can be geographically distributed and Oracle Key Vault endpoints interact with any node in the cluster.

This configuration replicates data to all other nodes, reducing risk of data loss. To prevent data loss, you must configure pairs of nodes called read-write pairs to enable bi-directional synchronous replication. This configuration enables an update to one node to be replicated to the other node, and verifies this on the other node, before the update is considered successful. Critical data can only be added or updated within the read-write pairs. All added or updated data is asynchronously replicated to the rest of the cluster.

After you have completed the upgrade process, every node in the Oracle Key Vault cluster must be at Oracle Key Vault release 18.1 or later, and within one release update of all other nodes. Any new Oracle Key Vault server that is to join the cluster must be at the same release level as the cluster.

The clocks on all the nodes of the cluster must be synchronized. Consequently, all nodes of the cluster must have the Network Time Protocol (NTP) settings enabled.

Every node in the cluster can serve endpoints actively and independently while maintaining an identical dataset through continuous replication across the cluster. The smallest possible configuration is a 2-node cluster, and the largest configuration can have up to 16 nodes with several pairs spread across several data centers.

### **Benefits of Using Oracle Key Vault**
- Oracle Key Vault helps you to fight security threats, centralize key storage, and centralize key lifecycle management
- Deploying Oracle Key Vault in your organization will help you accomplish the following:
- Manage the lifecycle for endpoint security objects and keys, which includes key creation, rotation, deactivation, and removal
- Prevent the loss of keys and wallets due to forgotten passwords or accidental deletion
- Share keys securely between authorized endpoints across the organization
- Enroll and provision endpoints easily using a single software package that contains all the necessary binaries, configuration files, and endpoint certificates for mutually authenticated connections between endpoints and Oracle Key Vault
- Work with other Oracle products and features in addition to Transparent Data Encryption (TDE), such as Oracle Real Application Clusters (Oracle RAC), Oracle Data Guard, pluggable databases, and Oracle GoldenGate. Oracle Key Vault facilitates the movement of encrypted data using Oracle Data Pump and transportable tablespaces, a key feature of Oracle Database
- Oracle Key Vault multi-master cluster provides additional benefits, such as:
- Maximum key availability by providing multiple Oracle Key Vault nodes from which data may be retrived
- Zero endpoint downtime during Oracle Key Vault multi-master cluster maintenance

## Want to Learn More?
Technical Documentation:
- [Oracle Key Vault](https://docs.oracle.com/en/database/oracle/key-vault/21.10/index.html)
- [Oracle Key Vault - Multimaster](https://docs.oracle.com/en/database/oracle/key-vault/21.10/okvag/multimaster_concepts.html)
- [Oracle Key Vault - SSH Key Management](https://docs.oracle.com/en/database/oracle/key-vault/21.10/okvag/management_of_ssh_keys_concepts.html)

    > To learn more about how to use OKV to manage SSH keys, please refer to the "[DB Security - Key Vault (SSH Key Management)] (https://livelabs.oracle.com/pls/apex/dbpm/r/livelabs/view-workshop?wid=727)" workshop

Video:
- *Introducing Oracle Key Vault 21 (January 2021)* [](youtube:SfXQEwziyw4)

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Peter Wahl, Rahil Mir
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - August 2024