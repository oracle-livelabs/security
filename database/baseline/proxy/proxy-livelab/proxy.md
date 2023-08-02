# How Developers Could Use Oracle Database Proxy Authentication

## Introduction
This workshop introduces the functionality of Proxy Authentication in Oracle's Database.

Description: Proxy Authentication allows a user (the proxy user) to connect to the database on behalf of another user (the target user) and this workshop show developers the proper usage, configuration and best practices with Proxy Authentication. 

*Estimated Lab Time:* 30 minutes

*Version tested in this lab:* Oracle DB 19.17

### Objectives
Allow a developer to access the application data without knowing the application schema password.  The developer created will inherit the privileges of the application schema.

### Prerequisites

This lab assumes you have:
- A Free Tier, Paid or LiveLabs Oracle Cloud account
- You have completed:
    - Lab: Prepare Setup (*Free-tier* and *Paid Tenants* only)
    - Lab: Environment Setup
    - Lab: Initialize Environment

## Task 1: Download proxy.tar file to local directory.

1.  Open a Terminal session on your **DBSec-Lab** VM as OS user *oracle* and use `cd` command to move to livelabs directory.

    ````
    <copy>cd livelabs</copy>
    ````

    **Note**: If you are using a remote desktop session, double-click on the *Terminal* icon on the desktop to launch a session

2.  Use the Linux command 'wget' to download a bundled (zipped) file of the commands for the lab. 

    ````
    <copy>wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/ZSKnVs6L8sGvA4HkZJjxv2sEFuf-30BYhE1F6jMHeltJ0icC-CBtLUKZzVwNObww/n/oradbclouducm/b/dbsec_rich/o/proxy.tar</copy>
    ````

3.  Unarchive the downloaded tar to expand the directory and scripts.

    ````
    <copy>tar xvf proxy.tar</copy>
    ````

4.   Use `cd` command to move to proxy directory.
    
    ````
    <copy>cd proxy</copy>
    ````

5.   Use `ls` command to list files. 
    
    ````
    <copy>ls</copy>
    ````
## Task 2: Proxy Lab

1.  First, create the developer, `DEV_DAVE`, account. Note that it has no privileges. This account cannot authenticate unless it is proxying as another account.

    ````
    <copy>./proxy_create_dave.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    Create a developer account named DEV_DAVE without any privileges...
    ==============================================================================

    create user dev_dave identified by Dave123

    User created.
    ````

2.   Authorize the `DEV_DAVE` account to proxy as if it were the `EMPLOYEESEARCH_PROD` application schema.

    ````
    <copy>./proxy_auth_dave.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    Authorize DEV_DAVE to proxy as if they were EMPLOYEESEARCH_PROD...
    ==============================================================================

    alter user employeesearch_prod grant connect through dev_dave

    User altered.


    PROXY			  CLIENT		    AUT FLAGS
    ------------------------- ------------------------- --- -----------------------------------
    DEV_DAVE		  EMPLOYEESEARCH_PROD	    NO	PROXY MAY ACTIVATE ALL CLIENT ROLES
    ````

3.  Create a Unified Audit policy to audit when proxying users access sensitive data in the `EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES` table.

    ````
    <copy>./proxy_create_audit_policy.sh</copy>
    ````
    **Output:**
    ````
    =================================================================================
    Create a Unified Audit policy to audit when proxy users query sensitive data...
    =================================================================================


    create audit policy aud_proxy_access
    ACTIONS select, update, delete, insert on employeesearch_prod.demo_hr_employees
    WHEN 'SYS_CONTEXT(''USERENV'',''proxy_user'') is not null'
    EVALUATE PER SESSION

    Audit policy created.
    ````

4.   Remember, you must enable a Unified Audit policy after creating it. This allows you to stage, or prepare, policies in advance.
    
    ````
    <copy>./proxy_enable_audit_policy.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    Enable Unified Audit policy...
    ==============================================================================

    audit policy aud_proxy_access

    Audit succeeded.
    ````

5.    Verify that `DEV_DAVE` cannot authenticate. This account has no privileges, it will inherit privileges from `EMPLOYEESEARCH_PROD` when it proxies as that user.
    
    ````
    <copy>./proxy_test_as_dave.sh</copy>
    ````
    **Output:**
    ````
    ==================================================================================
    Attempt to connect as DEV_DAVE, it should fail because they have no privileges...
    ==================================================================================

    connect dev_dave/Dave123@pdb1

    ERROR:
    ORA-01045: user DEV_DAVE lacks CREATE SESSION privilege; logon denied
    ````

6.  Now, demonstrate that `DEV_DAVE` can proxy as `EMPLOYEESEARCH_PROD`. Dave does not need to know the `EMPLOYEESEARCH_PROD` password, Dave uses his own password. Notice the user information shows the `EMPLOYEESEARCH_PROD` schema. We can verify the proxy user by querying the SYS_CONTEXT attribute `proxy_user`.
    
    ````
    <copy>./proxy_query_employee_data.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    Query on EMPLOYEESEARCH_PROD data...
    ==============================================================================

    USER is "EMPLOYEESEARCH_PROD"

    . Display current user and proxy_user from SYS_CONTEXT

    CURRENT_USER	     PROXY_USER
    -------------------- --------------------
    EMPLOYEESEARCH_PROD


    . Query EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES from employeesearch_prod user

    USERID      FIRSTNAME   LASTNAME	CITY	        POSITION	        SSN	        SIN	        NINO
    ----------  ----------  ----------  --------------  ----------------    ----------- ----------- -------------
	        73  Craig       Hunt	    Costa Mesa	    Administrator	    102-20-4997
	        74  Fred        Stewart	    Paris		    Project Manager		                        MN 33 14 95 E
	        75  Julie       Reed	    New York	    Clerk		        412-62-2417
	        76  Ruby        James	    Paris		    End-User	        537-78-8902
	        77  Alice       Harper	    Toronto         District Manager	            170-042-126
	        78  Marilyn     Lee	        Sunnyvale	    District Manager    553-51-1031
	        79  Laura       Ryan	    London 	        Project Manager     568-10-8709
	        80  William     Elliott	    Sunnyvale	    District Manager    787-89-2282
	        81  Martha      Carpenter   Berlin 	        Administrator		                        FZ 84 80 43 S

    9 rows selected.


    Query the data as dave proxying as the schema owner
    connect dev_dave[employeesearch_prod]/Dave123@pdb1
    USER is "EMPLOYEESEARCH_PROD"

    . Display current user and proxy_user from SYS_CONTEXT

    CURRENT_USER	     PROXY_USER
    -------------------- --------------------
    EMPLOYEESEARCH_PROD  DEV_DAVE


    . Query EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES from dba_debra user

    USERID      FIRSTNAME   LASTNAME	CITY	        POSITION	        SSN	        SIN	        NINO
    ----------  ----------  ----------  --------------  ----------------    ----------- ----------- -------------
	        73  Craig       Hunt	    Costa Mesa	    Administrator	    102-20-4997
	        74  Fred        Stewart	    Paris		    Project Manager		                        MN 33 14 95 E
	        75  Julie       Reed	    New York	    Clerk		        412-62-2417
	        76  Ruby        James	    Paris		    End-User	        537-78-8902
	        77  Alice       Harper	    Toronto         District Manager	            170-042-126
	        78  Marilyn     Lee	        Sunnyvale	    District Manager    553-51-1031
	        79  Laura       Ryan	    London 	        Project Manager     568-10-8709
	        80  William     Elliott	    Sunnyvale	    District Manager    787-89-2282
	        81  Martha      Carpenter   Berlin 	        Administrator		                        FZ 84 80 43 S

    9 rows selected.
    ````

7.  View the audit data created by the proxy user `DEV_DAVE`.
    
    ````
    <copy>./proxy_view_audit.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    View audit records related to the proxy account...
    ==============================================================================

    select event_timestamp, dbusername, dbproxy_username, action_name, sql_text
    from unified_audit_trail
    where dbproxy_username is not null
    and event_timestamp >  systimestamp-1
    order by 1 desc


    EVENT_TIMESTAMP 	            DBUSERNAME	        DBPROXY_USERNAME  ACTION_NAME     SQL_TEXT
    -----------------------------   ------------------- ----------------- --------------- -------------------------------------------------------------------
    02-AUG-23 07.55.42.151117 PM    EMPLOYEESEARCH_PROD DEV_DAVE	      LOGOFF
    02-AUG-23 07.55.42.149571 PM    EMPLOYEESEARCH_PROD DEV_DAVE	      SELECT	      select userid, firstname, lastname, city, position, ssn, sin, nino
                                                                                            from employeesearch_prod.demo_hr_employees
                                                                                           where rownum < 10

    02-AUG-23 07.55.42.147492 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select sys_context( 'userenv', 'current_user' ) current_user, sys_c
                                                                                          ontext( 'userenv', 'proxy_user' ) proxy_user from dual

    02-AUG-23 07.55.42.145157 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select upper(sys_context ('userenv', 'session_user') || ':' || sys_
                                                                                          context('userenv', 'con_name')) global_name from dual

    02-AUG-23 07.55.42.141075 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      SELECT DECODE(USER, 'XS$NULL',  XS_SYS_CONTEXT('XS$SESSION','USERNA
                                                                                          ME'), USER) FROM SYS.DUAL

    02-AUG-23 07.55.42.136314 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      LOGON

    6 rows selected.

    select sql_text, rls_info
    from unified_audit_trail
    where dbproxy_username = 'DEV_DAVE' and rls_info is not null
    and sql_text like 'select userid, firstname, lastname, city, position, ssn, sin, nino%'
    and event_timestamp >  systimestamp-1 and rownum < 2


    no rows selected
    ````

## Task 3: Optional Lab

In this lab, you will demonstrate how you can add additional security factors based on whether the database user is a proxying user or not.  We will prevent proxying users, like `DEV_DAVE` from viewing the social identifier columns (`SSN`, `SIN`, `NINO`) in `EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES`. The schema, without a proxy user, should be able to view these sensitive columns.  Create an Oracle Virtual Private Database (VPD) policy, sometimes called row-level security or fine-grain access control, to prevent the social identifier columns from being returned to proxy users. They will return as null values.

1.   Demonstrate the sensitive column data is displayed for both `EMPLOYEESEARCH_PROD` and `DEV_DAVE`.
    
    ````
    <copy>./proxy_query_employee_data.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    Query on EMPLOYEESEARCH_PROD data...
    ==============================================================================

    USER is "EMPLOYEESEARCH_PROD"

    . Display current user and proxy_user from SYS_CONTEXT

    CURRENT_USER	     PROXY_USER
    -------------------- --------------------
    EMPLOYEESEARCH_PROD


    . Query EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES from employeesearch_prod user

    USERID      FIRSTNAME   LASTNAME	CITY	        POSITION	        SSN	        SIN	        NINO
    ----------  ----------  ----------  --------------  ----------------    ----------- ----------- -------------
	        73  Craig       Hunt	    Costa Mesa	    Administrator	    102-20-4997
	        74  Fred        Stewart	    Paris		    Project Manager		                        MN 33 14 95 E
	        75  Julie       Reed	    New York	    Clerk		        412-62-2417
	        76  Ruby        James	    Paris		    End-User	        537-78-8902
	        77  Alice       Harper	    Toronto         District Manager	            170-042-126
	        78  Marilyn     Lee	        Sunnyvale	    District Manager    553-51-1031
	        79  Laura       Ryan	    London 	        Project Manager     568-10-8709
	        80  William     Elliott	    Sunnyvale	    District Manager    787-89-2282
	        81  Martha      Carpenter   Berlin 	        Administrator		                        FZ 84 80 43 S

    9 rows selected.


    Query the data as dave proxying as the schema owner
    connect dev_dave[employeesearch_prod]/Dave123@pdb1
    USER is "EMPLOYEESEARCH_PROD"

    . Display current user and proxy_user from SYS_CONTEXT

    CURRENT_USER	     PROXY_USER
    -------------------- --------------------
    EMPLOYEESEARCH_PROD  DEV_DAVE


    . Query EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES from dba_debra user

    USERID      FIRSTNAME   LASTNAME	CITY	        POSITION	        SSN	        SIN	        NINO
    ----------  ----------  ----------  --------------  ----------------    ----------- ----------- -------------
	        73  Craig       Hunt	    Costa Mesa	    Administrator	    102-20-4997
	        74  Fred        Stewart	    Paris		    Project Manager		                        MN 33 14 95 E
	        75  Julie       Reed	    New York	    Clerk		        412-62-2417
	        76  Ruby        James	    Paris		    End-User	        537-78-8902
	        77  Alice       Harper	    Toronto         District Manager	            170-042-126
	        78  Marilyn     Lee	        Sunnyvale	    District Manager    553-51-1031
	        79  Laura       Ryan	    London 	        Project Manager     568-10-8709
	        80  William     Elliott	    Sunnyvale	    District Manager    787-89-2282
	        81  Martha      Carpenter   Berlin 	        Administrator		                        FZ 84 80 43 S

    9 rows selected.
    ````

2.  Verify there are no current Oracle Virtual Private Database (VPD) policies on our table.
    
    ````
    <copy>./proxy_vpd_query_policies.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    Query on current VPD policies...
    ==============================================================================

    Show current VPD policies...

    no rows selected
    ````

3.  Create a PL/SQL function to identify `EMPLOYEESEARCH_PROD` session_user and if the session user is a proxying user. If it is only the schema, the function will not add a predicate to the SQL query. If the session user is a proxying user, it will add `1=0` to the SQL query and return `SSN`, `SIN`, and `NINO` columns as null values.
    
    ````
    <copy>./proxy_vpd_create_function.sh</copy>
    ````

4.  Create the policy to apply to the `EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES` table.
    
    ````
    <copy>./proxy_vpd_create_policy.sh</copy>
    ````
    **Output:**
    ````
    OBJECT_NAME	        POLICY_GROUP POLICY_NAME
    ------------------- ------------ ---------------------------
    DEMO_HR_EMPLOYEES   SYS_DEFAULT  VPD_EMPSEARCH_COLS


    OBJECT_NAME	        POLICY_NAME		        PF_OWNER	        PACKAGE	        FUNCTION
    ------------------- ----------------------- ------------------- --------------- --------------
    DEMO_HR_EMPLOYEES   VPD_EMPSEARCH_ROWS 	    EMPLOYEESEARCH_PROD	                VPD_PROTECT_SE
                                                                                    N_COLS

    POLICY_NAME		            SEL INS UPD DEL IDX CHK ENABLE STATIC_POLICY POLICY_TYPE
    --------------------------- --- --- --- --- --- --- ------ ------------- -------------------
    VPD_EMPSEARCH_COLS	        YES NO  NO  NO  NO	NO  YES    NO		     DYNAMIC
    ````

5.  Verify the `EMPLOYEESEARCH_PROD` schema is able to view the social identifier columns but the proxying user is not.
    
    ````
    <copy>./proxy_query_employee_data.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    Query on EMPLOYEESEARCH_PROD data...
    ==============================================================================

    USER is "EMPLOYEESEARCH_PROD"

    . Display current user and proxy_user from SYS_CONTEXT

    CURRENT_USER	     PROXY_USER
    -------------------- --------------------
    EMPLOYEESEARCH_PROD


    . Query EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES from employeesearch_prod user

    USERID      FIRSTNAME   LASTNAME	CITY	        POSITION	        SSN	        SIN	        NINO
    ----------  ----------  ----------  --------------  ----------------    ----------- ----------- -------------
	        73  Craig       Hunt	    Costa Mesa	    Administrator	    102-20-4997
	        74  Fred        Stewart	    Paris		    Project Manager		                        MN 33 14 95 E
	        75  Julie       Reed	    New York	    Clerk		        412-62-2417
	        76  Ruby        James	    Paris		    End-User	        537-78-8902
	        77  Alice       Harper	    Toronto         District Manager	            170-042-126
	        78  Marilyn     Lee	        Sunnyvale	    District Manager    553-51-1031
	        79  Laura       Ryan	    London 	        Project Manager     568-10-8709
	        80  William     Elliott	    Sunnyvale	    District Manager    787-89-2282
	        81  Martha      Carpenter   Berlin 	        Administrator		                        FZ 84 80 43 S

    9 rows selected.


    Query the data as dave proxying as the schema owner
    connect dev_dave[employeesearch_prod]/Dave123@pdb1
    USER is "EMPLOYEESEARCH_PROD"

    . Display current user and proxy_user from SYS_CONTEXT

    CURRENT_USER	     PROXY_USER
    -------------------- --------------------
    EMPLOYEESEARCH_PROD  DEV_DAVE


    . Query EMPLOYEESEARCH_PROD.DEMO_HR_EMPLOYEES from dba_debra user

    USERID      FIRSTNAME   LASTNAME	CITY	        POSITION	        SSN	        SIN	        NINO
    ----------  ----------  ----------  --------------  ----------------    ----------- ----------- -------------
	        73  Craig       Hunt	    Costa Mesa	    Administrator	    
	        74  Fred        Stewart	    Paris		    Project Manager		                        
	        75  Julie       Reed	    New York	    Clerk		        
	        76  Ruby        James	    Paris		    End-User	        
	        77  Alice       Harper	    Toronto         District Manager	            
	        78  Marilyn     Lee	        Sunnyvale	    District Manager    
	        79  Laura       Ryan	    London 	        Project Manager     
	        80  William     Elliott	    Sunnyvale	    District Manager    
	        81  Martha      Carpenter   Berlin 	        Administrator		                        

    9 rows selected.
    ````

6.  View the audit data related to our proxy user queries. Notice the Oracle VPD predicate (`RLS_INFO`) data is available in the Unified Audit trail. You can see the policy type and policy predicate that was applied to the proxying user’s SQL query.
    
    ````
    <copy>./proxy_view_audit.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    View audit records related to the proxy account...
    ==============================================================================

    select event_timestamp, dbusername, dbproxy_username, action_name, sql_text
    from unified_audit_trail
    where dbproxy_username is not null
    and event_timestamp >  systimestamp-1
    order by 1 desc


    EVENT_TIMESTAMP 	            DBUSERNAME	        DBPROXY_USERNAME  ACTION_NAME     SQL_TEXT
    -----------------------------   ------------------- ----------------- --------------- -------------------------------------------------------------------
    02-AUG-23 08.13.25.446428 PM    EMPLOYEESEARCH_PROD DEV_DAVE	      LOGOFF
    02-AUG-23 08.13.25.442949 PM    EMPLOYEESEARCH_PROD DEV_DAVE	      SELECT	      select userid, firstname, lastname, city, position, ssn, sin, nino
                                                                                            from employeesearch_prod.demo_hr_employees
                                                                                           where rownum < 10

    02-AUG-23 08.13.25.439201 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select sys_context( 'userenv', 'current_user' ) current_user, sys_c
                                                                                          ontext( 'userenv', 'proxy_user' ) proxy_user from dual

    02-AUG-23 08.13.25.437053 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select upper(sys_context ('userenv', 'session_user') || ':' || sys_
                                                                                          context('userenv', 'con_name')) global_name from dual

    02-AUG-23 08.13.25.433833 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      SELECT DECODE(USER, 'XS$NULL',  XS_SYS_CONTEXT('XS$SESSION','USERNA
                                                                                          ME'), USER) FROM SYS.DUAL

    02-AUG-23 08.13.25.429592 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      LOGON
    02-AUG-23 08.07.20.550624 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      LOGOFF
    02-AUG-23 08.07.20.548502 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select userid, firstname, lastname, city, position, ssn, sin, nino
                                                                                            from employeesearch_prod.demo_hr_employees
                                                                                           where rownum < 10

    02-AUG-23 08.07.20.546367 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select sys_context( 'userenv', 'current_user' ) current_user, sys_c
                                                                                          ontext( 'userenv', 'proxy_user' ) proxy_user from dual

    02-AUG-23 08.07.20.544402 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select upper(sys_context ('userenv', 'session_user') || ':' || sys_
                                                                                          context('userenv', 'con_name')) global_name from dual

    02-AUG-23 08.07.20.541255 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      SELECT DECODE(USER, 'XS$NULL',  XS_SYS_CONTEXT('XS$SESSION','USERNA
                                                                                          ME'), USER) FROM SYS.DUAL

    02-AUG-23 08.07.20.537439 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      LOGON
    02-AUG-23 07.55.42.151117 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      LOGOFF
    02-AUG-23 07.55.42.149571 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select userid, firstname, lastname, city, position, ssn, sin, nino
                                                                                            from employeesearch_prod.demo_hr_employees
                                                                                           where rownum < 10

    02-AUG-23 07.55.42.147492 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select sys_context( 'userenv', 'current_user' ) current_user, sys_c
                                                                                          ontext( 'userenv', 'proxy_user' ) proxy_user from dual

    02-AUG-23 07.55.42.145157 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      select upper(sys_context ('userenv', 'session_user') || ':' || sys_
                                                                                          context('userenv', 'con_name')) global_name from dual

    02-AUG-23 07.55.42.141075 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      SELECT	      SELECT DECODE(USER, 'XS$NULL',  XS_SYS_CONTEXT('XS$SESSION','USERNA
                                                                                          ME'), USER) FROM SYS.DUAL

    02-AUG-23 07.55.42.136314 PM    EMPLOYEESEARCH_PROD  DEV_DAVE	      LOGON

    18 rows selected.

    select sql_text, rls_info
    from unified_audit_trail
    where dbproxy_username = 'DEV_DAVE' and rls_info is not null
    and sql_text like 'select userid, firstname, lastname, city, position, ssn, sin, nino%'
    and event_timestamp >  systimestamp-1 and rownum < 2


    SQL_TEXT
    --------------------------------------------------------------------------------------------------------------------------------------------
    RLS_INFO
    --------------------------------------------------------------------------------------------------------------------------------------------
    select userid, firstname, lastname, city, position, ssn, sin, nino
    from employeesearch_prod.demo_hr_employees
    where rownum < 10
    ((POLICY_TYPE=[3]'VPD'),(POLICY_SCHEMA=[19]'EMPLOYEESEARCH_PROD'),(POLICY_NAME=[18]'VPD_EMPSEARCH_COLS'),(PREDICATE=[3]'1=0'));
    ````
## Task 4: Clean up. 

1.  Remove the PL/SQL functions and clean up the proxy.
    
    ````
    <copy>./proxy_cleanup.sh</copy>
    ````
    **Output:**
    ````
    ==============================================================================
    Clean-up the lab...
    ==============================================================================

    Disable the unified audit policy

    Noaudit succeeded.

    Drop the unified audit policy

    Audit Policy dropped.

    alter user employeesearch_prod revoke connect through dev_dave

    User altered.

    drop user dev_dave cascade

    User dropped.

    Drop VPD policy

    PL/SQL procedure successfully completed.

    Drop VPD PL/SQL function

    Function dropped.
    ````

## **Appendix**: About the Product
### **Overview**

Proxy Authentication allows a user (the proxy user) to connect to the database on behalf of another user (the target user) and this workshop show developers the proper usage, configuration and best practices with Proxy Authentication. 

## Learn More
Technical Documentation:
- [Proxy Authentication](https://docs.oracle.com/en/database/oracle/oracle-database/19/jjdbc/proxy-authentication.html#GUID-07E0AF7F-2C9A-42E9-8B99-F2716DC3B746)

- [Oracle Database 19c Security Guide](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/index.html#Oracle%C2%AE-Database)

## Acknowledgements
- **Author** - Stephen Stuart & Noah Galloso, Solution Engineers, North America Specialist Hub
- **Contributors** - Richard C. Evans, Database Security Product Manager 
- **Last Updated By/Date** - Stephen Stuart & Noah Galloso, August 2023
