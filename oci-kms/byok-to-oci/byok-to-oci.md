# Lab 2a - Bring Your Own Key to Oracle Cloud Infrastructure (BYOK to OCI)

## Introduction

This lab walks you through how to create your own keys outside of OCI in CTM, and bring them to your OCI tenant in your vault.

Estimated Time: -- minutes

### Objectives

In this lab, you will:
* Add and manage your own Vault from CTM
* Create Encryption keys in CTM and manage them in OCI Vault from CTM

### Prerequisites

This lab assumes you have:
* Access to your OCI and CTM accounts
* All previous labs successfully completed

## Task 1: Managing Oracle Vaults From CTM

1. Open the CipherTrust Manager Web UI.

    ![CTM UI](images/log-in-ctm.png "CTM UI")

2. On the left pane, click Containers and Oracle Vaults. 

    ![Oracle Vaults](images/oracle-vaults.png "Oracle Vaults")

3. Click Add Existing Vault.

    ![Add Vault](images/add-vault.png "Add Vault")

4. Under Add Existing Key Vault configuration, add the following parameters:
    * Oracle connection - select the connection that was previously created.
    * Compartment – Select the compartment created with Oracle.
    * Region - Select your relevant region from the dropdown.
    * Vault – Select the vault which we created earlier with Oracle.

    ![Info Vault](images/info-vault.png "Info Vault")

Click Next. 

5. Indeed this configuration does not apply to our lab use case. You can skip it.

     ![Add bucket](images/add-bucket.png "Add bucket")

6. Click Add and add the vault.

     ![New Vault](images/created-vault.png "New Vault")

## Task 2: Managing Oracle Keys From CTM

1.	On the left pane, click **Cloud Keys > Oracle**.

    ![Oracle keys](images/oracle-keys.png "Oracle keys")

2.	Click on Add Key tab. The Select Material Origin screen of the Add Oracle Key wizard is displayed. Select the key source, in this case we are going to create local key on CipherTrust. 

    ![Add key](images/add-key.png "Add key")

3. Add Oracle key by providing Key Name, Key Type and Key Size.

     ![Add AES key](images/aes-key.png "Add AES key")

4. You need to select existing compartment, Vault and protection mode. 

    ![Add AES key](images/key-compartment.png "Add AES key")

5. Click Next.

6. Review the key and click on add key.

     ![Review key](images/review-key.png "Review key")

7. If the key is created successfully, you will see the following screen:

    ![Successfully created key](images/created-key.png "Successfully created key")

8. The key now will appear on the list:

    ![List of created keys](images/list-key.png "List of created keys")

9. Now you can go back to the OCI Vault and check whether key created from CTM is visible or not. 

    ![Key in OCI Vault](images/keys-oci.png "Key in OCI Vault")

10. If you click on your recently created key, and check the key versions for this key, you will be able to see the key details, where the Source of the key is shown as External:

     ![External Key](images/external-key.png "External Key")

This concludes this lab.

## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> -- optional
* **Last Updated By/Date** - <Name, Month Year>
