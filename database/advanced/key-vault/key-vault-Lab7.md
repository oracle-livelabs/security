# Oracle Key Vault (OKV)

## Enable lights-out operations
In certain scenarios, it can be important to allow a database to open the connection to Oracle Key Vault without human intervention, for example when a RAC instance is automatically restarted by Oracle Grid Infrastructre, or when a Data Guard primary database restarts after a role transition to take on the standby role.

*Estimated Lab Time:* 2 minutes

### Objectives
- Learn how to setup an auto-open OKV connection.

### Prerequisites
This lab assumes you went through Lab 6. 

## Lab 7: Enable lights-out operations
### Task 1: Enable lights-out operations

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````plaintext
    <copy>
    cd $DBSEC_LABS/okv
    </copy>
    ````

2. Add the keystore password (that you defined when you installed the OKV client software) into a new (local) auto-open wallet in <WALLET_ROOT>/tde.

    ````
    <copy>
    administer key management add secret '*********' for client 'OKV_PASSWORD' to local auto_login keystore '/etc/ORACLE/WALLETS/cdb1/tde';
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-25_11-48-23.png "Add the OKV password to the TDE wallet in <WALLET_ROOT>/tde to enable auto-open OKV configuration.")

3. Change the TDE_CONFIGURATION to 'OKV|FILE' to enable the database to find the new wallet in <WALLET_ROOT>/tde.

    ```
    <copy>
    alter system set TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=OKV|FILE' scope = BOTH;
    </copy>
    ```

    ![Key Vault](./images/image-2025-7-24_12-53-4.png "Change the TDE configuration to OKV|FILE:")


