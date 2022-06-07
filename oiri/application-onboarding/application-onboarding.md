# Application Onboarding

## Introduction

This lab walks you through the steps to onboard an application into Oracle Identity Governance(OIG) using the flat file connector.

*Estimated Time*: 25 minutes

### Objectives

In this lab, you will:
* Onboard an application into OIG using flat file connector

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

## Task 1: Start the OIG server

1. On the web browser window on the right preloaded with *Weblogic Admin Console*, if not already logged in, click on the *Username* field and select the saved credentials or use the below to login.

    - Username

    ```
    <copy>weblogic</copy>
    ```

    - Password

    ```
    <copy>Welcome1</copy>
    ```

    ![](images/3-weblogic.png)

2. Click on *Servers* under *Environment*

    ![](images/4-weblogic.png)

3. Click on Control tab. Select oim\_server1 and soa\_server1 and click on *Start* to start the servers. This may take about 5-8 minutes.

    ![](images/5-weblogic.png)

    ![](images/6-weblogic.png)

4. Notice that the servers are in *Running* state.

    ![](images/7-weblogic.png)

## Task 2: Copy the flat files into the directory

1. Open a terminal session as oracle user and copy the entitlement file.

    ```
    <copy>
    cd ~
    unzip /u01/files/target/access/archived/documents_16-06-2021_09-51-31.zip -d /u01/files/target/access/
    ls -latr /u01/files/target/access
    </copy>
    ```

    ![](images/8-files.png)

2. Copy the User accounts file

    ```
    <copy>
    unzip /u01/files/target/accounts/archived/accounts_16-06-2021_09-53-03.zip -d /u01/files/target/accounts/
    ls -latr /u01/files/target/accounts
    </copy>
    ```

    ![](images/9-files.png)

## Task 3: Create Application Screen

1. On the browser window on the right preloaded with *Weblogic Admin Console*, open the URL below in a new tab, then click on the *Username* field and select the saved credentials or use the below to login to the *OIG Identity Console*

    - URL

    ```
    <copy>http://oiri.livelabs.oraclevcn.com:14000/identity/faces/signin</copy>
    ```

    - Username

    ```
    <copy>xelsysadm</copy>
    ```

    - Password

    ```
    <copy>Welcome1</copy>
    ```

    ![](images/10-oig.png)

2. Select the Application box on the Manage tab.

    ![](images/11-application.png)
    ![](images/11a-application.png)

3. On the Applications page, click the Create menu on the toolbar, and then select the *Target* option to create a Target application.

    ![](images/12-application.png)

## Task 4: Providing Basic Information

1. On the Basic Information page, ensure that the *Connector Package* option is selected.

2. From the Select Bundle drop-down list, select *Flat File Connector 12.2.1.3.0*.

3. Enter the Application Name, Display Name, and Description for the application.

    ```
    Application Name : <copy>DMS</copy>
    ```
    ```
    Display Name : <copy>Document Management System</copy>
    ```

    ![](images/1-app.png)

4. Expand the Advanced Settings section, enter value for the parameter *flatFileLocation*.

    ```
    flatFileLocation : <copy>/u01/files/target/accounts/accounts.csv</copy>
    ```

    ![](images/3-app.png)

5. Click on *Parse Headers* to parse the headers of your flat file.

6. In the Flat File Schema Properties table.
    * Mark the `document_access` as multivalued by selecting the corresponding checkbox in the MVA column.
    * Select the Name column for username attribute.
    * Change the datatype of `start_date` attribute by selecting the Date datatype from the Data Type column.
    * Select the UID column for id attribute.

  ![](images/4-app.png)

7. Click Next to proceed to the Schema page.

## Task 5: Updating Schema Information

1. Expand the *`document_access`* attribute and change the display name.

    ```
    Display Name : <copy>DMS Access</copy>
    ```

    ![](images/5-app.png)

2. Click the Advanced Setting icon for *`document_access`* attribute.
    * Select the Lookup and Entitlement checkbox.
    * Provide these details

        ```
        List of values : <copy>lookup.dms.access</copy>
        ```

        ```
        Length : <copy>15</copy>
        ```

  ![](images/5a-app.png)

  ![](images/6-app.png)

3. Select the Case Insensitive column for username, id and `document_access` attributes.

    ![](images/7-app.png)

4. Click Next to proceed to the Settings page.

## Task 6: Providing Settings Information

1. In the Settings page, click on Preview Settings to preview the settings.

2. On the Provisioning tab, select the Account Name as *username* from the dropdown.

    ![](images/8-app.png)

3. On the Reconciliation tab ,expand the Reconciliation Jobs.

    ![](images/9-app.png)

    ![](images/10-app.png)


4. Delete the jobs under Flat File Diff Sync, Flat File Delete Sync and Flat File Delete as these jobs are not necessary for this workshop.

    ![](images/11-app.png)

5. Expand the DMS Flat File Entitlements Loader under the Flat File Entitlement job and fill these details.

    ```
    Flat File directory : <copy>/u01/files/target/access/</copy>
    ```

    ```
    Lookup Name : <copy>lookup.dms.access</copy>
    ```

    ```
    Code Key Attribute : <copy>ID</copy>
    ```

    ```
    Decode Attribute : <copy>Access</copy>
    ```

    ![](images/13-app.png)

6. Expand the DMS Flat File Accounts Loader under the Flat File Full job and fill these details.

    ```
    Flat File directory : <copy>/u01/files/target/accounts/</copy>
    ```

    ![](images/14-app.png)

7. Click Next to proceed to the Finish page.

    ![](images/15-app.png)

## Task 7: Reviewing and Submitting the Application Details

1. On the Finish page, review your application summary and click Finish to submit the application.

    ![](images/16-app.png)

2. Click Yes to create default request form.

    ![](images/17-app.png)

3. On the Application page, click on the Search icon. Notice that the DMS application we created is listed.

    ![](images/18-app.png)

4. Log out and log in again into the Identity Self Service.

## Task 8: Performing Reconciliation
1. Choose the Applications box on the Manage tab.

2. Click Search icon and select the DMS application row.

3. Now select Manage Jobs.

    ![](images/19-app.png)

4. Performing Entitlement Reconciliation
    - Expand the Flat File Entitlement and then expand the DMS Flat File Entitlements Loader.
    - Click Run now and click on the Refresh icon multiple times until you see that the Stopped::Success result appears under Job history

    ![](images/20-app.png)

    ![](images/21-app.png)

5. Performing Full Reconciliation
    - Expand the Flat File Full and then expand the DMS Flat File Accounts Loader.
    - Click Run now and click on the Refresh icon multiple times until you notice that the Stopped::Success result appears under Job history

    ![](images/22-app.png)

    ![](images/23-app.png)

6. Go to Users box on the Manage tab and click any user.

    ![](images/24-app.png)

    ![](images/25-app.png)

7. Click on the Entitlements tab and Accounts tab and notice that the user is provisioned to the "DMS" application with appropriate Entitlement.

    ![](images/26-app.png)

    ![](images/27-app.png)


## Acknowledgements
* **Author** - Keerti R, Brijith TG, Vineeth Boopathy, NATD Solution Engineering
* **Contributors** -  Keerti R, Brijith TG, Vineeth Boopathy
* **Last Updated By/Date** - Rene Fontcha, LiveLabs Platform Lead, NA Technology, November 2021
