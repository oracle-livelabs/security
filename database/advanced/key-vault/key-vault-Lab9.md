# Increased key control for less secure environments

## Introduction
In certain scenarios, it may be necessary to share data with environments that operate under lower security controls. However, it is critical that the TDE master encryption keys aren't exposed with or downloaded to this environment, or cached with the secure persistent cache. For this purpose, the Oracle Key Vault can also manage keys that are non-extractable.

Estimated Lab Time: 2 minutes

### Objectives
In this lab, you will rekey with OKV as the external store, tagging the key as 'Non-Extractable'. You will then simulate a connectivity failure and attempt to create a new tablespace (which will fail), observing that keys remain protected.

### Prerequisites
This lab assumes you have completed lab 8.


## Task 1: Create a new tablespace with an Extractable key

1. Create a new tablespace

    ````
    <copy>
    sqlplus / as SYSDBA
    CREATE TABLESPACE extractable_key_tbs DATAFILE 'extractable_key_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT)';
    </copy>
    ````

2. Select from dba_tablespaces to verify that the new tablespace was created

    ````
    <copy>
    sqlplus / as SYSDBA
    SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE tablespace_name = UPPER('extractable_key_tbs');
    </copy>
    ````

## Task 2: Mark the key as Non-Extractable

1.  Login to Key Vault as user **KVRESTADMIN**

    Get the randonly generated password by executing this command

    ```
    <copy>
    cat wui_passphrase
    </copy>
    ```

    ![Key Vault](./images/Screenshot_2025-10-03_13.45.01.png "Login to Key Vault as the REST administrator.")

2. Click the **Endpoints** tab:

    ![Key Vault](./images/image-2025-7-24_12-11-54.png "Click the Endpoints tab.")

3. Click the **Settings** tab:

    <!-- TODO - change image -->
    **TO-DO: UPDATE PHOTO**

    ![Key Vault](./images/image-2025-7-24_15-59-1.png "Click on Add to add a new Endpoint:")

4. Scroll to the bottom and set the extractable attribute for the symmetric key to False

    <!-- TODO - add image -->
    **TO-DO: ADD PHOTO**


## Task 3: Cut the connectivity to Oracle Key Vault server

1. Cut the connectivity to the Key Vault server to simulate a network connection issue

    ````
    <copy>
    sudo iptables -A OUTPUT -p tcp --dport 5696 -j DROP
    </copy>
    ````

2. Confirm that the server is unreachable

    ````
    <copy>
    $OKV_HOME/bin/okvutil list -t OKV_PERSISTENT_CACHE -l /etc/ORACLE/WALLETS/cdb1/okv/conf
    </copy>
    ````

## Task 4: Attempt to create a new tablespace to confirm that database operations fail even when the secure persistent cache exists

   1. Attempt to create a new tablespace

    ````
    <copy>
    sqlplus / as SYSDBA
    CREATE TABLESPACE extractable_key_tbs DATAFILE 'extractable_key_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT)';
    </copy>
    ````

## Task 5: Restore connectivity

1. Restore the connectivity to the Key Vault server

    ````
    <copy>
    sudo iptables -D OUTPUT -p tcp --dport 5696 -j DROP
    </copy>
    ````

2. Confirm that the server is reachable

    ````
    <copy>
    $OKV_HOME/bin/okvutil list -t OKV_PERSISTENT_CACHE -l /etc/ORACLE/WALLETS/cdb1/okv/conf
    </copy>
    ````

