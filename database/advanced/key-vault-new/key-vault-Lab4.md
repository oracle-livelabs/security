# Review a typical TDE environment

## Introduction
Before migrating a database from a local TDE wallet to centralized key management with Oracle Key Vault, you need to understand what the TDE parameters are set, and what tablespaces are encrypted.

Estimated Lab Time: 3 minutes

### Objectives
In this lab, you will see a typical TDE setup with encrypted tablespaces.

### Prerequisites
This lab assumes you have completed lab 3.

## Task 1: Review TDE setup in an encrypted database

An encrypted database has been prepared for you to review the environment.

To review this environment, open a terminal and run the following script

````
<copy>
cd $DBSEC_LABS/okv
./review_tde_deployment.sh
</copy>
````

The output of the script will show:

1. The system parameters that are controlling the behavior of TDE in your database: 
- The default algorithm is AES256
- Newly created tablespaces will be encrypted by default
- The database uses a file-based wallet 
- File based wallets will be created in the &lt;WALLET_ROOT&gt;/tde directory

![Key Vault](./images/OKV-LL4-001a.png "You see the system parameters that are controlling the behaviour of TDE in your database.")

2. The file based wallet is open for use. Since the database is using united mode PDBs, they inherit their location from CDB$ROOT.

![Key Vault](./images/OKV-LL4-001b.png "The file based wallet is open for use. Since the database is using united mode PDBs, they inherit their location from CDB$ROOT.")

3. The identifier of the TDE master encryption key in use by the CDB and the PDB as well as their creation time

![Key Vault](./images/OKV-LL4-001c.png "The identifier of the TDE master encryption key in use by the CDB and the PDB as well as their creation time")

4. The list of encrypted tablespaces

![Key Vault](./images/OKV-LL4-001d.png "The list of encrypted tablespaces")

5. The list of encrypted RMAN backups

![Key Vault](./images/OKV-LL4-001e.png "The list of encrypted RMAN backups")
