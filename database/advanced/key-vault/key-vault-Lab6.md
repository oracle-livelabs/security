# Oracle Key Vault (OKV)

## Full Migration
Full migration is a term that only applies to Oracle Key Vault: Because OKV has been purpose-built for Oracle, it uniquely allows to upload pre-migration keys from the wallet into OKV, enabling you to eventually delete the old TDE wallet and comply with PCI which requires to remove encryption keys from the encrypting server. No other key manager can do this.

*Estimated Lab Time:* 2 minutes

### Objectives
- Learn how to upload pre-migration keys from the TDE wallet to OKV

### Prerequisites
This lab assumes you went through Lab 5. 

### Task 1: Achieve PCI compliance ONLY with Oracle Key Vault

1. Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

    ````plaintext
    <copy>
    cd $DBSEC_LABS/okv
    </copy>
    ````

2. Upload the pre-migration key from the TDE wallet into the OKV wallet that you created in Lab 5:

    ````plaintext
    <copy>
    $OKV_HOME/bin/okvutil upload -t WALLET -g LIVELABS_DB_WALLET -l /etc/ORACLE/WALLETS/cdb1/tde/ -v 3
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-27_upload.png "Upload the pre-migration key from the old TDE wallet into the OKV wallet that you created in Lab 5:")

3. Set the TDE_CONFIGURATION to "OKV":

    ````plaintext
    <copy>
    ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=OKV' scope = both;
    </copy>
    ````

   ![Key Vault](./images/TDE_CONFIG_OKV.png "Set the TDE_CONFIGURATION to 'OKV'")

4. Delete the TDE wallet from <WALLET_ROOT>/tde:

    ````plaintext
    <copy>
    rm -v /etc/ORACLE/WALLETS/cdb1/tde/*
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-05-delete-wallet-after-upload.png "Delete the old TDE wallet from <WALLET_ROOT>/tde:")
