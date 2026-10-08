-- Run as ADB ADMIN before creating the local end users.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt Creating Oracle Deep Data Security data roles.
prompt A data role holds authorization.
prompt Its data grant defines which rows and columns it can see.
prompt SQL> CREATE OR REPLACE DATA ROLE HOL_DATAROLE_EMPLOYEE_ACCESS
prompt CREATE OR REPLACE is a Deep Sec feature. Plain CREATE ROLE lacks it.
create or replace data role hol_datarole_employee_access;
prompt SQL> CREATE OR REPLACE DATA ROLE HOL_DATAROLE_MANAGER_ACCESS
create or replace data role hol_datarole_manager_access;

-- Direct local end users land in XS$NULL. HOL_DBROLE_CONNECT, an ordinary
-- Oracle role, was created on the previous page. Table access remains
-- controlled entirely by data grants below, not by this role.
prompt SQL> GRANT HOL_DBROLE_CONNECT TO HOL_DATAROLE_EMPLOYEE_ACCESS
prompt A database role can't be granted straight to an end user.
prompt Grant it to a data role first, then to Marvin or Emma.
grant hol_dbrole_connect to hol_datarole_employee_access;

prompt SQL> GRANT HOL_DBROLE_ORDER_HISTORY_QUERY TO HOL_DATAROLE_EMPLOYEE_ACCESS
prompt This only lets an authorized session resolve the external table's
prompt directory. A later data grant still decides whether it can read rows.
grant hol_dbrole_order_history_query to hol_datarole_employee_access;

prompt Data roles ready: the employee role carries CREATE SESSION and the
prompt directory privilege needed by the later Iceberg external table. Neither
prompt role authorizes table data yet; that is the data grant, created next.
