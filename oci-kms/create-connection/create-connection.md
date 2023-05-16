# Lab 2 - Link creation between OCI and your HSM and Master Encryption Key creation

## Introduction

*Describe the lab in one or two sentences, for example:* This lab walks you through the steps to ...

Estimated Time: -- minutes

### About <Product/Technology> (Optional)
Enter background information here about the technology/feature or product used in this lab - no need to repeat what you covered in the introduction. Keep this section fairly concise. If you find yourself needing more than two sections/paragraphs, please utilize the "Learn More" section.

### Objectives

In this lab, you will:
* Connect to your OCI tenant and create your Vault in OCI Vault
* Set up a link between Thales CipherTrust Manager (created in Lab 1) and OCI Vault
* Create a Master Encryption Key (MEK) in your Thales HSM via Thales CipherTrust Manager

### Prerequisites

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed


## Task 1: Connect to OCI and create your own Vault in OCI Vault

1. Log in to your OCI account by following steps in section Get Started

2. Navigate through the main hamburger menu to *"Identity & Security > Vault"*

	![Go to Vault](images/vault-menu.png)

3. Pick up the compartment in the left menu. Click the display menu and select the already created subcompartment "ocw23-OCI-Vault-HOL". Then click "Create Vault".

    ![Create Vault](images/select-compartment-create-vault.png)

4. Enter a name for your Vault. Please follow the naming convention:

     ![Enter name for Vault](images/create-name-vault.png)

5. Now your Vault will start to be created. Once it is created, the status will appear as Green and Active in your OCI console:

    ![Vault successfully created](images/vault-created.png)



## Task 2: Adding a connection between your Thales CipherTrust Manager and OCI

1. Click the + Add Connection button to open the Add Connection wizard. The wizard consists of the following steps:
    * Select Connection Type : Select “Cloud” : “Oracle Cloud Infrastructure”
    * General Info: provide a Name and Description (optional) for the new connection.
    * Configure Connection: 
        * Tenancy OCID: OCID of the tenancy.
        * User OCID: OCID of the user.
        * Region: An Oracle Cloud Infrastructure region.
        * Fingerprint: Fingerprint of the public key added to this user.
        * Key File: Private key file for the OCI connection in the PEM format. Either upload the key file or paste the file content.
        * File Upload: Select and click Upload Certificate to upload the key file from your machine.
        * Text: Select and paste the certificate content in the text field.
        * Passphrase: Passphrase of the encrypted key file.
        * Click Test Credentials to check whether the connection is configured correctly. If the test is successful, the status is OK else the status is Fail.
        Click Next to move to the next step.
    * Add Products: Use the check boxes in the Products list to select Cloud Key manager”

## Task 3: Master Encryption Key Creation

1.	Open the Cloud Key Manager application.

2.	In the left pane, click Cloud Keys > Oracle.

3.	Click Add Key. The Select Material Origin screen of the Add Oracle Key wizard is displayed.

4.	Under Select Method, select Create/Upload New Key Material. The Select Source section appears. Depending on your requirements, select from the following sources:

    * Luna HSM: Refer to Uploading Luna HSM Key Material for details.

5.	Select Material Origin > Select Source
    a.	Select Luna HSM.
    b.	Click Next. The Configure HSM Key screen is displayed. The drop-down list shows the HSM partitions linked with the configured Luna HSM connection.

6.	Configure HSM Key

7.	    Select the Partition ID of the desired Luna HSM partition.

8.	    Enter an HSM Key Name. A new key with this name will be created on the Luna HSM and its key material will be uploaded to Oracle cloud.

9.	    Select Key Type. The options are AES and RSA. It creates and uploads an RSA key pair.

10.	    Select the Key Size based on the key type:
    a.	        For an AES key, the options are 128, 192, and 256.
    b.	        For an RSA key, the options are 2048, 3072, and 4096.

11.	    (Optional) Specify the tags.
	To add a new tag: Select a Tag Namespace. The options are:
    * Free Form: Allows adding free form tags.
    * Oracle Tags: Allows adding tags based on created on and created by.
	    Specify a Tag Key.
	    Specify a Tag Value.
	    Click +.
    Similarly, add as many tags as required.

12.	    Select the Key Attributes. The options are:
    * Modifiable, Extractable, Sensitive (all three are selected for a BYOK Compatible key)
    * Encrypt, Decrypt, Wrap, Unwrap
    * Sign, Verify, Derive

13.	Click Next. The Configure Oracle Key screen is displayed.
    Configure Oracle Key:
    * Enter a unique, user-friendly alias as the Oracle Key Name. This will be the key name on Oracle cloud. This name helps uniquely identify an Oracle key. By default, the HSM Key Name you specified on the previous screen is populated.
    * Select the desired Oracle Compartment from the drop-down list. The drop-down list shows the list of Oracle compartments added to the CCKM.
    * Select the desired Key Vault from the drop-down list. The drop-down list shows the list of Oracle vaults added to the CCKM.
    * Select the Protection Mode. The options are Software and HSM.

    (Optional) Specify the tags.
    To add a new tag: Select a Tag Namespace. The options are:
    * Free Form: Allows adding free form tags.
    * Oracle Tags: Allows adding tags based on created on and created by
    Specify a Tag Key.
    Specify a Tag Value.
    Click +.
    Similarly, add as many tags as required.

14.	Click Next. The Review and Add screen is displayed. Review and Add.

15.	This screen shows the key details that you have provided. These details are divided into MATERIAL ORIGIN, SOURCE KEY, and DESTINATION KEY sections.

    Before adding the key, review all details. After the key is added, certain features will no longer be editable.
    Review the key details displayed on the screen.
    If details are incorrect or you want to make any changes, click Edit next to the SOURCE KEY and DESTINATION KEY sections and update details. Alternatively, click Back and make changes, as appropriate.

16.	    Click Add Key.
    The key creation starts. A Create Key In Progress message is displayed on the screen. Leave the window open until the process is completed.
    When the status next to the SOURCE KEY and DESTINATION KEY sections becomes Complete and the Key ID links are displayed, the key is created successfully.

17.	    Click Close. The Add Oracle Key wizard is closed.
18.	The newly created key is displayed in the list of Oracle keys.


## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> -- optional
* **Last Updated By/Date** - <Name, Month Year>

