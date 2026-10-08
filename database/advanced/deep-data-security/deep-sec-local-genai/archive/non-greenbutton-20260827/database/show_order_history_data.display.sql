-- Run as ADB ADMIN. Read-only.
-- ORDER_HISTORY is still backed by the same Iceberg files in Object Storage.

SELECT COUNT(*) AS order_history_rows
  FROM APPLAB.order_history;

SELECT order_id,
       customer_id,
       TO_CHAR(order_date, 'YYYY-MM-DD') AS order_date,
       sales_rep,
       product_category,
       amount
  FROM APPLAB.order_history
 ORDER BY order_date DESC, order_id DESC
 FETCH FIRST 5 ROWS ONLY;

-- Ordinary SQL returns rows from Iceberg. No data is copied into Oracle.
