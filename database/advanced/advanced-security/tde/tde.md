# Oracle Transparent Data Encryption (TDE)

## Introduction
This workshop introduces the various features and functionality of Oracle Transparent Data Encryption (TDE). It gives the user an opportunity to learn how to configure those features in order to encrypt sensitive data.

*Estimated Lab Time:* 45 minutes

*Version used in this lab:* Oracle Database Enterprse Edition 19.25 (October 2024)

### Video Preview
Watch a preview of "*Livelabs - Oracle ASO (Transparent Data Encryption & Data Redaction) (May 2022)*" [](youtube:JflshZKgxYs)

### Objectives
- Enable Transparent Data Encryption in the database
- Encrypt data using Transparent Data Encryption

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
|1 | Create Keystore | <5 minutes |
|2 | Create Local Auto-login Keystore | <5 minutes |
|3 | Create Master Key | <5 minutes |
|4 | Encrypt Existing USERS Tablespaces in CDB$ROOT | 5 minutes |
|5 | Encrypt Credentials in CDB$ROOT | 5 minutes |
|6 | Encrypt SYSTEM, SYSAUX and USERS Tablespaces in PDB | 5 minutes |
|7 | Encrypt All New Tablespaces | 5 minutes |
|8 | Rekey Master Key | 5 minutes |
|9| View Keystore Details | 5 minutes |
|10| Restore Before TDE | 5 minutes |

## Task 1: Create Keystore

1. Go to the scripts directory

    ````
    <copy>cd $DBSEC_LABS/tde</copy>
    ````
    
2. Run this script to create the Keystore directories on the Operating System


    ````
    <copy>./tde_create_os_directory.sh</copy>
    ````

    ![TDE](./images/tde-002.png "Create the Keystore directories")

3. Set the database parameters to configure your datbaase for TDE. This will require a database restart to take effect. The script will perform the restart for you.

    ````
    <copy>./tde_set_tde_parameters.sh</copy>
    ````

    ![TDE](./images/tde-003.png "Set TDE parameters")

4. Create the software keystore (**Oracle Wallet**) for the container database. You will see the status result goes from `NOT_AVAILABLE` to `OPEN_NO_MASTER_KEY`.

    ````
    <copy>./tde_create_wallet.sh</copy>
    ````

    ![TDE](./images/tde-004.png "Create the software keystore")

    **Note:** We create a secret for the Administer password in order to hide it for the next command!

4. Now, your Oracle Wallet has been created!

## Task 2: Create a master encryption key for the CDB:

1. To create the container database TDE Master Key (**MEK**), run the following command

    ````
    <copy>./tde_create_mek_cdb.sh</copy>
    ````

    ![TDE](./images/tde-005.png "Create the container database TDE Master Key")

2. To create a master encryption key for the pluggable database **pdb1**, run the following command

    ````
    <copy>./tde_create_mek_pdb.sh pdb1</copy>
    ````

    ![TDE](./images/tde-006.png "Create the pluggable database TDE Master Key")

3. If you want, you can do the same for **pdb2**... This is not a requirement and it might be helpful to show some databases with TDE and some without

    ````
    <copy>./tde_create_mek_pdb.sh pdb2</copy>
    ````

    ![TDE](./images/tde-007.png "Create the pluggable database TDE Master Key")

4. Now, you have a master key and you can begin encrypting tablespaces!

## Task 3: Create Local Auto-login Wallet

1. Run the script to view the Oracle Wallet content on the Operating System

    ````
    <copy>./tde_view_wallet_on_os.sh</copy>
    ````

    ![TDE](./images/tde-010.png "View the Oracle Wallet content on the OS")

2. You can view what the Oracle Wallet looks like in the database

    ````
    <copy>./tde_view_wallet_in_db.sh</copy>
    ````

    ![TDE](./images/tde-011.png "View the Oracle Wallet content on the database")

3. Now, create the **Auto-login Oracle Wallet**

    ````
    <copy>./tde_create_local_autologin_wallet.sh</copy>
    ````

    ![TDE](./images/tde-012.png "Create a LOCAL auto-login Oracle Wallet")

4. Run the same queries to view the Oracle Wallet content on the Operating System

    ````
    <copy>./tde_view_wallet_on_os.sh</copy>
    ````   

    ![TDE](./images/tde-013.png "View the Oracle Wallet content on the OS")

    **Note**: You should now see the **cwallet.sso** file

5. And no changes to the Oracle Wallet in the d
atabase

    ````
    <copy>./tde_view_wallet_in_db.sh</copy>
    ````

    ![TDE](./images/tde-014.png "View the Oracle Wallet content on the database")

6. Now your local autologin is created!

## Task 4: Encrypt Existing Tablespace

1. Use the Linux command "strings" to view application data in the data file, `empdata_prod.dbf` that is associated with the `EMPDATA_PROD` tablespace

    ````
    <copy>./tde_strings_data_empdataprod.sh</copy>
    ````

    ![TDE](./images/tde-015.png "View the data in the data file")

    **Note:**
    - You can see the data and you are not connected to the database!
    - This is an Operating System command that bypasses the database to view the data
    - This is called a 'side-channel attack' because the database is unaware of it

2. Next, **encrypt explicitly** the data by encrypting the entire tablespace

    ````
    <copy>./tde_encrypt_tbs.sh</copy>
    ````

    ![TDE](./images/tde-016.png "Encrypt explicitly the data")

    **Note:** By default, the syntax is using the AES256 encryption algorithm

3. Now, try the side-channel attack again

    ````
    <copy>./tde_strings_data_empdataprod.sh</copy>
    ````

    ![TDE](./images/tde-017.png "Try the side-channel attack again")

4. You see that all of the data is now encrypted and no longer visible!

## Task 5: Automatically Encrypt New Tablespaces

1. First, check the existing initialization parameters

    ````
    <copy>./tde_check_init_params.sh</copy>
    ````

    ![TDE](./images/tde-018.png "Check the existing initialization parameters")

    **Note**:
    - The `TABLESPACE_ENCRYPTION` parameter is set to `AUTO_ENABLE` and cannot be modified, hence if you want to change it **the database must be restarted**!
    - This parameter, **introduced in Oracle Database version 19.16**, allows you to specify whether to encrypt newly created tablespaces
    - It replaces the `ENCRYPT_NEW_TABLESPACES` parameter which is now deprecated.
    - `ENCRYPT_NEW_TABLESPACES` follows `TABLESPACE_ENCRYPTION` and is set to `ALWAYS` when `TABLESPACE_ENCRYPTION` is set to `AUTO_ENABLE`
    - The init parameter `_tablespace_encryption_default_algorithm` is set to "`AES256`" and should not be changed to shorter algorithms.

<!--
2. Next, change the init parameter `TABLESPACE_ENCRYPTION` to "`AUTO_ENABLE`" to always **encrypt implicitly all new tablespaces**, and the hidden init parameter `_tablespace_encryption_default_algorithm` to use "`AES256`" as default encryption algorithm

    ````
    <copy>./tde_set_encrypt_all_new_tbs.sh</copy>
    ````

    ![TDE](./images/tde-019.png "Change the init parameters")

    **Note**:
    - The `TABLESPACE_ENCRYPTION` parameter cannot be modified, hence **the database must be restarted**!
    - This parameter is **introduced in Oracle Database version 19.16**, as an alternative to the `ENCRYPT_NEW_TABLESPACES` parameter
    - Similar to `ENCRYPT_NEW_TABLESPACES`, this parameter allows you to specify whether to encrypt newly created user tablespaces
    - If the behavior specified by the `ENCRYPT_NEW_TABLESPACES` setting conflicts with the behavior specified by the `TABLESPACE_ENCRYPTION` setting, then the `TABLESPACE_ENCRYPTION` behavior takes precedence
    - So, `ENCRYPT_NEW_TABLESPACES` is automatically set to `ALWAYS` when `TABLESPACE_ENCRYPTION` is set to `AUTO_ENABLE`
-->

2. Finally, create and drop a tablespace TEST to check the effect

    ````
    <copy>./tde_create_new_tbs.sh</copy>
    ````

    ![TDE](./images/tde-020.png "Create and drop a tablespace TEST to check the effect")

    **Note**: Despite the fact that the tablespace **TEST** was created without specifying encryption parameters, it's encrypted by default with the AES256 encryption algorithm.

3. Now, when tablespaces are created, for example during application install time, those application tablespace will be encrypted, even if the installation commands to not include the encryption keywords of the CREATE TABLESPACE command!

## Task 6: Rekey Master Key

1. To rekey the container database TDE Master Key (MEK), run the following command

    ````
    <copy>./tde_rekey_mek_cdb.sh</copy>
    ````

    - Have a look on the CDB key before rekeying...

  ![TDE](./images/tde-021.png "Before rekeying the container database TDE Master Key (MEK)")

    - ... and after:

    ![TDE](./images/tde-022.png "After rekeying the container database TDE Master Key (MEK)")

    - You can see the new key generated for the container

2. To rekey a Master Key (MEK) for the pluggable database **pdb1**, run the following command

    ````
    <copy>./tde_rekey_mek_pdb.sh pdb1</copy>
    ````

    - Have a look on the pdb1 key before rekeying...

    ![TDE](./images/tde-023.png "Before rekeying the pluggable database TDE Master Key (MEK)")

    - ...and after

    ![TDE](./images/tde-024a.png "After rekeying the pluggable database TDE Master Key (MEK)")

    - You can see the new key generated for the pluggable database

3. If you want, you can do the same for **pdb2**

    ````
    <copy>./tde_rekey_mek_pdb.sh pdb2</copy>
    ````

    **Note**:
    - This is not a requirement though
    - It might be helpful to show some databases with TDE and some without

4. Now that you have a master key, you can begin encrypting tablespaces or column!

## Task 7: View Keystore Details

1. Once you have a keystore, you can run either of these scripts. You will notice there are multiple copies of the **ewallet.p12** file. Every time you make a change, including create or rekey, the ewallet.p12 file is backed up. You will also see the contents of the Oracle Wallet file by using **orapki**

   - View the OS files related to the keystore

    ````
    <copy>./tde_view_wallet_on_os.sh</copy>
    ````
       
    ![TDE](./images/tde-024b.png "View the OS files related to the keystore")

   - View the keystore data in the database

    ````
    <copy>./tde_view_wallet_in_db.sh</copy>
    ````

    ![TDE](./images/tde-024c.png "View the keystore data in the database")

## Task 8: Optionally, Restore Before TDE

1. First, execute this script to restore the pfile

    ````
    <copy>./tde_restore_init_parameters.sh</copy>
    ````

    ![TDE](./images/tde-025.png "Restore the PFILE")


2. Second, restore the database (this may take some time)

    ````
    <copy>./tde_restore_db.sh</copy>
    ````

    ![TDE](./images/tde-026.png "Restore the database")

3. Third, delete the associated Oracle Wallet files

    ````
    <copy>./tde_delete_wallet_files.sh</copy>
    ````

    ![TDE](./images/tde-027.png "Delete the associated Oracle Wallet files")

4. Fourth, start the container and pluggable databases

    ````
    <copy>./tde_start_db.sh</copy>
    ````

    ![TDE](./images/tde-028.png "Start the databases")

    **Note**: This should have restored your database to it's pre-TDE state!

5. Finally, verify the initialization parameters don't say anything about TDE

    ````
    <copy>./tde_check_init_params.sh</copy>
    ````

    ![TDE](./images/tde-029.png "Check the initialization parameters")

7. Now, your database is restored to the point in time prior to enabling TDE and you can remove your dabase backup (optional)!

    ````
    <copy>./tde_delete_backup_db.sh</copy>
    ````

    ![TDE](./images/tde-030.png "Remove your dabase backup (optional)")

You may now proceed to the next lab!

## **Appendix**: About the Product
### **Overview**

Available with the Oracle Database core product, this features is part of the *Advanced Security Option (ASO)*

TDE Enables you to encrypt data so that only an authorized recipient can read it.

Use encryption to protect sensitive data in a potentially unprotected environment, such as data you placed on backup media that is sent to an off-site storage location. You can encrypt individual columns in a database table, or you can encrypt an entire tablespace.

After the data is encrypted, this data is transparently decrypted for authorized users or applications when they access this data. TDE helps protect data stored on media (also called data at rest) in the event that the storage media or data file is stolen.

Oracle Database uses authentication, authorization, and auditing mechanisms to secure data in the database, but not in the operating system data files where data is stored. To protect these data files, Oracle Database provides Transparent Data Encryption (TDE). TDE encrypts sensitive data stored in data files. To prevent unauthorized decryption, TDE stores the encryption keys in a security module external to the database, called a keystore.

You can configure Oracle Key Vault as part of the TDE implementation. This enables you to centrally manage TDE keystores (called TDE wallets in Oracle Key Vault) in your enterprise. For example, you can upload a software keystore to Oracle Key Vault and then make the contents of this keystore available to other TDE-enabled databases.

![TDE](./images/aso-concept-tde.png "TDE concept")

### **Benefits of Using Transparent Data Encryption**
- As a security administrator, you can be sure that sensitive data is encrypted and therefore safe in the event that the storage media or data file is stolen
- Using TDE helps you address security-related regulatory compliance issues
- You do not need to create auxiliary tables, triggers, or views to decrypt data for the authorized user or application. Data from tables is transparently decrypted for the database user and application. An application that processes sensitive data can use TDE to provide strong data encryption with little or no change to the application
- Data is transparently decrypted for database users and applications that access this data. Database users and applications do not need to be aware that the data they are accessing is stored in encrypted form
- You can encrypt data with zero downtime on production systems by using `Online Table Redefinition` or you can encrypt it offline during maintenance periods (see `Oracle Database Administrator’s Guide` for more information about `Online Table Redefinition`)
- You do not need to modify your applications to handle the encrypted data. The database manages the data encryption and decryption
- Oracle Database automates TDE master encryption key and keystore management operations. The user or application does not need to manage TDE master encryption keys

## Want to Learn More?
Technical Documentation
- [Transparent Data Encryption (TDE) 19c](https://docs.oracle.com/en/database/oracle/oracle-database/19/asoag/asopart2.html)

Video:
- *Understanding Oracle Transparent Data Encryption (TDE) - Part1 (January 2020)* [](youtube:avNWykLpic4)
- *Understanding Oracle Transparent Data Encryption (TDE) - Part2 (February 2020)* [](youtube:aUfwG5MIMNU)
- *Back to basics with Transparent Data Encryption (TDE) (March 2021)* [](youtube:JflshZKgxYs)

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Peter Wahl, Database Security PM
- **Last Updated By/Date** - Peter Wahl, Database Security PM for Encryption, Key and Secrets Management - November 2024