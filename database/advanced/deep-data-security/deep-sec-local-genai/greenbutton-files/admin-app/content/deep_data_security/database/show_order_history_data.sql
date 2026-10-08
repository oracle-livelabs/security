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

prompt
prompt Bigger picture: every Iceberg order belongs to an APPLAB customer.
prompt This read-only profile shows the complete dataset grouped by the
prompt customer's sales representative and manager relationship. It is not
prompt an authorization query; it simply maps where the order rows belong.
prompt
prompt SQL> All ORDER_HISTORY rows by EMPLOYEE_ID, SALES_REP, and MANAGER_ID
column customer_accounts format 9990
column order_rows format 9999990
column employee_id format a28
column sales_rep format a16
column manager_relationship format a22
select case
         when m.manager_id is null then 'No manager'
         else m.manager_name || ' (Manager ID ' || to_char(m.manager_id) || ')'
       end as employee_id,
       c.sales_rep,
       case
         when c.manager_id is null then 'No manager'
         else 'Manager ID ' || to_char(c.manager_id)
       end as manager_relationship,
       count(distinct c.customer_id) as customer_accounts,
       count(oh.order_id) as order_rows
  from APPLAB.customers c
  join APPLAB.order_history oh on oh.customer_id = c.customer_id
  left join APPLAB.managers m on m.manager_id = c.manager_id
 group by m.manager_id,
          m.manager_name,
          c.sales_rep,
          case
            when c.manager_id is null then 'No manager'
            else 'Manager ID ' || to_char(c.manager_id)
          end
 order by employee_id, c.sales_rep, manager_relationship;

prompt ORDER_HISTORY returned Iceberg rows through ordinary SQL; no data was copied into Oracle.
