# Oracle Data Masking and Subsetting (DMS)

## Introduction
This workshop introduces the core functionality of the **Oracle Data Masking and Subsetting (DMS)** pack for Enterprise Manager 24. Participants will learn how to configure and utilize key features to protect sensitive data in non-production environments. A particular emphasis will be placed on the **Data Sharing** use case, showcasing how DMS ensures secure sharing of data with third parties, such as developers, testers, or external collaborators, by masking or subsetting sensitive information. This approach helps maintain compliance with privacy regulations while ensuring data remains usable for non-production purposes. 

* *`Estimated Lab Time:`* 90 minutes.
* *`Version tested in this lab:`* DBEE 19.23 and Oracle Enterprise Manager 24.

### Problem Statement 
An organization needs to share a development application (EMPLOYEESEARCH_DEV) with third party collaborator and want to mask sensitive columns that contain Email ID, User ID and Password data before sharing it. They also want to share the subset of the masked data for testing. How can we automatically identify sensitive columns, mask and subset data using Oracle Data Masking and Subsetting?

### Objectives
- Data Discovery: Create an Application Data Model (ADM) with discovered sensitive columns.
- Data Masking: Generate and execute a data masking script to mask sensitive data.
- Data Subsetting: Generate and execute the data subsetting script to create a subset of the data.

Finally, we will see how the masked and subsetted data can be used securely for data sharing with third-party collaborators. By ensuring that sensitive information is protected, participants will see how this approach allows for seamless collaboration in testing, development, or analytics while maintaining regulatory compliance and data privacy.

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account.
- Completed:
    - Lab 1: Prepare Setup (*`Free-tier`* and *`Paid Tenants`* only)
    - Lab 2: Environment Setup

## Task 1: Navigate to DMS

### Objective
Access Oracle Data Masking and Subsetting (DMS) within the Oracle Enterprise Manager (OEM) console. This task will familiarize users with the interface and ensure they can locate and open the DMS platform, which will be used throughout the workshop.

### Steps
1. On your NoVNC remote desktop, the OEM login page should be open by default. If it’s not, click the **Get Started with your Workshop** icon on the desktop. 

    **Note:** If you are NOT using the remote desktop you can also access this page by going to *`https://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:7803/em`* where you can get your *`YOUR_DBSEC-LAB_VM_PUBLIC_IP`* from the Stack details page shown in Lab 2 Task 2.

2. Login as *`SYSMAN`* with the password *`Oracle123`*.

    ````
    <copy>SYSMAN</copy>
    ````

    ````
    <copy>Oracle123</copy>
    ````

    ![DMS](./images/dms-001a.png "001")

3. Navigate to **Targets > Databases**. 

    ![DMS](./images/dms-002.png "002")  

4. Click **Security > Data Masking and Subsetting > Data Discovery** as shown below: 
    
    ![DMS](./images/dms-003b.png "003")

5. Now, navigate to the **Overview** section on the top left:  

    ![DMS](./images/dms-004.png "004")

6. Click on **Workflow** to review the Data Masking and Subsetting process.  

    ![DMS](./images/dms-005.png "005")

Below is a breakdown of the flowchart steps:

**i. Create Application Data Model (ADM)**
This is the first step and a prerequisite for Data Discovery, Masking, and Subsetting, where sensitive data is identified and cataloged.

**ii. Data Masking Path**
- Create Masking Definitions: Define masking formats to protect sensitive data.
- Generate and Execute Masking Job: Apply the defined masking rules to the sensitive data.  
**Output:** Data is masked on the non-production database.

**iii. Data Subsetting Path**
- Create Subsetting Definitions: Define which data subset will be extracted from the production database.
- Choose Masking Definitions (Optional): Apply masking to the subsetted data before execution.
- Generate and Execute Subsetting Job: Execute the subsetting and optional masking rules together.  
**Output:** Data is Subsetted (and optionally Masked) on the non-production database.

**What You Accomplished**  
Navigated to Oracle Data Masking and Subsetting on Oracle Enterprise Manager 24 console.

## Task 2: Data Discovery- Create Application Data Model (ADM)

### Objective
Create an ADM and associate it with a target database and schema. This ADM will serve as a centralized reference, detailing tables with sensitive information.

### Steps
1. Navigate to **Data Discovery > Application Data Models**. Click **Create** to add a new ADM.  
Fill in the following details:
 - Name: *`Employee_ADM`*.
 - Target Type: *`Pluggable Database`*.
 - Target Database: *`cdb1_PDB1`*.
 - Database Named Credentials: *`DMS_ADMIN`*.
 - Application Suite: *`Custom (default)`*.
 - Schemas: *`EMPLOYEESEARCH_DEV`* (Type in the text and select from the drop-down options).
 - Relationship Discovery Type: *`Database Level (Dictionary-Based)`* (Default).

![DMS](./images/dms-124.png "102")

**Note:** Database Level (Dictionary-Based) automatically identifies relationships within the database using its data dictionary. Refer to the [**documentation**](https://docs.oracle.com/en/database/oracle/oracle-database/19/dmksb/data_modeling.html#GUID-CA75BEBB-74DF-46BD-8112-9EFE1164F4CE) for more details on referential relationship type.  
    
2. Click **Create**. Use the Re-fetch button to check the status. Proceed once the **Most Recent Jobs Status** for *`Employee_ADM `* displays "**Succeeded**"!

    ![DMS](./images/dms-103.png "103")

**What You Accomplished**  
Created Application Data Model *`Employee_ADM `* for *`cdb1_PDB1`* target database.

## Task 3: Data Discovery- Create New Sensitive Types

### Objective
Create two new **Sensitive Types** for **USERID** and **PASSWORD** columns: To identify columns containing sensitive data like Email ID, User ID, and Password, we rely on the **Sensitive Types** library in Data Masking and Subsetting. This library includes a range of predefined Sensitive Types representing specific data categories, and it also allows users to add custom Sensitive Types. Since **Email ID** is already available as a predefined Sensitive Type, we would create two new Sensitive Types: **USER_ID** and **PASSWORD** to complete our requirements.

### Steps
1. Navigate to **Sensitive Types** under **Data Discovery**. 

    ![DMS](./images/dms-008.png "008")

2. Click **Create**.

    ![DMS](./images/dms-009.png "009")

3. Fill in the details as below:

- Name: *`USER_ID`*.
- Column Name Pattern: *`USERID.*;ID.*`*
- Column Comment Pattern: *`USERID.*;ID.*`*

    ![DMS](./images/dms-106.png "106")  
    
    Optionally, you can also define the Column Data Pattern.

4. Click **Create**.

5. Now, let's create the second Sensitive Type **PASSWORD** by clicking **Create** option at the top again.  

    ![DMS](./images/dms-009.png "009")

6. Fill in the below details on **Create Sensitive Type** page:

- Name: *`PASSWORD`*
- Column Name Pattern: *`PASSWORD.*;PASS.*`*
- Column Column Pattern: *`PASSWORD.*;PASS.*`*

    ![DMS](./images/dms-107.png "11")  

7. Click **Create**.

**Note**:
- This process uses Oracle Regular Expressions which is compatible with the IEEE Portable Operating System Interface (POSIX) regular expression standard and to the Unicode Regular Expression Guidelines of the Unicode Consortium.
- In this case, the **Search Type** has been set as an **Or** condition, so if any of the conditions listed above are met, it will result in a match.

**What You Accomplished**  
 You now have two new customized Sensitive Types: **USER_ID** and **PASSWORD**, available in the **Sensitive Types** Library. 

## Task 4 Data Discovery- Discover Sensitive Data (Automated)

### Objective
Run the **Discover Sensitive Columns** job: To identify sensitive columns, run the Discover Sensitive Columns job using Oracle's predefined sensitive type, **Email ID**, along with user-defined sensitive types, **USER_ID** and **PASSWORD**. Data Discovery uses column name, comment and data patterns from your selected sensitive types to discover potential relationships between columns.

### Steps
1. Go to **Application Data Models** page under **Data Discovery**. You can **close left side bar navigation menu** using below icon to enlarge the screen:

    ![DMS](./images/dms-012.png "12")

2. Highlight *`Employee_ADM`* created in Task 2 and go to **Actions > Modify > Discover Sensitive Columns**.

    ![DMS](./images/dms-013.png "13")

3. Now, click **Schedule** shown under **Sensitive Column Discovery Jobs** page:
    
    ![DMS](./images/dms-014.png "14")

    Please note the two sections in the image above: **Sensitive Column Discovery Jobs** and **Discovered Columns**.
    - **Sensitive Column Discovery Jobs:** Shows a list of discovery jobs.
    - **Discovered Columns:** When you highlight any discovery job, this section will display a list of discovered columns for that job.

4. Fill in the following details on the **Create Sensitive Column Discovery Job** page:

- Database Named Credentials: *`DMS_ADMIN`*.
- Applications: *`EMPLOYEESEARCH_DEV`* (Start typing to select from the drop-down).
- Sensitive Types: **Email ID**, **USER_ID** and **PASSWORD** (Type in and select from the drop-down for each of the values).

  ![DMS](./images/dms-108.png "15")  

5. Click **Submit**. Check the discovery job status by pressing the **Refresh** button and move forward when status shows **Succeeded**!

    ![DMS](./images/dms-112.png "16")

6. Highlight the succeeded Discovery Job and notice thirteen sensitive columns discovered and shown under the **Discovered Columns** section. Next, highlight each row with columns EMAIL, USERID or PASSWORD one by one and select **Mark Sensitive** option at the top. Notice that the **Sensitive Status** has been changed from *`UNDEFINED`* to *`SENSITIVE`* for eight rows.

    ![DMS](./images/dms-113.png "17")

7. Click **Close**. Now, your ADM is populated with sensitive columns *`EMAIL`*, *`USERID`* and *`PASSWORD`* from different objects.

    **Note:** 
    - This ADM is later used for Data Masking and Data Subsetting tasks.
    - Please note how we use the terms Application, Schema, Object, and Table. Find a brief description of each below:  
    a. **Application**: An application groups related schemas and objects, providing a high-level organizational view for managing data masking and subsetting configurations.  
    b. **Schema**: A logical collection of database objects, typically associated with a user, that includes tables, views, indexes, and more.  
    c. **Object**: Any entity within a schema that holds data or defines a structure, such as a table, view, or index.  
    d. **Table**: A structured set of data organized in rows and columns within a schema. 

**What You Accomplished**  
Successfully ran the **Discover Sensitive Columns** job to identify and mark sensitive columns. Utilized Oracle's predefined sensitive type, **Email ID**, along with user-defined sensitive types, **USER_ID** and **PASSWORD**.

## Task 5: Data Masking- Create a New Masking Format

### Objective
Create a new **Masking Format** for previously discovered sensitive column *`Email ID`*: The **Masking Formats** library, provided by Data Masking and Subsetting, is available for use. However, for this task, we will create a new masking format to specifically mask the **EMAIL** column. This custom masking format will be used in the next task when creating the Masking Definitions.

### Steps
1. To create a new masking format, navigate to the **Masking Formats** page under **Data Masking** as follows:

    ![DMS](./images/dms-018.png "18")

2. Notice that **Masking Formats** library appears with predefined masking formats that Oracle Enterprise Manager provides. Click **Create** and fill in the following details:

 - Name: *`Email ID`*.
 - Description: *`Mask the corporate email by changing prefix and domain name`*.
 - Sensitive Type: *`Email ID`*.
 - Format Entry: *`Random Strings`*.
 - Mention the **Start Length** as 6 and **End Length** as 8. Click **Add Format Entry**.  
 
3. Now, add another **Format Entry** as shown below:
 
- Format Entry: *`Fixed String`*.
- Mention the fixed doman string such as *`@xyz.com`* and click on **Add Format Entry**.
- Optional: You can click Generate to view sample data.

    ![DMS](./images/dms-019.png "19")

4. Click **Create**. 

You can see the newly created Masking Format for the EMAIL columns in the library.

![DMS](./images/dms-020.png "20")

**What You Accomplished:**  
A new Masking Format **Email ID** that will be used to replace sensitive data in *`EMAIL`* columns with new values generated from the concatenation of a random string of 6 to 8 characters at the beginning, followed by the fixed value *`@xyz.com`*.

## Task 6: Data Masking- Create Masking Definition

### Objective
Create a new Masking Definition under **Data Masking** where the masking formats will be set for the sensitive columns *`EMAIL`*, *`USERID`* and *`PASSWORD`* in *`Employee_ADM`* Application Data Model.

### Steps
1. To create a Masking Definition, navigate to **Masking Definitions** under **Data Masking** as follows:

    ![DMS](./images/dms-021.png "21")

2. Click **Create**.

3. On the **Create Masking Definitions page: Basic Details**, fill it as follows:

- Name: *`Employee_Data_Mask.`*
- Application Data Model: *`Employee_ADM.`*
- Associated Database: *`cdb1_PDB1.`*
- Database Named Credentials: *`DMS_ADMIN.`*

    ![DMS](./images/dms-022.png "22")

4. Click **Next**.

5. On the next screen, you can see two different sections- **Columns Available in Application Data Model** and **Columns Available in Masking Definition**. Notice all discovered sensitive columns shown under **Columns Available in Application Data Model** section:

    ![DMS](./images/dms-114.png "23")

Now, let's define and add the masking formats for all the columns for EMAIL, USERID and PASSWORD. 

6. For **EMAIL** columns: Select both the EMAIL columns and click the **Define Format and Add** option at the top.

    ![DMS](./images/dms-115.png "24")

7. On the **Define Format and Add** page, choose **Email ID** (**Masking Format** created in task 5) under **Choose From Masking Formats** drop-down box and click **Import**.
Notice, Masking Format Entries are automatically populated.

8. View the sample data by clicking **Generate** under **Sample Data**:

    ![DMS](./images/dms-025.png "25")

9. Notice the *`EMAIL`* columns now appear under **Columns Available in Masking Definition** along with the defined Masking Format:

    ![DMS](./images/dms-116.png "26")

Stay on the **Create Masking Definitions** page to define and add the formats for the other columns- *`USERID`* and *`PASSWORD`* as shown in the next steps.

10. For **USERID** columns: let’s group columns with the same data type and apply a masking format. Start by selecting the three **USERID** columns with the **VARCHAR** data type listed under **Columns Available in Application Data Model**, then click **Define Format and Add**.

    ![DMS](./images/dms-117.png "27")

    **Note**: You can define masking formats for multiple columns with the same data type.

 - Choose **Custom Format Entry** as **Random Numbers** and enter *`Start Integer`* and *`End Integer`* as *`101`* and *`1999`*.
 - Click **Add Format Entry**.
    
    ![DMS](./images/dms-118.png "028")

- click **Add**. 

11. Repeat the process for the remaining two **USERID** columns. Select the other two **USERID** columns with the **NUMBER** data type listed under **Columns Available in Application Data Model**, then click **Define Format and Add**.

    ![DMS](./images/dms-119.png "29")

 - Choose **Custom Format Entry** as **Random Numbers** and enter *`Start Integer`* and *`End Integer`* as *`101`* and *`1999`*.
 - Click **Add Format Entry** and click **Add**. 
    
12. Now, select the **PASSWORD** column shown under **Columns Available in Application Data Model** and click **Define Format and Add**:

- Choose **Custom Format Entry** as **Fixed String** and enter the string as *`***`*. 
- Click **Add Format Entry**. 
    
    ![DMS](./images/dms-120.png "30")

- Click **Add** and notice, all columns- **EMAIL**, **USERID** and **PASSWORD** are added under **Columns Available in Masking Definitions**:  
        
    ![DMS](./images/dms-121.png "31")
       
13. Click **Next**.

14. Users have an option to add a pre-masking script and a post-masking script. For this task, however, you can leave it empty.

**Note**:
    - Use the **Pre Mask Script** text box to specify any SQL script that must run before masking starts.
    - Use the **Post Mask Script** text box to specify any SQL script that must run after masking completes.  
    
15. Click **Next**.

16. Click **Create** on the next page. A new Masking Definition is created.

    ![DMS](./images/dms-032.png "32")

**What You Accomplished:**  
A new Masking Definition for sensitive columns EMAIL, USERID and PASSWORD in the *`Employee_Data_Mask`* is created and shown on the **Masking Definitions** page.

## Task 7: Data Masking- Generate and Execute Masking Script  

### Objective
- **Generate the masking script** for the previously created Masking Definition, *`Employee_Data_Mask`*. If needed, you can also export the script and perform bulk operations.
- **Update the Named Credential** required to run the masking job. Then, **execute the generated masking script** to mask the sensitive data.

### Steps
**Generate the Masking Script**:
1. Click **Actions** for *`Employee_Data_Mask`* and choose **Manage Masking Script > Generate Masking Script** as shown below:  

    ![DMS](./images/dms-033.png "33")

2. On **Generate Masking Script** page, you can choose either of the two options:

 - **In-Database Masking**: This performs in-place masking by replacing sensitive data in a database. 
 - **In-Export Masking**: This performs masking while exporting data from a source database using Oracle Data Pump. It is safe to use this option in a production environment because it does not modify any source data.

Fill in the below details:

 - Data Masking Option: **In-Database Masking** (we are choosing In-Database for this lab).
 - Associated Database: *`cdb1_PDB1`*.
 - Database Named Credential: *`DMS_ADMIN`*.  
 
    ![DMS](./images/dms-034.png "34")


3. Click **Generate**.  

To monitor the status of the job, refresh the screen by clicking the **Re-fetch** icon on the **Masking Definitions** page. 

**Tips**:
 - You have the ability to export the script locally by clicking **Export** under **Actions**.
 - This exported script can then be executed on other targets with the same schema and sensitive data.

Notice that the **Most Recent Job Status** has changed to *`Script Generated`* for *`Employee_Data_Mask`*. Now, your masking script is ready to be used!

![DMS](./images/dms-035.png "35")

**Note:**  
Pre-Masking Validation Checks:  
Oracle Data Masking Pack performs a series of validation checks during script generation to ensure that the Data Masking process proceeds successfully without errors. Once the validation checks listed below are successfully completed, Oracle Data Masking Pack generates a PL/SQL-based masking script, which is then transferred to the target database for execution:
- Masking Formats: This is a necessary step in the Data Masking process to ensure that the chosen masking formats meet the database and application integrity requirements.
- Data Constraints: The requirements may include generating unique values for the column being masked because of uniqueness constraints or generating values that meet the column length or type requirements

**Update the Host Named Credential**  
4. The Host Named Credential has been pre-configured for you, but before running the masking script, you need to add your own SSH private key to enable it. Follow the steps below to update the Host Named Credential with the new SSH key based on your connection method:  

    **Step 4(a).** Complete this step only if you are using the embedded remote desktop. If not, skip to Step 4(b).  
    **Step 4(b).** Complete this step only if you are NOT using the embedded remote desktop.

**Step 4(a).** If you are using the embedded remote desktop:  

i. Generate SSH Keys  
- From your noVNC remote desktop session, open a **Terminal** session:

![DMS](./images/dms-122.png "36")

 Run the following to generate the key pair:  

    ````
    <copy>
        cd ~
        ssh-keygen -b 2048 -t rsa
    </copy>
    ````  

- Accept defaults for file and passphrase by pressing Enter three times to create a key with no passphrase.
- Update *`~/.ssh/authorized_keys`* and copy the private key to *`/tmp`*.  

    ````
    <copy>
        cd .ssh
        cat id_rsa >/tmp/rsa_priv
        cat id_rsa.pub >>authorized_keys
    </copy> 
    ```` 
    
ii. Update the Host Named Credential with the new SSH Key:

- From the EM Console as SYSMAN, navigate to menu **Setup > Security > Named Credentials**:
    ![DMS](./images/dms-037.png "Add the formats entries types")

- Select *`OS_ORACLE_SSH`* credential and click *`Edit`*.

    ![DMS](./images/dms-038.png "Add the formats entries types")

- Keep the General Properties section unchanged and update the Credential Properties as followed:

    - Username: *`oracle`*.
    - Delete any content from SSH Public Key Textbox.
    - Delete any content from Run as Textbox (no delegated sudo privilege needed).
        
        ![DMS](./images/dms-039.png "39")

    - Under SSH Private Key, upload the key by clicking **Choose File**. On the file browser, navigate to **Other Locations > tmp** and select the file *`rsa_priv`*.

        ![DMS](./images/dms-040.png "40")

- Click **Test and Save**.

    ![DMS](./images/dms-041.png "41")

**Step 4(b).** If you are NOT using the remote desktop embedded:  

- Make sure you can R/W files to your DBSecLab VM from the OEM Console by selecting the menu **Setup > Security > Named Credentials**.
- Select *`OS_ORACLE_SSH`* named credential.
- Click **Edit**.

    ![DMS](./images/dms-038.png "38")

- We have already pre-configured this Named Credential for you but you have to put your own **SSH Private Key** to enable it.

    ![DMS](./images/dms-039.png "39")

- In the section Credential Properties, load your SSH Private Key. Remember, this key must be in RSA format, so please open your own SSH Private Key file, copy the content and paste it in the text box.
- Click **Test and Save**.  
Your connection should be successful, if not please make sure your SSH Private Key is the correct one.

![DMS](./images/dms-041.png "41")

**Schedule Masking Job**  

5. Now, lets schedule the Masking job by navigating to **Targets > Databases**. Click **Security** > **Data Masking and Subsetting** and Choose **Data Masking**.  

    ![DMS](./images/dms-003b.png "43")

6. Highlight *`Employee_Data_Mask`* and select **Actions > Schedule Masking**.

    ![DMS](./images/dms-043.png "43")

Fill in the following details on the **Schedule Data Masking Job: Basic Details page**:

    - Data Masking Option: **In-Database Masking**.
    - Tablespace for Temporary Objects: **Default Tablespace** (Default).
    - Associated Database: *`cdb1_PDB1`*.
    - Database Named Credentials: *`DMS_ADMIN`*.
    - Host Named Credentials: *`OS_ORACLE_SSH`*
    - Select the checkbox for **Selected Database is not a production database**.

![DMS](./images/dms-044.png "44")  

7. Click **Next**.

On the next page, mention:

- Script File Location: *`/tmp`*.

![DMS](./images/dms-045.png "45")

8. Click **Submit**.

Observe that the **Most Recent Job Status** changes to **Masking Job Scheduled**. Click the **re-fetch** button periodically until the status updates to **Masking Job Succeeded**.

![DMS](./images/dms-046.png "46")

**Note:**
- Oracle Data Masking Pack performs bulk operations to rapidly replace the table containing sensitive data with an identical table containing masked data while retaining the original database constraints, referential integrity and associated access structures, such as INDEXes and PARTITIONs, and access permissions, such as GRANTs.
- Unlike masking processes that are traditionally slow because they perform table updates, Oracle Data Masking Pack takes advantage of the built-in optimizations in the database to disable database logging and execute in parallel to quickly create a masked replacement for the original table.
- The original table containing sensitive data is dropped from the database completely and is no longer accessible.

**What You Accomplished:**  
Generated the Masking Script for the *`Employee_Data_Mask`* definition, with the option to export it for future bulk operations. Updated the required Host Named Credential and executed the script by submitting a masking job, successfully masking the sensitive data.

## Task 8: Review the Masked Data and Share with Third-Party

### Objective
**Query and review the masked data** in the development and production environments for a before and after comparison. Share the masked data with your third-party collaborator.

### Steps
**Query the masked data:**
1. Launch **SQL Developer** in your noVNC session  

    ![DMS](./images/dms-122.png "47")

Connect to *`PDB1_SYSTEM`* by double-clicking the connection.

![DMS](./images/dms-048.png "48")

2. You should open two separate worksheets for *`PDB1_SYSTEM`*. Open the second worksheet by right clicking *`PDB1_SYSTEM`* shown under **Oracle Connections** and selecting **Open SQL Worksheet**.

    ![DMS](./images/dms-049.png "Open SQL Developer")

3. In the first one, copy the following queries for **Production data BEFORE masking**:

    ````
    <copy>
    -- -----------------------------
    -- PROD: BEFORE MASKING
    -- -----------------------------

    -- EMPLOYEE_DATA
    SELECT EMAIL, USERID FROM EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES
     ORDER BY 1;

    -- USERS_DATA
    SELECT EMAIL, USERID, PASSWORD FROM EMPLOYEESEARCH_PROD.DEMO_HR_USERS
     ORDER BY 1;

    </copy>
    ````

    ![DMS](./images/dms-050.png "Queries for the PROD (BEFORE MASKING)")

4. In the second one, copy the following queries for the **development data AFTER masking**

    ````
    <copy>
    -- -----------------------------
    -- DEV: AFTER MASKING
    -- -----------------------------

    -- EMPLOYEE_DATA
    SELECT EMAIL, USERID FROM EMPLOYEESEARCH_DEV.DEMO_HR_EMPLOYEES
    ORDER BY 1;

    -- USERS_DATA
    SELECT EMAIL, USERID, PASSWORD FROM EMPLOYEESEARCH_DEV.DEMO_HR_USERS
    ORDER BY 1;

    </copy>
    ````
    ![DMS](./images/dms-051.png "51")

**Compare the results:**  
5. Before and after masking job comparison for **DEMO_HR_EMPLOYEES** and **DEMO_HR_USERS** have been shown below:  
- Employee Data:  
    - **BEFORE masking** (on prod)

        ![DMS](./images/dms-052.png "Employee data BEFORE masking (in PROD)")

    - **AFTER masking** (on dev)

        ![DMS](./images/dms-053.png "Employee data AFTER masking (in DEV)")

- Users Data:
    - **BEFORE masking** (on prod)

        ![DMS](./images/dms-054.png "Users data BEFORE masking (in PROD)")

    - **AFTER masking** (on dev)

        ![DMS](./images/dms-055.png "Users data AFTER masking (in DEV)")

As shown, sensitive data has been masked according to the defined formats in the development environment, allowing you to share this environment securely. With sensitive columns like Email, UserID, and Password masked while keeping other non-sensitive columns unmasked, organizations can safely share data with external partners without exposing sensitive information. This ensures secure data sharing while maintaining usability for various purposes, including analytics, as illustrated below:  
*`The collaborator can perform workforce analysis while protecting privacy by utilizing masked columns like Email, UserID, and Password, alongside unmasked, non-sensitive columns. For example, the firm could examine employee engagement and activity without needing direct identifiers. Suppose the data shows that out of 1000 masked employees in HR_EMPLOYEES, 300 have logged into the system over 50 times in the past month, indicating high engagement. In HR_USERS, masked UserIDs can show 100 distinct users who accessed sensitive internal reports.`*

*`These insights can provide actionable recommendations, such as “Internal report access patterns suggest a need to audit access controls.” This analysis allows the organization to improve workforce management while safeguarding sensitive information.`*

**What You Accomplished:**  
Queried and reviewed masked data using Oracle SQL Developer, while also exploring the use case for securely sharing data with a third-party collaborator.

## Task 9: Data Subsetting- Create Data Subsetting Definition

### Objective
Subset and mask your sensitive data for secure sharing with external partners. The following tasks will be performed to subset and mask the data together:

- Create **Data Subsetting Definition**.
- Add **Object Rules** to specify the data to be included.
- Associate the previously generated **Masking Definition**.

### Steps
**Create Data Subsetting Definition:**
1. Go to OEM and navigate to Data Subsetting on the left side as shown below:

    ![DMS](./images/dms-056.png "Navigate to the Application Data Models")

2. On the **Data Subsetting Definitions** page, click **Create**.

    ![DMS](./images/dms-057a.png "Begin the process of subsetting data")

3. On the **Data Subsetting Definition Properties** screen, fill it as follows:  
    - Name: *`Employee_Data_Subset`*.
    - Description: *`Subset Employee Data`*.
    - Application Data Model: *`Employee_ADM`* (Use search option).
    - Source Database: *`cdb1_PDB1`* (Use search option).

        ![DMS](./images/dms-058.png "Subsetting Definition Properties")

4. Click **Continue**.  

5. In the **Credentials** section, select the **Named** radio button, choose the **Credential Name** as *`DMS_ADMIN`*.

6. Click **Submit**.  

Now, your Subsetting definition is being created. Please refresh the page until you see **Succeeded** under **Most Recent Job Status**.

![DMS](./images/dms-060.png "Subsetting definition is scheduling")

7. Once the subsetting definition is created, select it and click on **Edit**.

    ![DMS](./images/dms-062.png "Edit the Subsetting definition")

8. In the **Database Login** page, select the **Named** radio button, choose the **Credential Name** as *`DMS_ADMIN`*. Click **Continue**.

    ![DMS](./images/dms-061.png "Edit the Subsetting definition")

9. In the **Applications** tab, select *`EMPLOYEESEARCH_DEV(EMPLOYEESEARCH_DEV)`* available in your ADM.

    ![DMS](./images/dms-104.png "Select the schema")

**Add Object (Subset) Rules:**  
10. In the **Object Rules** tab, define the subset rules by clicking **Create** as many times as needed. Here, we will create **four** Object Rules, so click **Create** and proceed as below:

![DMS](./images/dms-064.png "Create all the Subset rules")

- Object Rule 1: For *`DEMO_HR_EMPLOYEES`* table, we will keep only **25% of rows** as this is a dataset table.
    - In **Objects**, select **Specified** and choose *`DEMO_HR_EMPLOYEES`*.
    - In **Rows to Include**, select **Some Rows** and enter *`25`*.
    - Check "**Include Related Rows**" and select **Ancestor and Descendant Objects** (Default).

        ![DMS](./images/dms-065.png "... for DEMO_HR_EMPLOYEES table")

    - Click **OK**.

- Object Rule 2: For *`DEMO_HR_ERROR_LOG`* table, we will keep **0% of rows** as this is a log table.
    - Click **Create**.
    - In **Objects**, select **Specified** and choose *`DEMO_HR_ERROR_LOG`*.
    - In **Rows to Include**, select **Rows Where** and enter *`1=0`* (here, this condition allow to extract 0 rows!).
    - Uncheck **Include Related Rows**.

        ![DMS](./images/dms-066.png "... for DEMO_HR_ERROR_LOG table")

    - Click **OK**.

- Object Rule 3: For *`DEMO_HR_ROLES`* table, we will keep **100% of rows** as this is a reference table.
    - Click **Create**.
    - In **Objects**, select **Specified** and choose *`DEMO_HR_ROLES`*.
    - In **Rows to Include**, select **All Rows**.
    - Check **Include Related Rows** and select **Ancestor and Descendant Objects** (Default).

        ![DMS](./images/dms-067.png "... for DEMO_HR_ROLES table")

    - Click **OK**.

- Object Rule 4: For *`DEMO_HR_USERS`* table, we will keep **100% of rows** as this is a reference table.
    - In **Objects**, select **Specified** and choose *`DEMO_HR_USERS`*.
    - In **Rows to Include**, select **All Rows**.
    - Check **Include Related Rows** and select **Ancestor and Descendant Objects**.
    - Click **OK**.  

        ![DMS](./images/dms-068.png "... for DEMO_HR_USERS table")

Now, all 4 defined Object Rules should show as below:

![DMS](./images/dms-069.png "List of your Object Rules")

11. In the **Space Estimates** tab, expand the **Applications and Objects** list as shown below:

    ![DMS](./images/dms-070.png "Space Estimate")

    **Note:**
    - Here, you can see the **Source and Estimated Subset Size** (in MB and number of rows).
    - Since the tables are interdependent, you will see the effects of subsetting on parent-child tables. In this example, *`DEMO_HR_EMPLOYEES`* retains 25% of its rows as previously defined. However, due to its dependency on the *`DEMO_HR_SUPPLEMENTAL_DATA`* table, this table is also affected by the subsetting and will retain 71% of its rows.

You may stop here if you only need to subset your data. However, we will proceed by **associating the Data Masking script** previously generated to demonstrate how subsetting and masking can be combined in a single process.

**Associate the previously generated Masking Definition**  

12. In the **Data Masking Definitions** tab, click **Add**.  

    ![DMS](./images/dms-071.png "Data Masking Definitions is associated")

13. Select the masking definition *`Employee_Data_Mask`* created earlier. Click **OK**.

    ![DMS](./images/dms-072.png "Data Masking Definitions")

Now, your Data Masking script is associated with your Data Subsetting definition and it will be executed along with data subsetting. You do not need to execute the masking script separately.
        
![DMS](./images/dms-073.png "Data Masking Definitions is associated")

14. Click **Return** to go to the Data Subsetting Definitions screen.

**What you accomplished:**  
Data Subsetting Definition is created with defined subsetting and masking rules. Alternatively, you can choose to just define subsetting rules without the masking definition inclusion by skipping step 13 and 14.

## Task 10: Data Subsetting- Generate and Execute Data Subsetting Script

### Objective
Once the Data Subsetting Definition containing subsetting and masking rules is created, the next step is to:

- **Restore the development schema** on *`cdb1_PDB1`* target database by cloning data from production schema.
- **Generate** and **execute** the Subsetting Script.

### Steps
**Restore the development schema**
1. Since the data was masked as part of Task 8, lets restore the *`EMPLOYEESEARCH_DEV`* schema on **pdb1** by cloning data from *`EMPLOYEESEARCH_PROD`* schema to have original data.
Open a Terminal session on your **DBSec-Lab** VM as OS user *`oracle`* by running the following command:

        ````
        <copy>sudo su - oracle</copy>
        ````

**Note**: If you are using a **remote desktop session**, simply double-click the **Terminal** icon to launch a session directly as Oracle. 

2. Go to the scripts directory.

        ````
        <copy>cd $DBSEC_LABS/dms</copy>
        ````

3. Reset the *`EMPLOYEESEARCH_DEV`* data as it was before masking.

        ````
        <copy>./dms_restore_pdb1_dev.sh</copy>
        ````

    ![DMS](./images/dms-074.png "Restore original data")

**Generate and execute the subsetting script:**  
4. Go back to the OEM Console and navigate to **Target > Databases**, then choose **Security** > **Data Masking and Subsetting** > **Data Subsetting**.  

![DMS](./images/dms-003b.png "Navigate to the Application Data Models")

5. Select the *`Employee_Data_Subset`* subsetting definition, go to **Actions**, and choose **Generate Subset**.

    ![DMS](./images/dms-076.png "Navigate to the Application Data Models")

6. On the **Generate Subset: General** screen, fill in as shown below:

    - In **Create Subset By**, select **Deleting Data From a Target Database** (similar to the In-Database Masking).
    - In **Database Credentials**, select the **Named** radio button and choose the Credential Name as  *`DMS_ADMIN`*.
    - In **Host Credentials**, select the **Named** radio button and choose the Credential Name as  *`OS_ORACLE_SSH`*.

        ![DMS](./images/dms-077.png "Generate Subset: General")

7. Click **Continue**.

8. On the **Generate Subset: Parameters** screen, fill in as shown below:

    - In **Subset Directory**, select **Select a custom directory path on target database to save subset scripts**.
    - Enter this location: *`/home/oracle/DBSecLab/livelabs/dms`*.
    - Select the checkbox *`The selected target is not a production database`*.

        ![DMS](./images/dms-078.png "Generate Subset: Parameters")

9. Click **Continue**. A warning message tells you that a directory will be created to store the script into the location you mentioned earlier.

    ![DMS](./images/dms-079.png "Warning message")

10. Click **OK**.  
After reviewing that the required space is available, click **Submit** to generate the script.

**Note:** The script is generated and automatically executed!

11. Refresh the **Data Subsetting Definitions** page until you see the **Job Status** as **Succeeded**.

    ![DMS](./images/dms-081.png "Job Status as Succeeded")

**What you accomplished:**  
 Generated the Data Subsetting script including subsetting as well as masking rules and executed the script to successfully subset and mask the data in one step.

## Task 11: Review the Subsetted (and Masked) Data

### Objective
Review subsetted and masked data across environments to understand how Data Masking and Subsetting enables secure data sharing with third-party collaborators. This includes querying subsetted and masked data in Production and Development environments for a before-and-after comparison.

### Steps
1. Query the data in the production and development environments using SQL Developer: Open **SQL Developer** on your noVNC session.  

![DMS](./images/dms-122.png "122")

2. You should open two separate worksheets for *`PDB1_SYSTEM`* connection:  
    - Under the list of **Oracle Connections**, double-click on PDB1_SYSTEM.  
    - Open the second worksheet by right-clicking PDB1_SYSTEM shown under **Oracle Connections** and selecting **Open SQL Worksheet**.
    
    **Note**: If you have an existing SQL Developer session open from Task 8, you may continue using the current worksheets.

3. In the first worksheet, copy the following queries for the **production before subsetting and masking** operation:

    ````
    <copy>
    -- -----------------------------
    -- PROD: BEFORE SUBSETTING AND MASKING
    -- -----------------------------

    -- EMPLOYEE_DATA COUNT
    SELECT count(*) "EMPLOYEES COUNT" FROM EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES;

    -- SUPPLEMENTAL_DATA COUNT
    SELECT count(*) "SUPPLEMENTAL_DATA COUNT" FROM EMPLOYEESEARCH_PROD.DEMO_HR_SUPPLEMENTAL_DATA;

    -- USERS_DATA COUNT
    SELECT count(*) "USERS COUNT" FROM EMPLOYEESEARCH_PROD.DEMO_HR_USERS;

    -- EMPLOYEE_DATA
    SELECT EMAIL, USERID FROM EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES
    ORDER BY 1;

    -- USERS_DATA
    SELECT EMAIL, USERID, PASSWORD FROM EMPLOYEESEARCH_PROD.DEMO_HR_USERS
    ORDER BY 1;
    </copy>
    ````

    ![DMS](./images/dms-083.png "Queries for the PROD (BEFORE SUBSETTING)")

4. In the second one, copy the following queries for the **development after subsetting and masking** operation:

    ````
    <copy>
    -- -----------------------------
    -- DEV: AFTER SUBSETTING AND MASKING
    -- -----------------------------

    -- EMPLOYEE_DATA COUNT
    SELECT count(*) "EMPLOYEES COUNT" FROM EMPLOYEESEARCH_DEV.DEMO_HR_EMPLOYEES;

    -- SUPPLEMENTAL_DATA COUNT
    SELECT count(*) "SUPPLEMENTAL_DATA COUNT" FROM EMPLOYEESEARCH_DEV.DEMO_HR_SUPPLEMENTAL_DATA;

    -- USERS_DATA COUNT
    SELECT count(*) "USERS COUNT" FROM EMPLOYEESEARCH_DEV.DEMO_HR_USERS;

    -- EMPLOYEE_DATA
    SELECT EMAIL, USERID FROM EMPLOYEESEARCH_DEV.DEMO_HR_EMPLOYEES
    ORDER BY 1;

    -- USERS_DATA
    SELECT EMAIL, USERID, PASSWORD FROM EMPLOYEESEARCH_DEV.DEMO_HR_USERS
    ORDER BY 1;

    </copy>
    ````

    ![DMS](./images/dms-086.png "Queries for the DEV (AFTER SUBSETTING)")

5. Execute all the above queries and compare the results as shown below:

    - Rows count **before subsetting**:

        ![DMS](./images/dms-085.png "Row count AFTER subsetting (in DEV)")

    - Employee Data **before masking**:

        ![DMS](./images/dms-087.png "Employee Data BEFORE masking (in PROD)")

    - Employee Data **after masking**

        ![DMS](./images/dms-089.png "Employee Data AFTER masking (in DEV)")

    - Users Data **before masking**

        ![DMS](./images/dms-088.png "Users Data BEFORE masking (in PROD)")

    - Users Data **after masking**

        ![DMS](./images/dms-090.png "Users Data AFTER masking (in DEV)")

As you can see, the sensitive data is subsetted and masked as per the defined object rules and masking definition. 

**Why This Matters:**  
By combining subsetting with masking, the enterprise ensures that the third-party receives a masked and representative dataset without unnecessary exposure of sensitive or irrelevant data. This approach allows the third-party team to:

- Conduct application testing on anonymized data.
- Maintain the relationships and integrity of reference data.
- Ensure compliance with privacy regulations, even when sharing data externally.

**What You Accomplished:**  
Queried and reviewed subsetted and masked data on production and development environments using Oracle SQL Developer.

## Final Task: Reset the Lab Environment

### Objective

Lastly, let’s reset the lab by restoring the development environment tables through data cloning from production. Then, delete the previously created:

- Application Data Model
- Masking Definition
- Subsetting Definition

This task ensures a clean environment for future exercises and prevents any potential conflicts or errors that could arise from leftover configurations.

### Steps
1. Restore the *`EMPLOYEESEARCH_DEV`* tables by cloning data from *`EMPLOYEESEARCH_PROD`* schema.

    - Open a Terminal session on your **DBSec-Lab** VM as OS user *`oracle`*.

        ````
        <copy>sudo su - oracle</copy>
        ````

        **Note**: If you are using a **remote desktop** session, simply double-click the **Terminal** icon on the desktop to launch a session directly as *`oracle`*. In this case, you do not need to execute this command.

    - Go to the scripts directory.

        ````
        <copy>cd $DBSEC_LABS/dms</copy>
        ````

    - Reset the *`EMPLOYEESEARCH_DEV`* data as it was before masking.

        ````
        <copy>./dms_restore_pdb1_dev.sh</copy>
        ````

        ![DMS](./images/dms-091.png "Reset Data")

2. Now, go back to the OEM Console and remove all definitions created. 

**Note:** You must first drop the Masking and Subsetting Definition before dropping the associated Application Data Model.

3. First, **drop the Data Masking definition**.

    - Navigate to the main menu: **Targets > Databases**, then select **Security** > **Data Masking and Subsetting** > **Data Masking**.
        ![DMS](./images/dms-092.png "Navigate to the Application Data Models")

    - Select each Data Masking Definition, then click **Delete** at the top.
        ![DMS](./images/dms-093.png "Delete all the Data Masking definitions")

    - Click **Delete** to confirm.

        ![DMS](./images/dms-094.png "Confirm deletion")

    - Now, your Data Masking Definition is deleted.

4. Next, **drop the Data Subsetting definition**.

    - Navigate to the **Data Subsetting Definitions** by clicking **Data Subsetting**.

        ![DMS](./images/dms-056.png "Navigate to the Application Data Models")

    - Select each Data Subsetting Definition and click **Delete** at the top.
        
        ![DMS](./images/dms-095.png "Delet all the Data Subsetting Definition")

    - Click **Yes** to confirm.

        ![DMS](./images/dms-096.png "Confirm deletion")

    - Now, your Data Subsetting Definition is dropped!

        ![DMS](./images/dms-097.png "Data Subsetting Definition are dropped")

5. Finally, **drop the Application Data Model**.

    - Navigate to the main menu and select **Targets > Databases**. At the top, click **Security**, then select **Data Discovery**.

        ![DMS](./images/dms-098.png "Navigate to the Application Data Models")

    - Select each Application Data Model, then click **Actions > Delete**.

        ![DMS](./images/dms-099.png "Delete all the Application Data Model")

    - Click **Yes** to confirm.

        ![DMS](./images/dms-100.png "Confirm deletion")

    - Now, your Application Data Model is dropped!

        ![DMS](./images/dms-101.png "Application Data Model are dropped")

**What you accomplished:**  
The lab has been reset for future exercises.

## **Appendix**: About the Product
### **Overview**
Oracle Data Masking and Subsetting pack for Enterprise Manager, part of Oracle's comprehensive portfolio of database security solutions, helps organizations comply with data privacy and protection mandates such as Payment Card Industry (PCI) Data Security Standard (DSS), Health Insurance Portability and Accountability Act (HIPAA), EU General Data Protection Regulation (GDPR), and numerous laws that restrict the use of actual customer data. With Oracle Data Masking, sensitive information such as credit card or social security numbers can be replaced with realistic values, allowing production data to be safely used for development, testing, or sharing with outsourced or off-shore partners for other non-production purposes. Oracle Data Masking uses a library of templates and format rules, consistently transforming data in order to maintain referential integrity for applications.

### **Data Masking**
Data masking (also known as data scrambling and data anonymization) is the process of replacing sensitive information copied from production databases to non-production databases with realistic, but scrubbed, data based on masking rules. Data masking is ideal for virtually any situation when confidential or regulated data needs to be shared with other non-production users; for instance, internal users such as application developers, or external business partners, like offshore testing companies or suppliers and customers. These non-production users need to access some of the original data, but do not need to see every column of every table, especially when the information is protected by government regulations.

Data masking allows organizations to generate realistic and fully functional data with similar characteristics as the original data to replace sensitive or confidential information. This contrasts with encryption or Virtual Private Database, which simply hides data, allowing the original data to be retrieved with the appropriate access or key. With data masking, the original sensitive data cannot be retrieved or accessed. Names, addresses, phone numbers, and credit card details are examples of data that require protection of the information content from inappropriate visibility. Live production database environments contain valuable and confidential data — access to this information is tightly controlled. However, each production system usually has replicated development copies, and the controls on such test environments are less stringent. This greatly increases the risks that the data might be used inappropriately. Data masking can modify sensitive database records so that they remain usable, but contain no confidential or personally identifiable information. Yet, the masked test data resembles the original in appearance to ensure the integrity of the application.

![DMS](./images/dms-concept.png "DMS Concept")

### **Data Subsetting**
Data Subsetting helps reduce security risks and minimize storage costs by removing unnecessary data from a database before sharing it for non-production use. Data Subsetting provides goal-based and condition-based subsetting. A goal can be a relative table size, such as extracting a 1% subset of a table containing 10 billion rows. A condition can be based on factors such as time, such as discarding all user records created before a particular year. A condition can also be based on region, for example, extracting Asia-Pacific information to support the development of a new application.


### **Why do I need Data Masking and Subsetting?**

**Challenges**  
There are several reasons why your business may need it, based on the critical challenges outlined below:  
- Multiple Copies of Sensitive Data  
Creating multiple copies of sensitive data for testing, development, and analytics increases the risk of exposure and makes tracking and securing that data across environments more difficult.

- Increased Vulnerability to Data Breaches  
Without masking or anonymization, sensitive data remains exposed in non-production environments, leaving organizations vulnerable to catastrophic breaches.

- Regulatory and Compliance Risks  
Failing to protect sensitive data can result in non-compliance with critical regulations like GDPR or CCPA, leading to hefty fines and reputational damage.

- Complex Data Management  
Managing sensitive data without proper protection solutions increases operational inefficiencies and overhead costs.

**Business Use Cases**
- Data Sharing
When outsourcing or collaborating with third parties, sharing full datasets can pose a risk. Oracle Data Masking and Subsetting ensures that only relevant, non-sensitive data is shared, protecting sensitive details.

- Secure Application Testing
Developers need real data for effective testing. Oracle Data Masking and Subsetting allows them to safely use real-world data by obfuscating sensitive information like personal identifiers and financial details. This ensures robust testing without compromising data privacy.

- Analytics Without Compromise
By masking sensitive information, businesses can share data securely for analytics without exposing personal data. This enables effective data-driven insights while maintaining privacy and compliance.

- Regulatory Compliance
With regulations like GDPR and CCPA, organizations are required to handle sensitive data securely. Oracle’s solution helps anonymize and protect sensitive information in non-production environments, ensuring compliance and minimizing the risk of penalties.

### **Benefits of using DMS**
- Create multiple data copies of production environment safely.
- Leverage a comprehensive library of Masking Formats, Sensitive Types, Subsetting Techniques, and Application Templates.
- Minimize the compliance boundary by not proliferating the sensitive production information.
- Lower the storage costs on test and development environments by subsetting data.
- Automate the discovery of sensitive data and parent-child relationships.
- Mask and subset data In-Database or In-Export by extracting the data from a target database.
- Mask and subset both Oracle and non-Oracle databases.
- Mask and subset Oracle Databases hosted on the Oracle cloud.
- Preserve data integrity during masking and subsetting offering many more unique features.
- Integrate with select Oracle testing, security, and integration products.

## Want to Learn More?
Technical Documentation:
- [Oracle Data Masking & Subsetting](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/dmksb/intro.html#GUID-24B241AF-F77F-46ED-BEAE-3919BF1BBD80)

Video:
- *Understanding Oracle Data Masking & Subsetting* [](youtube:3zi0Bs_bgEw)
- *Oracle Data Masking & Subsetting - Advanced Use Cases* [](youtube:06EzV-TM4f4)

## Acknowledgements
- **Author** - Kajal Singh, Database Security PM
- **Contributors** - Rene Fontcha
- **Last Updated By/Date** - Kajal Singh, Database Security PM - January 2025