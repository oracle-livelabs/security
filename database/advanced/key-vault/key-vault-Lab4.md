# Oracle Key Vault (OKV)

## Review a typical TDE environment
- In this lab you will confirm the encryption status of an Oracle database, and you will understand how TDE has been setup.

*Estimated Lab Time:* 2 minutes

### Objectives
- You have been tasked with migrating an encrypted database to Oracle Key Vault for centralized key management. The first thing to do is to understand how TDE has been setup and which tablespaces are encrypted.

### Prerequisites
This lab assumes you went through Lab 3. 

## Lab 4: Review a typical TDE environment
### Task 1: Review TDE setup in an encrypted database

An encrypted database has been prepared for you:

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

<if type="brown">
    ````
    <copy>sudo su - oracle</copy>
    ````
</if>
<if type="green">
    **Note**: Double-click on the Terminal icon on the desktop to launch a session directly as oracle
</if>

2. Go to the OKV LiveLab scripts directory

    ````
    <copy>cd $DBSEC_LABS/okv</copy>
    ````

3. Display the parameters that define how TDE is setup in your database:

    ````
    <copy>./01_tde_show_tde_parameters.sh</copy>
    ````

    ![Key Vault](./images/okv_2504_001.png "Display the parameters that define how TDE is setup in your database:")

4. Confirm the encryption status of the root database and PDB1:

    ````
    <copy>./02_tde_list_enc_tbs.sh</copy>
    ````

    ![Key Vault](./images/okv_2504_002.png "Confirm the encryption status of the root database and PDB1:")

5. See the TDE master encryption keys in the TDE wallet:

    ````
    <copy>./03_tde_show_TDE_keys.sh</copy>
    ````

    ![Key Vault](./images/okv_xxxxxxxxx.png "See the TDE master encryption in the TDE wallet:")

### Task 2: Drop an encrypted tablespace for 'True Migration' Lab (Backup has been taken)

1. Select from table; delete tablespace; select from table (fails)
    ````
    <copy>./04_xxxxxxxxxxxxxxxxxx.sh</copy>
    ````

    ![Key Vault](./images/.png "Make an RMAN backup of an encrypted tablespace:")