# Enable lights-out operations

## Introduction
For high availability purposes, you may want to configure your databases to open a connection to Oracle Key Vault without human intervention. For example, when your Oracle Grid Infrastructure restarts your Oracle RAC database instance, or the Data Guard standby restarts as the primary database after a role switch.

Estimated Lab Time: 3 minutes

### Objectives
In this lab, you will learn how to setup an auto-open OKV connection.

### Prerequisites
This lab assumes you have completed lab 6.

## Task 1: Enable lights-out operations

1. Add the Key Vault endpoint password (that you defined when you installed the Oracle Key Vault client software in lab 5) into a new local auto-open wallet in &lt;WALLET_ROOT&gt;/tde.

    ````
    <copy>
    sqlplus / as SYSDBA
    administer key management add secret '<Key Vault endpoint password>' for client 'OKV_PASSWORD' to local auto_login keystore '/etc/ORACLE/WALLETS/cdb1/tde';
    </copy>
    ````

   ![Key Vault](./images/image-2025-09-25_11-48-23.png "Add the Key Vault endpoint password (that you defined when you installed the Oracle Key Vault client software in lab 5) into a new local auto-open wallet in <WALLET_ROOT>/tde.")

2. Change the TDE\_CONFIGURATION of the database to 'OKV|FILE' to enable the database to find the new wallet in &lt;WALLET_ROOT&gt;/tde.

    ```
    <copy>
    sqlplus / as SYSDBA
    alter system set TDE_CONFIGURATION = 'KEYSTORE_CONFIGURATION=OKV|FILE' scope = BOTH;
    </copy>
    ```

    ![Key Vault](./images/image-2025-7-24_12-53-4.png "Change the TDE_configuration of the database to OKV|FILE to enable the database to find the new wallet in <WALLET_ROOT>/tde.")

3. Restart the database

    ```
    <copy>
    sqlplus / as SYSDBA
    shutdown immediate;
    startup;
    </copy>
    ```

    ![Key Vault](./images/Screenshot_2025-10-03_14.23.38.png "Restart the database")