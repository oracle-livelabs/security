-- Run as ADB admin. Creates Marvin and Emma for this lab.
whenever sqlerror exit sql.sqlcode rollback
set echo off
set verify off

define end_user_password = &1

prompt SQL> Validate the shared Stack password
begin
  if nvl(length('&&end_user_password'), 0) = 0 then
    raise_application_error(-20001, 'The shared Stack password is empty. Sign in to the Admin Console with the generated password and run this action again.');
  end if;
end;
/

prompt SQL> DROP END USER MARVIN (if it already exists)
begin
  execute immediate 'drop end user marvin';
exception
  when others then
    if sqlcode != -52515 then raise; end if;
end;
/

prompt SQL> DROP END USER EMMA (if it already exists)
begin
  execute immediate 'drop end user emma';
exception
  when others then
    if sqlcode != -52515 then raise; end if;
end;
/

prompt SQL> CREATE END USER MARVIN IDENTIFIED BY "<shared Stack password>"
create end user marvin identified by "&end_user_password";

prompt SQL> CREATE END USER EMMA IDENTIFIED BY "<shared Stack password>"
create end user emma identified by "&end_user_password";

prompt SQL> GRANT DATA ROLE HOL_DATAROLE_EMPLOYEE_ACCESS TO EMMA
grant data role hol_datarole_employee_access to emma;

prompt
prompt Marvin and Emma are ready.
prompt Marvin has no data role yet. Emma always holds the employee role.
undefine end_user_password
