# Tolerate Connectivity Issues with Secure Persistent Cache

## Introduction
Oracle Key Vault already provides continuous availability by building a multi-master cluster on-prem or stretching it into any cloud. But what happens if there is an underwater landslide that cuts the connection between your databases and your OKV cluster? Not to worry, OKV's secure persistent cache saves your day and keeps your databases running.

Estimated Lab Time: 2 minutes

### Objectives
In this lab, you will check the contents of the secure persistent cache, simulate a connectivity failure, and then create a new tablespace to observe how the action will succeed using the secure persistent cache.

shorten objective

### Prerequisites
This lab assumes you have completed lab 5.

## Task 1: Investigate OKV's persistent cache

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````plaintext
    <copy>
    cd $DBSEC_LABS/okv
    </copy>
    ````

2. Confirm the expiration times in the secure persistent cache:

    ````plaintext
    <copy>
    $OKV_HOME/bin/okvutil list -t OKV_PERSISTENT_CACHE -l /etc/ORACLE/WALLETS/cdb1/okv/conf
    </copy>
    ````

   ![Key Vault](./images/XXimage-2025-09-27_upload.png "Upload the pre-migration key from the old TDE wallet into the OKV wallet that you created in Lab 5:")

    <!-- Shubham TBD -->

## Task 2: Cut the connectivity to OKV server

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

## Task 3: Create a new tablespace to confirm that DB operations continue uninterrupted

   1. Create a new tablespace

    ````plaintext
    <copy>
    sqlplus / as sysdba
    CREATE TABLESPACE tolerance_tbs DATAFILE 'tolerance_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT)';
    </copy>
    ````

    2. Select from v$encrypted_tablespaces to show the new tablespace was created

    ````plaintext
    <copy>
    sqlplus / as sysdba
    SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE tablespace_name = UPPER('tolerance_tbs');
    </copy>
    ````

## Task 4: Restore connectivity

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