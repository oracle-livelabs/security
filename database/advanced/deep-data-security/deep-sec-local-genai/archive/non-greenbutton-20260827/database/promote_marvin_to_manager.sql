-- Run as ADB ADMIN.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt SQL> GRANT DATA ROLE HOL_DATAROLE_MANAGER_ACCESS TO MARVIN
grant data role hol_datarole_manager_access to marvin;

prompt Marvin now holds HOL_DATAROLE_MANAGER_ACCESS. Build his manager
prompt data grant on this page, nothing about it is scripted for you.
