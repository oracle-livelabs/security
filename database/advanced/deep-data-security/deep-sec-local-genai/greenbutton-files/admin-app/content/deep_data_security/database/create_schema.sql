-- Run as an ADB administrator. This fixed lab uses the APPLAB schema.

whenever sqlerror exit sql.sqlcode rollback
set echo off
set verify off

define applab_password = &APPLAB_PASSWORD

prompt Preparing a clean APPLAB schema for the lab data.
prompt SQL> DROP USER APPLAB CASCADE (if it already exists)
begin
  execute immediate 'drop user APPLAB cascade';
exception
  when others then
    if sqlcode != -1918 then raise; end if;
end;
/

prompt SQL> CREATE USER APPLAB IDENTIFIED BY "<protected setup password, never displayed>"
create user APPLAB identified by "&applab_password";
PROMPT Grant ADMIN and APPLAB outbound HTTPS access to Object Storage.
PROMPT This will be used when Apache Iceberg is configured as an external table.
declare
  procedure grant_oraclecloud_https(p_host varchar2, p_principal varchar2) is
  begin
    dbms_network_acl_admin.append_host_ace(
      host           => p_host,
      lower_port     => 443,
      upper_port     => 443,
      ace            => xs$ace_type(
                          privilege_list => xs$name_list('http', 'http_proxy'),
                          principal_name => p_principal,
                          principal_type => xs_acl.ptype_db
                        )
    );
  exception
    when others then
      if sqlcode != -24243 then raise; end if;
  end;
begin
  grant_oraclecloud_https('*.oraclecloud.com', 'ADMIN');
  grant_oraclecloud_https('*.oraclecloud.com', 'APPLAB');
end;
/
prompt SQL> GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE TO APPLAB
prompt APPLAB is the pre-created lab schema used to own and create lesson objects.
grant create session, create table, create procedure, create sequence to APPLAB;
prompt SQL> GRANT DWROLE TO APPLAB
grant dwrole to APPLAB;
prompt SQL> GRANT EXECUTE ON DBMS_CLOUD TO APPLAB
grant execute on dbms_cloud to APPLAB;
prompt SQL> GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO APPLAB
grant read, write on directory data_pump_dir to APPLAB;
prompt SQL> ALTER USER APPLAB QUOTA 500M ON DATA
alter user APPLAB quota 500m on data;

-- Stay connected as admin for the rest of the lesson setup. APPLAB owns the
-- table and can also create its own external objects; MARVIN is the local end
-- user used for validation.
prompt SQL> CREATE TABLE APPLAB.CUSTOMERS (... customer data and sensitive columns ...)
prompt Later data roles and grants decide what MARVIN sees.
create table APPLAB.customers (
  customer_id          number primary key,
  customer_name        varchar2(100) not null,
  region               varchar2(20) not null,
  sales_rep            varchar2(100) not null,
  manager_id           number,
  revenue              number not null,
  credit_limit         number not null,
  sensitive_identifier varchar2(50) not null
);

prompt SQL> CREATE INDEX APPLAB.CUSTOMERS_SALES_REP_IX ON APPLAB.CUSTOMERS (SALES_REP)
create index APPLAB.customers_sales_rep_ix on APPLAB.customers (sales_rep);
prompt APPLAB schema is ready for sample customer data.
undefine applab_password
undefine APPLAB_PASSWORD
