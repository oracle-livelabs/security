# Introduction

### About this Workshop

Did you know you can manage your encryption keys outside of Oracle Cloud Infrastructure?

Customer controlled key management is a crucial security requirement for many customers around the world, specifically to answer Sovereignty requirements.

In this Hands-On Lab, you will learn how to manage your encryption keys outside of OCI using a Thales HSM. With OCI Vault « Bring Your Own Key » and « Hold Your Own Key » feature, which we call « External KMS », you stay in control of your keys, you store them where you want, and you can still use the advanced IaaS and PaaS features of OCI.

This Hands-On Lab will walk you through how to enable the feature, link your HSM outside of OCI to your OCI tenant and start encrypting data in OCI, for storage encryption and OCI Database encryption through TDE support. Now your Master Encryption Keys never leave your own HSM. You will also simulate an Emergency Situation in which you are being asked to block access to data stored in OCI Storage Buckets or Database Service. You’re in control. 

Estimated Workshop Time: 1 hour

*Note*  In this lab you will truly use an external KMS service: each student will have a Thales CipherTrust Manager tenant, which is a Key management as a Service tenant for Key Management, based on Thales HSM as a service solution.

### Objectives

In this workshop, you will learn how to:
* Connect to the two environements you will need to use to perform the lab: an OCI tenant and a Thales CipherTrust Manager
* Add a connection between your Thales CipherTrust Manager and OCI
* Create Oracle keys in Thales
* Bring Your Own Key (BYOK) to OCI
    > BYOK means “Bring Your Own Key”. It is the concept of bringing into Oracle Cloud Infrastructure (OCI) Encryption Keys which have been created outside of OCI. This might be mandatory to comply with certain regulations mandating that the encryption Key creation ceremony is done outside of the Cloud. 
    BYOK is compatible with any key material you are creating which is compatible with OCI Vault supported key types. 
    For a complete list of OCI Vault supported Key Types, please refer to the following link: [Supported Key Types and Key Sizes](https://docs.oracle.com/en-us/iaas/Content/KeyManagement/Tasks/importingkeys.htm)

* Configure customer managed encryption for OCI resources
* Emergency simulation test (I): blocking data access
* Emergency simulation test (II): re-enabling data access

Optionally, you will have an extra lab to perform Hold Your Own Key (HYOK) to OCI. HYOK means “Hold Your Own Key” and is officially called in OCI Vault “External Key management”. It means that your Master Encryption Key (MEK) never leaves your  own HSM located outside of OCI, whether it is in your own Data Center or hosted by a third party. 
As of today, HYOK is only compatible with Thales CipherTrust Manager. Hence the reason why during this lab you will use THALES CipherTrust Key Manager.


### Prerequisites

This lab assumes you have:
* An Oracle Cloud Infrastructure account
* A Thales CipherTrust Key Manager as a Service account

Both environments will be provided to you by the trainers.

## Lab breakdown

- **Lab 1:** Link creation between OCI and you HSM and Master Encryption Key creation
- **Lab 2:** Bring Your Own Key to Oracle Cloud Infrastructure (BYOK to OCI)
- **Lab 3:** Configure Customer Managed Encryption for OCI Resources
- **Lab 4:** Emergency simulation test: block data access
- **Lab 5:**  Emergency simulation test: re-enable data access


## What's Next?

  You are all set to begin the labs! You may now **proceed to the next lab**.


## Learn More

* [Key Management with OCI Vault](https://www.oracle.com/security/cloud-security/key-management/)
* [Thales CipherTrust Manager](https://cpl.thalesgroup.com/en-gb/encryption/ciphertrust-manager)

## Acknowledgements
* **Authors** - Damien Rilliard (OCI Security Senior Director), Sonia Yuste (OCI Security Specialist) 
* **Last Updated By/Date** - Sonia Yuste, June 2023
