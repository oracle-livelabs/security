# Oracle Key Vault (OKV)

## Ignore intermittent connectivity with Persistent cache
- Oracle Key Vault already provides continuous availability by building an OKV cluster on-prem, or stretching it into any Cloud. What if something happens, like an underwater landslide, that cuts the connection between your databases and your OKV cluster? Not to worry, OKVs persistent cache saves your day and keeps your databases running. 

*Estimated Lab Time:* 2 minutes

### Objectives
- Learn how to read current pCache settings and tune them to match your expectations.

### Prerequisites
This lab assumes you went through Lab 7. 

## Lab 8: Ignore intermittent connectivity with Persistent cache
### Task 1: Investigate OKV's persistent cache

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````plaintext
    <copy>
    cd $DBSEC_LABS/okv
    </copy>
    ````

2. Confirm the expiration times in the persistent cache:

    ````plaintext
    <copy>
    $OKV_HOME/bin/okvutil list -t OKV_PERSISTENT_CACHE -l /etc/ORACLE/WALLETS/cdb1/okv/conf
        </copy>
    ````

   ![Key Vault](./images/XXimage-2025-09-27_upload.png "Upload the pre-migration key from the old TDE wallet into the OKV wallet that you created in Lab 5:")