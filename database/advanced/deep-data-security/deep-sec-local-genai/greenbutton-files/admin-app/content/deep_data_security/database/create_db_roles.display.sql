-- Run as an ADB administrator. This creates an ordinary Oracle role,
-- not a Deep Data Security data role.

-- 1. Create a plain role that grants nothing but the ability to connect.
CREATE ROLE HOL_DBROLE_CONNECT;
GRANT CREATE SESSION TO HOL_DBROLE_CONNECT;

-- 2. This ordinary role lets a session resolve DATA_PUMP_DIR when it queries
--    the Iceberg-backed ORDER_HISTORY external table. It grants no table data.
CREATE ROLE HOL_DBROLE_ORDER_HISTORY_QUERY;
GRANT READ ON DIRECTORY DATA_PUMP_DIR TO HOL_DBROLE_ORDER_HISTORY_QUERY;

-- Nothing here touches Deep Data Security. A later page attaches these
-- roles to a data role once it exists.
