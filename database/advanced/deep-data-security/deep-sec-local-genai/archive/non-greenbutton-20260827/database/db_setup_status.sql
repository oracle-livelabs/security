-- Run as ADB ADMIN. Read-only. Confirms the ordinary Oracle plumbing this
-- page created, no Deep Data Security objects exist yet.
whenever sqlerror exit sql.sqlcode rollback
set echo off
set pagesize 200
set linesize 200

prompt Confirming the APPLAB schema exists.
column username format a12
column account_status format a12
select username, account_status, created
  from dba_users
 where username = 'APPLAB';

prompt
prompt Confirming the customer table exists, and how many rows it holds.
column table_name format a12
select t.table_name,
       (select count(*) from applab.customers) as row_count
  from all_tables t
 where t.owner = 'APPLAB'
   and t.table_name = 'CUSTOMERS';

prompt
prompt Confirming the role created on this page, and its system privileges.
column database_role format a20
column system_privilege format a20
select r.role as database_role,
       p.privilege as system_privilege
  from dba_roles r
  join dba_sys_privs p on p.grantee = r.role
 where r.role = 'HOL_DBROLE_CONNECT';

prompt
prompt Review complete. Nothing above is Deep Data Security, that starts on
prompt the Deep Sec Setup page next.
