-- Run as an ADB administrator. Removes only objects created by this lab.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt SQL> DROP END USER MARVIN (if it exists)
begin execute immediate 'drop end user marvin'; exception when others then if sqlcode != -52515 then raise; end if; end;
/
prompt SQL> DROP END USER EMMA (if it exists)
begin execute immediate 'drop end user emma'; exception when others then if sqlcode != -52515 then raise; end if; end;
/
prompt SQL> DROP END USER CONTEXT APPLAB.MGR_CTX (if it exists)
declare
  v_count number;
begin
  select count(*) into v_count
    from dba_end_user_context_definitions
   where context_owner = 'APPLAB'
     and context_name = 'MGR_CTX';
  if v_count > 0 then
    execute immediate 'drop end user context applab.mgr_ctx';
  end if;
end;
/
prompt SQL> DROP PACKAGE APPLAB.MGR_CTX_PKG (if it exists)
declare
  v_count number;
begin
  select count(*) into v_count
    from all_objects
   where owner = 'APPLAB'
     and object_name = 'MGR_CTX_PKG'
     and object_type = 'PACKAGE';
  if v_count > 0 then
    execute immediate 'drop package applab.mgr_ctx_pkg';
  end if;
end;
/
prompt SQL> DROP USER APPLAB CASCADE (if it exists)
begin execute immediate 'drop user applab cascade'; exception when others then if sqlcode != -1918 then raise; end if; end;
/
prompt SQL> DROP DATA ROLE HOL_DATAROLE_EMPLOYEE_ACCESS (if it exists)
begin execute immediate 'drop data role hol_datarole_employee_access'; exception when others then if sqlcode != -52507 then raise; end if; end;
/
prompt SQL> DROP DATA ROLE HOL_DATAROLE_MANAGER_ACCESS (if it exists)
begin execute immediate 'drop data role hol_datarole_manager_access'; exception when others then if sqlcode != -52507 then raise; end if; end;
/
prompt SQL> DROP ROLE HOL_DBROLE_CONNECT (if it exists)
begin execute immediate 'drop role hol_dbrole_connect'; exception when others then if sqlcode != -1919 then raise; end if; end;
/

prompt SQL> DROP ROLE HOL_DBROLE_ORDER_HISTORY_QUERY (if it exists)
begin execute immediate 'drop role hol_dbrole_order_history_query'; exception when others then if sqlcode != -1919 then raise; end if; end;
/
prompt SQL> DROP ROLE HOL_DBROLE_MGR_CTX_ADMIN (if it exists)
begin execute immediate 'drop role hol_dbrole_mgr_ctx_admin'; exception when others then if sqlcode != -1919 then raise; end if; end;
/
prompt Reset complete: schema, context, package, both end users, and
prompt every role and data role this lab created have been removed.
