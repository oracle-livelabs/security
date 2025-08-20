# Oracle Key Vault (OKV)

## Review a typical TDE environment
Before migrating a database from local TDE wallet to centralized key management with Oracle Key Vault, you need to understand how the TDE parameters are set, and what tablespaces are encrypted.

Estimated Lab Time: 10 minutes

#### Objectives
You have been tasked with migrating an encrypted database to Oracle Key Vault for centralized key management. The first thing to do is to understand how TDE has been setup and which tablespaces are encrypted.

#### Prerequisites
This lab assumes you went through Lab 3. 

## Lab 4: Review a typical TDE environment
### Task 1: Review TDE setup in an encrypted database

An encrypted database has been prepared for you:

1. To start, run the following script; it will show you exactly what you need to know before migrating to Oracle Key Vault:

    ````
    <copy>
    ./review_tde_deployment.sh
    </copy>
    ````
Under 1) You see the system parameters that are controlling the behaviour of TDE in your database: The default algorithm is AES256; new tablespaces will be created encrypted, the database uses a file-based wallet in the wallet_root directory.

Under 2) You see the wallet location; the entry for PDB1 is empty, because united PDBs inherit that location from CDB$ROOT.

Under 3) You see the key-IDs (names of the keys) of the TDE master keys for CDB$ROOT and each PDB.
    ![Key Vault](./images/OKV-LL4-001.png "Display the parameters that define how TDE is setup in your database:")

For a later LiveLab, we have already prepared an RMAN backup of the encrypted tablespaces.
