# Oracle Transparent Data Encryption (TDE)

## Introduction
This workshop introduces you to Oracle Transparent Data Encryption (TDE). You will learn how to configure your database for TDE, and how to encrypt sensitive data.

*Estimated Lab Time:* 45 minutes

*Version used in this lab:* Oracle Database Enterprise Edition 19.25 (October 2024)

### Video Preview
Watch a preview of "*Livelabs - Oracle ASO (Transparent Data Encryption & Data Redaction) (May 2022)*" [](youtube:JflshZKgxYs)

### Objectives
- Enable Transparent Data Encryption (TDE) in your database
- Encrypt tablespaces with Transparent Data Encryption (TDE)

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
|1 | Configure database for TDE | <5 minutes |
|2 | Create password-protected TDE wallet | <5 minutes |
|3 | Create **local** auto-open TDE wallet | <5 minutes |
|4 | Create tagged master key for your database | <5 minutes |
|5 | Side-channel attack against an un-encrypted tablespace | <5 minutes |
|6 | Avoid side-channel attack by encrypting tablespace | <5 minutes |
|7 | Encrypt remaining tablespaces in CDB$ROOT and PDB1 | 5 minutes |
|8 | Rekey Master Encryption Keys | <5 minutes |

## Task 1: Configure database for TDE

1. Go to the scripts directory

    ````
    <copy>cd $DBSEC_LABS/tde</copy>
    ````
    
2. Set the database parameters to configure your database for TDE. This will require a database restart to take effect. The script will perform the restart for you.

    ````
    <copy>./01_tde_set_tde_parameters.sh</copy>
    ````

    ![TDE](./images/tde-003.png "Set TDE parameters")

## Task 2: Create password-protected TDE wallet

1. Create a password-protected TDE wallet for the root container and united PDBs:

    ````
    <copy>./02_tde_create_wallet.sh</copy>
    ````

    ![TDE](./images/tde-004.png "Create the TDE wallet")
**Note:** We added the password of the TDE wallet into another local auto-open wallet in `<WALLET_ROOT>/tde_seps` in order to replace the TDE wallet password with "EXTERNAL STORE" on the SQL*Plus command line.

## Task 3: Create local auto-open TDE wallet

1. Create a **LOCAL** auto-open TDE wallet from the password-protected TDE wallet:

    ````
    <copy>./03_tde_create_local_autologin_wallet.sh</copy>
    ````

    ![TDE](./images/tde-012.png "Create a LOCAL auto-login TDE wallet")

The `WALLET_TYPE` has changed from PASSWORD to `LOCAL_AUTOLOGIN`   

## Task 4: Create tagged master keys for your database:
1. To create the TDE master key for the container database, run the following command:

    ````
    <copy>./04a_tde_create_mek_cdb.sh</copy>
    ````

    ![TDE](./images/tde-005.png "Create the container database TDE Master Key")

2. To create a master encryption key for the pluggable database **PDB1**, run the following command:
   
   If the PDB **creates a master key**, that master key can only go into the wallet that is owned by the CDB$ROOT, automatically making the PDB a united PDB.

    ````
    <copy>./04b_tde_create_mek_pdb.sh</copy>
    ````

    ![TDE](./images/tde-006.png "Create the TDE Master Key for PDB1")

3. Confirm TDE master keys in the TDE wallet:

    ````
    <copy>./04c_tde_view_wallet_in_db.sh</copy>
    ````

    ![TDE](./images/tde-007.png "View key-ID and tag of the keys that you just created")

## Task 5: Side-channel attack against an un-encrypted tablespace

1. Use the Linux "strings" command to view application data in the data file `empdata_prod.dbf` which is associated with the `EMPDATA_PROD` tablespace:

    ````
    <copy>./05_tde_strings_data_empdataprod.sh</copy>
    ````

    ![TDE](./images/tde-015.png "View the data in the data file")

    **Note:**
    - You can see the data, bypassing the access controls of the database!
    - This is an Operating System command that bypasses the database to view the data
    - This is called a 'side-channel attack' because the database is unaware of it
    
## Task 6: Avoid side-channel attack by encrypting tablespace

 1. Encrypt the EMPDATA_PROD tablespace with AES256 (default):

    ````
    <copy>./06a_tde_encrypt_tbs.sh</copy>
    ````

    ![TDE](./images/tde-016.png "Encrypt EMPDATA_PROD tablespace")

 2. Now, try the side-channel attack again

    ````
    <copy>./06b_tde_strings_data_empdataprod.sh</copy>
    ````

    ![TDE](./images/tde-017.png "Try the side-channel attack again")

 You see that all of the data is now encrypted and no longer visible!

## Task 7: Encrypt remaining tablespaces in CDB$ROOT and PDB1

1. Encrypt SYSTEM, SYSAUX and USERS tablespaces in CDB$ROOT and all remaining tablespaces in PDB1.
Encrypting TEMP and UNDO tablespaces is optional, since all data is tracked and written into those files in encrypted form.

    ````
    <copy>./07_tde_encrypt_tbs.sh</copy>
    ````
   ![TDE](./images/tde-018.png "List of encrypted tablespaces.")

## Task 8: Rekey Master Encryption Keys

1. To rekey the TDE Master Key (MEK) of the CDB$ROOT, run the following command:

    ````
    <copy>./08a_tde_rekey_mek_cdb.sh</copy>
    ````

    - See the wallet content before and after re-keying CDB$ROOT:

    ![TDE](./images/tde-022.png "After rekeying the TDE Master Key of CDB$ROOT")

    
2. To rekey a Master Key (MEK) for the pluggable database **PDB1**, run the following command:

    ````
    <copy>./08b_tde_rekey_mek_pdb.sh</copy>
    ````

    - See the wallet content before and after re-keying PDB1:

    ![TDE](./images/tde-024.png "After rekeying the pluggable database TDE Master Key (MEK)")

## Task 9: Optionally, Restore Before TDE

1. Execute this script to restore the database:

    ````
    <copy>./99_restore-DB_before_TDE</copy>
    ````

    ![TDE](./images/tde-029.png "Check the initialization parameters")

You may now repeat this lab!

## **Appendix**: About the Product
### **Overview**

Available with the Oracle Database core product, this features is part of the *Advanced Security Option (ASO)*

TDE Enables you to encrypt data so that only an authorized recipient can read it.

Use TDE to protect sensitive data in a potentially unprotected environment, such as data you placed on backup media that is sent to an off-site storage location.

After the data is encrypted, this data is transparently decrypted for authorized users or applications when they access this data. TDE helps protect data stored on media (also called data at rest) in the event that the storage media or data file is stolen.

Oracle Database uses authentication, authorization, and auditing mechanisms to secure data in the database, but not in the operating system data files where data is stored. To protect these data files, Oracle Database provides Transparent Data Encryption (TDE). TDE encrypts sensitive data stored in data files. To prevent unauthorized decryption, TDE stores the encryption keys in a security module external to the database (Oracle Wallet, Oracle Key Vault, OCI KMS).

You can configure Oracle Key Vault as part of the TDE implementation. This enables you to centrally manage TDE master encryption keys of your enterprise. 

![TDE](./images/aso-concept-tde.png "TDE concept")

### **Benefits of Using Transparent Data Encryption**
- As a security administrator, you can be sure that sensitive data is encrypted and therefore safe in the event that the storage media or data file is stolen.
- Using TDE helps you address security-related regulatory compliance issues.
- You do not need to create auxiliary tables, triggers, or views to decrypt data for the authorized user or application. Data from tables is transparently decrypted for an authorized database user or application. An application that processes sensitive data can use TDE to provide strong data encryption with no changes to the application.
- Data is transparently decrypted for database users and applications that access this data. Database users and applications do not need to be aware that the data they are accessing is stored in encrypted form.
- You can convert un-encrypted tablespaces to encrypted tablespaces either **ONLINE** or **OFFLINE**, depending on your preferences.
- You do **not need to modify your applications** to handle the encrypted data. The database manages the data encryption and decryption.
- Oracle Database automates TDE master encryption key and keystore management operations. The user or application does not need to manage TDE master encryption keys.

## Want to Learn More?
Technical Documentation
- [Transparent Data Encryption (TDE) 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/asopart2.html)

Video:
- *Understanding Oracle Transparent Data Encryption (TDE) - Part1 (January 2020)* [](youtube:avNWykLpic4)
- *Understanding Oracle Transparent Data Encryption (TDE) - Part2 (February 2020)* [](youtube:aUfwG5MIMNU)
- *Back to basics with Transparent Data Encryption (TDE) (March 2021)* [](youtube:JflshZKgxYs)

## Acknowledgements
- **Author** - Peter Wahl, Database Security PM for Encryption, Key and Secrets Management
- **Last Updated By/Date** - Peter Wahl; December 2024