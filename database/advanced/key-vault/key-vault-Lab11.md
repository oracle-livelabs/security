# Bring your own key

## Introduction
A person or process may possess their own keys (which were created with a higher entropy) that they wish to manage with their other keys. These externally generated keys can be uploaded to and registered with Oracle Key Vault. At the time of use, the key administrator can share the key-ID (the name of a key) with the appropriate DBA. Both processes would be isolated from each other to maintain key secrecy.

Estimated Lab Time: 2 minutes

### Objectives
In this lab, you will create a file for uploading an externally generated key to the Key Vault server, view the key in the management console, and locate the key-ID to share with the DBA.

### Prerequisites
This lab assumes you have completed lab 10.


## Task 1: Save your imported key (BYOK) to a file

1.  Write your key to a file

    In this example, we use openssl to generate TDE Master Encryption Key. You can use other means to generate this key.

    ```
    <copy>
    openssl rand -hex 32 > $DBSEC_LABS/okv/byok_aes256.txt
    </copy>
    ```


## Task 2: Add the imported key (BYOK) to Oracle Key Vault

1.  Login to Key Vault as user **KVRESTADMIN**

    Get the randonly generated password by executing this command

    ```
    <copy>
    cat wui_passphrase
    </copy>
    ```

    ![Key Vault](./images/Screenshot_2025-10-03_13.45.01.png "Login to Key Vault as the REST administrator.")

2. Click the **Keys & Wallets** tab:

    ![Key Vault](./images/Screenshot_2025-10-03_13.52.35.png "Click the Keys & Wallets tab.")

3. Click the **Keys & Secrets** tab:

    <!-- TODO - add image -->
    **TO-DO: ADD IMAGE**
    
4. Click the **Create** button:

5. Click the **TDE Master Enryption Key** link:

6. Click the **Bring Your Own Key** radio button and choose the above file:

7. Click on **Select Wallet** button and choose the LIVELABS\_DB\_WALLET wallet:

8. Copy the **Master encryption key identifier** (at the top of this page):

9. Click the **Create** button:
<!-- TODO - add image -->

## Task 3: Activate the key in the database

1. Activate the imported key (BYOK):

    ````
    <copy>
    administer key management use key '<Master Encryption Key Identifier>' force keystore identified by external store;
    </copy>
    ````

2. Verify the key with the supplied master encryption key identifier was activated by the database

    ````
    <copy>
    sqlplus / as SYSDBA
    </copy>
    ````


3. Select from v$encrypted_tablespaces to show the new tablespace was created

    ````
    <copy>
    sqlplus / as SYSDBA
    select t.name, e.masterkeyid from v$encrypted_tablespaces e, v$tablespace t where e.TS#=t.TS#;
    </copy>
    ````