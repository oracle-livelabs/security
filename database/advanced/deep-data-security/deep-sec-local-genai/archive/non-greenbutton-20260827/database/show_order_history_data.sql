-- Run as ADB ADMIN. Read-only. ORDER_HISTORY remains backed by Iceberg files
-- in Object Storage; this is ordinary SQL against the external table.
whenever sqlerror exit sql.sqlcode rollback
set echo off
set pagesize 100
set linesize 200

prompt SQL> SELECT COUNT(*) FROM APPLAB.ORDER_HISTORY
select count(*) as order_history_rows
  from APPLAB.order_history;

prompt
prompt SQL> Five most recent orders from APPLAB.ORDER_HISTORY
column order_id format 9999999999
column customer_id format 9999999999
column order_date format a12
column sales_rep format a16
column product_category format a20
column amount format 9999990.00
select order_id,
       customer_id,
       to_char(order_date, 'YYYY-MM-DD') as order_date,
       sales_rep,
       product_category,
       amount
  from APPLAB.order_history
 order by order_date desc, order_id desc
 fetch first 5 rows only;

prompt ORDER_HISTORY returned Iceberg rows through ordinary SQL; no data was copied into Oracle.
