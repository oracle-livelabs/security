# Oracle Key Vault (OKV)

## Automate REKEY
DBA activities that do not change the TDE configuration can be executed without knowing the keystore password. That is important for separation of duties between DBAs and OKV administrators, and automation scripts that require TDE operations without spilling the keystore password.

*Estimated Lab Time:* 2 minutes 

### Objectives
- Learn how to hide the keystore password for separation of duties and automation.

### Prerequisites
This lab assumes you went through Lab 9. 

## Lab 10: Automate REKEY
### Task 1: Automate REKEY

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````
    <copy>
    cd $DBSEC_LABS/okv
    </copy>
    ````

2. Add the keystore password (that you defined when you installed the OKV client software) into a new local auto-open wallet in <WALLET_ROOT>/tde_seps.

    ````
    <copy>
    administer key management add secret 'Manager_1' for client 'OKV_PASSWORD' to local auto_login keystore '/etc/ORACLE/WALLETS/cdb1/tde_seps';
    </copy>
    ````
    ![Key Vault](./images/images-2025-09-26_12-41-08-tde_seps.png "Add the OKV password to a (local) auto-open wallet in <WALLET_ROOT>/tde_seps to replace it on the SQL*Plus command line with EXTERNAL STORE".)

3. To confirm the changed behaviour, execute a re-key operation without using the OKV password:

    ````
    <copy>
    administer key management set key identified by EXTERNAL STORE;
    </copy>
    ````
This command rotates the TDE master encryption keys for CDB\$ROOT and PDB1.    
