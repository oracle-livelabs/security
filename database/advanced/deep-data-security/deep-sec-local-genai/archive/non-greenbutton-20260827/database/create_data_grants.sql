-- Run as an ADB administrator. Defines the employee data grant wide open,
-- no WHERE clause at all, every row is authorized. The Customize Data
-- Grant page narrows it from here, it never gets rebuilt from scratch.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt Creating the employee data grant, wide open to start.
prompt SQL> CREATE OR REPLACE DATA GRANT APPLAB.EMPLOYEE_CUSTOMER_ACCESS AS SELECT ON APPLAB.CUSTOMERS TO HOL_DATAROLE_EMPLOYEE_ACCESS
create or replace data grant APPLAB.employee_customer_access
  as select
  on APPLAB.customers
  to hol_datarole_employee_access;

prompt Employee grant ready, wide open. Narrow it on the Customize Data Grant page.
