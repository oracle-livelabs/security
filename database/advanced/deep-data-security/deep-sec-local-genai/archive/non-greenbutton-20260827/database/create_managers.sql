-- Run as an ADB administrator. A small lookup resolving each manager's
-- own numeric ID, the only thing the end user context needs to compute.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt SQL> DROP TABLE APPLAB.MANAGERS (if it exists)
begin
  execute immediate 'drop table applab.managers purge';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/
prompt SQL> CREATE TABLE APPLAB.MANAGERS (MANAGER_NAME, MANAGER_ID)
create table applab.managers (
  manager_name  varchar2(100) primary key,
  manager_id    number not null unique
);

prompt SQL> Populate manager IDs.
insert into applab.managers (manager_name, manager_id) values ('MARVIN', 1);
insert into applab.managers (manager_name, manager_id) values ('PRIYA', 2);

prompt SQL> COMMIT
commit;

prompt MANAGERS ready: MARVIN is manager 1, PRIYA is manager 2. Neither
prompt customer row assignment nor Marvin's own book depends on this table,
prompt only the context lookup below does.
