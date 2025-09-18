# Oracle Key Vault (OKV)

## Full Migration (better use case, keep backups and keys that is compliance)
Full migration is a term that only applies to Oracle Key Vault: Because OKV has been purpose-built for Oracle, it uniquely allows to upload pre-migration keys from the wallet into OKV, enabling you to eventually delete the old wallet and comply with PCI which requires to remove encryption keys from the encrypting server. No other key manager can do this.

*Estimated Lab Time:* 2 minutes

### Objectives
- Learn how to upload pre-migration keys from the TDE wallet to OKV

### Prerequisites
This lab assumes you went through Lab 5. 

### Task 1: PCI compliance ONLY with Oracle Key Vault

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````
    <copy>
    cd $DBSEC_LABS/okv
    </copy>
    ````

2. Upload the pre-migration key from the TDE wallet into the OKV wallet that you created in Lab 5:

    ````
    <copy>
    $OKV_HOME/bin/okvutil upload -t WALLET -g LIVELABS_DB_WALLET -l /etc/ORACLE/WALLETS/cdb1/tde/ -v 3
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-04_upload.png "Upload the pre-migration key from the old TDE wallet into the OKV wallet that you created in Lab 5:")

3. Delete the TDE wallet from <WALLET_ROOT>/tde:
    ````
    <copy>
    rm -v /etc/ORACLE/WALLETS/cbd1/tde/*
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-05-delete-wallet-after-upload.png "Delete the old TDE wallet from <WALLET_ROOT>/tde:")

4.  Change the TDE configuration to OKV:
   
       ```
       <copy>
       alter system set TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=OKV' scope = BOTH;
       </copy>
       ```
   
       ![Key Vault](./images/TDE_CONFIG_OKV.png "Change the TDE configuration to OKV|FILE:")