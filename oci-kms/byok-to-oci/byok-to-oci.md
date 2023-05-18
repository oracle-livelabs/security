# Lab 3a - Bring Your Own Key to Oracle Cloud Infrastructure (BYOK to OCI)

## Introduction

This lab walks you through the steps to ...

Estimated Time: -- minutes

### About <Product/Technology> (Optional)
Enter background information here about the technology/feature or product used in this lab - no need to repeat what you covered in the introduction. Keep this section fairly concise. If you find yourself needing more than two sections/paragraphs, please utilize the "Learn More" section.

### Objectives

In this lab, you will:
* Bring Your Own Keys to your OCI Vault

### Prerequisites (Optional)

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed


## Task 1: Managing Oracle Keys From CCKM

1.	Open the CipherTrust Manager Web UI.

2. Click the **Cloud Key Manager** application.

3.	On the left pane, click **Cloud Keys > Oracle**.

4. Click **Refresh All**, the keys that are stored in Oracle will be displayed (note the refresh can take a few minutes).

5.	Click on Add Key tab. The Select Material Origin screen of the Add Oracle Key wizard is displayed.

6. 	You can Create/Upload new key material or Clone existing key material.

7. Select the key source. In this case we are going to create local key on CipherTrust.  

8. Add oracle key by providing Key name, Key Type and Key Size.

9. You need to select existing compartment, Vault and protection mode. 

10. Click next.

11. Review the key and click on add key.

12. Go back to the OCI Vault and check whether key created from CCKM is visible or not. 


## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> -- optional
* **Last Updated By/Date** - <Name, Month Year>
