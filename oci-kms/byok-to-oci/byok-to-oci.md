# Bring Your Own Key to Oracle Cloud Infrastructure (BYOK to OCI)

## Introduction

This lab walks you through how to create your own keys outside of OCI in CTM, and bring them to your OCI tenant in your vault.

Estimated Time: 15 minutes

[Walk through the Lab](videohub:1_grwhdvvv)

### Objectives

In this lab, you will:

* Add and manage your own Vault from CTM
* Create Encryption keys in CTM and manage them in OCI Vault from CTM

### Prerequisites

This lab assumes you have:

* Access to your OCI and CTM accounts
* All previous labs successfully completed

## Task 1: Manage Oracle Vaults From CTM

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

## Task 2: Manage Oracle Keys From CTM

1. On the left pane, click **Cloud Keys > Oracle**.

    ![Oracle keys](images/oracle-keys.png "Oracle keys")

2. Click on the "Add Key" button. The first step of the "Select Material Origin" screen of the "Add Oracle Key" wizard is displayed. Select the key source: in this case we are going to create the key locally on CipherTrust so for "Select Method" click on "Create/Upload New Key Material" and then for "Select Source" click on "CipherTrust":

    ![Add key](images/add-key.png "Add key")

3. In the second step "Configure CipherTrust Key", create a key for OCI by providing the following information:
    * **Key Name** - Enter "ocw23-AES-256-XXX" where "XXX" is your student number.
    * **Key Type** - Click on "AES".
    * **Key Size** - Click on "256".

    Then click "Next".

     ![Add AES key](images/aes-key.png "Add AES key")

4. In the third step "Configure oracle Key", you need to provide the following information:
    * **Oracle Key Name** - Enter "ocw23-AES-256-XXX" where "XXX" is your student number.
    * **Oracle Compartment** - Select "ocw23-OCI-Vault-HOL" from the dropdown list.
    * **Vault** - Select "ocw23-OCI-Vault-XXX" where "XXX" is your student number from the dropdown list.
    Make sure the radio button "HSM" is selected and clieck "Next". 

    ![Add AES key](images/key-compartment.png "Add AES key")

5. Review the key creation configuration and click on "add key" button.

     ![Review key](images/review-key.png "Review key")

6. Once the key is created successfully, you will see the following screen. Click "Close". 

    ![Successfully created key](images/created-key.png "Successfully created key")

7. The key now appears on the "Oracle Keys" list:

    ![List of created keys](images/list-key.png "List of created keys")

    Congratulations! You have created your first key in CTM. This key should have been automatically synchronized with the vault you have created in OCI.

8. Now we will make sure the key is indeed in OCI Vault. 
In order to do this you will act as the Security Operator of your company, using your Secops_XXX user (where "XXX" is your student number) and log in to the OCI console. If required, follow instructions in the preliminary lab "Getting started".
Once in the OCI console, click on the hamburger menu in the top left and select "Identity & Security" then "Vault".

   ![Accessing OCI Vault](images/accessing-oci-vault.png "Accessing OCI Vault")

9. On the main OCI Vault page, you should see your Vault listed. If not, make sure the compartment selected on the left is "ocw23-OCI-Vault-HOL". Once you have located it, click on your Vault name, it should be called "ocw23-OCI-Vault-XXX" where "XXX" is your student number. 

   ![OCI Vault](images/oci-vault.png "Vault")

10. You're now seeing all the keys in the vault you created. You should see the key you created in the Thales CTM interface displayed in your vault. Click on the name of your key. 

    ![Key in OCI Vault](images/keys-oci.png "Key in OCI Vault")

9. You will see all the details about this key. Now if you click on "Versions" in the "Resources" menu on the left, you will see more key details, including the Key Source which is shown as External:

     ![External Key](images/external-key.png "External Key")

Congratulations! You have linked the OCI Vault you created yourself to your own Thales CTM tenant, and you have created a key outside of OCI, which is now usable directly within OCI.
This concludes this lab, in the next lab we will see how it's possible to use this key to encrypt data in OCI native resources.

## Acknowledgements
* **Authors** - Damien Rilliard (OCI Security Senior Director), Sonia Yuste (OCI Security Specialist)
* **Last Updated By/Date** - Sonia Yuste, June 2023
