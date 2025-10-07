# Increased key control for less secure environments

## Introduction
In certain scenarios, it may be necessary to share data with environments that operate under lower security controls. However, it is critical that the TDE master encryption keys aren't exposed in or downloaded to this environment, or even cached in the secure persistent cache. For this purpose, Oracle Key Vault can also mark keys as non-extractable.

Estimated Lab Time: 5 minutes

### Objectives
In this lab, you will set a key as 'Non-Extractable'. Creation of a new tablespace will fail in case of a connectivity failure verifying that non-extractable keys remain protected in Key Vault.

### Prerequisites
This lab assumes you have completed lab 8.


## Task 1: Create a new tablespace with an Extractable key

1. Create a new tablespace

    ````
    <copy>
    sqlplus / as SYSDBA
    CREATE TABLESPACE extractable_key_tbs DATAFILE 'extractable_key_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT);
    </copy>
    ````

   ![Key Vault](./images/Screenshot_2025-10-03_16.06.27_create.png "Create a new tablespace")

2. Verify the new tablespace was created

    ````
    <copy>
    sqlplus / as SYSDBA
    SELECT tablespace_name, encrypted FROM dba_tablespaces WHERE tablespace_name = UPPER('extractable_key_tbs');
    </copy>
    ````

   ![Key Vault](./images/Screenshot_2025-10-03_16.06.27_verify.png "Verify the new tablespace was created")

## Task 2: Generate a Non-Extractable key

1.  Login to Key Vault as user **KVRESTADMIN**

    Get the randonly generated password by executing this command

    ```
    <copy>
    cat wui_passphrase
    </copy>
    ```

    ![Key Vault](./images/Screenshot_2025-10-03_13.45.01.png "Login to Key Vault as the REST administrator")

2. Click the **Endpoints** tab and then click the **Settings** tab on the left-side panel

    ![Key Vault](./images/Screenshot_2025-10-03_14.26.41.png "Click the Endpoints tab and then click the Settings tab on the left-side panel")

3. Scroll to the bottom and set the **Extractable Attribute** for the **Symmetric Key** to False

    ![Key Vault](./images/Screenshot_2025-10-03_14.29.00.png "Set the Extractable Attribute for the Symmetric Key to False")

4.  On the database host, set a new Non-Extractable key in the Key Vault

    ```
    <copy>
    sqlplus / AS SYSDBA
    ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY "<Key Vault endpoint password>";
    </copy>
    ```
    **UPDATE IMAGE**
    ![Key Vault](./images/Screenshot_2025-10-03_15.11.26.png "Add OKV password to the local TDE wallet")

## Task 3: Cut the connectivity to Oracle Key Vault server

1. Cut the connectivity to the Key Vault server to simulate a network connection issue

    ````
    <copy>
    sudo iptables -A OUTPUT -p tcp --dport 5696 -j DROP
    </copy>
    ````

2. Confirm that the server is unreachable

    ````
    <copy>
    $OKV_HOME/bin/okvutil list
    </copy>
    ````

   ![Key Vault](./images/Screenshot_2025-10-03_15.59.33.png "Confirm that the server is unreachable")

## Task 4: Attempt to create a new tablespace to confirm that database operations fail even when the secure persistent cache exists

   1. Attempt to create a new tablespace

    **TO-DO: THIS DOESN'T WORK BUT THAT'S BECAUSE extractable\_key\_tbs ALREADY EXISTS, NOT BECAUSE OF NON-EXTRACTABLE KEYS**
    ````
    <copy>
    sqlplus / as SYSDBA
    CREATE TABLESPACE extractable_key_tbs DATAFILE 'extractable_key_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT);
    </copy>
    ````

    **TO-DO: THIS WORKS EVEN THOUGH IT SHOULDN'T**
    ````
    <copy>
    sqlplus / as SYSDBA
    CREATE TABLESPACE non_extractable_key_tbs DATAFILE 'non_extractable_key_tbs01.dbf' SIZE 100M ENCRYPTION USING 'AES256' DEFAULT STORAGE (ENCRYPT);
    </copy>
    ````



## Task 5: Restore connectivity

1. Restore the connectivity to the Key Vault server

    ````
    <copy>
    sudo iptables -D OUTPUT -p tcp --dport 5696 -j DROP
    </copy>
    ````

2. Confirm that the server is reachable

    ````
    <copy>
    $OKV_HOME/bin/okvutil list
    </copy>
    ````

   ![Key Vault](./images/Screenshot_2025-10-03_16.04.40.png "Confirm that the server is reachable")

