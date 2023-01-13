# Use Redaction to Anonymize REST calls

## Introduction

In this lab, we will demonstrate an application of Oracle Data Redaction using REST Get Calls to view Employee table data both before and after applying a redaction policy.

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

## Task 2: Apply Data Redaction Policy to the Table

1. Navigate back to the **Database Actions** SQL Development page for Admin. Grant access for `EMPLOYEESEARCH_PROD` to the `DBMS_REDACT` package by pasting the text below in the worksheet.

    ```
    Username:<copy>grant execute on sys.dbms_redact to EMPLOYEESEARCH_PROD</copy>   
    ```

    ![Pre-Redaction REST Call](images/grant-red.png)

2. Run the **first query** and view the unredacted results under query results at the **bottom of the page**.
    
    ![Qry](images/qry.png)
    
    Also review the table data in our browser window from the previous task.

    This is how our data looks before any redaction policy is applied.

3. Add a **redaction policy** to run last name with random chars.
    
    ![Last Name](images/last-name.png)

4. Add an **email column** to the redaction policy and redact it using default **regex patterns** that anonymize it with `X`

    ![Email](images/email.png)

5. Add the **start date column** to the redaction policy, redacting the day and month.
    
    ![Start Date](images/start-date.png)

6. Add the **Salary column** to the redaction policy and redact the first two digits making it 99.
    
    ![Salary](images/salary.png)

## Task 3: See the data come redacted from the REST Get call

1. View the changes to the table by **reloading the browser** window.
    
    ![Redacted REST](images/redacted-rest-call.png)

2. Run the **first query from the previous task** and view the redacted data at the **bottom of the page**.
    
    ![Redacted REST](images/redacted-query.png)

3. Navigate back to the **SQL window** for `EMPLOYEESEARCH_PROD` and **drop the redaction policy**.
    
    ![Drop](images/drop.png)


Congratulations, You have successfully redacted REST calls using ORDS!

## Acknowledgements

- **Authors** - Alpha Diallo & Ethan Shmargad, North America Specialists Hub
- **Creator** - Pedro Lopes, Database Security Product Manager
- **Last Updated By/Date** - Alpha Diallo & Ethan Shmargad, January 2023
