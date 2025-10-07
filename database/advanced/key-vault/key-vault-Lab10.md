# Automate key rotation

## Introduction
Scripting of the key rotation operations can be made easier and safer by storing the keystore password in an external store.

Estimated Lab Time: 5 minutes 

### Objectives
In this lab, you will add the keystore password to a local auto-login wallet and then use this wallet to perform a re-key operation without needing to enter the OKV password.

### Prerequisites
This lab assumes you have completed lab 9.

## Task 1: Automate re-key

1. Add the keystore password (that you defined when you installed the OKV client software in lab 5) into a new (local) auto-open wallet in &lt;WALLET_ROOT&gt;/tde

    ````
    <copy>
    sqlplus / as SYSDBA
    administer key management add secret '<Key Vault endpoint password>' for client 'OKV_PASSWORD' to local auto_login keystore '/etc/ORACLE/WALLETS/cdb1/tde_seps';
    </copy>
    ````
    
    ![Key Vault](./images/Screenshot_2025-10-03_16.19.30.png "Add the keystore password (that you defined when you installed the OKV client software in lab 5) into a new (local) auto-open wallet in <WALLET_ROOT>/tde")

2. To confirm the changed behaviour, execute a re-key operation without using the OKV password

    **TO-DO: FIX THIS CODE:**
    ````
    <copy>
    administer key management set key identified by EXTERNAL STORE;
    </copy>
    ````

    **TO-DO: THIS IS FAILING WITH:**
    ````
    SQL> administer key management set key identified by EXTERNAL STORE;
    administer key management set key identified by EXTERNAL STORE
    *
    ERROR at line 1:
    ORA-28407: Hardware Security Module failed with PKCS#11 error
    CKR_FUNCTION_FAILED(6)
    ````

    This command rotates the TDE master encryption keys for CDB$ROOT and PDB1.    
