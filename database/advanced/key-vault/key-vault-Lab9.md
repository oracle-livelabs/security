# Increased Key Control for Less Secure Environments

## Introduction
In certain scenarios, it may be necessary to share data with environments that operate under lower security controls. However, it is critical that the TDE master encryption keys aren't exposed with this environment, downloaded or cached with the secure persistent cache. For this purpose, the Oracle Key Vault can manage keys that are non-extractable.

Estimated Lab Time: 2 minutes

### Objectives
In this lab, you will rekey a key with OKV as the external store but tag the key with the attribute 'Non-Extractable'. You will then simulate a connectivity failure, and then attempt to create a new tablespace (which will fail), to observe how the keys weren't exposed/available to the riskier environment.

### Prerequisites
This lab assumes you have completed lab 8.


## Task 1: Create a new tablespace with Extractable key

   1. Create a new tablespace

    ````plaintext
    <copy>
    sqlplus / as sysdba
    CREATE TABLESPACE extractable_key_tbs DATAFILE 'extractable_key_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT)';
    </copy>
    ````

    2. Select from v$encrypted_tablespaces to show the new tablespace was created

    ````plaintext
    <copy>
    sqlplus / as sysdba
    SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE tablespace_name = UPPER('extractable_key_tbs');
    </copy>
    ````



## Task 2: Mark the key as non-extractable

1.  Login to Key Vault as user **KVRESTADMIN**

    Get the randonly generated password by executing this command

    ```
    <copy>
    cat wui_passphrase
    </copy>
    ```
<!-- TODO - change image -->
     ![Key Vault](./images/image-2025-7-24_12-13-38.png "Login to Key Vault as an endpoint administrator.")

2. Click the **Endpoints** tab:

    ![Key Vault](./images/image-2025-7-24_12-11-54.png "Click the Endpoints tab.")

3. Click the **Settings** tab:
<!-- TODO - change image -->
    ![Key Vault](./images/image-2025-7-24_15-59-1.png "Click on Add to add a new Endpoint:")

4. Scroll to the bottom and set the extractable attribute for the symmetric key to False

<!-- TODO - add image -->


## Task 3: Cut the connectivity to OKV server

1. Cut the connectivity to the OKV server

    ````plaintext
    <copy>
    sudo iptables -A OUTPUT -p tcp --dport 5696 -j DROP
    </copy>
    ````

2. Run okvutil list to confirm network connectivity is not there

    ````plaintext
    <copy>
    $OKV_HOME/bin/okvutil list -t OKV_PERSISTENT_CACHE -l /etc/ORACLE/WALLETS/cdb1/okv/conf
    </copy>
    ````

    <!-- Shubham TBD -->

## Task 4: Create a new tablespace to confirm that DB operations fail even if secure persistent cache exists

   1. Create a new tablespace

    ````plaintext
    <copy>
    sqlplus / as sysdba
    CREATE TABLESPACE extractable_key_tbs DATAFILE 'extractable_key_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT)';
    </copy>
    ````

## Task 5: Restore connectivity

1. Restore the connectivity to the OKV server

    ````plaintext
    <copy>
    sudo iptables -D OUTPUT -p tcp --dport 5696 -j DROP
    </copy>
    ````

2. Run okvutil list to confirm network connectivity is there

    ````plaintext
    <copy>
    $OKV_HOME/bin/okvutil list -t OKV_PERSISTENT_CACHE -l /etc/ORACLE/WALLETS/cdb1/okv/conf
    </copy>
    ````

