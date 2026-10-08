-- Run as ADB ADMIN.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt SQL> GRANT DATA ROLE HOL_DATAROLE_MANAGER_ACCESS TO MARVIN
grant data role hol_datarole_manager_access to marvin;

prompt Marvin is still an employee and has HOL_DATAROLE_EMPLOYEE_ACCESS.
prompt Now, he also holds the HOL_DATAROLE_MANAGER_ACCESS data role.
prompt These two data roles provide unique privileges.
