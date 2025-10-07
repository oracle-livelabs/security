# Bring your own key

## Introduction
You may want to bring an externally generated key, potentially with higher entropy, and manage it with Key Vault.

Estimated Lab Time: 5 minutes

### Objectives
In this lab, you will upload an externally generated key to the Key Vault server, and activate it for the database.

### Prerequisites
This lab assumes you have completed lab 10.


## Task 1: Generate a key external to Oracle Key Vault

1.  Write your key to a file

    In this example, we use openssl to generate TDE Master Encryption Key. You can use other means to generate this key.

    ```
    <copy>
    openssl rand -hex 32 | tr '[:lower:]' '[:upper:]' > $DBSEC_LABS/okv/byok_aes256.txt
    </copy>
    ```


## Task 2: Upload the key to Oracle Key Vault

1.  Login to Key Vault as user **KVRESTADMIN**

    Get the randonly generated password by executing this command

    ```
    <copy>
    cat wui_passphrase
    </copy>
    ```

    ![Key Vault](./images/Screenshot_2025-10-03_13.45.01.png "Login to Key Vault as the REST administrator")

2. Click the **Keys & Wallets** tab and then click the **Keys & Secrets** tab

    ![Key Vault](./images/Screenshot_2025-10-03_14.31.43.png "Click the Keys & Secrets tab")
    
3. Click the **Create** button

    ![Key Vault](./images/Screenshot_2025-10-03_14.37.46.png "Click the Create button")

4. Click the **TDE Master Encryption Key** link

    ![Key Vault](./images/Screenshot_2025-10-03_14.33.54.png "Click the TDE Master Encryption Key link")

5. Click the **Bring Your Own Key** radio button and upload `byok_aes256.txt` file you had created above.

    This will be located at `/home/oracle/DBSecLab/livelabs/byok_aes256.txt`

    ![Key Vault](./images/Screenshot_2025-10-03_14.38.50.png "Click the Bring Your Own Key radio button and upload byok_aes256.txt file you had created above")

6. Click the **Select Wallet** button, choose the **LIVELABS\_DB\_WALLET** wallet, and click the **Close** button

    ![Key Vault](./images/Screenshot_2025-10-03_14.42.12.png "Click the Select Wallet button and choose the LIVELABS_DB_WALLET wallet")

7. Copy the **Master Encryption Key Identifier** (at the top of this page)

    ![Key Vault](./images/Screenshot_2025-10-03_14.44.02.png "Copy the Master Encryption Key Identifier")

8. Click the **Create** button

## Task 3: Activate the key in the database

1. Activate the imported key (BYOK)

    **TO-DO: DOESN'T WORK**
    ````
    <copy>
    administer key management use key '<Master Encryption Key Identifier>' force keystore identified by external store;
    </copy>
    ````

2. Verify the key with the supplied master encryption key identifier was activated by the database

    ````
    <copy>
    sqlplus / as SYSDBA
    select t.name, e.masterkeyid from v$encrypted_tablespaces e, v$tablespace t where e.TS#=t.TS#;
    </copy>
    ````