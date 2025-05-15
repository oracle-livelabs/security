# Introduction

## About this Workshop
### Overview
*Estimated Time to complete the workshop*: 55 minutes

This workshop is dedicated to encrypting data at rest (TDE), removing the encryption wallet from the database server (OKV), and separating application data from privileged users (DV). Here, we will migrate an encrypted database to Oracle Key Vault for centralized key management, encrypt an existing tablespace, and prevent privileged users from accessing sensitive application data. 

Based on an OCI architecture, deployed in a few minutes with a simple internet connection, it allows you to test DB Security use cases in a complete environment already pre-configured by the Oracle Database Security Product Manager Team.

Now, you no longer need important resources on your PC (storage, CPU or memory), nor complex tools to master, making you completely autonomous to discover at your rhythm all new DB Security features.

### Components
The complete architecture of the **DB Security Hands-On Labs** is as following:

  ![DBSec LiveLabs Archi](./images/dbseclab-archi.png "DBSec LiveLabs Archi")

It's composed of 2 VMs:
  - **DBSec-Lab VM** 
  - **Key Vault Server VM** 

During this mini-lab, you'll use different resources to interact with these VMs:
  - SSH Terminal Client
  - Oracle Key Vault Web Console

So that your experience of this workshop is the best possible, DO NOT FORGET to perform "Lab: *Initialize Environment*" to be sure that all these resources are correctly set!

### Objectives
This Hands-On Labs give the user an opportunity to learn how to configure the DB Security features to protect and secure their databases from the Baseline to the Maximum Security Architecture (MSA).

In this mini-lab, you will learn how to use the **Oracle Key Vault** (OKV), **Transparent Data Encryption** (TDE), and **Database Vault** (DV). 

You may now [proceed to the next lab](#next).

## Acknowledgements
- **Author** - Richard C. Evans, Database Security PM
- **Contributors** - Ethan Shmargad, Peter Wahl, Rahil Mir, Hakim Loumi
- **Last Updated By/Date** - Richard C. Evans, Database Security PM - May 2025
