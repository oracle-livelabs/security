-- Run as ADB ADMIN.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt SQL> REVOKE DATA ROLE HOL_DATAROLE_MANAGER_ACCESS FROM MARVIN (if currently granted)
begin
  execute immediate 'revoke data role hol_datarole_manager_access from marvin';
exception
  when others then
    if sqlcode != -1951 then raise; end if;
end;
/

prompt Manager role revoked. Marvin falls back to HOL_DATAROLE_EMPLOYEE_ACCESS if it remains active.
