# Successfully protect your database communication using 1-way Transport Layer Security (TLS)

## Introduction
This workshop introduces the functionality of Oracle Transport Layer Security (TLS) network encryption. It gives the user an opportunity to learn how to configure this feature to encrypt and secure its data in-motion.

Description: TLS is the industry-standard for encrypting data in motion. Since TLS provides one-way authentication or mutual two-way authentication, it minimizes the chance of a breach.

*Estimated Lab Time:* 30 minutes

*Version tested in this lab:* Oracle DB 19.17

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

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

## Task 1: Download tls.zip file to local directory.

1.  Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle* and use `cd` command to move to livelabs directory.

    ````
    <copy>cd livelabs</copy>
    ````

    **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

2.  Use the Linux command 'wget' to download a bundled (zipped) file of the commands for the lab. 

    ````
    <copy>wget https://c4u04.objectstorage.us-ashburn-1.oci.customer-oci.com/p/EcTjWk2IuZPZeNnD_fYMcgUhdNDIDA6rt9gaFj_WZMiL7VvxPBNMY60837hu5hga/n/c4u04/b/livelabsfiles/o/security-library/tls.zip</copy>
    ````

3.  Unzip the tls.zip file downloaded.

    ````
    <copy>unzip tls.zip</copy>
    ````

4.  Remove tls zip. 
    
    ````
    <copy>rm tls.zip</copy>
    ````

5.  Change directory to tls. 
    
    ````
    <copy>cd tls/</copy>
    ````

6. Use following command to enable execute permissions on the shell scripts in the tls directory. 
    
    ````
    <copy>chmod +x *.sh</copy>
    ````

7.  Converts file to Unix. This may not be necessary but it will not harm the files to run it. 
    
    ````
    <copy>dos2unix *</copy>
    ````
    
## Task 2: Verify network traffic is unencrypted before configuring TLS.

1. Use the following command to ping the pluggable database, PDB1.

    ````
    <copy>tnsping pdb1</copy>
    ````

2. First, let's look at the existing PDB1 connection to see that the data is not encrypted in motion.

    ````
    <copy>./tls_is_sess_encrypt.sh pdb1</copy>
    ````
    Your NETWORK_PROTOCOL should not be encrypted and read 'tcp'


3. This allows you to intercept traffic on port 1521 and generates a packet capture (pcap) file. 

    ````
    <copy>./tls_tcpdump_traffic.sh pdb1</copy>
    ````

4. Extracts readable data from pcap file, you will see email addressess in the output.

    ````
    <copy>./tls_tcpdump_extract.sh pdb1</copy>
    ````



## Task 3: Create root wallet and self signed root CA certificate. 

1. In this step, the script will use `orapki` to create the wallet, generate the self-signed certificate and export the trusted certificate for use by the client trust store. 

    ````
    <copy>./tls_create_rootCA_wallet.sh</copy>
    ````

## Task 4: Create database server wallet and create certificate request.

1. Next, you will create the DB wallet and certificate request to be signed by the rootCA. This step also imports the rootCA trusted certificate into the DB wallet.

    ````
    <copy>./tls_create_DB_wallet.sh</copy>
    ````

## Task 5: Sign database certificate with root CA certificate.

1. Now, you will have the rootCA sign the DB server user certificate. This provides validity to the certificate. If it is not signed by a public root, or intermediate, certificate authority (CA), or an organization's root, or intermediate, CA, then the certificate may not be trustworthy.

    ````
    <copy>./tls_sign_DB_cert.sh</copy>
    ````


## Task 6: Add CA root certificate and database server certificate to database wallet.

1. After generating the signed DB user certificate, import it to the DB wallet. In this step, you will see that the DB server user certificate changes from a "requested certificate" to a "user certificate". 

    ````
    <copy>./tls_import_signed_cert.sh</copy>
    ````
Note: Before importing the signed user certificate, the DB wallet output looks like this:

```
Requested Certificates: 
Subject:        CN=dbsec-lab,OU=dbsecdemo,O=LiveLabs,L=Austin,ST=Texas,C=US
User Certificates:
Trusted Certificates: 
Subject:        C=US,CN=ROOT
```

After importing the signed certificate, the DB wallet output looks like this:

```
Requested Certificates: 
User Certificates:
Subject:        CN=dbsec-lab,OU=dbsecdemo,O=LiveLabs,L=Austin,ST=Texas,C=US
Trusted Certificates: 
Subject:        C=US,CN=ROOT
```

## Task 7: Import CA root certificate into client trust store (Linux, Windows only)

1. Now that you have your signed DB server user certificate, you will deploy it to your DB wallet root location. The DB will use the `WALLET_ROOT` parameter to look for it's wallet-related information, including tde and tls. This step will copy the DB wallet, with the signed certificate, to both the PDB's `WALLET_ROOT` tls directory and the default directory an Oracle software client would search for the wallet, `/etc/ORACLE/WALLETS/<user>`, in this case it would be `/etc/ORACLE/WALLETS/oracle` since we are using `sqlplus` as the `oracle` user. 

    ````
    <copy>./tls_deploy_db_wallet.sh</copy>
    ````
Note: In order to set the WALLET_ROOT initialization parameter the DB must be restarted. The script will automatically restart the DB for you. 

## Task 8: Configure for TLS network encryption.

1. Add a new tnsnames.ora entry for the pdb1_tls connection string. This will copy the existing pdb1 connection string and modify it to use TCPS protocol and port 1522 instead of TCP and 1521.

    ````
    <copy>./tls_update_tnsnames_ora.sh</copy>
    ````

2. In this step, we update the database's sqlnet.ora to include the SSL\_CLIENT\_AUTHENTICATION parameter as false. When set to false, one-way TLS can be used by the client. If set to true, mutual TLS (mTLS) must be used.

    ````
    <copy>./tls_update_sqlnet_ora.sh</copy>
    ````

3. This step will stop the Oracle Listener and update the listener.ora to be available for TCPS (TLS) connections on port 1522. After starting the Oracle Listener, it will dynamically register the existing CDB and PDBs with it.

    ````
    <copy>./tls_update_listener_ora.sh</copy>
    ````
4. Ensure you can still use tnsping to connect to the un-encrypted listener alias for PDB1.

    ````
    <copy>tnsping pdb1</copy>
    ````

5. Now, because our listener is available for TCPS (TLS) connections on port 1522, we can use tnsping to verify connectivity.

    ````
    <copy>tnsping pdb1_tls</copy>
    ````
## Task 9: Connect using TLS network encryption and verify traffic is encrypted.

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
    You have succesfully encrypted data-in-motion between the Oracle Database and the Oracle SQL*Plus client.

## Task 10: Create new OS user and encrypt SQL traffic. 

1. The next step is to create a separate operating system user and ensure the connectivity between the new user and the Oracle Database is also encrypted. Create the OS user, 'dba_dan'.

    ````
    <copy>./tls_useradd_dba_dan.sh</copy>
    ````
2. Install the Oracle Instant Client and SQL*Plus RPMs. Note: For this step, your VM must have internet access to download two RPMs.

    ````
    <copy>./tls_install_oracle_ic.sh</copy>
    ````
3. Create a tns\_admin directory and a sqlnet.ora for 'dba\_dan' in Dan's home directory.

    ````
    <copy>./tls_dba_dan_sqlnet_ora.sh</copy>
    ````
4. Create a tns\_admin directory and a tnsnames.ora file for 'dba\_dan' in Dan's home directory. The tnsnames.ora file will only have an entry for the pdb1_tls alias. 

    ````
    <copy>./tls_dba_dan_tnsnames_ora.sh</copy>
    ````
5. Because the Oracle Database is using a self-signed certificate, from the rootCA, either 'dba_dan' must maintain a wallet with the rootCA trusted certificate or the rootCA trusted certificate must be added to the Linux trusted root certificates list. In this step, you will add the rootCA trusted certificate to the Linux trusted root certificates list, allowing all users on the OS to use it to connect to PDB1 via TCPS on port 1522. In an enterprise environment, this would be the most efficient method to manage internal, self-signed, certificates to connect to Oracle Databases that use TLS.  On Windows, you would install this certificate using the Microsoft Management Console (MMC).

    ````
    <copy>./tls_install_linux_cert.sh</copy>
    ````
Note: You will see that the rootCA.crt was copied to the Linux directory '/etc/pki/ca-trust/source/anchor' and loaded into the list of trusted certificates. This location may vary based on the Linux distribution you use in your environment.

6. Test the connectivity as the Linux user 'dba_dan'.

    ````
    <copy>sudo su - dba_dan</copy>
    ````
7. The Oracle Instant Client needs to know where to find the tns-related parameters. This will be the alias, pdb1\_tls, and the SSL\_CLIENT\_AUTHENTICATION connection specifying TLS instead of mTLS.

    ````
    <copy>export TNS_ADMIN=$HOME/tns_admin</copy>
    ````
8.  Use SQL*Plus to connect to the DB using the tcps encrypted listener. 

    ````
    <copy>sqlplus system/Oracle123@pdb1_tls</copy>
    ````
9. Show that the network protocol is 'tcps'.

    ````
    <copy>SELECT sys_context('USERENV', 'NETWORK_PROTOCOL') as network_protocol FROM dual;</copy>
    ````

## Task 11 : (Optional) Disable encryption 

1. Exit SQL*Plus.

    ````
    <copy>exit</copy>
    ````

2. Exit from DBA Dan back to Oracle user. 

    ````
    <copy>exit</copy>
    ````

3. This step will disable TLS encryption for the listener, remove the parameters from the sqlnet.ora and tnsnames.ora file, and delete the TLS wallet files.

    ````
    <copy>./tls_disable.sh</copy>
    ````



## **Appendix**: About the Product
### **Overview**

Oracle Database provides both native data network encryption and TLS-based encryption to ensure that data in-motion is secure as it travels across the network.

![Network Encryption](./images/nne-concept.png "Network Encryption")



## Learn More
Technical Documentation:
- [Configuring Transport Layer Security Authentication](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/configuring-secure-sockets-layer-authentication.html)

## Acknowledgements
- **Author** - Stephen Stuart & Alpha Diallo, Solution Engineers, North America Specialist Hub
- **Contributors** - Richard C. Evans, Database Security Product Manager 
- **Last Updated By/Date** - Stephen Stuart & Alpha Diallo, April 2023
