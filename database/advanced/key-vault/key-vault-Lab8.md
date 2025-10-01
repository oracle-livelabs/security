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