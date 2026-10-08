-- Run as ADB ADMIN. Read-only. A comprehensive snapshot of every Deep
-- Data Security object created so far, not scoped to one page, safe to
-- rerun anywhere in the lab.
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
column grant_name format a32
column predicate format a70
select distinct grant_name, predicate
  from dba_data_grants
 where object_owner = 'APPLAB'
 order by grant_name;

prompt
prompt Summary: how many columns each grant authorizes on its own object,
prompt plus whether its row-level DELETE privilege is present.
column grant_name format a32
column object_name format a16
column can_delete format a10
with grants as (
  select distinct grant_name, object_name
    from dba_data_grants
   where object_owner = 'APPLAB'
),
obj_cols as (
  select table_name as object_name, column_name, column_id
    from all_tab_columns
   where owner = 'APPLAB'
),
grant_priv as (
  select g.grant_name, g.object_name, g.privilege, c.column_name
    from dba_data_grants g
    join obj_cols c on c.object_name = g.object_name and (g.column_name = c.column_name or g.column_name is null)
   where g.object_owner = 'APPLAB'
     and g.privilege in ('SELECT', 'UPDATE')
),
grant_delete as (
  select distinct grant_name, object_name
    from dba_data_grants
   where object_owner = 'APPLAB' and privilege = 'DELETE'
)
select gr.grant_name,
       gr.object_name,
       (select count(*) from obj_cols oc2 where oc2.object_name = gr.object_name) as total_columns,
       count(distinct case when gp.privilege = 'SELECT' then gp.column_name end) as select_columns,
       count(distinct case when gp.privilege = 'UPDATE' then gp.column_name end) as update_columns,
       case when gd.grant_name is not null then 'YES' else 'NO' end as can_delete
  from grants gr
  left join grant_priv gp on gp.grant_name = gr.grant_name
  left join grant_delete gd on gd.grant_name = gr.grant_name
 group by gr.grant_name, gr.object_name, gd.grant_name
 order by gr.object_name, gr.grant_name;

prompt
prompt Column-level authorization matrix: every real column on each grant's
prompt own object, cross-referenced against that grant. NO/NO means no
prompt SELECT or UPDATE on that column, that's where sensitive_identifier
prompt should show up for every customer grant except full access, and
prompt where amount should show up once excluded on order history. CAN_DELETE
prompt is row-level, not per-column, it repeats the same value for every
prompt row of a given grant since Oracle does not scope DELETE by column.
column grant_name format a32
column object_name format a16
column column_name format a20
column can_select format a10
column can_update format a10
column can_delete format a10
with grants as (
  select distinct grant_name, object_name
    from dba_data_grants
   where object_owner = 'APPLAB'
),
obj_cols as (
  select table_name as object_name, column_name, column_id
    from all_tab_columns
   where owner = 'APPLAB'
),
grant_priv as (
  select g.grant_name, g.object_name, g.privilege, c.column_name
    from dba_data_grants g
    join obj_cols c on c.object_name = g.object_name and (g.column_name = c.column_name or g.column_name is null)
   where g.object_owner = 'APPLAB'
     and g.privilege in ('SELECT', 'UPDATE')
),
grant_delete as (
  select distinct grant_name, object_name
    from dba_data_grants
   where object_owner = 'APPLAB' and privilege = 'DELETE'
)
select gr.grant_name,
       gr.object_name,
       oc.column_name,
       case when max(case when gp.privilege = 'SELECT' and gp.column_name = oc.column_name then 1 end) = 1 then 'YES' else 'NO' end as can_select,
       case when max(case when gp.privilege = 'UPDATE' and gp.column_name = oc.column_name then 1 end) = 1 then 'YES' else 'NO' end as can_update,
       case when gd.grant_name is not null then 'YES' else 'NO' end as can_delete
  from grants gr
  join obj_cols oc on oc.object_name = gr.object_name
  left join grant_priv gp on gp.grant_name = gr.grant_name and gp.column_name = oc.column_name
  left join grant_delete gd on gd.grant_name = gr.grant_name
 group by gr.grant_name, gr.object_name, oc.column_name, oc.column_id, gd.grant_name
 order by gr.object_name, gr.grant_name, oc.column_id;

prompt
column role_type format a13
column role_name format a40
column grantee format a40
column grantee_type format a17
prompt DBA_DATA_ROLE_GRANTS: which roles are granted
prompt to which data roles or end users.
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
prompt DBA_END_USER_CONTEXT_DEFINITIONS: any custom end user contexts
prompt defined so far. Empty here is expected, this exists once you reach
prompt the End User Context page.
column context_owner format a15
column context_name format a16
column handler_package format a24
column handler_procedure format a24
column handler_status format a14
select context_owner, context_name, handler_package, handler_procedure, handler_status
  from dba_end_user_context_definitions
 where context_owner = 'APPLAB';

prompt
prompt Review complete. This same script works anywhere later in the lab,
prompt rerun once the manager context exists to see it fill in.
