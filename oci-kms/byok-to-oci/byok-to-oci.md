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

1. Open the CipherTrust Manager Web UI and click on the "Cloud Key Manager" tile.

    ![CTM UI](images/log-in-ctm.png "CTM UI")

2. On the left pane, click Containers and Oracle Vaults. 

    ![Oracle Vaults](images/oracle-vaults.png "Oracle Vaults")

3. Click "Add Existing Vault".

    ![Add Vault](images/add-vault.png "Add Vault")

4. Under "Add Existing Vault" configuration, add the following parameters:
    * Oracle connection - select the connection that was previously created, it should be "OCI-Connection_XXX" where "XXX" is your student number.
    * Compartment – Select the compartment "ocw23-OCI-Vault-HOL".
    * Region - Select your relevant region from the dropdown, it should be the same as in the previous lab.
    * Vault – Select the vault you created earlier, it should be "ocw23-OCI-Vault-XXX" where "XXX" is your student number.
    BE CAREFUL to select your Vault and not the one of another student!
    Then click Next. 

    ![Info Vault](images/info-vault.png "Info Vault")

5. The next step "Add Bucket Name, Bucket Namespace" does not apply to our lab use case so we will skip it, go directly to step 6. 

     ![Add bucket](images/add-bucket.png "Add bucket")

6. click "Add" to add your Vault in your CTM tenant.

     ![New Vault](images/created-vault.png "New Vault")

    You should receive a "Success" message and see you Vault listed in the "Oracle Vaults" pane. Congratulations, now you can remotely manage your Oracle Vault from your CTM tenant. 

## Task 2: Managing Oracle Keys From CTM

1.	On the left pane, click **Cloud Keys > Oracle**.

    ![Oracle keys](images/oracle-keys.png "Oracle keys")

2.	Click on the "Add Key" button. The "Select Material Origin" screen of the "Add Oracle Key" wizard is displayed. Select the key source: in this case we are going to create the key locally on CipherTrust so for "Select Method" click on "Create/Upload New Key Material" and then for "Select Source" click on "(Local)":

    ![Add key](images/add-key.png "Add key")

3. Add Oracle key by providing the following information:
    * **Key Name** - <Enter "ocw23-AES-256-XXX" where "XXX" is your student number.>
    * **Key Type** - <Click on "AES".>
    * **Key Size** - <Click on "256".>

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
