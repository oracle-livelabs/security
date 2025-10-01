# Review a Typical TDE Environment

## Introduction
Before migrating a database from a local TDE wallet to centralized key management with Oracle Key Vault, you need to understand how the TDE parameters are set, and what tablespaces are encrypted.

Estimated Lab Time: 10 minutes

### Objectives
...to understand how TDE has been setup and which tablespaces are encrypted.

### Prerequisites
This lab assumes you have completed lab 3.

## Task 1: Review TDE setup in an encrypted database

An encrypted database has been prepared for you:

To start, run the following script; it will show you exactly what you need to know before migrating to Oracle Key Vault.

 ````
 <copy>
 ./review_tde_deployment.sh
 </copy>
 ````
   ![Key Vault](./images/OKV-LL4-001a.png "You see the system parameters that are controlling the behaviour of TDE in your database:")

You see the system parameters that are controlling the behaviour of TDE in your database: 
- The default algorithm is AES256
- New tablespaces will be created encrypted
- the database uses a file-based wallet 
- in the <WALLET_ROOT>/tde directory

![Key Vault](./images/OKV-LL4-001b.png "You see the wallet location:")

You see the wallet location; the entry for PDB1 is empty, because united PDBs inherit that location from CDB$ROOT.

   ![Key Vault](./images/OKV-LL4-001c.png "You see the key-IDs (names of the keys) of the TDE master keys for CDB$ROOT and each PDB:")

You see the key-IDs (names of the keys) of the TDE master keys for CDB$ROOT and each PDB, and their creation times.

   ![Key Vault](./images/OKV-LL4-001d.png "See which tablespaces are encrypted and the encryption algorithm:")

See which tablespaces are encrypted and the encryption algorithm.