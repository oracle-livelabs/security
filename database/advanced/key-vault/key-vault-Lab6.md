# Ensure a complete key transfer, leaving no keys on the database host

## Introduction
Full migration allows you to upload pre-migration keys from your local TDE wallet to Key Vault. This enables you to eventually delete the old TDE wallet and comply with PCI requirements, which mandate the removal of the TDE master encryption keys from the database hosts. Oracle Key Vault is the only key manager with this unique ability because OKV has been purpose-built for Oracle. No other key manager can do this.

Estimated Lab Time: 3 minutes

### Objectives
In this lab, you will upload pre-migration keys from your local TDE wallet to Oracle Key Vault (OKV), ensuring that no keys remain on the database host.

### Prerequisites
This lab builds on concepts and operations from lab 5. Complete lab 5 first before starting this lab.

## Task 1: Achieve PCI compliance with Oracle Key Vault

1. As part of achieving PCI compliance, upload the pre-migration keys from the database's TDE wallet to the default wallet in the Key Vault server created in lab 5.

    Enter the TDE wallet password when prompted for the source wallet password.

    When prompted for the Oracle Key Vault endpoint password, enter the Key Vault endpoint password.

    ````
    <copy>
    $OKV_HOME/bin/okvutil upload -t WALLET -g LIVELABS_DB_WALLET -l /etc/ORACLE/WALLETS/cdb1/tde/ -v 3
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-27_upload.png "Upload the pre-migration key from the local TDE wallet into the OKV wallet that you created in Lab 5:")

2. Set the TDE_CONFIGURATION of the database to "OKV"

    ````
    <copy>
    sqlplus / as sysdba
    ALTER SYSTEM SET TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=OKV' SCOPE = BOTH;
    exit;
    </copy>
    ````

   ![Key Vault](./images/TDE_CONFIG_OKV.png "Set the TDE_CONFIGURATION to 'OKV'")

3. To ensure security, delete the local TDE wallet from &lt;WALLET_ROOT&gt;/tde

    ````
    <copy>
    rm -v /etc/ORACLE/WALLETS/cdb1/tde/*
    ls /etc/ORACLE/WALLETS/cdb1/tde/
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-05-delete-wallet-after-upload.png "To ensure security, delete the local TDE wallet from <WALLET_ROOT>/tde:")
