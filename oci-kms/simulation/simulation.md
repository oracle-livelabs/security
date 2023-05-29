# Lab 4 - Emergency simulation test: blocking data access

## Introduction

*Describe the lab in one or two sentences, for example:* This lab walks you through the steps to ...

Estimated Lab Time: -- minutes

### About <Product/Technology> (Optional)
Enter background information here about the technology/feature or product used in this lab - no need to repeat what you covered in the introduction. Keep this section fairly concise. If you find yourself needing more than two sections/paragraphs, please utilize the "Learn More" section.

### Objectives

*List objectives for this lab using the format below*

In this lab, you will:
* Simulate an emergency situation where you as a customer want to block access to your data in OCI
* Remove encryption key from the external CipherTrust Key management console
* Test access to the encrypted data and confirm users cannot access cleartext data in the Storage Bucket and Autonomous Database anymore

### Prerequisites (Optional)

*List the prerequisites for this lab using the format below. Fill in whatever knowledge, accounts, etc. is necessary to complete the lab. Do NOT list each previous lab as a prerequisite.*

This lab assumes you have:
* An Oracle Cloud account
* All previous labs successfully completed


## Task 1: Disable keys in CTM

1. Log in to your CTM account and navigate to Cloud Key Manager:

2. Go to Cloud Keys section where your ecnryption keys will be shown:

3. Click on the three points on the right and select **Disable**:

4. Click **Refresh All** and wait that keys are in Disabled status:


## Task 2: Check data visibility into your bucket


## Task 3: Check data visibility into your Autonomous Database




 
## Learn More

*(optional - include links to docs, white papers, blogs, etc)*

* [URL text 1](http://docs.oracle.com)
* [URL text 2](http://docs.oracle.com)

## Acknowledgements
* **Author** - <Name, Title, Group>
* **Contributors** -  <Name, Group> -- optional
* **Last Updated By/Date** - <Name, Month Year>
