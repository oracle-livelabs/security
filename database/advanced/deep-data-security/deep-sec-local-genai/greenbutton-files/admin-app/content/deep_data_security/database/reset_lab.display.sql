-- Run as ADB admin. Removes only objects this lab created, so
-- the initial setup action can recreate a clean, predictable environment.

-- 1. Remove Marvin and Emma, the two local end users.
DROP END USER MARVIN;
DROP END USER EMMA;

-- 2. Remove the custom end-user context and its PL/SQL handler package.
DROP END USER CONTEXT APPLAB.MGR_CTX;
DROP PACKAGE APPLAB.MGR_CTX_PKG;

-- 3. Remove APPLAB and every schema object it owns: customer and manager
--    tables, data grants, and any remaining PL/SQL objects.
DROP USER APPLAB CASCADE;

-- 4. Remove the data roles and the ordinary database roles.
DROP DATA ROLE HOL_DATAROLE_EMPLOYEE_ACCESS;
DROP DATA ROLE HOL_DATAROLE_MANAGER_ACCESS;
DROP ROLE HOL_DBROLE_CONNECT;
DROP ROLE HOL_DBROLE_ORDER_HISTORY_QUERY;
DROP ROLE HOL_DBROLE_MGR_CTX_ADMIN;
