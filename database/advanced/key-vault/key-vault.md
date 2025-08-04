# Oracle Key Vault (OKV)

## Introduction
This workshop guides you through the process of migrating an encrypted Oracle database 19c from a local TDE wallet to centralized key management with Oracle Key Vault.

*Estimated Lab Time:* 60 minutes

*Version tested in this lab:* Oracle OKV 21.11 and DBEE 19.28

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
| Lab No.  | Feature                                           | Approx. Time | Details                                                                    |
| -------- | ------------------------------------------------- | ------------ | -------------------------------------------------------------------------- |
| 3        | Review TDE setup in an encrypted database         | 2 minutes    |                                                                            |
| 4        | Migrate to OKV in 5 easy steps                    | 2 minutes    |                                                                            |
| 5        | Show and Tell                                     | 2 minutes    |                                                                            |
| x        | True migration (OKV only !)                       | 2 minutes    |                                                                            |
| x        | Enable "hands-off" operation                      | 2 minutes    |                                                                            |
| x        | Make database immune against connectivity issues  | 2 minutes    |                                                                            |
| x        | Zero key caching for lower security environments  | 2 minutes    |                                                                            |
|xx        | Automate re-key operations                        | 2 minutes    |                                                                            |
|xx        | Bring your own key                                | 2 minutes    |                                                                            |</if>
</if>
<if type="green">
| Lab No.  | Feature                                           | Approx. Time | Details                                                                    |
| -------- | ------------------------------------------------- | ------------ | -------------------------------------------------------------------------- |
| 3        | Review TDE setup in an encrypted database         | 2 minutes    |                                                                            |
| 4        | Migrate to OKV in 5 easy steps                    | 2 minutes    |                                                                            |
| 5        | Show and Tell                                     | 2 minutes    |                                                                            |
| x        | True migration (OKV only !)                       | 2 minutes    |                                                                            |
| x        | Enable "hands-off" operation                      | 2 minutes    |                                                                            |
| x        | Make database immune against connectivity issues  | 2 minutes    |                                                                            |
| x        | Zero key caching for lower security environments  | 2 minutes    |                                                                            |
|xx        | Automate re-key operations                        | 2 minutes    |                                                                            |
|xx        | Bring your own key                                | 2 minutes    |                                                                            |</if>

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