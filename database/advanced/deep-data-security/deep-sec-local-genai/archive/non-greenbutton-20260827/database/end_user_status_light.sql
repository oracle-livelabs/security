-- Run as ADB ADMIN. Read-only baseline review for Deep Sec Setup.
whenever sqlerror exit sql.sqlcode rollback
set echo off
set pagesize 200
set linesize 200

prompt DBA_DATA_ROLES: every data role that exists right now.
column role_name format a40
column mapped_to format a24
select data_role as role_name, mapped_to, enabled_by_default
  from dba_data_roles
 order by data_role;

prompt
prompt DBA_DATA_GRANTS: every grant, its privilege, and authorized column.
column grant_name format a32
column privilege format a10
column column_name format a20
column grantee format a40
select grant_name, privilege, column_name, grantee
  from dba_data_grants
 where object_owner = 'APPLAB'
 order by grant_name, privilege, column_name;

prompt
prompt Predicate for each grant, shown once rather than once per column.
column predicate format a70
select distinct grant_name, predicate
  from dba_data_grants
 where object_owner = 'APPLAB'
 order by grant_name;

prompt
column role_type format a13
column grantee_type format a17
prompt DBA_DATA_ROLE_GRANTS: which roles are granted to which data roles or end users.
select role_type, data_role as role_name, grantee, grantee_type
  from dba_data_role_grants
 order by role_type, data_role, grantee;

prompt
prompt DBA_END_USERS: every local end user and their account status.
column username format a20
column account_status format a20
column created_date format a12 heading "CREATED_DATE"
select username, account_status, created_date
  from dba_end_users
 order by username;

prompt
prompt DBA_END_USER_CONTEXT_DEFINITIONS: any custom end user contexts defined so far.
column context_owner format a15
column context_name format a16
column handler_package format a24
column handler_procedure format a24
column handler_status format a14
select context_owner, context_name, handler_package, handler_procedure, handler_status
  from dba_end_user_context_definitions
 where context_owner = 'APPLAB';

prompt
prompt Review complete. The detailed column matrix appears on later Review pages.
