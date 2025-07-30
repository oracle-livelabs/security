# Oracle Key Vault (OKV)

## Migrate to OKV in 5 easy steps
## Prepare Oracle Key Vault and the encrypted database for centralized TDE key management. 
- In this lab you will prepare Oracle Key Vault for the incoming database and install the OKV client endpoint software on the database host:

*Estimated Lab Time:* 2 minutes

### Objectives
In Oracle Key Vault, you create:
1. an endpoint (which represents a database instance in OKV), and
2. a virtual wallet, which will contain the encryption keys. For easier handling, the wallet is 
3. defined as the 'Default Wallet' of the endpoint
In the second half of this lab you will download and install the OKV client (endpoint) software on your database host.

### Prerequisites
This lab assumes you went through Lab 4. 

## Lab 5: Migrate to OKV in 5 easy steps
### Task 1: Prepare OKV for the incoming database

1. Click on the "Endpoints" tab:

     ![Key Vault](./images/001-ep-tab.png "Click on the 'Endpoints' tab.")

2. Click the "Add" button to add an endpoint for your LiveLabs database:

    ![Key Vault](./images/002-ep.png "Click the 'Add' button to add an endpoint in OKV for your LiveLabs database")

3. Fill in the details of your endpoint and click the "Register" button:

    ![Key Vault](./images/004-add-ep-details.png "Fill in the details of your endpoint: Endpoint Name is 'LIVELABS_DB_EP'; Type is 'Oracle Database'; OS Type is 'Linux'; click 'Register'")

4. OKV will take you back to the 'Endpoint Details' page; Scroll down and enter the name of the default wallet into the text field; click 'Save'. That will create the default wallet for this endpoint:

    ![Key Vault](./images/005-add-default-wallet.png "Type the name of the Endpoint's wallet ('LIVELAB_DB_WALLET') into the 'Default Wallet' text field; click 'Save'")

5. Confirm endpoint's access to wallet:

    ![Key Vault](./images/okv_2504_006.png "Make the wallet the 'default wallet' of the endpoint:")

### Task 2: Install OKV client (endpoint) software on your database host:

1. Grab the enrollment token from list of endpoints:

    ![Key Vault](./images/grab-ep-token.png "Copy the enrollment token for your endpoint to the clipboard")

2. Logout and navigate to the software download page:

    ![Key Vault](./images/logout.png "")

    ![Key Vault](./images/sw-download01.png "")

3. Download OKV client (endpoint) software package

    ![Key Vault](./images/download.png "")

4. Install OKV client (endpoint) software package

    ![Key Vault](./images/install.png "")