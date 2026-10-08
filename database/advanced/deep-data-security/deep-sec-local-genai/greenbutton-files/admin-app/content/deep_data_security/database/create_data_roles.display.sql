-- Run as ADB ADMIN before creating local end users.
-- Data roles receive database roles and data grants. They do not receive
-- system privileges directly.

CREATE OR REPLACE DATA ROLE HOL_DATAROLE_EMPLOYEE_ACCESS;
CREATE OR REPLACE DATA ROLE HOL_DATAROLE_MANAGER_ACCESS;

GRANT HOL_DBROLE_CONNECT TO HOL_DATAROLE_EMPLOYEE_ACCESS;

-- This permits the eventual external-table query to resolve DATA_PUMP_DIR.
-- It does not authorize ORDER_HISTORY data; the later data grant does that.
GRANT HOL_DBROLE_ORDER_HISTORY_QUERY TO HOL_DATAROLE_EMPLOYEE_ACCESS;
