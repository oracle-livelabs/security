# Oracle TLS Network Encryption (TLS)

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
| 1 | Download tls.zip file to local directory | <5 minutes |
| 2 | Generate and capture unencrypted SQL traffic | 5 minutes |
| 3 | Create wallet and self signed certificate | 5 minutes |
| 4 | Enable TLS network encryption | <5 minutes |
| 5 | Generate and capture encrypted SQL traffic | <5 minutes |
| 6 | (Optional) Disable encryption | <5 minutes |

## Task 1: Download tls.zip file to local directory

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle* and use `cd` command to move to livelabs directory.

    ````
    <copy>cd livelabs</copy>
    ````

    **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

2. Create TLS directory within the livelabs folder. 

    ````
    <copy>mkdir -v tls</copy>
    ````

3. Move into TLS directory you just created. 

    ````
    <copy>cd tls</copy>
    ````

4. Use `wget` command to download tls.zip file.

    ````
    <copy>wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/go8OvUV3HWuaHALnGYA3pHooq_AkPU2oK3JIOu5SFBBrOlZ_STdjpnHmOA78uhMM/n/oradbclouducm/b/dbsec_rich/o/tls.zip</copy>
    ````

5. Unzip tls.zip file. 
    
    ````
    <copy>unzip tls.zip</copy>
    ````

6. Remove tls.zip file. 
    
    ````
    <copy>rm -v tls.zip</copy>
    ````

7. Use following command to enable execute permissions on the scripts in the tls directory. 
    
    ````
    <copy>chmod +x *.sh</copy>
    ````

7.  Use the following command to list files in tls directory. Now you should be able to see the folder is populated with .sh files. 
    
    ````
    <copy>ls -al</copy>
    ````
    

## Task 2: Generate and capture unencrypted SQL traffic

1. Use the following command to ping the pluggable database, PDB1.

    ````
    <copy>tnsping pdb1</copy>
    ````

2. First, let's look at the existing PDB1 connection to see that the data is not encrypted in motion.

    ````
    <copy>./tls_is_sess_encrypt.sh pdb1</copy>
    ````
    Your NETWORK_PROTOCOL should not be encrypted and read 'tcp'


3. This allows you to intercept traffic on port 1521 and generates a pcap file. 

    ````
    <copy>./tls_tcpdump_traffic.sh pdb1</copy>
    ````

4. Extracts readable data from pcap file, you will see email addressess in the output.

    ````
    <copy>./tls_tcpdump_extract.sh pdb1</copy>
    ````



## Task 3: Create wallet and self signed certificate 

1. This script will create the TLS wallet directory, create the wallet with orapki, and generate a self-signed certificate based on the DB server's hostname.

    ````
    <copy>./tls_create_wallet_cert.sh</copy>
    ````

    You should see 'wallet and certificate creation completed!' 

2. The trusted certificate was exported to be used for the client. Display the contents of the dbseclab.crt file.

    ````
    <copy>cat dbseclab.crt</copy>
    ````

## Task 4: Enable TLS network encryption

1. Add a new tnsnames.ora entry for the pdb1_tls connection string. This will copy the existing pdb1 connection string and modify it to use TCPS protocol and connect to port 1522 instead of 1521.

    ````
    <copy>./tls_update_tnsnames_ora.sh</copy>
    ````

2. In this step, we update the database's sqlnet.ora to include the SSL_CLIENT_AUTHENTICATION parameter as false. When set to false, one-way TLS can be used by the client. If set to true, mutual TLS (mTLS) must be used.

    ````
    <copy>./tls_update_sqlnet_ora.sh</copy>
    ````

3. This step will stop the Oracle Listener and update the listener.ora to be available for TLS connections on port 1522. It will start the Oracle listener and dynamically register the existing CDB and PDBs with it.

    ````
    <copy>./tls_update_listener_ora.sh</copy>
    ````
4. Ensure you can still ping the un-encrypted connection to PDB1.

    ````
    <copy>tnsping pdb1</copy>
    ````

5. Now, because our listener is available for TLS connections on port 1522, we can use tnsping to verify connectivity.

    ````
    <copy>tnsping pdb1_tls</copy>
    ````
## Task 5: Generate and capture encrypted SQL traffic

1. As we did for the un-encrypted connection to PDB1, we will re-run the step using the tnsnames alias of pdb1_tls.  This connection will now be a TLS encrypted connection to PDB1 on port 1522 instead of port 1521.

    ````
    <copy>./tls_is_sess_encrypt.sh pdb1_tls</copy>
    ````
    The output should read 'tcps' instead. 

2. Again, we will capture SQL queries from sqlplus using tcpdump. The queries will show on our screen but the packet capture (pcap) file will not contain unencrypted emails.

    ````
    <copy>./tls_tcpdump_traffic.sh pdb1_tls</copy>
    ````
3. When we extract data from the pcap file, we will no longer see email addresses because the traffic we captured was encrypted.

    ````
    <copy>./tls_tcpdump_extract.sh pdb1_tls</copy>
    ````
## Task 6 (Optional): Disable encryption 

1. This step will disable TLS encryption for the listener, remove the parameters from the sqlnet.ora and tnsnames.ora file, and delete the TLS wallet files.

    ````
    <copy>./tls_disable.sh</copy>
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