# Oracle Data Masking and Subsetting (DMS)

## Introduction
This workshop introduces the various features and functionality of Oracle Data Masking and Subsetting (DMS) pack for Enterprise Manager. It gives the user an opportunity to learn how to configure those features in order to secure their sensitive data in a Non-Production environment.

*Estimated Lab Time:* 85 minutes

*Version tested in this lab:* DBEE 19.23 and Oracle Enterprise Manager 13.5.0.21

### Video Preview
Watch a preview of "*Understanding Oracle Data Masking & Subsetting (April 2019)*" [](youtube:3zi0Bs_bgEw)

### Objectives
- Create an Application Data Model (ADM)
- Generate a data masking script to mask sensitive data
- Execute the data masking script and compare before/after values

### Prerequisites
This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

### Lab Timing (estimated)
| Step No. | Feature | Approx. Time |
|--|------------------------------------------------------------|-------------|
| 1 | Import Schema Structure | 5 minutes |
| 2 | Enhance the Meta-Model | 5 minutes |
| 3 | Use Pre-Defined Sensitive Column Types | 5 minutes |
| 4 | Create a New Sensitive Column Type | 5 minutes |
| 5 | Create a New Sensitive Column Type Using Pre-Defined Templates | 5 minutes |
| 6 | Create a New Masking Format | 5 minutes |
| 7 | Manually Identify Sensitive Columns | 5 minutes |
| 8 | Create Data Masking Definitions | 5 minutes |
| 9 | Format Columns Using the Format Library and Masking Primitive | 10 minutes |
|10 | Generate Data Masking Scripts | 5 minutes |
|11 | Execute the Data Masking Scripts | 5 minutes |
|12 | Compare the Pre-Masked Data vs. the Post-Masked Data | 5 minutes |
|13 | Create Data Subsetting Definitions | 5 minutes |
|14 | Execute Data Subsetting Scripts | 5 minutes |
|15 | Compare the Pre-Subsetted Data vs. the Post-Subsetted Data | 5 minutes |
|16 | Reset the Labs Environment | <5 minutes |

## Task 1: Import Schema Structure

1. Open a Web Browser to *`https://dbsec-lab:7803/em`* to access to Oracle Enterprise Manager 13c Console

    **Notes:** If you are not using the remote desktop you can also access this page by going to *`https://<YOUR_DBSEC-LAB_VM_PUBLIC_IP>:7803/em`*

2. Login as *`SYSMAN`* with the password "*`Oracle123`*"

    ````
    <copy>SYSMAN</copy>
    ````

    ````
    <copy>Oracle123</copy>
    ````

    ![DMS](./images/dms-001.png "OEM Login")

3. Navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Application Data Modeling** as follow:

    ![DMS](./images/dms-002.png "Application Data Modeling")

4. Briefly review the Secure **Test Data Management diagram** to familiarize yourself with the process

    ![DMS](./images/dms-003.png "Test Data Management diagram")

5. Click [**Create**] to add a new ADM
    - Name the ADM: *`Employee_ADM`*
    - Click the magnifying glass for Source Database and select *`cdb_PDB1`*
    - Choose the option type *`Custom Application Suite`*
    - Checkbox the option *`Create One Application For Each Schema (default)`*

        ![DMS](./images/dms-004.png "Create an ADM")

    **Note**: Notice the options to create ADMs for Oracle Enterprise Business Suite (EBS) and Fusion Applications

6. Click [**Continue**]

7. Connect with the DMS Admin pre-defined user
    - Select the **Named** radio button
    - Choose the Credential Name *`DMS_ADMIN`* (for your information, its password is "`Oracle123`")

        ![DMS](./images/dms-005.png "Create an ADM")

    - Click [**Login**]

    **Note**: Alternatively, `SYS` can be used as well... In a production environment, you could limit the privileges of `DMS_ADMIN` to only the packages necessary to perform their duties

8. Select the *`EMPLOYEESEARCH_DEV`* schema for the application data model

    ![DMS](./images/dms-006.png "Select schemas")

9. Click [**Continue**]

10. Click [**Submit**] to schedule the job

    ![DMS](./images/dms-007.png "Schedule the job")

11. The job collect the ADM has been submitted

    ![DMS](./images/dms-008.png "The job collect the ADM has been submitted")

    **Tips**: Right click on **View Job Details** link and select **Open Link in New Tab** to follow the process in another Web browser tab

12. Once the job completes, the `EMPLOYEE_ADM` will no longer be in a locked, uneditable status. Check the status by refreshing this page (**refresh icon**) and move forward when the Most Recent Jobs Status of the `Employee_ADM` has "**Succeeded**"!

## Task 2: Enhance the Meta-Model

1. Once you've created the ADM in Step 1, highlight the *`Employee_ADM`* Model and click the [**Edit**] button

    ![DMS](./images/dms-009.png "Edit Employee_ADM Model")

2. You may be asked for the database credentials. If so, select the **Named** radio button, choose the default credential using the *`DMS_ADMIN`* username and click [**Continue**]

    ![DMS](./images/dms-010.png "Database credentials")

3. In the **Edit Application Data Model** screen, notice the applications for `EMPLOYEESEARCH_DEV` have been created based on the schema. Expand the entire list of tables associated with these applications (Menu **View** and Submenu **Expand All**)

    ![DMS](./images/dms-011.png "List of tables associated with these applications")

4. Now view the referential relationships captured in the ADM by clicking the tab **Referential Relationships**. Expand the entire list of applications (Menu **View** and Submenu **Expand All**) to examine the referential relationships under each application. Now that Cloud Control is aware of the foreign keys, it will automatically apply the same format masks to child tables

    ![DMS](./images/dms-012.png "View the referential relationships")

5. **CAUTION: THIS PORTION IS FOR WORKBOOK REVIEW ONLY AND SHOW THE STEPS NEEDED TO MANUALLY ASSIGN A FOREIGN KEY. YOU DO NOT NEEED TO PERFORM THIS!**
    - If the database manages the referential relationships, the ADM will automatically capture these. However, if these are managed by the application, you will need to define these manually

    - If it is necessary to define a Referential Relationships, click the [**Add**] button provide the details. In your case, there is an additional table named `DEMO_HR_USERS` that is part of the `EMPLOYEESEARCH_DEV` application, but all of its constraints are enforced by the application and NOT in the database

        ![DMS](./images/dms-013.png "Define a Referential Relationships")

    - The `DEMO_HR_USERS` table uses **USERID**, but the relationship is not registered in the database as a foreign key constraint. Therefore, you must add a Dependent column on the `USERID` column

        ![DMS](./images/dms-014.png "Define a Referential Relationships")

    - Click [**OK**]

    - The new relation is available in the referential relationships view of your ADM, and now that Cloud Control is aware of the foreign keys, it will automatically apply the same format masks to child tables

        ![DMS](./images/dms-015.png "Define a Referential Relationships")

6. Click [**Save and Return**]

7. Now, your ADM is created!

## Task 3: Use Pre-Defined Sensitive Column Types

1. Navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Application Data Modeling** as follow:

    ![DMS](./images/dms-002.png "Navigate to the Application Data Models")

2. Look at the list of Sensitive column types. Click the menu **Actions** and select the sub-menu **Sensitive Column Types**

    ![DMS](./images/dms-016.png "List of Sensitive column types")

3. Review the Sensitive Column Discovery Templates that are shipped by default with the Data Masking Pack.

    As an example, by hovering over the name *`EMAIL_ID`*, review this template to understand what this Sensitive Column Type will do when using it:
    - Search for '`EMAIL`' or '`MAIL`' in the Column Name
    - Search for '`EMAIL`' or '`MAIL`' in the Column Comment
    - Apply a regular expression pattern match to all of the Column Data if the user (i.e. `DMS_ADMIN`) has access to the data

        ![DMS](./images/dms-017.png "Example of sensitive column type")

        **Note**:
        - This process uses Oracle Regular Expressions which is compatible with the IEEE Portable Operating System Interface (POSIX) regular expression standard and to the Unicode Regular Expression Guidelines of the Unicode Consortium
        - In this case, the **Search Type** has been set as an **Or** condition, so if any of the conditions listed above are met, it will result in a match

## Task 4: Create a New Sensitive Column Type

1. Navigate to the sub-menu **Sensitive column types** as described in Step 3 previously and click [**Create...**] to add a custom Sensitive Column Type

    ![DMS](./images/dms-018.png "Navigate to the sub-menu Sensitive column types")

2. Create a Sensitive Column Type that will look for the wildcard "**NAME**" as part of the Column Name or the Column Comment:
    - Name: *`NAME`*
    - Description: *`Search for NAME in either the Column Name or in the Column Comment`*
    - Column Name: *`*NAME*`*
    - Column Comment: *`*NAME*`*

        ![DMS](./images/dms-019.png "Create a Sensitive Column Type")

    - Click [**OK**]
    - Here is the newly created Sensitive Column Type

        ![DMS](./images/dms-020.png "Create a Sensitive Column Type")

## Task 5: Create a New Sensitive Column Type using Pre-Defined Templates

1. Navigate to the sub-menu **Sensitive column types** as described in Step 3 previously and select the Sensitive Column Type template that you want to duplicate (here `EMAIL_ID`)

    ![DMS](./images/dms-021.png "Navigate to the sub-menu Sensitive column types")

2. Click [**Create Like...**]

3. Create the customized Sensitive Column Type "`EMAIL_ORA`" to identify the email from "oracle.com"
    - Name: *`EMAIL_ORA`*
    - Description: *`Search for EMAIL from Oracle Corp`*
    - Column Name: *`EMAIL.*;MAIL.*`*
    - Column Comment: *`EMAIL.*;MAIL.*`*
    - Column Data: *`^[a-zA-Z0-9._%+-]+@oracle[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$`*

        ![DMS](./images/dms-022.png "Create a customized Sensitive Column Type")

    - Click [**OK**]
    - Here is the newly created Sensitive Column Type

        ![DMS](./images/dms-023.png "Create a customized Sensitive Column Type")

## Task 6: Create a New Masking Format

1. To create a masking format in the format library, navigate to the Data Masking Formats page from the menu **Enterprise > Quality Management > Data Masking Formats Library** as follow:

    ![DMS](./images/dms-024.png "Create a masking format in the format library")

    **Note**: Alternatively if you are in Database Home page, select "**Data Masking Format Library**" from the schema menu

2. **Format library** appears with predefined formats that Oracle Enterprise Manager Provides

    ![DMS](./images/dms-025.png "Format library")

3. Click [**Create**] to define a new use defined masking format

    ![DMS](./images/dms-026.png "Define a new use defined masking format")

4. Provide required information for the new format:
  - Name: *`Mask Oracle Corp Email`*
  - Sensitive Colum Type: *`EMAIL_ORA`*
  - Description: *`Mask the Oracle Corp email by changing prefix and domain name`*

    ![DMS](./images/dms-027.png "Provide required information for the new format")

  - Add the formats entries types from the Add list, here:
      - Select **Random Strings** and click [**Go**]

        ![DMS](./images/dms-028.png "Add the formats entries types")

          - Mention the **start length** (here "*`6`*") and **end length** (here "*`8`*") in the Edit Format screen of Format Library

            ![DMS](./images/dms-029.png "Add the formats entries types")

          - Click [**OK**]

      - Select **Fixed String** and click [**Go**]

        ![DMS](./images/dms-030.png "Add the formats entries types")

          - Mention the string you want to add (here "*`@ercoal.com`*")

            ![DMS](./images/dms-031.png "Add the formats entries types")

          - Click [**OK**]

    **Note**:
    - When you will use this masking algorithm, it will replace the initial value by a new value generated from the concatenation of a random string of 6 to 8 characters at the beginning, followed by the fixed value `@ercoal.com`
    - At the bottom, you can see examples of the new values will be used

        ![DMS](./images/dms-032.png "Examples of the new values will be used")

  - Click [**OK**]
  - Here is the newly created Masking Format

    ![DMS](./images/dms-033.png "Newly created Masking Format")

## Task 7: Manually Identify Sensitive Columns

1. Navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Application Data Modeling** as follow:

    ![DMS](./images/dms-002.png "Navigate to the Application Data Models")

2. Select the *`Employee_ADM`* Model and click [**Edit...**]

    ![DMS](./images/dms-034.png "Edit the Application Data Models")

3. You may be asked for the database credentials. If so, select the **Named** radio button, choose the default credential using the *`DMS_ADMIN`* username and click [**Continue**]

    ![DMS](./images/dms-010.png "Database credentials")

4. Select the **Sensitive Columns** tab

    ![DMS](./images/dms-036a.png "Select the Sensitive Columns tab")

5. Currently, there are no sensitive columns discovered so you must initiate a search. Click the option to **Create Discovery Job...**

    ![DMS](./images/dms-036b.png "Create Discovery Job")

6. Provide the parameters for the sensitive columns discovery job. Choose the *`EMPLOYEESEARCH_DEV`* schema and choose the following Sensitive Column Types:
    - *`CREDIT_CARD_NUMBER`*
    - *`EMAIL_ORA`*
    - *`IP_ADDRESS`*
    - *`NAME`*
    - *`NATIONAL_INSURANCE_NUMBER`*
    - *`PHONE_NUMBER`*
    - *`SOCIAL_INSURANCE_NUMBER`*
    - *`SOCIAL_SECURITY_NUMBER`*
    - *`UNIVERSAL_PRODUCT_CODE`*

    ![DMS](./images/dms-037.png "Provide the parameters for the sensitive columns discovery job")

7. Click [**Continue**] to perform the search

8. And click [**Submit**] to run the job

    ![DMS](./images/dms-038.png "Run the job")

9. The job discover the Sensitive Data has been submitted

    ![DMS](./images/dms-039.png "Job discovers the Sensitive Data")

    **Tips**: Right click on **View Job Details** link and select **Open Link in New Tab** to follow the process in another Web browser tab

10. Once the job completes, click [**Discover Results...**]

    ![DMS](./images/dms-040.png "Discover Results")

11. Click "**View**" the "**Expand All**" to review the Sensitive Column Discovery Results

    ![DMS](./images/dms-041a.png "Discover Results")

12. Notice that the Sensitive Status of these columns is currently set to **Undefined** and now you have to set the sensitive status of all columns to **Sensitive** that you want to mask

    ![DMS](./images/dms-041b.png "Discover Results")

    - Select each identified sensitive column entry that you want to mask, for this lab select the columns:
    
        - *`DEMO_HR_SUPPLEMENATL_DATA.PAYMENT_ACCT_NO`*
        - *`DEMO_HR_EMPLOYEES.EMAIL`*
        - *`DEMO_HR_USERS.EMAIL`*
        - *`DEMO_HR_EMPLOYEES.FIRST_NAME`*
        - *`DEMO_HR_EMPLOYEES.LAST_NAME`*
        - *`DEMO_HR_EMPLOYEES.SSN`*
    
            ![DMS](./images/dms-042a.png "DMS")

    - Click [**Set Sensitive Status**] menu item and select "*`Sensitive`*"

        ![DMS](./images/dms-042b.png "Discover Results")

        **Note**: Upon successful completion, you should see all "`UNDEFINED`" labels toggle to "`SENSITIVE`"

        ![DMS](./images/dms-042c.png "Discover Results")

13. Click [**OK**]

14. Here is the result expected:

    ![DMS](./images/dms-043.png "Discover Results")

15. Click [**Save and Return**]

16. Your sensitive data are now identified!

## Task 8: Create Data Masking Definitions

1. Navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Data Masking Definitions** as follow:

    ![DMS](./images/dms-044.png "Navigate to the Application Data Models")

2. Click on the [**Create**]

    ![DMS](./images/dms-044b.png "Create Masking Definition")

3. From the **Create Masking Definition** screen, fill it as follow:
    - Name: *`EMPLOYEE_DATA_MASK`*
    - Application Data Model: *`Employee_ADM`*
    - Reference Database: *`cdb1_pdb1`*
    - Description: *`Mask Employee Sensitive Data`*

    ![DMS](./images/dms-045.png "Create Masking Definition")

4. Click [**Add**]

    ![DMS](./images/dms-045b.png "Create Masking Definition")

5. You may be asked for the database credentials, if so, select the **Named** radio button and choose the default credential using the *`DMS_ADMIN`* username and click [**Login**]

    ![DMS](./images/dms-046.png "Database credentials")

6. Click [**Search**] to search for all of the identified and tagged "**Sensitive**" columns in Step 7 previously

    ![DMS](./images/dms-047.png "Search all the Sensitive columns")

7. Tick the checkboxes to select all the columns

    ![DMS](./images/dms-048.png "Search all the Sensitive columns")

8. Click [**Add**]

9. All the columns appear in the Masking Definition page

    ![DMS](./images/dms-049.png "All the Sensitive columns")

10. The next step is to format columns by clicking the **Define Format** icon:

    ![DMS](./images/dms-050.png "Define Format")

    **Note** Colums that have this icon do not have a masking format defined

## Task 9: Format Columns Using the Format Library and Masking Primitive

As previously discussed, there are many different options to format the column of data to ensure the quality of the data masking and in this lab you will see few of them

1. Let's have a look on how to use the "**Format Library**"

    - In the Data Masking Definitions page definied previously in Step 8, select *`DEMO_HR_EMPLOYEES.EMAIL`* row
    
        ![DMS](./images/dms-051.png "Define Format")

    - Click on the **Define Format** icon

        ![DMS](./images/dms-050.png "Define Format")

    - To use an existing format from the Format Library, click on the [**Import Format**] button

        ![DMS](./images/dms-052.png "Import Format")

    - In this particular example, we are going to select the Masking Format "*`Mask Oracle Corp Email`*" we've defined ourselves previously in Step 6

        ![DMS](./images/dms-053.png "Select the Masking Format")

    - Click [**Import**]

    - You can see the algorythmic sequence

        ![DMS](./images/dms-054.png "See the algorythmic sequence")

    - Click on the **Sample** icon to check the generated masked value

        ![DMS](./images/dms-054b.png "Check the generated masked value")

        **Note** Here, we will take a random value from the same column

        ![DMS](./images/dms-054c.png "Take a random value from the same column")
    
    - Click [**OK**]

    - Once a masking format is defined, the **Define Format** icon is replaced by the **Edit Format** icon: this means that you can change the format later if you wish

        ![DMS](./images/dms-055.png "The Define Format icon is replaced by the Edit Format icon")

2. Now, let's have a look on how to use a **pre-defined masking format**

    - Select *`DEMO_HR_EMPLOYEES.FIRSTNAME`* row and click on the **Define Format** icon to define its masking format
    
        ![DMS](./images/dms-055b.png "Define the masking format")

    - Select **Shuffle** from the drop down list box

        ![DMS](./images/dms-056.png "Select Shuffle")

    - Click [**Add**]

    - Click on the **Sample** icon to check the generated masked value

        ![DMS](./images/dms-057.png "Check the generated masked value")

    - Click [**OK**]

        ![DMS](./images/dms-058.png "Validate")

        **Note** Now, the masking format is defined for this column 

3. Let's use the same **Shuffle** algorythm for the `LASTNAME` column but this one according to the `FIRSTNAME` column value in order to keep the consistence of the employee identity for the app. Of course in real life we won't do that, but here we only want to show you how to associate a masking value to another

    - Select *`DEMO_HR_EMPLOYEES.LASTNAME`* row and click on **Define Format** icon

        ![DMS](./images/dms-058b.png "Define Format")

    - Select **Shuffle** from the drop down list box

        ![DMS](./images/dms-056.png "Select Shuffle")

    - Click [**Add**]

    - Click on the **Search** icon

        ![DMS](./images/dms-059.png "Search icon")

    - In the Search window, enter *`FIRST`* as value in the **Column Name** and click [**Go**]

        ![DMS](./images/dms-059b.png "Search value")

    - Select *`FIRSTNAME`* and click [**Select**]

        ![DMS](./images/dms-059c.png "Search value")

        **Note**:
        - Here, we take the value of `LASTNAME` associated to the `FIRSTNAME` value which has been attributed randomly previoulsy
        - You can only use another column from the same table, but in that case, be sure that the Datatype is similar

    - Click on the **Sample** icon to check the generated masked value

        ![DMS](./images/dms-059d.png "Check the generated masked value")

        **Note** Here, a random value from the column `FIRSTNAME` is taken

    - Click [**OK**]

        ![DMS](./images/dms-059e.png "Validate icon")

        **Note** Now, the masking format is defined for this column 

4. Now, let's define our own **customised masking format** ("`999-999-999`" where digits are randomly attributed)

    - Select *`DEMO_HR_EMPLOYEES.SSN`* row and click on **Define Format** icon
    
        ![DMS](./images/dms-060.png "Define Format")
    
    - Select **Random Digits** from the drop down list box and click [**Add**]

        ![DMS](./images/dms-061.png "Define Format - Value")

    - Enter "*`3`*" for **Start Length** and **End Length**

        ![DMS](./images/dms-062.png "Define Format - Value")

    - Select **Fixed String** from the drop down list box and click [**Add**]

        ![DMS](./images/dms-063.png "Define Format - Value")

    - Enter "*`-`*" for value

        ![DMS](./images/dms-064.png "Define Format - Value")

    - Select **Random Digits** from the drop down list box and click [**Add**]

        ![DMS](./images/dms-061.png "Define Format - Value")

    - Enter "*`3`*" for **Start Length** and **End Length**

        ![DMS](./images/dms-065.png "Define Format - Value")

    - Select **Fixed String** from the drop down list box and click [**Add**]

        ![DMS](./images/dms-063.png "Define Format - Value")

    - Enter "*`-`*" for value

        ![DMS](./images/dms-066.png "Define Format - Value")

    - Select **Random Digits** from the drop down list box and click [**Add**]

        ![DMS](./images/dms-061.png "Define Format - Value")

    - Enter "*`3`*" for **Start Length** and **End Length**

        ![DMS](./images/dms-067.png "Define Format - Value")

    - Click on the **Sample** icon to check the generated masked value

        ![DMS](./images/dms-068.png "Check the generated masked value")

    - Click [**OK**]

        ![DMS](./images/dms-069.png "Validate")

        **Note** Now, the masking format is defined for this column 

5. Now, let's use another masking format from "**Format Library**" that Oracle provides: the "**Generic Credit Card**"

    - Select *`DEMO_HR_SUPPLEMENTAL_DATA.PAYMENT_ACCT_NO`* row and click on **Define Format** icon

        ![DMS](./images/dms-070a.png "Define Format")

    - Click on the [**Import Format**]

        ![DMS](./images/dms-070b.png "Import Format")

    - Select the **Generic Credit Card Number** radio button

        ![DMS](./images/dms-070c.png "Generic Credit Card Number")

    - Click [**Import**]

        ![DMS](./images/dms-070d.png "Import")

        **Note**: Here, this pre-defined library uses the Function `MGMT_DM_GEN_ANYC` of the Package `DBSNMP.DM_FMTLIB`

    - Please, be sure your algorithm is correctly set with right Package Name `DBSNMP.DM_FMTLIB` and Function Name `MGMT_DM_GEN_ANYC`

        ![DMS](./images/dms-070e.png "Be sure your algorithm is correctly set")

        **Note**: If not, you will have an error when you will click [OK]!

        ![DMS](./images/dms-070f.png "Be sure your algorithm is correctly set")

    - Click on the **Sample** icon to check the generated masked value

        ![DMS](./images/dms-070g.png "Check the generated masked value")

        **Note** Here, a random "true-false" generic credit card number is generated!

    - Click [**OK**]

        ![DMS](./images/dms-070h.png "Validate")

        **Note** Now, the masking format is defined for this column 

6. Finally, we’ll define another **list-based custom masking format** ("`<List1>@<List2>`" where values are randomly attributed by only using values within the lists set)

    - Select *`DEMO_HR_USERS.EMAIL`* row and click on the **Define Format** icon

        ![DMS](./images/dms-071.png "Define Format")

    - Select **Array List** from the drop down list box and click [**Add**]

        ![DMS](./images/dms-071b.png "Define Format - Value")

    - Enter "*`mask0,mask1,mask2,mask3`*" as **List of Values**

        ![DMS](./images/dms-072.png "Define Format - Value")

    - Select **Fixed String** from the drop down list box and click [**Add**]

        ![DMS](./images/dms-065.png "Define Format - Value")

    - Enter "*`@`*" for value

        ![DMS](./images/dms-073.png "Define Format - Value")

    - Select **Array List** from the drop down list box and click [**Add**]

        ![DMS](./images/dms-071b.png "Define Format - Value")

    - Enter "*`mail.com,look.com,ux.net,boot.org`*" as **List of Values**

        ![DMS](./images/dms-074.png "Define Format - Value")

    - Click on the **Sample** icon to check the generated masked value

        ![DMS](./images/dms-075.png "Check the generated masked value")

    - Click [**OK**]

        ![DMS](./images/dms-076.png "Validate")

54. Now click [**OK**] to complete the creation of a Masking Definition

    ![DMS](./images/dms-077.png "Complete the creation of a Masking Definition")

## Task 10: Generate Data Masking Scripts

1. Once you've defined all the data masking formats in Step 9, the status of your masking definition is "**Script Not Generated**"

    ![DMS](./images/dms-078.png "Default status of your masking definition")

    **Note**: This status means that you have to generate now the script before executing the masking of your sensitive data

2. Select the masking definition *`EMPLOYEE_DATA_MASK`* and click on the [**Generate Script**] button

    ![DMS](./images/dms-079.png "Generate Script")

    **Note**:
    - Enterprise Manager Cloud Control 13c may route the submission as a submitted Job
    - In that event, choose the **Named** credential for `DMS_ADMIN` and click [**Login**] or [**Continue**]

        ![DMS](./images/dms-010.png "Database crédentials")

3. In the **Script Generation Options** section, tick the masking mode you want (here *Mask In-Database*):

    ![DMS](./images/dms-080.png "Script Generation Options")

    **Note**:
    - **Mask In-Database** to replace sensitive directly inside the database. Usually, you will execute this script into a copy of the Production DB
    - **Mask In-Export** to generate from the source database an Oracle Data Pump file including the masked data. Usually, you will execute this script from Production DB

4. In the **Database Credentials** section, check the *`Named`* option and select *`DMS_ADMIN`* for Credential Name

    ![DMS](./images/dms-081.png "Database Credentials")

5. In the **Start** section, make sure *`Immediately`* is ticked and click [**Submit**]

    ![DMS](./images/dms-082.png "Script Generation Options")

6. To follow the status of your job, refresh the screen by clicking [**Go**]

    ![DMS](./images/dms-083.png "Follow the status of your job")

7. During the script generation, the status will change from "**Script Generation Job Scheduled**"...

    - ... to "**Generating Script**"

        ![DMS](./images/dms-084.png "Generating Script")

    - ... to "**Script Generated**"

        ![DMS](./images/dms-084b.png "Script Generated")

    - Once the job has been successfully generated, the masking script is ready to be executed

        ![DMS](./images/dms-084c.png "The masking script is ready to be executed")

8. To view the **Script Generation Results** page, make sure the radio button next to `EMPLOYEE_DATA_MASK` is selected and from **Actions**, select **View Script** and click [**Go**]

    ![DMS](./images/dms-085.png "Script Generation Results")

9. Have a look over the PL/SQL generated script

    ![DMS](./images/dms-086.png "PL/SQL generated script")

    **Note**:
    - Oracle Data Masking Pack **performs a series of validation steps** to ensure that the data masking process proceeds to a successful completion without errors. One of the checks that it performs is **validating the masking formats**. This is a necessary step in the data masking process to ensure that the chosen masking formats meet the database and application integrity requirements
    - These requirements may include generating unique values for the column being masked because of uniqueness constraints or generating values that meet the column length or type requirements
    - Upon successful completion of the validation check, Oracle Data Masking Pack **generates the PL/SQL-based masking script that is transferred to the target database for execution**
    - Oracle Data Masking Pack uses a highly efficient and robust mechanism to create masked data
    - Oracle Data Masking Pack **performs bulk operations** to rapidly replace the table containing sensitive data with an identical table containing masked data while retaining the original database constraints, referential integrity and associated access structures, such as INDEXs and PARTITIONs, and access permissions, such as GRANTs
    - Unlike masking processes that are traditionally slow because they perform table updates, Oracle Data Masking Pack takes advantage of the built-in optimizations in the database to **disable database logging** and **execute in parallel** to quickly create a masked replacement for the original table
    - The original table containing sensitive data is dropped from the database completely and is no longer accessible

    **Tips**:
    - This script could be taken and executed on other targets which have exactly the same schema structure
    - You have the ability to save the script locally by clicking [**Save Script**]

        ![DMS](./images/dms-087.png "PL/SQL generated script")

10. Click [**Return**] to return to the Data Masking Definitions screen

11. **Now, your Data Masking script is ready to be used!**

## Task 11: Execute the Data Masking Scripts

### **Warning: SSH Key-pair pre-requisites**

To execute the Data Masking script you will need an SSH key-pair and **DO  NOT** use a putty key-pair, instead follow the instructions below to create an RSA key-pair

1. **Only if YOU ARE USING the remote desktop embedded!** If not, please skip this step

    - Generate SSH Keys

        - From your remote desktop session, open a terminal window and run the following to generate the key pair

            ```
            <copy>
            cd ~
            ssh-keygen -b 2048 -t rsa
            </copy>
            ```

        - Accept defaults for file and passphrase by pressing *Enter* three times to create a key with no passphrase.

            ![DMS](./images/ssh-key-gen.png "Generate SSH Keys")

        - Update *`~/.ssh/authorized_keys`* and copy the *private key* to */tmp*.

            ```
            <copy>
            cd .ssh
            cat id_rsa >/tmp/rsa_priv
            cat id_rsa.pub >>authorized_keys
            </copy>
            ```

    - Update the Named Credentials with the new SSH Key

        - From the EM Console as *SYSMAN*, navigate to "*Setup menu > Security > Named Credential*" and Select *`OS_ORACLE_SSH`* credential;

        - Click [**Edit**]
        
        - Replace the existing entry with the *SSH Private Key* you copied to *"/tmp"*
        
        - Keep the General section unchanged and update the *Credential Properties* as followed:

            - Username: *oracle*
            - Delete any content from *SSH Public Key* Textbox
            - Delete any content from *Run as* Textbox (no delegated sudo privilege needed)
            - Click [**Browse**] to select the *Private Key*

                ![DMS](./images/update_ssh_creds-1.png "Update the Named Credentials with the new SSH Key")

        - On the file browser, navigate to *"+Other Locations >> tmp"* and select the file *rsa_priv*

            ![DMS](./images/update_ssh_creds-2.png "Select the file rsa_priv")

        - Click *Test and Save*

            ![DMS](./images/update_ssh_creds-3.png "Test and Save the Named Credentials with the new SSH Key")
            ![DMS](./images/update_ssh_creds-4.png "Test and Save the Named Credentials with the new SSH Key")

2. **Only if YOU ARE NOT USING the remote desktop embedded!** If not, please skip this step

    - **Make sure you can R/W files to your DBSecLab VM** from the OEM Console by selecting the menu "*Setup > Security > Named Credentials*"

      ![DMS](./images/dms-201.png "Make sure you can R/W files to your DBSecLab VM")

    - Select *`OS_ORACLE_SSH`* named credential

      ![DMS](./images/dms-202.png "Select OS_ORACLE_SSH named credential")

     - Click [**Edit**]

    - We have already pre-configured this Named Credential for you but **you have to put your own SSH Private Key to enable it**!
        - In the section **Credential Properties**, load your *`SSH Private Key`*
        - Remember, this key must be *`in RSA format`*, so please **open your own "SSH Private Key" file, copy the content and paste it here**!

          ![DMS](./images/dms-203.png "Copy/Paste the content of your own SSH Private Key file")

    - Click [**Test and Save**]

      ![DMS](./images/dms-204.png "Test and Save")

    - Your connection has to be successful, if not please make sure your SSH Private Key is the correct one

      ![DMS](./images/dms-205.png "Make sure your SSH Private Key is the correct one")

### **Execute the Data Masking Scripts**

3. Now, go back to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Data Masking Definitions** as follow:

    ![DMS](./images/dms-044.png "Navigate to the Application Data Models")

4. Select *`EMPLOYEE_DATA_MASK`* and click [**Schedule Job**]

    ![DMS](./images/dms-087b.png "Schedule Job")

    **Note**: This action will run the masking operation on your target database

5. Select the masking mode used during the script generating phase previously

    - Here, select "*`Mask In-Database`*"
    - And tick "*`The selected target is not a production database.`*"

        ![DMS](./images/dms-088.png "Select the masking mode")

        **Note**: If you don't tick it, the script will not be executed!

6. In the **Data Mask Options** section, enter:
    - Script File Location: *`/home/oracle/DBSecLab/livelabs/dms`*
    - Script File Name: *`mask_empdata_in-db_<your_timestamp>.sql`*

        ![DMS](./images/dms-089.png "Select the masking script target location")

        **Note**: The masking script file will be stored in this directory on **DBSecLab VM** and can be reused as many times as you need

7. Configure access permissions
    - In the **Host Credentials** section, check the *`Named`* option and select *`OS_ORACLE_SSH`* for Credential Name

        ![DMS](./images/dms-090a.png "Configure access permissions")
    
    - Click on **More Details**

        ![DMS](./images/dms-090b.png "Configure access permissions")

    - And click on [**Test**]

        ![DMS](./images/dms-090c.png "Test your access permissions")

    **Note**:
    - This test must be succeeded!
    - If not, please go back to step 1 or 2 above according your situation

    - In the **Database Credentials** section, check the *`Named`* option and select *`DMS_ADMIN`* for Credential Name

        ![DMS](./images/dms-090d.png "Database Credentials")

8. Click [**Submit**]

9. Once you submit the job, right-click on **Masking Job Executing** link and select **Open Link in New Tab** to follow the script execution

    ![DMS](./images/dms-091.png "Masking Job Executing")

10. Refresh the "**Job** page until the end of the process

    ![DMS](./images/dms-091b.png "Masking Job Executing")

 11. Once the job is successfully completed, go back to the Data Masking Definitions screen and click [**Go**] to refresh the status of the job
 
    ![DMS](./images/dms-083.png "Masking Job Executing")
 
    **Note**: The status should be **Masking Job Succeeded**!

    ![DMS](./images/dms-092.png "Masking Job Succeeded")

12. **Now, your sensitive data has been masked!**

## Task 12: Compare the Pre-Masked Data vs. the Post-Masked Data

1. Once the job successfully completes, query the masked data in the Development and Production environments for a before and after comparison

2. Open **SQL Developer** on your PC and connect to **pdb1 as SYSTEM**

    ![DMS](./images/dms-093.png "Open SQL Developer")

3. Press [**Alt**]+[**F10**] to open a SQL Worksheet and select `PDB1_SYSTEM`

    ![DMS](./images/dms-094.png "Open a SQL Worksheet")

4. Do it again in order to have 2 tabs

5. In the first one, copy the following queries for the **PROD: BEFORE MASKING**

    ````
    <copy>
    -- -----------------------------
    -- PROD: BEFORE MASKING
    -- -----------------------------

    -- EMPLOYEE_DATA
    SELECT distinct(e.userid), e.firstname, e.lastname, e.email, e.ssn, sd.payment_acct_no
      FROM EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES e, EMPLOYEESEARCH_PROD.DEMO_HR_SUPPLEMENTAL_DATA sd
     WHERE e.userid = sd.userid
       AND e.ssn is not null
     ORDER BY 1;

    -- USERS_DATA
    SELECT userid, email
      FROM EMPLOYEESEARCH_PROD.DEMO_HR_USERS
     ORDER BY 1;

    </copy>
    ````

    ![DMS](./images/dms-097.png "Queries for the PROD (BEFORE MASKING)")

6. In the second one, copy the following queries for the **DEV: AFTER MASKING**

    ````
    <copy>
    -- -----------------------------
    -- DEV: AFTER MASKING
    -- -----------------------------

    -- EMPLOYEE_DATA
    SELECT distinct(e.userid), e.firstname, e.lastname, e.email, e.ssn, sd.payment_acct_no
      FROM EMPLOYEESEARCH_DEV.DEMO_HR_EMPLOYEES e, EMPLOYEESEARCH_DEV.DEMO_HR_SUPPLEMENTAL_DATA sd
     WHERE e.userid = sd.userid
       AND e.ssn is not null
     ORDER BY 1;

    -- USERS_DATA
    SELECT userid, email
      FROM EMPLOYEESEARCH_DEV.DEMO_HR_USERS
     ORDER BY 1;

    </copy>
    ````

    ![DMS](./images/dms-098.png "Queries for the DEV (AFTER MASKING)")

7. **Execute all these queries** and **compare the results** to confirm your sensitives data have been masked

    - Employee Data:
        - **BEFORE masking** (in PROD)

            ![DMS](./images/dms-099.png "Employee data BEFORE masking (in PROD)")

        - **AFTER masking** (in DEV)

            ![DMS](./images/dms-100.png "Employee data AFTER masking (in DEV)")

    - Users Data:
        - **BEFORE masking** (in PROD)

            ![DMS](./images/dms-101.png "Users data BEFORE masking (in PROD)")

        - **AFTER masking** (in DEV)

            ![DMS](./images/dms-102.png "Users data AFTER masking (in DEV)")

8. As you can see, the masked data is quite different from the original sensitive data and you can now share it without worrying!

## Task 13: Create Data Subsetting Definitions

1. Navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Data Subsetting Definitions** as follow:

    ![DMS](./images/dms-130.png "Navigate to the Application Data Models")

2. From the Data Subsetting Definitions Dialog, click [**Create**] to begin the process of subsetting data

    ![DMS](./images/dms-130b.png "Begin the process of subsetting data")

3. From the **Data Subsetting Definition Properties** screen, fill it as follow:
    - Name: *`EMPLOYEE_DATA_SUBSET`*
    - Description: *`Subset Employee Data`*
    - Application Data Model: *`Employee_ADM`*
    - Source Database: *`cdb1_pdb1`*

        ![DMS](./images/dms-131.png "Subsetting Definition Properties")

4. Click [**Continue**]

5. In the **Credentials"** section, select the **Named** radio button, choose the default credential using the `DMS_ADMIN` username

    ![DMS](./images/dms-132.png "Database credentials")

6. Click [**Submit**]

7. Now your Subsetting definition is scheduling... please refresh the page until you see "**Succeeded**"

    ![DMS](./images/dms-133.png "Subsetting definition is scheduling")

8. Once the subsetting definition is created, select it and click on [**Edit...**]

    ![DMS](./images/dms-134.png "Edit the Subsetting definition")

9. In the "**Applications**" tab, select the schema `EMPLOYEESEARCH_DEV(EMPLOYEESEARCH_DEV)` available in your ADM

    ![DMS](./images/dms-135.png "Select the schema")

10. In the "**Object Rules**" tab, create all the Subset rules by clicking [**Create**] as many time as needed

    ![DMS](./images/dms-136.png "Create all the Subset rules")

    Here, we will create 4 Object Rules, so in the "Create Object Rule" screen proceed like this...

    - ... for `DEMO_HR_EMPLOYEES` table, because this a dataset table, we will keep only **25% of rows**
        - In "Objects", select **Specified** and choose "*`DEMO_HR_EMPLOYEES`*"
        - In "Rows to Include", select **Some Rows** and put "*`25`*"
        - Tick "**Include Related Rows**" and select "**Ancestor and Descendant Objects**"

            ![DMS](./images/dms-137.png "... for DEMO_HR_EMPLOYEES table")

        - Click [**OK**]

    - ... for `DEMO_HR_ERROR_LOG` table, because this is a log table we will keep **0% of rows**
        - In "Objects", select **Specified** and choose "*`DEMO_HR_ERROR_LOG`*"
        - In "Rows to Include", select **Rows Where** and put "*`1=0`*" (here this condition allow to extract 0 rows!)
        - Tick "**Include Related Rows**" and select "**Ancestor and Descendant Objects**"

            ![DMS](./images/dms-138.png "... for DEMO_HR_ERROR_LOG table")

        - Click [**OK**]

    - ... for `DEMO_HR_ROLES` table, because this a reference table, we will keep **100% of rows**
        - In "Objects", select **Specified** and choose "*`DEMO_HR_ROLES`*"
        - In "Rows to Include", select **All Rows**
        - Tick "**Include Related Rows**" and select "**Ancestor and Descendant Objects**"

            ![DMS](./images/dms-139.png "... for DEMO_HR_ROLES table")

        - Click [**OK**]

    - ... for `DEMO_HR_USERS` table, because this a reference table, we will keep **100% of rows**
        - In "Objects", select **Specified** and choose "*`DEMO_HR_USERS`*"
        - In "Rows to Include", select **All Rows**
        - Tick "**Include Related Rows**" and select "**Ancestor and Descendant Objects**"

            ![DMS](./images/dms-140.png "... for DEMO_HR_USERS table")

        - Click [**OK**]

    - Now, you should see all your Object Rules like this

        ![DMS](./images/dms-141.png "List of your Object Rules")

11. In the **Space Estimate** tab, expand the entire list (Menu **View** and Submenu **Expand All**)

    ![DMS](./images/dms-142.png "Space Estimate")

    **Note:**
    - Here, you can see a simulation of the effects of your subsetting scripts
    - The "Object Rule" column shows you the "Object Rules" defined previously
    - Like that you can see easily the direct impact on the subset size targeted (in MB and in number of rows)
    - Because the tables are dependant each other, you see the effect of your subsetting on the parent-child tables. In this example, `DEMO_HR_EMPLOYEES` keep only 25% of rows, but because there's a dependance with `DEMO_HR_SUPLLEMENTAL_DATA` table, this one is also impacted by the subsetting and it will keep only 71%.

12. You can stop here if you just want to subset your data, but we will continue by **associating the Data Masking scripts** generated previously in Step 11 to show that is possible to combine the subsetting and the masking in a same process

    - In the **Data Masking Definitions** tab, click [**Add**]

        ![DMS](./images/dms-143.png "Data Masking Definitions")

    - Select the masking définition *`EMPLOYEE_DATA_MASK`* created earlier

        ![DMS](./images/dms-144.png "Data Masking Definitions")

    - Click [**OK**]

    - Now, you Data Masking script is associated to you Data Subsetting definition and it will be executed after subsetting your data

        ![DMS](./images/dms-145.png "Data Masking Definitions is associated")

13. Click [**Return**] to return to the Data Subsetting Definitions screen

14. **Now, your Data Subsetting script is ready to be used!**

## Task 14: Execute Data Subsetting Scripts

Once you've defined all the data subsetting definitions in Step 13, it's time to execute the Subsetting scripts

1. But before, because you have masked data in Task 11 above, you have to restore the `EMPLOYEESEARCH_DEV` tables on **pdb1** by cloning data from `EMPLOYEESEARCH_PROD` schema to have original data

    - Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

        ````
        <copy>sudo su - oracle</copy>
        ````

        **Note**: Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle, so, in that case **you don't need to execute this command**!

    - Go to the scripts directory

        ````
        <copy>cd $DBSEC_LABS/dms</copy>
        ````

    - Reset the `EMPLOYEESEARCH_DEV` data as it was before masking

        ````
        <copy>./dms_restore_pdb1_dev.sh</copy>
        ````

        ![DMS](./images/dms-150.png "Restore original data")

2. Now, go back to the OEM Console and navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Data Subsetting Definitions**

    ![DMS](./images/dms-130.png "Navigate to the Application Data Models")

3. From the Data Subsetting Definitions Dialog

    - Select the *`EMPLOYEE_DATA_SUBSET`* subsetting definition and select **Action** menu

        ![DMS](./images/dms-151.png "Select Subsetting definition")

    - Select **Generate Subset...**

        ![DMS](./images/dms-152.png "Generate Subset script")

4. In the "**Generate Subset: General**" screen

    - In "Create Subset By", select "*`Deleting Data From a Target Database`*" (this is similar than the "Mask-in-database" for Data Masking)
    - In "Database Credentials", select the **Named** radio button and choose the default credential using the *`DMS_ADMIN`* username
    - In "Host Credentials", select the **Named** radio button and choose the default credential using the *`OS_ORACLE_SSH`* credential name

        ![DMS](./images/dms-153.png "Generate Subset: General")

    - Click [**Continue**]

5. In the "**Generate Subset: Parameters**" screen

    - In "Subset Directory", select "*`Select a custom directory path on target database to save subset scripts`*"
    - Enter this location: *`/home/oracle/DBSecLab/livelabs/dms`*
    - Tick the checkbox "*`The selected target is not a production database`*"

        ![DMS](./images/dms-154.png "Generate Subset: Parameters")

    - Click [**Continue**]

6. A warning message tells you that a Directory will be created to store the scripts into the location you've mentioned

    ![DMS](./images/dms-155.png "Warning message")

    - Click [**OK**]

7. After reviewing that the required space is available, click [**Submit**] to generate the scripts

    ![DMS](./images/dms-156.png "Generate the scripts")

    **Note:** The script is generated and automatically executed!

8. In the "Data Subsetting Definitions" page, refreshing the page until you see the "Job Status" as "**Succeeded**"

    ![DMS](./images/dms-157.png "Job Status as Succeeded")

9. **Now, your sensitive data has been subsetted and masked in the same process!**

## Task 15: Compare the Pre-Subsetted Data vs. the Post-Subsetted Data

1. Once the job successfully completes, query the subsetted data in the Development and Production environments for a before and after comparison

2. Open **SQL Developer** on your PC and connect to **pdb1 as SYSTEM**

    ![DMS](./images/dms-093.png "Open SQL Developer")

3. Press [**Alt**]+[**F10**] to open a SQL Worksheet and select `PDB1_SYSTEM`

    ![DMS](./images/dms-094.png "Open SQL Developer")

4. Do it again in order to have 2 tabs

5. In the first one, copy the following queries for the **PROD: BEFORE SUBSETTING**

    ````
    <copy>
    -- -----------------------------
    -- PROD: BEFORE SUBSETTING
    -- -----------------------------

    -- EMPLOYEE_DATA
    SELECT count(*) "EMPLOYEES COUNT" FROM EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES;

    -- SUPPLEMENTAL_DATA
    SELECT count(*) "SUPPLEMENTAL_DATA COUNT" FROM EMPLOYEESEARCH_PROD.DEMO_HR_SUPPLEMENTAL_DATA;

    -- USERS_DATA
    SELECT count(*) "USERS COUNT" FROM EMPLOYEESEARCH_PROD.DEMO_HR_USERS;


    -- -----------------------------
    -- PROD: BEFORE MASKING
    -- -----------------------------

    -- EMPLOYEE_DATA
    SELECT distinct(e.userid), e.firstname, e.lastname, e.email, sd.routing_number, sd.payment_acct_no
      FROM EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES e, EMPLOYEESEARCH_PROD.DEMO_HR_SUPPLEMENTAL_DATA sd
     WHERE e.userid = sd.userid
     ORDER BY 1;

    -- USERS_DATA
    SELECT userid, email
      FROM EMPLOYEESEARCH_PROD.DEMO_HR_USERS
     ORDER BY 1;

    </copy>
    ````

    ![DMS](./images/dms-158.png "Queries for the PROD (BEFORE SUBSETTING)")

6. In the second one, copy the following queries for the **DEV: AFTER SUBSETTING**

    ````
    <copy>
    -- -----------------------------
    -- DEV: AFTER SUBSETTING
    -- -----------------------------

    -- EMPLOYEE_DATA
    SELECT count(*) "EMPLOYEES COUNT" FROM EMPLOYEESEARCH_DEV.DEMO_HR_EMPLOYEES;

    -- SUPPLEMENTAL_DATA
    SELECT count(*) "SUPPLEMENTAL_DATA COUNT" FROM EMPLOYEESEARCH_DEV.DEMO_HR_SUPPLEMENTAL_DATA;

    -- USERS_DATA
    SELECT count(*) "USERS COUNT" FROM EMPLOYEESEARCH_DEV.DEMO_HR_USERS;


    -- -----------------------------
    -- DEV: AFTER MASKING
    -- -----------------------------

    -- EMPLOYEE_DATA
    SELECT distinct(e.userid), e.firstname, e.lastname, e.email, sd.routing_number, sd.payment_acct_no
      FROM EMPLOYEESEARCH_DEV.DEMO_HR_EMPLOYEES e, EMPLOYEESEARCH_DEV.DEMO_HR_SUPPLEMENTAL_DATA sd
     WHERE e.userid = sd.userid
     ORDER BY 1;

    -- USERS_DATA
    SELECT userid, email
      FROM EMPLOYEESEARCH_DEV.DEMO_HR_USERS
     ORDER BY 1;

    </copy>
    ````

    ![DMS](./images/dms-159.png "Queries for the DEV (AFTER SUBSETTING)")

7. **Execute all these queries** and **compare the results** to confirm your sensitives data have been masked

    - Row count **before subsetting** (in PROD)

        ![DMS](./images/dms-160.png "Row count BEFORE subsetting (in PROD)")

    - Row count **after subsetting** (in DEV)

        ![DMS](./images/dms-161.png "Row count AFTER subsetting (in DEV)")

    - Employee Data:
        - **BEFORE masking** (in PROD)

            ![DMS](./images/dms-099.png "Employee Data BEFORE masking (in PROD)")

        - **AFTER masking** (in DEV)

            ![DMS](./images/dms-100.png "Employee Data AFTER masking (in DEV)")

    - Users Data:
        - **BEFORE masking** (in PROD)

            ![DMS](./images/dms-101.png "Users Data BEFORE masking (in PROD)")

        - **AFTER masking** (in DEV)

            ![DMS](./images/dms-102.png "Users Data AFTER masking (in DEV)")

8. As you can see, the new dataset is different from the original sensitive data, it subsetted and masked and you can now share it without worrying!

## Task 16: Advanced Data Masking Definitions

Now, let's have a look on few advanced features for Data Masking

1. But before, because you have masked data in previous task, you have to restore the `EMPLOYEESEARCH_DEV` tables on **pdb1** by cloning data from `EMPLOYEESEARCH_PROD` schema to have original data

    - Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

        ````
        <copy>sudo su - oracle</copy>
        ````

        **Note**: Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle, so, in that case **you don't need to execute this command**!

    - Go to the scripts directory

        ````
        <copy>cd $DBSEC_LABS/dms</copy>
        ````

    - Reset the `EMPLOYEESEARCH_DEV` data as it was before masking

        ````
        <copy>./dms_restore_pdb1_dev.sh</copy>
        ````

        ![DMS](./images/dms-150.png "Reset data")

2. Now, we will add a new ADM, with advanced Masking scripts already preset, by importing its XML file

    ````
    <copy>./dms_import_adv_def.sh</copy>
    ````

    ![DMS](./images/dms-165.png "Import advanced definitions")

3. Now, go back to the OEM Console and navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Application Data Modeling**

    ![DMS](./images/dms-002.png "Navigate to the Application Data Models")

4. Refresh the web page by pressing F5 to see the ADM imported called `ADM_Advanced`

    ![DMS](./images/dms-166.png "ADM imported")

5. Select it and click on [**Edit...**] to see its details

    ![DMS](./images/dms-167.png "Edit ADM imported")

6. Select the **Sensitive Columns** tab

    ![DMS](./images/dms-168.png "Select the Sensitive Columns tab")

    **Note**: The sensitive columns are already loaded and ready to be masked

7. Click [**Save and Return**]

8. Open the **Create Data Masking Definition** page by clicking on the link

    ![DMS](./images/dms-169.png "Open the Create Data Masking Definition")

9. The Masking defintion `EMPLOYEE_ADV_MASK`is already created, but the script is not generated (default behavior after importing it)

    ![DMS](./images/dms-170.png "The Masking defintion is already created")

10. Select it and click on [**Edit**] to see its details

    ![DMS](./images/dms-171.png "Edit the Masking defintion")

11. Let's have a look on the advanced algorithms used in this masking definition
    
    ![DMS](./images/dms-172.png "Have a look on the advanced algorithms used")

12. By selecting:
    
    - *`ADDRESS_1`*, *`CITY`*, *`COUNTRY`*, *`STATE`* or *`POSTAL_CODE`*, you will see an example of a **COMPOUND masking**
    
        ![DMS](./images/dms-173.png "COMPOUND masking")

        **Note**:
        - Compound masking, also known as grouping option, enables you to mask related columns together as a group, ensuring that the masked data across the related columns retain the same relationship, so the masked data appears consistent
        - The columns being masked as a group must belong to the same table, and each column will be masked with data from another table (here the table *`EMPLOYEESEARCH_DEV.MASK_DATA`*)
        - You can use Deterministic Substitution, Random Substitution, Shuffle, or User Defined Function for compound masking

    - *`PHONEFAX`*, you will see an example of a **ENCRYPT masking**

        ![DMS](./images/dms-174.png "ENCRYPT masking")

        **Note**:
        - Deterministic Encryption encrypts column data using a cryptographic key and Advanced Encryption Standard (AES 128), hashing, and regular expression to produce a deterministic masked output
        - The format of the masked output corresponds to the specified regular expression
        - As this technique uses a key to encrypt the data, the same string can be used to decrypt the data
        - The key also acts as seed to maintain consistent outputs for a given input
        - It supports format preserving encryption, i.e., the format of column data is preserved after encryption
        - **It’s a deterministic and reversible masking format**
        - It's helpful when businesses need to mask and send their data to a third party for analysis, reporting, or any other business processing purpose
        - After the processed data is received from the third party, the original data can be recovered (decrypted) using the same seed value that was used to encrypt the data
        - **Caution**, this method is therefore not compatible with strict regulations such as EU GDPR!

    - *`PHONEMOBILE`*, you will see an example of a **SQL EXPRESSION masking with ORA-HASH function**

        ````
        decode(%PHONEMOBILE%,null,'N/A',ORA_HASH (%PHONEMOBILE%, 9) || '-(' || ORA_HASH (%PHONEMOBILE%, 999) || ')' || ORA_HASH (%PHONEMOBILE%, 999) || '-' || ORA_HASH (%PHONEMOBILE%, 9999))
        ````

        ![DMS](./images/dms-175.png "SQL EXPRESSION masking with ORA-HASH function")

        **Note**:
        - SQL Expression lets you use a SQL expression to mask column data
        - Data Masking uses the specified SQL expression to generate values which are used to replace the original data
        - It can also contain substitution columns (columns from the same table as the column to be masked)
        - You should specify the substitution columns within percent (%) symbols
        - You can also use ORA_HASH function in order to have a deterministic value
        - ORA_HASH takes three arguments: Expression / Number of hash buckets / Seed (can be any number which decides the consistency)
        - The uniqueness is not guaranteed but depends on the input and the number of hash buckets used

    - *`SALARY`*, you will see an example of a **CONDITIONAL masking**

        ![DMS](./images/dms-176.png "CONDITIONAL masking")

        **Note**:
        - Conditional transformation provides an ability to arrange masking formats according to different conditions
        - For example, consider masking the `SALARY` column based on the job `POSITION` of an employee. Depending on the position he occupies within the company, a different algorithm will be applied to make it more or less difficult to access the real original data

    - *`FIRSTNAME`*, you will see an example of a **DETERMINISTIC masking**

        ![DMS](./images/dms-177.png "DETERMINISTIC masking")

        **Note**:
        - The determistic technique ensures repeatable masked values after a mask run
        - One of the key requirements while masking data in large databases or multi-database environment is to consistently mask some columns, i.e., for a given input, the output should always be the same. At the same time, the masked output should not be predictable
        - Deterministic masking generates consistent output for a given input across databases and data masking jobs
        - Masking multiple times across different databases yields the same masked value
        - This characteristic is valid across multiple databases or multiple runs assuming that the same input values are used in the two runs
        - Deterministic masking is helpful in maintaining data integrity across multiples applications and preserve system integrity and an Enterprise may use this technique to ensure that certain values, e.g. a customer number gets masked to the same value across all databases
        - **Note for Substitute**: the method uses a hash-based algorithm in the back end, the mappings are consistent that the uniqueness of the masked value is not guaranteed but depends on the number of columns being used in the substitution table i.e. if the original table contains 50000 unique values, then for the masked output to be unique and deterministic the substitution column should also contain 50000 unique values without which only consistency is maintained but not uniqueness

13. Once you are comfortable with this masking definition, go back to **Data Masking Definition** page and click [**Generate Script**] to create the Masking script

    ![DMS](./images/dms-178.png "Generate Script")

14. In the "**Generate Masking**" screen, fill it out as following:

    - Reference Database: Select *`cdb1_PDB1`*
    - Script Generation Options: Select "*`Mask-in-database`*"
    - Database Credentials: select the **Named** radio button and choose the default credential using the *`DMS_ADMIN`* username

        ![DMS](./images/dms-179.png "Generate Masking Script")

15. Click [**Submit**]

16. Once is created, you must see "**Script Generated**" as status

    ![DMS](./images/dms-180.png "Status of the script generated")

17. Click [**Schedule Job**] to execute the masking script

    ![DMS](./images/dms-181.png "Schedule Job")

18. In the "**Schedule Data Masking Job**" screen, fill it out as following:

    - Database: Select *`cdb1_PDB1`*
    - Select "*`Mask-in-database`*" and check "*`The selected target is not a production database`*" (**Mandatory!**)
    - Seed: *`Enter any string`*  (this is the hash-key required for Substitue and Encrypt format)
    - Script File Location: *`/home/oracle/DBSecLab/livelabs/dms/scripts`*
    - Host Credentials: select the **Named** radio button and choose the default credential using the *`OS_ORACLE_SSH`* username
    - Database Credentials: select the **Named** radio button and choose the default credential using the *`DMS_ADMIN`* username

        ![DMS](./images/dms-182.png "Schedule Data Masking Job parameters")

19. Click [**Submit**]

20. Once is executed, you must see "**Masking Job Succeeded**" as status

    ![DMS](./images/dms-183.png "Status of the Masking Job")

21. Now, you can compare the data between PROD and DEV

    - Open **SQL Developer** on your PC and connect to **pdb1 as SYSTEM**

        ![DMS](./images/dms-093.png "Open SQL Developer")

    - Press [**Alt**]+[**F10**] to open a SQL Worksheet and select `PDB1_SYSTEM`

        ![DMS](./images/dms-094.png "Open SQL Developer")

    - Do it again in order to have 2 tabs

    - In the first one, copy the following queries for the **PROD: BEFORE MASKING**

        ````
        <copy>
        -- -----------------------------
        -- PROD: BEFORE MASKING
        -- -----------------------------
        SELECT userid, firstname, lastname, position, address_1, address_2, postal_code, city, state, country, phonemobile, phonefax, salary
          FROM employeesearch_prod.demo_hr_employees
         WHERE phonefax is not null
         ORDER BY 1;
        </copy>
        ````

        ![DMS](./images/dms-184.png "Queries for the PROD (BEFORE MASKING)")

    - In the second one, copy the following queries for the **DEV: AFTER MASKING**

        ````
        <copy>
        -- -----------------------------
        -- DEV: AFTER MASKING
        -- -----------------------------
        SELECT userid, firstname, lastname, position, address_1, address_2, postal_code, city, state, country, phonemobile, phonefax, salary
          FROM employeesearch_dev.demo_hr_employees
         WHERE phonefax is not null
         ORDER BY 1;
        </copy>
        ````

        ![DMS](./images/dms-185.png "Queries for the DEV (AFTER MASKING)")

22. As you can see, the new dataset is different from the original sensitive data based on all advanced masking formats!


## Task 17: Reset the Labs Environment

1. Restore the `EMPLOYEESEARCH_DEV` tables on pdb1 by cloning data from `EMPLOYEESEARCH_PROD` schema

    - Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle*

        ````
        <copy>sudo su - oracle</copy>
        ````

        **Note**: Only **if you are using a remote desktop session**, just double-click on the Terminal icon on the desktop to launch a session directly as oracle, so, in that case **you don't need to execute this command**!

    - Go to the scripts directory

        ````
        <copy>cd $DBSEC_LABS/dms</copy>
        ````

    - Reset the `EMPLOYEESEARCH_DEV` data as it was before masking

        ````
        <copy>./dms_restore_pdb1_dev.sh</copy>
        ````

        ![DMS](./images/dms-150.png "Reset Data")

2. Now, go back to the OEM Console and remove all definitions created

3. First, **drop the Data Masking definitions**

    - Navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Data Masking Definitions**

        ![DMS](./images/dms-044.png "Navigate to the Application Data Models")

    - Select **every** Data Masking Definition and click [**Delete**]

        ![DMS](./images/dms-190.png "Delete all the Data Masking definitions")

    - Click [**Yes**] to confirm

        ![DMS](./images/dms-191.png "Confirm deletion")

    - Now, your Data Masking Definition are dropped!

        ![DMS](./images/dms-192.png "Data Masking Definition are dropped")

4. Next, **drop the Data Subsetting definitions**

    - Navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Data Subsetting Definitions**

        ![DMS](./images/dms-130.png "Navigate to the Application Data Models")

    - Select **every** Data Subsetting Definition and click [**Delete**]

        ![DMS](./images/dms-193.png "Delet all the Data Subsetting Definition")

    - Click [**Yes**] to confirm

        ![DMS](./images/dms-194.png "Confirm deletion")

    - Now, your Data Subsetting Definition are dropped!

        ![DMS](./images/dms-195.png "Data Subsetting Definition are dropped")

5. Finally, **drop the Application Data Model (ADM)**

    - Navigate to the Application Data Models page from the Quality Management submenu by selecting the menu **Enterprise > Quality Management > Application Data Modeling**

        ![DMS](./images/dms-002.png "Navigate to the Application Data Models")

    - Select **every** Application Data Model and click [**Delete**]

        ![DMS](./images/dms-196.png "Delete all the Application Data Model")

    - Click [**Yes**] to confirm

        ![DMS](./images/dms-197.png "Confirm deletion")

    - Now, your Data Subsetting Definition are dropped!

        ![DMS](./images/dms-198.png "Application Data Model are dropped")

You may now proceed to the next lab!

## **Appendix**: About the Product
### **Overview**
Oracle Data Masking pack for Enterprise Manager, part of Oracle's comprehensive portfolio of database security solutions, helps organizations comply with data privacy and protection mandates such as Sarbanes-Oxley (SOX), Payment Card Industry (PCI) Data Security Standard (DSS), Health Insurance Portability and Accountability Act (HIPAA), EU General Data Protection Regulation (GDPR), and the upcoming California Consumer Privacy Act (CCPA), and numerous laws that restrict the use of actual customer data. With Oracle Data Masking, sensitive information such as credit card or social security numbers can be replaced with realistic values, allowing production data to be safely used for development, testing, or sharing with out-sourced or off-shore partners for other non-production purposes. Oracle Data Masking uses a library of templates and format rules, consistently transforming data in order to maintain referential integrity for applications.

Data masking (also known as data scrambling and data anonymization) is the process of replacing sensitive information copied from production databases to test or non-production databases with realistic, but scrubbed, data based on masking rules. Data masking is ideal for virtually any situation when confidential or regulated data needs to be shared with other non-production users; for instance, internal users such as application developers, or external business partners, like offshore testing companies or suppliers and customers. These non-production users need to access some of the original data, but do not need to see every column of every table, especially when the information is protected by government regulations.

Data masking allows organizations to generate realistic and fully functional data with similar characteristics as the original data to replace sensitive or confidential information. This contrasts with encryption or Virtual Private Database, which simply hide data, allowing the original data to be retrieved with the appropriate access or key. With data masking, the original sensitive data cannot be retrieved or accessed. Names, addresses, phone numbers, and credit card details are examples of data that require protection of the information content from inappropriate visibility. Live production database environments contain valuable and confidential data — access to this information is tightly controlled. However, each production system usually has replicated development copies, and the controls on such test environments are less stringent. This greatly increases the risks that the data might be used inappropriately. Data masking can modify sensitive database records so that they remain usable, but contain no confidential or personally identifiable information. Yet, the masked test data resembles the original in appearance to ensure the integrity of the application.

![DMS](./images/dms-concept.png "DMS Concept")

### **Why do I need Data Masking?**

There are several reasons why you would need it, based on challenges like the ones below
- Personally Identifiable and sensitive data is being shared with parties that do not have a business need-to-know in development and testing groups.
- The use of operational databases containing personal information or any other sensitive information is being used for testing purposes. All identified sensitive details and content should be removed or modified beyond recognition before use.
- There is no established, documented procedure and enforcement of data cleansing standards in masking and cleansing of sensitive production data before distribution to development and QA environments.
- The steps and process necessary to provide development and QA environments with properly masked data are very time consuming, manual and inconsistent.

### **Benefits of using DMS**
- Maximize the business value of data by masking sensitive information
- Minimize the compliance boundary by not proliferating the sensitive production information
- Lower the storage costs on test and development environments by subsetting data
- Automate the discovery of sensitive data and parent-child relationships
- Provide a comprehensive library of masking formats, masking transformations, subsetting techniques, and select application templates
- Mask and subset data in-Database or on-the-file by extracting the data from a source database
- Mask and subset both Oracle and non-Oracle databases
- Mask and subset Oracle Databases hosted on the Oracle cloud
- Preserve data integrity during masking and subsetting and offers many more unique features
- Integrate with select Oracle testing, security, and integration products.

## Want to Learn More?
Technical Documentation:
- [Oracle Data Masking & Subsetting Pack 12.2](https://docs.oracle.com/en/database/oracle/oracle-database/12.2/dmksb/intro.html#GUID-24B241AF-F77F-46ED-BEAE-3919BF1BBD80)

Video:
- *Understanding Oracle Data Masking & Subsetting (April 2019)* [](youtube:3zi0Bs_bgEw)
- *Oracle Data Masking & Subsetting - Advanced Use Cases (June 2019)* [](youtube:06EzV-TM4f4)

## Acknowledgements
- **Author** - Hakim Loumi, Database Security PM
- **Contributors** - Rene Fontcha
- **Last Updated By/Date** - Hakim Loumi, Database Security PM - May 2024