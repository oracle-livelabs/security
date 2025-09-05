# Oracle Key Vault (OKV)

## Enable lights-out operations
In certain scenarios, it can be important to allow a database to open the connection to Oracle Kay Vault without human intervention, for example when a RAC instance is automatically restarted, or when a Data Guard primary database restarts after a role transition to take on the standby role.

*Estimated Lab Time:* 2 minutes

### Objectives
- Learn how to setup an auto-open OKV connection.

### Prerequisites
This lab assumes you went through Lab 5. 

## Lab 7: Enable lights-out operations
### Task 1: Enable lights-out operations

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````
    <copy>
    cd $DBSEC_LABS/okv
    </copy>
    ````

2. Add the keystore password (that you defined when you installed the OKV client software) into a new (local) auto-open wallet in <WALLET_ROOT>/tde.

    ````
    <copy>
    ./enable-lights-out-operation.sh
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-05-enable-light-out-operation.png "Upload the pre-migration key from the old TDE wallet into the OKV wallet that you created in Lab 5:")