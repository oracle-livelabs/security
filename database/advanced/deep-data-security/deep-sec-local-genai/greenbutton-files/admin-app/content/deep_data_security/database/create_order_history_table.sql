-- Run as the prepared APPLAB lab schema after the deployment publishes the
-- pre-created Order History Iceberg bundle. The administrator bootstrap
-- grants APPLAB the required privileges before this action runs.
-- Read the published metadata JSON directly. No catalog traversal setting or
-- custom metadata rewrite is used by this database-side statement.
whenever sqlerror exit sql.sqlcode rollback
set echo off

-- The deployment grants APPLAB CREATE SESSION, DWROLE, EXECUTE on DBMS_CLOUD,
-- and direct DATA_PUMP_DIR access while connected as ADMIN. Keep this block
-- idempotent for an administrator who copies the script manually, but make it
-- a no-op for the APPLAB session that owns the external table.
begin
  if sys_context('USERENV', 'SESSION_USER') = 'ADMIN' then
    execute immediate 'grant dwrole to APPLAB';
    execute immediate 'grant execute on dbms_cloud to APPLAB';
    execute immediate 'grant read, write on directory data_pump_dir to APPLAB';
  end if;
end;
/

prompt SQL> Verify APPLAB can resolve DATA_PUMP_DIR from definer-rights PL/SQL
create or replace procedure APPLAB.verify_data_pump_dir
authid definer
as
  l_directory_path all_directories.directory_path%type;
begin
  select directory_path
    into l_directory_path
    from all_directories
   where directory_name = 'DATA_PUMP_DIR';
end;
/
begin
  APPLAB.verify_data_pump_dir;
end;
/
drop procedure APPLAB.verify_data_pump_dir;

-- ORDER_HISTORY_CREDENTIAL_SETUP

prompt SQL> Use the outbound HTTPS ACL prepared for APPLAB and the ADMIN setup session

prompt SQL> DROP TABLE APPLAB.ORDER_HISTORY (if it exists, external definition only)
begin
  execute immediate 'drop table APPLAB.order_history purge';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/

prompt SQL> CREATE EXTERNAL TABLE APPLAB.ORDER_HISTORY (published Iceberg metadata JSON)
-- Do not supply a manual column list: DBMS_CLOUD derives the schema from
-- the published Iceberg metadata JSON.
create or replace procedure APPLAB.create_order_history_external_table
authid definer
as
begin
  dbms_cloud.create_external_table(
    table_name      => 'ORDER_HISTORY',
    credential_name => 'READER_CREDENTIAL_NAME',
    file_uri_list   => '<order_history_metadata_url>',
    format          => json_object(
                         'access_protocol' value json_object(
                           'protocol_type' value 'iceberg'
                         )
                       )
  );
end;
/
begin
  APPLAB.create_order_history_external_table;
end;
/
drop procedure APPLAB.create_order_history_external_table;

prompt SQL> Verify APPLAB can read an actual Iceberg row
create or replace procedure APPLAB.verify_order_history_row_access
authid definer
as
  l_order_id APPLAB.order_history.order_id%type;
begin
  select order_id
    into l_order_id
    from APPLAB.order_history
   where rownum = 1;
exception
  when no_data_found then
    raise_application_error(-20002, 'Iceberg ORDER_HISTORY returned no rows.');
end;
/
begin
  APPLAB.verify_order_history_row_access;
end;
/
drop procedure APPLAB.verify_order_history_row_access;

prompt ORDER_HISTORY is now queryable as a normal table, backed by Iceberg
prompt files in Object Storage, no data grant on it yet.
