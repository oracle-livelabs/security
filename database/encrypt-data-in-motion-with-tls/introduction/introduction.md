# Introduction

## About this Workshop

This workshop introduces the functionality of Oracle Transport Layer Security (TLS) network encryption. It gives the user an opportunity to learn how to configure this feature to encrypt and secure its data in-motion.

*Estimated Workshop Time*: 45 minutes

### About TLS 

TLS is the standard based approach for encrypting data in motion. Since TLS provides one-way authentication or mutual two-way authentication, it minimizes the chance of a breach. 

### Objectives
- Successfully protect your database communication using 1-way TLS
- Verify network traffic is unencrypted before configuring TLS
- Create root wallet and self signed root CA certificate
- Create database server wallet and create certificate request
- Sign database certificate with root CA certificate
- Add CA root certificate and database server certificate to database wallet
- Import CA root certificate into client trust store (Linux, Windows only)
- Configure for TLS network encryption
- Connect using TLS network encryption and verify traffic is encrypted
- Create new OS user and encrypt SQL traffic.
- (Optional) Disable encryption

The entire DB Security PMs Team wishes you an excellent workshop!

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

## Acknowledgements
- **Author** - Stephen Stuart & Alpha Diallo, Solution Engineers, North America Specialist Hub
- **Contributors** - Richard C. Evans, Database Security Product Manager 
- **Last Updated By/Date** - Stephen Stuart & Alpha Diallo, April 2023
