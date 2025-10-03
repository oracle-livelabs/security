# Tolerate connectivity issues with secure persistent cache

## Introduction
Oracle Key Vault cluster deployment provides continuous availability in case of server failures, but may not help with network connectivity issues. What happens if there is an underwater landslide that cuts the connection between your databases and your Key Vault cluster? Not to worry, Key Vault's secure persistent cache saves your day and keeps your databases running.

Estimated Lab Time: 2 minutes

### Objectives
In this lab, you will check the secure persistent cache, simulate a connectivity failure, and create a new tablespace to observe cache-based operation.

### Prerequisites
This lab assumes you have completed lab 5.

## Task 1: Review Oracle Key Vault's secure persistent cache

1. List the IDs of the keys in the secure persistent cache

    ````
    <copy>
    $OKV_HOME/bin/okvutil list -t OKV_PERSISTENT_CACHE -l /etc/ORACLE/WALLETS/cdb1/okv/conf
    </copy>
    ````
    <!-- SHUBHAGO TO-DO -->
    **TO-DO: UPDATE THE PHOTO HERE**

   ![Key Vault](./images/image-2025-09-27_upload.png "Upload the pre-migration key from the old TDE wallet into the OKV wallet that you created in lab 5:")

## Task 2: Cut the connectivity to Oracle Key Vault server

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

    <!-- Shubham TBD -->

## Task 3: Create a new tablespace to confirm that database operations continue uninterrupted

1. Create a new tablespace

    ````
    <copy>
    sqlplus / as SYSDBA
    CREATE TABLESPACE tolerance_tbs DATAFILE 'tolerance_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT)';
    </copy>
    ````

2. Verify the new tablespace was created

    ````
    <copy>
    sqlplus / as SYSDBA
    SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE tablespace_name = UPPER('tolerance_tbs');
    </copy>
    ````

## Task 4: Restore connectivity

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