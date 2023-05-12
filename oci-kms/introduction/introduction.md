# Introduction

## About this Workshop

Did you know you can manage your encryption keys outside of OCI? 

That’s an important security requirement from many customers around the world, specifically to answer Sovereignty requirements. 

In this HOL, you will learn how to manage your encryption keys outside of OCI using a Thales HSM. With OCI Vault « Bring Your Own Key » and “Hold Your Own Key or External KMS” features, you stay in control of your keys, storing them where you want, and you can still use the advanced IaaS and PaaS features of OCI. 

This Hands-On Lab will walk you through how to enable the feature, link your HSM outside of OCI to your OCI tenant and start encrypting data in OCI, for storage encryption and OCI Database encryption through TDE support. Now your Master Encryption Keys never leave your own HSM. You will also simulate an Emergency Situation in which you are being asked to block access to data stored in OCI Storage Buckets or Database Service. You’re in control. 

Estimated Workshop Time: -- hours -- minutes (This estimate is for the entire workshop - it is the sum of the estimates provided for each of the labs included in the workshop.)

*You may add an option video, using this format: [](youtube:YouTube video id)*

  [](youtube:zNKxJjkq0Pw)

*Note* In this lab you will use THALES CipherTrust Key Manager as a Service for the Key Management and HSM service. 


### Objectives

*List objectives for the workshop*

In this workshop, you will learn how to:
* Set up HSM and Key Management in Thales
* Connect to OCI and create your own Vault in OCI Vault
* Add a connection between your Thales CipherTrust Manager and OCI
* Create the keys

Then you will have 2 options: “BYOK” (Lab 3a) or “HYOK” (Lab 3b). 

* BYOK means “Bring Your Own Keys”. It is the concept of bringing into Oracle Cloud Infrastructure (OCI) Encryption Keys which have been created outside of OCI. This might be mandatory to comply with certain regulations mandating that the encryption Key creation ceremony is done outside of the Cloud. 
BYOK is compatible with any key material you are creating which is compatible with OCI Vault supported key types. 
For a complete list of OCI Vault supported Key Types, please refer to the following link:[Supported Key Types and Key Sizes](https://docs.oracle.com/en-us/iaas/Content/KeyManagement/Tasks/importingkeys.htm)

* HYOK means “Hold Your Own Key” and is officially called in OCI Vault “External Key management”. It means that your Master Encryption Key (MEK) never leaves your  own HSM located outside of OCI, whether it is in your own Data Center or hosted by a third party. 
As of today, HYOK is only compatible with Thales CipherTrust Manager. Hence the reason why during this lab you will use THALES CipherTrust Key Manager.

Whatever option you chose, the remaining points are the following:

* Configure customer managed encryption for OCI resources
* Emergency simulation test: blocking data access


### Prerequisites (Optional)

*List the prerequisites for this lab using the format below. Fill in whatever knowledge, accounts, etc. is needed to complete the lab. **Do NOT list** each previous lab as a prerequisite.*

This lab assumes you have:
* An Oracle account
* A Thales account

*This is the "fold" - below items are collapsed by default*


## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> -- optional
* **Last Updated By/Date** - <Name, Month Year>
