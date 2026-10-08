-- Execute with an attached local end-user security context.
-- The Flask app uses this same SELECT before and after role changes.
set echo off
set linesize 160 pagesize 100
column customer_Name format a25
column sales_rep format a10
column sensitive_identifier format a20
prompt SQL> SELECT * FROM APPLAB.CUSTOMERS ORDER BY REVENUE DESC
prompt Same broad query every time. Oracle decides what comes back.
select *
  from applab.customers
 order by revenue desc;

column username format a20
prompt SQL> SELECT ORA_END_USER_CONTEXT.USERNAME FROM DUAL
prompt Showing the authenticated end user Oracle used for authorization.
select ora_end_user_context.username as end_user from dual;

column active_data_role format a20
prompt SQL> SELECT ROLE_NAME FROM V$END_USER_DATA_ROLE ORDER BY ROLE_NAME
prompt Showing the active Deep Sec data roles for this session.
select role_name as active_data_role
  from v$end_user_data_role
 order by role_name;
