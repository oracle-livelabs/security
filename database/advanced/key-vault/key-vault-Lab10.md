# Automate key rotation

## Introduction
Scripting of the key rotation operations can be made easier and safer by storing the keystore password in an external store.

Estimated Lab Time: 5 minutes 

### Objectives
In this lab, you will add the keystore password to a local auto-login wallet and then use this wallet to perform a re-key operation without needing to enter the OKV password.

### Prerequisites
This lab assumes you have completed lab 9.

## Task 1: Automate re-key

1. Add the keystore password into a new local auto-open wallet in &lt;WALLET_ROOT&gt;/tde

    ````
    <copy>
    sqlplus / as sysdba
    ADMINISTER KEY MANAGEMENT ADD SECRET '<Key Vault endpoint password>' FOR CLIENT 'OKV_PASSWORD' TO LOCAL AUTO_LOGIN KEYSTORE '/etc/ORACLE/WALLETS/cdb1/tde_seps';
    exit;
    </copy>
    ````
    
    ![Key Vault](./images/Screenshot_2025-10-03_16.19.30.png "Add the keystore password into a new local auto-open wallet in <WALLET_ROOT>/tde")

2. Check the Master Encryption Key ID before a re-key

    ```
    <copy>
    sqlplus / as sysdba
    select t.name as "ENCRYPTED TABLESPACE", 
        e.MASTERKEYID as "MASTER ENCRYPTION KEY ID"
      from v$tablespace t, v$encrypted_tablespaces e 
      where t.ts#=e.ts# and t.con_id = 1;
    exit;
    </copy>
    ```

    ![Key Vault](./images/Screenshot_2025-10-07_23.41.30.png "Check the Master Encryption Key ID before a re-key")

3. Execute a re-key operation without using the Key Vault password

    ````
    <copy>
    sqlplus / as sysdba
    ADMINISTER KEY MANAGEMENT SET KEY FORCE KEYSTORE IDENTIFIED BY EXTERNAL STORE;
    exit;
    </copy>
    ````

    This command rotates the TDE master encryption keys for CDB$ROOT and PDB1.    

    ![Key Vault](./images/Screenshot_2025-10-07_23.29.07.png "Execute a re-key operation without using the Key Vault password")

4. Verify that the tablespace was re-keyed

    ```
    <copy>
    sqlplus / as sysdba
    select t.name as "ENCRYPTED TABLESPACE", 
        e.MASTERKEYID as "MASTER ENCRYPTION KEY ID"
      from v$tablespace t, v$encrypted_tablespaces e 
      where t.ts#=e.ts# and t.con_id = 1;
    exit;
    </copy>
    ```

    ![Key Vault](./images/Screenshot_2025-10-07_23.39.39.png "Verify that the tablespace was re-keyed")