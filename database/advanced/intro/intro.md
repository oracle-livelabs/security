# Introduction

## About this Workshop
### Overview
*Estimated Time to complete the workshop*: 425 minutes

This workshop environment is dedicated to Oracle Database Security features and functionalities.

Based on an OCI architecture, deployed in a few minutes with a simple internet connection, it allows you to test DB Security use cases in a complete environment already pre-configured by the Oracle Database Security Product Manager Team.

Now, you no longer need important resources on your PC (storage, CPU or memory), nor complex tools to master, making you completely autonomous to discover at your rhythm all new DB Security features.

Watch a preview of "*Livelabs - Database Security Advanced (May 2022)*" [](youtube:h4gXFpOxWZU)

### Components
The complete architecture of the **DB Security Hands-On Labs** is as following:

  ![DBSec LiveLabs Archi](./images/dbseclab-archi.png "DBSec LiveLabs Archi")

It's composed of 5 VMs:
  - **DBSec-Lab VM** (mandatory for all workshops: Baseline and Advanced workshops)
  - **Audit Vault Server VM** (for Advanced workshop only)
  - **DB Firewall Server VM** (for Advanced workshop only)
  - **Key Vault Server VM** (for Advanced workshop only)
  - **DB23ai VM** (for SQL Firewall workshop only)

During this 2nd workshop, you'll use different resources to interact with these VMs:
  - SSH Terminal Client
  - Glassfish HR App
  - Oracle Enterprise Manager 13c
  - Oracle SQL Developer
  - Oracle Golden Gate Web Console (for AVDF labs only)
  - Oracle AVDF Web Console (for AVDF labs only)
  - Oracle Key Vault Web Console (for OKV labs only)

So that your experience of this workshop is the best possible, DO NOT FORGET to perform "Lab: *Initialize Environment*" to be sure that all these resources are correctly set!

### Objectives
This Hands-On Labs give the user an opportunity to learn how to configure the DB Security features to protect and secure their databases from the Baseline to the Maximum Security Architecture (MSA).

In this second part, you will see the Oracle Database Security advanced products and solutions as following:
- Oracle Advanced Security Option
    - **Oracle Transparent Data Encryption** (TDE)
    - **Oracle Data Redaction**
 - **Oracle Database Vault** (DV)
 - **Oracle Label Security** (OLS)
 - **Oracle Data Masking and Subsetting** (DMS)
 - **Oracle Audit Vault and Database Firewall** (AVDF)
 - **Oracle Key Vault** (OKV)

The entire DB Security PMs Team wishes you an excellent workshop!

You may now [proceed to the next lab](#next).

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Rene Fontcha
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - January 2024
