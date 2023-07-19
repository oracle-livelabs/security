# Protecting Data with Row-Level and Column-Level Security using Oracle VPD

## Introduction
This workshop introduces the functionality of Oracle Transport Layer Security (TLS) network encryption. It gives the user an opportunity to learn how to configure this feature to encrypt and secure its data in-motion.

Description: TLS is the industry-standard for encrypting data in motion. Since TLS provides one-way authentication or mutual two-way authentication, it minimizes the chance of a breach.

*Estimated Lab Time:* 30 minutes

*Version tested in this lab:* Oracle DB 19.17

### Objectives
- Understand how to create a PL/SQL function for use in a VPD policy
- Limit the rows returned based on session user and client identifier
- Prevent sensitive column data from being displayed in SQL*Plus queries

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

## Task 1: Download vpd.tar file to local directory.

1.  Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle* and use `cd` command to move to livelabs directory.

    ````
    <copy>cd livelabs</copy>
    ````

    **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

2.  Use the Linux command 'wget' to download a bundled (zipped) file of the commands for the lab. 

    ````
    <copy>wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/AC5TmVamZJxZfPG21L3cjuGER4BBS5lvMS80Du3DOwkkVtwoySpGfPIdo4Zf9knM/n/oradbclouducm/b/dbsec_rich/o/dbsec-livelabs-vpd.tar</copy>
    ````

3.  Unarchive the downloaded tar to expand the directory and scripts.

    ````
    <copy>tar xvf dbsec-livelabs-vpd.tar</copy>
    ````

4.   Use `cd` command to move to vpd directory.
    
    ````
    <copy>cd vpd</copy>
    ````

5.   Use `ls` command to list files. 
    
    ````
    <copy>ls</copy>
    ````

6.  Initial query to show that there have not been VPD policies created yet.
    
    ````
    <copy>./vpd_query_policies.sh</copy>
    ````

7.  Initial query to demonstrate that `EMPLOYEESEARCH_PROD` and `DBA_DEBRA` can see employee-related data.  Note the number of rows and the sensitive data returned in the columns.
    
    ````
    <copy>./vpd_query_employee_data.sh</copy>
    ````

8.  VPD relies on PL/SQL functions for business logic. Create a function that applies a `1=0` predicate (where clause) to the query if the session user is not the application owner, `EMPLOYEESEARCH_PROD`
    
    ````
    <copy>./vpd_create_row_function.sh</copy>
    ````

9.  Apply a VPD policy to the `EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES` table that will call the PL/SQL function and restrict rows for `SELECT` queries.
    
    ````
    <copy>./vpd_create_row_policy.sh</copy>
    ````

10.  Re-run the query to view employee data. With the VPD row policy applies, `EMPLOYEESEARCH_PROD` will still see all rows but `DBA_DEBRA` will no longer be able to see employee data.
    
    ````
    <copy>./vpd_query_employee_data.sh</copy>
    ````
11.  Now that you understand how to use VPD to limit the number of rows returned, we will drop the row policy and move on to protecting column values.
    
    ````
    <copy>./vpd_drop_row_policy.sh</copy>
    ````
## Task 2: Create column function and policies. 
1.  Similar to the row function, the PL/SQL function will limit the number of rows returned for users who are not the application schema owner, `EMPLOYEESEARCH_PROD`.  In addition, the the application user, the function will also verify the `CLIENT_IDENTIFIER` value is set in the user's session context. 
    
    ````
    <copy>./vpd_create_col_function.sh</copy>
    ````

2.  Create the VPD policy using the PL/SQL column function. This policy will apply to the `SSN`, `SIN`, and `NINO` columns.
    
    ````
    <copy>./vpd_create_col_policy.sh</copy>
    ````

3.  When `EMPLOYEESEARCH_PROD` queries data, 9 rows will be returned but the values for the sensitive columns will not. This is because the VPD policy function will not return the values of these columns until the session user and `CLIENT_IDENTIFIER` session context are both met.
    
    ````
    <copy>./vpd_query_employee_data.sh</copy>
    ````

4.  To demonstrate the results when both session user and `CLIENT_IDENTIFIER` are met, append `hradmin` to the previous query. Sensitive column values will be displayed. However, `DBA_DEBRA` will never see this data because she is not authorized by the PL/SQL function.
    
    ````
    <copy>./vpd_query_employee_data.sh hradmin</copy>
    ````

5.  Altering the query from `hradmin` to `can_candy` will not display any of the sensitive columns because our PL/SQL function does not recognize `can_candy` as a `CLIENT_IDENTIFIER` yet.
    
    ````
    <copy>./vpd_query_employee_data.sh can_candy</copy>
    ````

6.  Update the PL/SQL function to include an `elsif` to allow `can_candy` to see the sensitive columns for Toronto-based employees.
    
    ````
    <copy>./vpd_update_col_function.sh</copy>
    ````

7.  Demonstrate that `hradmin` sees 9 rows and sensitive columns but `DBA_DEBRA` does not.
    
    ````
    <copy>./vpd_query_employee_data.sh hradmin</copy>
    ````

8.  Demonstrate that `can_candy` will see 9 rows and only the sensitive columns for Toronto-based employees.  `DBA_DEBRA` will still not see any sensitive columns.
    
    ````
    <copy>./vpd_query_employee_data.sh can_candy</copy>
    ````
## Task 3: Clean up. 

1.  Remove the PL/SQL functions and drop the VPD-related policies.
    
    ````
    <copy>./vpd_cleanup.sh</copy>
    ````

2.  Verify both `EMPLOYESEARCH_PROD` and `DBA_DEBRA` have full access to rows and columns without the VPD policies in place.
    
    ````
    <copy>./vpd_query_employee_data.sh</copy>
    ````
## **Appendix**: About the Product
### **Overview**

Oracle Database provides both native data network encryption and TLS-based encryption to ensure that data in-motion is secure as it travels across the network.

![Network Encryption](./images/nne-concept.png "Network Encryption")



## Learn More
Technical Documentation:
- [Using Oracle Virtual Private Database to Control Data Access](https://docs.oracle.com/en/database/oracle/oracle-database/21/dbseg/using-oracle-vpd-to-control-data-access.html#GUID-06022729-9210-4895-BF04-6177713C65A7)

## Acknowledgements
- **Author** - Stephen Stuart & Noah Galloso, Solution Engineers, North America Specialist Hub
- **Contributors** - Richard C. Evans, Database Security Product Manager 
- **Last Updated By/Date** - Stephen Stuart & Noah Galloso, July 2023
