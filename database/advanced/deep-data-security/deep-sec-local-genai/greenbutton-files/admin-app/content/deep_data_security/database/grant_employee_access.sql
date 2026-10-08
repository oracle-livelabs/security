-- Run as ADB ADMIN.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt SQL> GRANT DATA ROLE HOL_DATAROLE_EMPLOYEE_ACCESS TO MARVIN
grant data role hol_datarole_employee_access to marvin;

prompt SQL> GRANT DATA ROLE HOL_DATAROLE_EMPLOYEE_ACCESS TO EMMA
grant data role hol_datarole_employee_access to emma;

prompt Marvin now holds HOL_DATAROLE_EMPLOYEE_ACCESS, wide open until you
prompt narrow it on the Customize Data Grant page.
