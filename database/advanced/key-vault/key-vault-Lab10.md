# Simplify Key Rotation

## Introduction
DBA activities that do not change the TDE configuration can be executed without knowing the keystore password. This is critical for separation of duties between DBAs and OKV administrators. Additionally, this is useful for automation scripts that perform TDE operations eliminating the need to manually type the keystore password.


simplify password management for scripting key rotation operations for example not to expose password in bash scrpt

Estimated Lab Time: 2 minutes 

### Objectives
In this lab, you will add the keystore password to a local auto-login wallet and then use this wallet to perform a rekey operation without needing to enter the OKV password.

### Prerequisites
This lab assumes you have completed lab 9.

## Task 1: Automate REKEY

1. Log into your **DBSec-Lab** database as SYSDBA:

    ````
    <copy>
    sqlplus / as SYSDBA
    </copy>
    ````

2. Add the keystore password (that you defined when you installed the OKV client software) into a new local auto-open wallet in <WALLET_ROOT>/tde_seps.

    ````
    <copy>
    administer key management add secret '*********' for client 'OKV_PASSWORD' to local auto_login keystore '/etc/ORACLE/WALLETS/cdb1/tde_seps';
    </copy>
    ````

    ![Key Vault](./images/images-2025-09-26_12-41-08-tde_seps.png "Add the OKV password to a (local) auto-open wallet in <WALLET_ROOT>/tde_seps to replace it on the SQL*Plus command line with EXTERNAL STORE.")

3. To confirm the changed behaviour, execute a re-key operation without using the OKV password:

    ````
    <copy>
    administer key management set key identified by EXTERNAL STORE;
    </copy>
    ````
This command rotates the TDE master encryption keys for CDB\$ROOT and PDB1.    
