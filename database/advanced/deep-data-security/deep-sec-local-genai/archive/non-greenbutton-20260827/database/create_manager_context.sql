-- Run as an ADB administrator, after create_managers.sql.
-- Creates a session-scoped end user context and the PL/SQL package that
-- resolves the authenticated manager's own numeric ID.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt ORA_END_USER_CONTEXT.username is built in for every session.
prompt There is no built-in for "what is my manager ID." This
prompt step creates a custom context attribute for exactly that, resolved
prompt once per session, the first time it is read, from a lookup table.

prompt SQL> CREATE END USER CONTEXT APPLAB.MGR_CTX
create or replace end user context APPLAB.mgr_ctx using json schema '{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "o:onFirstRead": "APPLAB.mgr_ctx_pkg.init_manager_id"
    }
  }
}';

prompt SQL> CREATE PACKAGE APPLAB.MGR_CTX_PKG
prompt When ID is first read in a session, Oracle calls this procedure,
prompt which looks up the authenticated user's own manager_id and caches it
prompt for the rest of the session.
create or replace package APPLAB.mgr_ctx_pkg as
  procedure init_manager_id;
end;
/

create or replace package body APPLAB.mgr_ctx_pkg as
  procedure init_manager_id is
    v_id number;
    v_id_sql varchar2(40);
  begin
    begin
      select manager_id
        into v_id
        from APPLAB.managers
       where upper(manager_name) = upper(ora_end_user_context.username);
    exception
      when no_data_found then
        v_id := null;
    end;

    -- onFirstRead executes while Oracle is evaluating the calling SQL.
    -- END_USER_CONTEXT callbacks must issue their context update dynamically.
    v_id_sql := case
                  when v_id is null then 'null'
                  else to_char(v_id, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''')
                end;
    execute immediate
      'update end_user_context t set t.context.id = ' || v_id_sql ||
      q'[ where owner = 'APPLAB' and name = 'MGR_CTX']';
  end init_manager_id;
end;
/
