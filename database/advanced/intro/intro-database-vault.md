# Introduction

## About this Workshop
### Overview
*Estimated Time to complete the workshop*: 150 minutes

- This workshop is the second part of the Hands-On Labs series on Oracle Database Security. For the first part, see DB Security Basics. 
- Based on an OCI architecture, deployed in a few minutes with a simple internet connection, it allows you to test DB Security use cases in a complete environment already pre-configured by the Oracle Database Security Product Management Team.
- No significant PC resources or complex tools are needed, allowing you to explore new features at your own pace.

### Components
The complete architecture of the **DB Security Hands-On Labs** is as follows:

  ![DBSec LiveLabs Archi](./images/dbseclab-archi.png "DBSec LiveLabs Archi")

It's composed of 5 VMs:
  - **DBSec-Lab VM** (mandatory for all workshops: Baseline and Advanced workshops)
  - **Audit Vault Server VM** (for Advanced workshop only)
  - **DB Firewall Server VM** (for Advanced workshop only)
  - **Key Vault Server VM** (for Advanced workshop only)
  - **DB23ai VM** (for SQL Firewall workshop only)

During this mini-lab, you'll use different resources to interact with these VMs:
  - SSH Terminal Client
  - Glassfish HR App
  - (Optionally) SQL Developer

To ensure the best experience in this workshop, remember to complete the *Lab: Initialize Environment* to verify that all resources are correctly set up!

### Objectives
This mini-lab provides an opportunity to learn how to configure DB Security features to protect and secure the Oracle Database in the context of the Maximum Security Architecture (MSA), specifically exploring Database Vault and how to implement advanced data access controls - including separation of duties, privileged user access controls, and enforcing a trusted path to data.

The entire DB Security PM team wishes you an excellent workshop!

You may now proceed to the next lab.

## Acknowledgments
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Alan Williams, Rene Fontcha, Kajal Singh
- **Last Updated By/Date** - Ethan Shmargad, Database Security Product Management - January 2025