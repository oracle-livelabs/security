# Use Redaction to Anonymize REST calls

## Introduction

In this lab, we will demonstrate an application of Oracle Data Redaction using REST Get Calls to view Employee table data before and after applying a redaction policy.

Estimated Time: 15 minutes

### Objectives

In this lab, you will complete the following tasks:

- REST enable the table.
- Apply the Data Redaction Policy to the Table.
- See the data come redacted from the REST Get call.

### Prerequisites

This lab assumes you have:
- An Oracle Cloud Infrastructure (OCI) tenancy account
- Completed all the previous labs in the **Redacting restcalls with ORDS** LiveLab workshop

*Warning: Terminating resources may take a few minutes*

## Task 1: REST enable the table

1. From the Database Actions Launchpad for `EMPLOYEESEARCH_PROD` navigate to **SQL** under the **Development section**.

    ![Select SQL from Launchpad](images/launchpad-sql.png) 

2. **REST enabling the table** is simple. To do this, find the table we just created named `DEMO_HR_EMPLOYEE`S in the **navigator** on the left of the **SQL Worksheet**. Right click on the table name and select **REST** in the pop up menu then Enable.

    ![Enable REST](images/enable-rest.png)

3. The **REST Enable Object slider** will appear from the right side of the page. We are going to use the defaults for this page but take note and **copy** the Preview URL to a clipboard of your choice. This is the URL we will use to **access the REST enabled table**. When ready, click the **Enable button** in the lower right of the slider.

    ![Enable REST](images/rest-enable-object.png)

3. That's it! Your table is **REST enabled**. Open a new browser window or tab and enter **URL** that was copied in the previous step.

    ![Pre-Redaction REST Call](images/pre-redaction-rest.png)

## Task 2: Create users and upload data

1. Navigate back to the **Database Actions** SQL Development page for Admin. Grant access for `EMPLOYEESEARCH_PROD` to the `DBMS_REDACT` package by pasting the text below in the worksheet.

    ```
    <copy>grant execute on sys.dbms_redact to EMPLOYEESEARCH_PROD</copy>   
    ```

    ![Pre-Redaction REST Call](images/grant-red.png)

2. Return to the **Database Actions** SQL Development page for EMPLOYEESEARCH_PROD and run the **first query**. View the unredacted results under query results at the **bottom of the page**.
    
    ```
    <copy>SELECT
        USERID,
        FIRSTNAME,   
        LASTNAME,  --redact
        EMAIL, --redact
        PHONEMOBILE,
        STARTDATE, --redact
        SALARY, --redact
        MANAGERID,
        DEPARTMENT
    FROM
        DEMO_HR_EMPLOYEES;</copy>   
    ```

    ![Qry](images/qry.png)
    
    Also review the table data in our browser window from the previous task.

    This is how our data looks before any redaction policy is applied.


3. Enable ORDS for the schema and the table.

    ![Enable ORDS](images/enable-ords.png)
    ```
    <copy>BEGIN
    /* enable ORDS for schema */
    ORDS.ENABLE_SCHEMA(p_enabled => TRUE,
                       p_schema => 'EMPLOYEESEARCH_PROD',
                       p_url_mapping_type => 'BASE_PATH',
                       p_url_mapping_pattern => 'EMPLOYEESEARCH_PROD',
                       p_auto_rest_auth => FALSE);
     /* enable ORDS for table */         
    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'EMPLOYEESEARCH_PROD',
                       p_object => 'DEMO_HR_EMPLOYEES',
                       p_object_type => 'TABLE',
                       p_object_alias => 'employees',
                       p_auto_rest_auth => FALSE);
    COMMIT;
    END;
    /</copy>   
    ```
4. Add a **redaction policy** to run last name with random chars.
    
    ```
    <copy>begin
            dbms_redact.add_policy(
                object_schema => 'EMPLOYEESEARCH_PROD',
                object_name   => 'demo_hr_employees',
                column_name   => 'lastname',
                policy_name   => 'redact_emp_info',
                function_type => dbms_redact.random,
                expression    => '1=1'
            );
    end;
    /</copy>   
    ```
    ![Last Name](images/last-name.png)

5. Add an **email column** to the redaction policy and redact it using default **regex patterns** that anonymize it with `X`

    ```
    <copy>begin
            dbms_redact.alter_policy (
            object_schema => 'EMPLOYEESEARCH_PROD',
            object_name   => 'DEMO_HR_EMPLOYEES',
            column_name   => 'email',
            policy_name   => 'redact_emp_info',
            action              => dbms_redact.add_column,
            function_type          => DBMS_REDACT.REGEXP,
            function_parameters    => NULL,
            expression             => '1=1',
            regexp_pattern         => DBMS_REDACT.RE_PATTERN_EMAIL_ADDRESS,
            regexp_replace_string  => DBMS_REDACT.RE_REDACT_EMAIL_NAME,
            regexp_position        => DBMS_REDACT.RE_BEGINNING,
            regexp_occurrence      => DBMS_REDACT.RE_FIRST,
            regexp_match_parameter => DBMS_REDACT.RE_CASE_INSENSITIVE,
            policy_description     => 'Regular expressions to redact email address names',
            column_description     => 'email column contains customer emails');
        END;
    /</copy>   
    ```
    ![Email](images/email.png)

6. Add the **start date column** to the redaction policy, redacting the day and month.
    
    ```
    <copy>BEGIN
            DBMS_REDACT.alter_policy (
            object_schema       => 'EMPLOYEESEARCH_PROD',
            object_name         => 'DEMO_HR_EMPLOYEES',
            policy_name         => 'redact_emp_info',
            action              => DBMS_REDACT.add_column,
            column_name         => 'startdate',
            function_type       => DBMS_REDACT.partial,
            function_parameters => 'm1d1Y'
            );
        END;
    /</copy>   
    ```
    ![Start Date](images/start-date.png)

7. Add the **Salary column** to the redaction policy and redact the first two digits making it 99.
    
    ```
    <copy>BEGIN
            DBMS_REDACT.alter_policy (
            object_schema          => 'EMPLOYEESEARCH_PROD', 
            object_name            => 'DEMO_HR_EMPLOYEES', 
            column_name            => 'salary',
            column_description     => 'holds employee salaries',
            policy_name            => 'redact_emp_info', 
            policy_description     => 'Partially redacts the salary column',
            function_type          => DBMS_REDACT.PARTIAL,
            function_parameters    => '9,1,2',
            expression             => '1=1');
        END;
    /</copy>   
    ```
    ![Salary](images/salary.png)

## Task 3: See the data come redacted from the REST Get call

1. View the changes to the table by **reloading the browser** window.
    
    ![Redacted REST](images/redacted-rest-call.png)

2. Run the **first query from the previous task** and view the redacted data at the **bottom of the page**.
    
    ![Redacted REST](images/redacted-query.png)

3. Navigate back to the **SQL window** for `EMPLOYEESEARCH_PROD` and **drop the redaction policy**.
    
    ```
    <copy>BEGIN
            dbms_redact.drop_policy (
            object_schema => 'EMPLOYEESEARCH_PROD',
            object_name   => 'DEMO_HR_EMPLOYEES',
            policy_name   => 'redact_emp_info'
            );
        end;
    /</copy>   
    ```
    ![Drop](images/drop.png)


Congratulations, You have successfully redacted REST calls using ORDS!

## Acknowledgements

- **Authors** - Alpha Diallo & Ethan Shmargad, North America Specialists Hub
- **Creator** - Pedro Lopes, Database Security Product Manager
- **Last Updated By/Date** - Alpha Diallo & Ethan Shmargad, January 2023
