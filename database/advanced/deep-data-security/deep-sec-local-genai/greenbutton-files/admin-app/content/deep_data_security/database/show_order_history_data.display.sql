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

-- Bigger picture: every Iceberg order maps to an APPLAB customer. This is a
-- complete data profile, grouped by the manager lookup, sales rep, and
-- manager ID; it does not apply any authorization rule.
SELECT CASE
         WHEN m.manager_id IS NULL THEN 'No manager'
         ELSE m.manager_name || ' (Manager ID ' || TO_CHAR(m.manager_id) || ')'
       END AS employee_id,
       c.sales_rep,
       CASE
         WHEN c.manager_id IS NULL THEN 'No manager'
         ELSE 'Manager ID ' || TO_CHAR(c.manager_id)
       END AS manager_relationship,
       COUNT(DISTINCT c.customer_id) AS customer_accounts,
       COUNT(oh.order_id) AS order_rows
  FROM APPLAB.customers c
  JOIN APPLAB.order_history oh ON oh.customer_id = c.customer_id
  LEFT JOIN APPLAB.managers m ON m.manager_id = c.manager_id
 GROUP BY m.manager_id,
          m.manager_name,
          c.sales_rep,
          CASE
            WHEN c.manager_id IS NULL THEN 'No manager'
            ELSE 'Manager ID ' || TO_CHAR(c.manager_id)
          END
 ORDER BY employee_id, c.sales_rep, manager_relationship;

-- Ordinary SQL returns rows from Iceberg. No data is copied into Oracle.
