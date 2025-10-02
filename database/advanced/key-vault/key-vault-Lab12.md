# Explore ~~/Review/Walk through~~ Key Vault in a Typical Customer Deployment

## Introduction
Oracle Key Vault provides many rich and meaningful activity, audit and awareness reports that support you in keeping your business running in a secure fashion without unneccessay and avoidable interruptions.

before the above line, talk about deployment types (standalone, mm cluster, RAC, multi-cloud)
then talk about keys,certs, what we manage
then talk about the existing intro line: sys management, reports, etc.


Estimated Lab Time: 5 minutes

### Objectives
In this lab you will learn how to navigate to the many actionable reports that OKV provides and how to interpret them. Among other things, see which DBAs have failed to re-key their TDE master keys regularly, and which certificates are nearing expiration or no longer satisfy new, stricter compliance requirements.

### Prerequisites
This lab assumes you have completed lab 11.

## Task 1: Utilize the OKV reports to keep your business running

1. Login to Key Vault as user **KVRESTADMIN**

     ![Key Vault](./images/image-2025-09-03_13-29-46.png "Login to Key Vault as an OKV administrator.")

2. Click the **Reports** Tab:

    ![Key Vault](./images/image-2025-7-24_12-11-54.png "Click the Reports Tab.")

3. System Overview before clustering:

    ![Key Vault](./images/image-2025-09-11-17.41.21.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

4. Key Management Report:

    ![Key Vault](./images/image-2025-09-11-17.53.46.png "Certficates are listed and grouped by their length and remaining life time:")

5. DB Activated TDE Master Encryption Key Report:

    ![Key Vault](./images/image-2025-09-11-18.09.03.png "Click the Endpoints Tab.")

6. Endpoints page:

    ![Key Vault](./images/image-2025-09-11-18.13.52.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

7. Wallets page:

    ![Key Vault](./images/image-2025-09-11-18.20.43.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

8. Alerts page:

    ![Key Vault](./images/image-2025-09-11-18.27.41.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

9. Manager Users page:

    ![Key Vault](./images/image-2025-09-11-18.29.46.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

10. Empty LDAP Group Mappings:

    ![Key Vault](./images/image-2025-09-11-18.33.10.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

11. Change user password:

    ![Key Vault](./images/image-2025-09-11-18.42.01.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

12. CPU and memory metrics:

    ![Key Vault](./images/image-2025-09-11-18.46.22.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

13. Settings page:

    ![Key Vault](./images/image-2025-09-11-18.48.38-CUSTOM.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

14. Configure as Candidate node:

    ![Key Vault](./images/image-2025-09-11-18.50.51.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

15. Cluster page:

    ![Key Vault](./images/image-2025-09-11-18.58.43.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")

16. System overview after clustering:

    ![Key Vault](./images/image-2025-09-11-19.02.06.png "Expand Keys and Wallets Reports and click on Certificate Awareness Report:")