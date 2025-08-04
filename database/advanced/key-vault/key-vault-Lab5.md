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

1.  Login to Key Vault:

     ![Key Vault](./images/image-2025-7-24_12-13-38.png "Login to Key Vault.")

2. Click the Endpoints Tab:

    ![Key Vault](./images/image-2025-7-24_12-11-54.png "Click the Endpoints Tab.")

3.  Click on Add to add a new Endpoint:

    ![Key Vault](./images/image-2025-7-24_15-59-1.png "Click on Add to add a new Endpoint:")

4.  Provide the Endpoint details and click Register:

    ![Key Vault](./images/image-2025-7-24_12-17-29.png "Fill in the details of your endpoint: Endpoint Name is LIVELABS_DB_EP; Type is Oracle Database; OS Type is Linux; click 'Register'")

5.  Click the Endpoints Tab to view the recently created endpoint "LIVELABS_DB_EP":

    ![Key Vault](./images/image-2025-7-24_12-26-31.png "Click the Endpoints Tab to view the recently created endpoint LIVELABS_DB_EP:")

6.  Click on the endpoint name "LIVELAB_DB_EP" to view the details:

    ![Key Vault](./images/image-2025-7-24_12-26-40.png "Click on the endpoint name LIVELAB_DB_EP to view the details:")

7.  On the endpoint details page, add the default wallet and click save:

    ![Key Vault](./images/image-2025-7-24_16-12-59.png "On the endpoint details page, add the default wallet and click save:")

8.  Check the permissions of the default wallet:

    ![Key Vault](./images/image-2025-7-24_16-15-52.png "Check the permissions of the default wallet:")

9.  Click the Endpoints Tab and copy the "Enrollment Token":

    ![Key Vault](./images/image-2025-7-24_16-17-13.png "Click the Endpoints Tab and copy the Enrollment Token:")

10. Click "Logout" on the right-hand corner of the page:

    ![Key Vault](./images/image-2025-7-24_12-27-48.png "Click Logout on the right-hand corner of the page:")

### Task 2: Download the OKV client software for this endpoint:

1.  On the database machine, go to the Key Vault login page, click on "Endpoint Enrollment and Software Download":

    ![Key Vault](./images/grab-ep-token.png "On the database machine, go to the Key Vault login page, click on Endpoint Enrollment and Software Download:")

2. Logout and navigate to the software download page:

    ![Key Vault](./images/logout.png "")

    ![Key Vault](./images/sw-download01.png "")

3. Download OKV client (endpoint) software package

    ![Key Vault](./images/download.png "")

4. Install OKV client (endpoint) software package

    ![Key Vault](./images/install.png "")