-- Run as an ADB administrator, after create_manager_context.sql.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt A session also needs authorization to read the context object itself,
prompt separate from being able to execute its handler package.

prompt SQL> GRANT UPDATE ANY END USER CONTEXT TO APPLAB
grant update any end user context to applab;

prompt SQL> CREATE ROLE HOL_DBROLE_MGR_CTX_ADMIN (if needed)
begin
  execute immediate 'create role hol_dbrole_mgr_ctx_admin';
exception
  when others then
    if sqlcode != -1921 then raise; end if;
end;
/
prompt SQL> GRANT EXECUTE ON APPLAB.MGR_CTX_PKG TO HOL_DBROLE_MGR_CTX_ADMIN
grant execute on APPLAB.mgr_ctx_pkg to hol_dbrole_mgr_ctx_admin;
prompt SQL> GRANT HOL_DBROLE_MGR_CTX_ADMIN TO HOL_DATAROLE_EMPLOYEE_ACCESS, HOL_DATAROLE_MANAGER_ACCESS
grant hol_dbrole_mgr_ctx_admin to hol_datarole_employee_access;
grant hol_dbrole_mgr_ctx_admin to hol_datarole_manager_access;

prompt SQL> CREATE OR REPLACE DATA GRANT APPLAB.MGR_CTX_ACCESS AS SELECT ON SYS.END_USER_CONTEXT WHERE OWNER = 'APPLAB' AND NAME = 'MGR_CTX' TO HOL_DATAROLE_EMPLOYEE_ACCESS, HOL_DATAROLE_MANAGER_ACCESS
create or replace data grant APPLAB.mgr_ctx_access
  as select
  on sys.end_user_context
  where owner = 'APPLAB' and name = 'MGR_CTX'
  to hol_datarole_employee_access, hol_datarole_manager_access;

prompt Context is now readable. The manager data grant, built next, uses
prompt a plain equality against ora_end_user_context.APPLAB.MGR_CTX.id.
