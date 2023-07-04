# Lab 5 - Emergency simulation test: re-enable data access

## Introduction

Scenario: 
You're part of your company Security Operations team. The Security alrt is over. After all the required checks, the CISO has taken the decision to re-enable access to data stored in the Cloud. So the CISO is asking you to go ahead and restore normal operations and data access in OCI, your Company Cloud. 

In order to re-enable access to the data, you will re-enable the encryption key that you created at the beginning of this hands-on lab. As this key is used to encrypt data in the bucket you created as well as in the Autonomous Database, this will fully re)enable access to the data. 

As a Data Administrator, you will test proper access to the data is now indeed possible and normal operations can restart, now that the security alert is over. This will mark the end of this hands-on lab! 

Estimated Lab Time: -- minutes

### Objectives

In this lab, you will:
* As the Security alert is over, you will re-enable the encryption key used in OCI from the external CipherTrust Key management console
* Test access to the encrypted data and confirm users can access data again in both the Storage Bucket and Autonomous Database


## Task 1: Re-enable key in CipherTrust Manager

1. Go back to the CipherTrust Manager console. If you closed it, use the following URL to access CipherTrust Manager as a Service: *"https://us1.ciphertrust.dpondemand.io/?tenant=oracle-OracleCTM"* and append your student number. For example, if your student number is 001, go to the following URL: *"https://us1.ciphertrust.dpondemand.io/?tenant=oracle-OracleCTM001"*

  ![Log in to CipherTrust Manager](images/ctm-login.png "Log in to CipherTrust Manager")

  Enter the credentials you have been provided with. You are now logged into the CipherTrust Manager web console. Click on the Cloud Key Manager icon:

  ![CipherTrust Manager web console](images/ctm-page.png "CipherTrust Manager web console")


2. On the left pane, click **Cloud Keys > Oracle**.

  ![Oracle keys](images/menu-keys.png "Oracle keys")

3. Click on the three points on the right of your key line and select **Enable**:

  ![Enable keys](images/to-enable.png "Enable keys")

4. A new window will prompt you to confirm. Click **Enable**:

  ![Enable keys](images/enable-key.png "Enable keys")

6. Click **Refresh All**: 

  ![Refresh All](images/refresh-all.png "Refresh All")

  a new window will prompt you again to confirm. Click **Refresh All** again:

  ![Refresh all](images/refresh.png "Refresh all")

7. Wait until keys are in "Enabled" state:

  ![Enabled keys](images/enabled-key.png "Enabled keys")


## Task 2: Confirm data access into your bucket is possible as a result

1. Log in to OCI cloud tenant as Data\_Manager\_XXX, where "XXX" is your student number (please go to lab TODO to see how to log in to OCI), and navigate through the main hamburger menu to *"Storage > Object Storage > Buckets"*.
    
    ![Buckets](./images/buckets.png "Buckets")

2. As you can see, the bucket you created with an external key is accessible again: 

   ![Buckets](./images/bucket-visible.png "Buckets")

  If you click on your bucket, you will be able to access:

   ![Access](./images/upload-object.png "Access")

  and ocw23-resources bucket is still accessible because it has been configured with Oracle-managed keys by design. That is a best practice customers can use when they do not want to manage the keys and key lifecycle for resources that do not contain any sensitive data. This way, OCI enables companies to have a very granular and powerfull key management solution for all of their OCI resources. 

3. Now we will check that the pre-authenticated request (PAR) that you have created is functional again as the key is enabled.
  Copy the URL you saved in lab 3 task 2 and paste it in your browser again. Confirm you can download the document. 
  Thus we have now confirmed that re-enabling the key from the external CipherTrust Manager instance brings back a fully functional behavior to OCI storage bucket.


## Task 3: Check data access into your Autonomous Database

1. Navigate through the main hamburger menu to: *"Oracle Database > Autonomous Database"*.

  ![Autonomous Database](./images/autonomous-database.png "Autonomous Database")

2. As you can see, the database is still stopped as the key was disabled: 

  ![Stopped Autonomous Database](./images/stopped-adb.png "Stopped Autonomous Database")

3. Now you will try to start the database because the key is enabled again: start again the database by clicking on **More Actions** and **Start**:

  ![Start Autonomous Database](./images/re-start.png "Start Autonomous Database")

  Once you click **Start**, you will see the database is starting:

  ![Starting Autonomous Database](./images/starting-adb.png "Starting Autonomous Database")
  
  Wait until the database is started:
  
  ![Autonomous Database available](./images/adb-available.png "Autonomous Database available")

  As you can see, now it is possible to start the database as the key is re-enabled and reachable by the autonomous database. 


4. In order to ensure the data can be decrypted, let's try to access the data within the database. In order to do that, go to the Database Actions Launchpad:

  ![Database Actions](./images/db-actions.png "Database Actions")

5. Once there, click to SQL under Development:

  ![SQL Development](./images/sql.png "SQL Development")

6. Web SQL Development UI is open and now you can see the data into the table, right click to the table and click **Open**:

  ![Open table](./images/see-data.png "Open table")

7. In the new window, click the tab Data:

  ![See data](./images/data.png "See data")

  As you can see, now you have again complete visibility on the data within the database, as the key was re-enabled.

Congratulations, you have completed all the labs!!

## Learn More

* [Using Your Own Keys in Vault for Server-Sode Encryption](https://docs.oracle.com/en-us/iaas/Content/Object/Tasks/encryption.htm#UsingYourKMSKeys)
* [Managing Encryption Keys on Autonomous Database](https://docs.oracle.com/en/cloud/paas/autonomous-database/adbsa/autonomous-encrypt-set-rotate-keys.html#GUID-0795135D-B057-4DBC-92C9-368AF4C82D0A)

## Acknowledgements
* **Authors** - Damien Rilliard (OCI Security Seno#ior Director), Sonia Yuste (OCI Security Specialist)
* **Last Updated By/Date** - Sonia Yuste, June 2023
