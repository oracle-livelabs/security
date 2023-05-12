# lab 1 - HSM (Hardware Security Module) and Key Management Setup

## Introduction

This lab walks you through the steps to create a HSM (Hardware Security Module) and Key Management environment. 

Estimated Time: -- minutes

### About <Product/Technology> (Optional)
It is representing the situation of you as an Oracle Cloud Infrastructure (OCI) customer. Either you are already owning an HSM On-Premise, or  you want to use an “HSM-as-a-Service” outside of Oracle Cloud like the Thales service we will use in this lab. 
For the purpose of this lab, you will work with Thales CipherTrust Data Security Platform service to create your encryption keys. 

### Objectives

*List objectives for this lab using the format below*

In this lab, you will:
* Create an external Thales HSM/Key Management

### Prerequisites (Optional)

*List the prerequisites for this lab using the format below. Fill in whatever knowledge, accounts, etc. is needed to complete the lab. Do NOT list each previous lab as a prerequisite.*

This lab assumes you have:
* An Oracle Cloud account
* A Thales account


*Below, is the "fold"--where items are collapsed by default.*

## Task 1: External Thales HSM/Key Management creation


1. Register a DPoD subscriber tenant through either of the following URLs, depending on your region. A DPoD subscriber tenant is a DPoD instance, with its own unique URL subdomain, where users consume services, including HSM as a Service where you will be able to create your encryption keys and simulate the usage of your own HSM. 

	![Image alt text](images/sample1.png)

  > Tip: When you create the CDSPaaS service on DPoD, you can select a different cloud region to deploy the service in. The cloud region of the service has more of an effect on network latency for CDSPaaS than the DPoD subscriber tenant region.

2. Log in to your DPoD subscriber tenant as the Tenant Administrator.

  ![Image alt text](images/sample1.png)

  Provision the CDSPaaS service on DPoD to make a CDSPaaS tenant with an 	automatically generated tenant name. A CDSPaaS tenant is a logical boundary for 	each customer, cryptographically isolated from other customers by a unique Luna Cloud HSM encryption key.

3. Navigate to Services, select Add Service and select the CipherTrust Data Security Platform service.

  ![Image alt text](images/sample2.png) click **Navigation**.

4. Enter your configuration details in the Add Service wizard and click Finish to confirm.

   > Note: The service name you provide here is a convenience for display in DPoD. The 	CDSPaaS tenant name used in the CDSPaaS interfaces is different.

5. Click the service name in DPoD to launch CDSPaaS web console UI in a separate browser tab.
    	The URL is of the form:	
      
      https://ciphertrust.dpondemand.io/?tenant=<generated_tenant_name>

	The tenant cannot be renamed.


## Task 2: Concise Task Description

1. Step 1 - tables sample

  Use tables sparingly:

  | Column 1 | Column 2 | Column 3 |
  | --- | --- | --- |
  | 1 | Some text or a link | More text  |
  | 2 |Some text or a link | More text |
  | 3 | Some text or a link | More text |

2. You can also include bulleted lists - make sure to indent 4 spaces:

    - List item 1
    - List item 2

3. Code examples

    ```
    Adding code examples
  	Indentation is important for the code example to appear inside the step
    Multiple lines of code
  	<copy>Enclose the text you want to copy in <copy></copy>.</copy>
    ```

4. Code examples that include variables

	```
  <copy>ssh -i <ssh-key-file></copy>
  ```

## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> -- optional
* **Last Updated By/Date** - <Name, Month Year>
