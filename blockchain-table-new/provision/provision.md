# Prepare your environment

## Introduction

This lab provides step-by-step instructions to create an Oracle Autonomous Database and connect to it using SQLcl.

Estimated time: 10 minutes

Watch the video below for a quick walk-through of the lab.
[Prepare your environment](videohub:)


### Objectives

-   Learn how to provision a new Autonomous Database
-   Create a new user for demo purpose
-   Connect to Autonomous Database using Oracle CloudShell and SQLcl

## Task 1: Provision an Autonomous Database

  **Note:** If you plan to use an existing Autonomous Database in your own tenancy, or you are using an Oracle-provided environment, you can skip the Task 1 and Task 2.

1. Log in to the Oracle Cloud Infrastructure

2. Once you are logged in, you are taken to the cloud services dashboard where you can see all the services available to you. Click the navigation menu in the upper left to show top level navigation choices.

    ![](./images/lab1-task1-1.png "In the top left corner, click the 3 lines menu to expand. ")

3. The following steps apply similarly to either Autonomous Data Warehouse (ADW) or Autonomous Transaction Processing (ATP). So please **click the provisioning of Autonomous Database of your choice** (here we choose an Oracle Autonomous Data Warehouse but again you can also choose Oracle Autonomous Transaction Processing if you prefer).

    ![](./images/lab1-task1-2.png "click the provision autonomous transactional database ")

4. From the **Compartment** drop-down list, select your compartment and click [**Create Autonomous Database**]

  **Note:**
     - If there were a long list of databases, you could filter the list by the **State** of the databases (Available, Stopped, Terminated, and so on)
     - You can also sort by **Workload Type** (here, we selected **All**)

         ![](./images/lab1-task1-3.png "Make sure you are in the correct compartment and the workload is either All or Transaction Processing.")


5. On the **Create Autonomous Database** page, provide basic information for your database:
    - **Compartment** - If needed, select your compartment
    - **Display name** - Enter a memorable name for the database for display purposes, for this lab, use *`Blockchain-Table-Demo`*

        ```
        <copy>Blockchain-Table-Demo</copy>
        ```

    - **Database Name** - Enter *`BlockchainTableDemo`*, it's important to use letters and numbers only, starting with a letter (the maximum length is 14 characters and Underscores are not supported)
        
        ```
        <copy>BlockchainTableDemo</copy>
        ```

    - **Workload Type** - Select the type of your Autonomous Database to match your choice at Step 3 earlier above (here we select "Transaction Processing")
    - **Deployment Type** - Leave *`Serverless`* selected

         ![](./images/lab1-task1-4.png "Select the appropriate compartment, display name, database, workload and deployment types. ")

6. Configure the database:

    - **Always Free** - Select this option by moving the slider to the right
    - **Database version** - Select *`23ai`* 


7. Create administrator credentials:

    - **Password** and **Confirm Password** - Specify a password for the ADMIN database user and jot it down. The password must be between 12 and 30 characters long and must include at least one uppercase letter, one lowercase letter, and one numeric character. It cannot contain your username or the double quote (") character. For example : *`Welcome_123#`*

        ```
        <copy>Welcome_123#</copy>
        ```

        ![](./images/lab1-task1-5.png "select always free and 23ai, if available ")

8. Choose the network access :

    - **Network Access** - Leave *`Secure access from everywhere`* selected
    - **Provide Contacts** - You can leave this blank

         ![](./images/lab1-task1-6.png "choose the network type and provide contact info, if you want. ")

9. Click [**Create Autonomous Database**]

10.  Your instance will begin provisioning. In a few minutes, the state will turn from Provisioning to Available. At this point, your Autonomous Database is ready to use! Have a look at your instance's details here including its name, database version, OCPU count, and storage size.

      ![](./images/lab1-task1-7.png "provisioning the instance will take a few minutes ")

## Task 2: Create a New User Using Database Actions

1. On the Blockchain-Table-Demo ATP instance details page, click on the **Database Actions** tab, select **Database Users**, a new tab will open up.
    ![](./images/lab1-task2-2.png " ")

2. Click on **Create User** to create a new user to access the database.
    ![](./images/lab1-task2-3.png " ")

3. In the Create User page, under User tab, give the following details and click **Create User**:
    - **User Name** - Give the new user a User Name. The username is case-sensitive. In the lab, we name the user **Username - DEMOUSER**.
    - **Password** - Give the new user a password and confirm the Password. In this lab, we give the same password as admin user for ease of use, **Password - Welcome_123#** and confirm the password.
    - **Quota on tablespace DATA** - Set a value for the Quota on tablespace DATA for the user. Choose **500M** for this user.
    - **Web Access** - Turn on the Web Access radio button to access the SQL Developer Web.
    - **Web access advanced features** - Expand the Web access advanced features and turn off the Authorization required radio button to disable the authorization for `demouser` REST services

    ![](./images/lab1-task2-4.png " ")

4.  Notice that the new user is created successfully.
    ![](./images/lab1-task2-5.png " ")

## Task 3: Connect to Autonomous Database using Oracle CloudShell and SQLcl

1. On the **Blockchain-Table-Demo ATP** instance details page, click on **Copy** to copy the **OCID** of the ATP instance.  
    ![](./images/lab1-task3-2.png " ")

2. In the top-right corner, click on **Developer Tools** and select **Cloud Shell**.  
    ![](./images/lab1-task3-3.png " ")

3. Once the **Cloud Shell** interface loads, create a wallet for the ATP instance and store it in the root directory of the Cloud Shell:
    - **autonomous-database-id**: Paste the OCID copied in Step 1 into this field.
    - **file**: Specify the file name for the generated wallet (e.g., **wallet.zip**).
    - **password**: Specify a password for the wallet.
    ```bash
    <copy>
    oci db autonomous-database generate-wallet --autonomous-database-id <OCID> --file <FILE_NAME> --password <PASSWORD>
    </copy>
    ```
    ![](./images/lab1-task3-4.png " ")

4. After the wallet is downloaded, unzip it using the following command:
    ```bash
    <copy>
    unzip <FILE_NAME>
    </copy>
    ```
    ![](./images/lab1-task3-5.png " ")

5. Now, set up the **TNS_ADMIN** environment variable for SQLcl:
    - Run the following command to view the directory where the unzipped wallet is stored:
    ```bash
    <copy>
    pwd
    </copy>
    ```
    - Replace `<PATH_TO_UNZIPPED_WALLET>` with the output of the previous command and run:
    ```bash
    <copy>
    export TNS_ADMIN=<PATH_TO_UNZIPPED_WALLET>
    echo $TNS_ADMIN
    </copy>
    ```
    ![](./images/lab1-task3-6.png " ")

6. To connect to the Autonomous Database instance, use the **mTLS connection string**:
    - On the **Blockchain-Table-Demo ATP** instance details page, click **Database Connection**.  
    ![](./images/lab1-task3-7.png " ")
    - Select the connection string for the **blockchaintabledemo_medium** TNS name.  
    ![](./images/lab1-task3-8.png " ")

7. In the **Cloud Shell**, run the following command to connect to the Blockchain-Table-Demo ATP instance:
    - Note: `demouser` is the user created in Task 2.
    ```bash
    <copy>
    sql demouser@'<CONNECTION_STRING>'
    </copy>
    ```
    ![](./images/lab1-task3-9.png " ")
    - When the password prompt appears, enter the password for `demouser` set in Task 2, i.e., **Welcome_123#**.

8. **Your environment is ready to use!** You may now proceed to the next lab.  
    ![](./images/lab1-task3-10.png " ")

## Acknowledgements
* **Author** - Amit Ketkar, Pavas Navaney, Vinay Pandhariwal
* **Contributors** - Pavas Navaney, Vinay Pandhariwal 
* **Last Updated By/Date** - Vinay Pandhariwal, Member of Technical Staff
