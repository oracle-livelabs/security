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

prompt SQL> CREATE USER APPLAB IDENTIFIED BY "<internal password, generated fresh each run, never displayed or stored>"
create user APPLAB identified by "&applab_password";
prompt SQL> GRANT CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE TO APPLAB
prompt APPLAB is a schema owner, not a login, so it gets no CREATE SESSION.
grant create table, create procedure, create sequence to APPLAB;
prompt SQL> ALTER USER APPLAB QUOTA 500M ON DATA
alter user APPLAB quota 500m on data;

-- Stay connected as admin. APPLAB owns the table,
-- while MARVIN is the local end user used for validation.
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
