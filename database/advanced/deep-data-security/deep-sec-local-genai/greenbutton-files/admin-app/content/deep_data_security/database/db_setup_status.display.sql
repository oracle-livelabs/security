-- Run as an ADB administrator, read-only, changes nothing.

-- 1. Confirm the schema exists.
SELECT USERNAME, ACCOUNT_STATUS, CREATED FROM DBA_USERS WHERE USERNAME = 'APPLAB';

-- 2. Confirm the table exists and how many rows it holds.
SELECT T.TABLE_NAME,
       (SELECT COUNT(*) FROM APPLAB.CUSTOMERS) AS ROW_COUNT
  FROM ALL_TABLES T
 WHERE T.OWNER = 'APPLAB' AND T.TABLE_NAME = 'CUSTOMERS';

-- 3. Confirm the role and its system privileges.
SELECT R.ROLE AS DATABASE_ROLE,
       P.PRIVILEGE AS SYSTEM_PRIVILEGE
  FROM DBA_ROLES R
  JOIN DBA_SYS_PRIVS P ON P.GRANTEE = R.ROLE
 WHERE R.ROLE = 'HOL_DBROLE_CONNECT';
