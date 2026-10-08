-- Run as an ADB administrator. Creates the plain Oracle role every Deep
-- Data Security data role will build on. Nothing here is Deep Data
-- Security yet; this is completely ordinary Oracle role security.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt Creating the database roles the data roles will use.
prompt SQL> CREATE ROLE HOL_DBROLE_CONNECT (if it doesn't already exist)
begin
  execute immediate 'create role hol_dbrole_connect';
exception
  when others then
    if sqlcode != -1921 then raise; end if;
end;
/

prompt SQL> GRANT CREATE SESSION TO HOL_DBROLE_CONNECT
grant create session to hol_dbrole_connect;

prompt SQL> CREATE ROLE HOL_DBROLE_ORDER_HISTORY_QUERY (if it doesn't already exist)
begin
  execute immediate 'create role hol_dbrole_order_history_query';
exception
  when others then
    if sqlcode != -1921 then raise; end if;
end;
/

prompt SQL> GRANT READ ON DIRECTORY DATA_PUMP_DIR TO HOL_DBROLE_ORDER_HISTORY_QUERY
-- Queries against the Iceberg external table resolve its default directory.
-- The role is attached to the employee data role on the next page; it does
-- not itself authorize any APPLAB table data.
grant read on directory data_pump_dir to hol_dbrole_order_history_query;

prompt HOL_DBROLE_CONNECT and HOL_DBROLE_ORDER_HISTORY_QUERY are ready. These
prompt are ordinary Oracle roles with ordinary privileges, nothing Deep Sec
prompt about them yet. The next page attaches them to a Deep Data Security data role.
