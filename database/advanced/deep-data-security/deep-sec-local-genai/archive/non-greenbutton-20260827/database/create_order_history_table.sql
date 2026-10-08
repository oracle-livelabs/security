-- Run as ADB ADMIN. Points Oracle at pre-generated Iceberg files in the
-- wallet bucket. The files are written once by setup/generate_order_history_iceberg.py.
whenever sqlerror exit sql.sqlcode rollback
set echo off

prompt SQL> Grant APPLAB the database privileges required to own an Iceberg external table
grant dwrole to APPLAB;
grant execute on dbms_cloud to APPLAB;
prompt SQL> GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO APPLAB
-- DBMS_CLOUD creates the external-table definition with DATA_PUMP_DIR as its
-- default directory. This must be a direct grant because the call runs in an
-- APPLAB definer-rights procedure; privileges delivered only through DWROLE
-- are not available there.
grant read, write on directory data_pump_dir to APPLAB;

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

prompt SQL> Allow APPLAB and the ADMIN setup session outbound HTTPS access to Oracle Cloud
begin
  for l_principal in (select 'APPLAB' principal_name from dual union all select 'ADMIN' from dual) loop
    dbms_network_acl_admin.append_host_ace(
      host           => '*.oraclecloud.com',
      lower_port     => 443,
      upper_port     => 443,
      ace            => xs$ace_type(
                          privilege_list => xs$name_list('http'),
                          principal_name => l_principal.principal_name,
                          principal_type => xs_acl.ptype_db
                        )
    );
  end loop;
end;
/

prompt SQL> Verify APPLAB can read the native Iceberg metadata object
create or replace procedure APPLAB.verify_order_history_metadata_access
authid definer
as
  l_metadata_blob blob;
begin
  l_metadata_blob := dbms_cloud.get_object(
    credential_name => 'READER_CREDENTIAL_NAME',
    object_uri      => '<order_history_metadata_url>'
  );

  if dbms_lob.getlength(l_metadata_blob) = 0 then
    raise_application_error(-20001, 'Iceberg metadata object is empty.');
  end if;
end;
/
begin
  APPLAB.verify_order_history_metadata_access;
end;
/
drop procedure APPLAB.verify_order_history_metadata_access;

prompt SQL> DROP TABLE APPLAB.ORDER_HISTORY (if it exists, external definition only)
begin
  execute immediate 'drop table APPLAB.order_history purge';
exception
  when others then
    if sqlcode != -942 then raise; end if;
end;
/

prompt SQL> CREATE EXTERNAL TABLE APPLAB.ORDER_HISTORY (Iceberg metadata URI)
-- DBMS_CLOUD reads the Iceberg metadata and derives the columns itself.
-- Do not supply a manual column list for an Iceberg external table.
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
