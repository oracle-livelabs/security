# DBA Dan Lab (update name)

## Introduction
This workshop introduces the functionality of Oracle Transport Layer Security (TLS) network encryption. It gives the user an opportunity to learn how to configure this feature to encrypt and secure its data in-motion.

*Estimated Lab Time:* 15 minutes

*Version tested in this lab:* Oracle DB 19.17

### Video Preview
Watch a preview of "*LiveLabs - Oracle Native Network Encryption (May 2022)*" [](youtube:N6Uz-pVTkaI)

### Objectives
- Download tls.zip file to local directory  
- Generate and capture unencrypted SQL traffic 
- Create wallet and self signed certificate 
- Enable TLS network encryption 
- Generate and capture encrypted SQL traffic 
- (Optional) Disable encryption 


### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

### Lab Timing (estimated)
| Step No. | Feature | Approx. Time |
|--|------------------------------------------------------------|-------------|
| 1 | DBA Dan | 10 minutes |
| 2 |  | 5 minutes |
| 3 | | 5 minutes |


## Task 1: DBA Dan

1. 

    ````
    <copy>cd adv-linux-user</copy>
    ````
2. 

    ````
    <copy>./tls_useradd_dba_dan.sh</copy>
    ````
3. 

    ````
    <copy>./tls_install_oracle_ic.sh</copy>
    ````
4. 

    ````
    <copy>./tls_dba_dan_sqlnet_ora.sh</copy>
    ````
5. 

    ````
    <copy>./tls_dba_dan_tnsnames_ora.sh</copy>
    ````
6. 

    ````
    <copy>./tls_install_linux_cert.sh</copy>
    ````
7. 

    ````
    <copy>sudo su - dba_dan</copy>
    ````
8. 

    ````
    <copy>export TNS_ADMIN=$HOME/tns_admin</copy>
    ````
9. 

    ````
    <copy>sqlplus system/Oracle123@pdb1_tls</copy>
    ````




## **Appendix**: About the Product
### **Overview**

Oracle Database provides both native data network encryption and TLS-based encryption to ensure that data in-motion is secure as it travels across the network.

![Network Encryption](./images/nne-concept.png "Network Encryption")



## Want to Learn More?
Technical Documentation:
- [Configuring Transport Layer Security Authentication](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/configuring-secure-sockets-layer-authentication.html)
- [Oracle Native Network Encryption 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/configuring-network-data-encryption-and-integrity.html)

## Acknowledgements
- **Author** - Stephen Stuart & Alpha Diallo, Solution Engineers, North America Specialist Hub
- **Contributors** - Richard C. Evans, Database Security Product Manager 
- **Last Updated By/Date** - Stephen Stuart & Alpha Diallo, March 2023