-- Run as ADB ADMIN. Creates the initial, deliberately broad employee grant.
-- Bare SELECT grants every column; no WHERE clause grants every row.
CREATE OR REPLACE DATA GRANT APPLAB.EMPLOYEE_CUSTOMER_ACCESS
  AS SELECT
  ON APPLAB.CUSTOMERS
  TO HOL_DATAROLE_EMPLOYEE_ACCESS;
