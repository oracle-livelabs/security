-- Run as the connected local end user. Flask uses the same query.
-- same broad query before and after every authorization change.

-- 1. Request every customer column, sorted by revenue. Active data
--    grants decide which rows and columns are actually returned.
SELECT *
  FROM APPLAB.CUSTOMERS
 ORDER BY REVENUE DESC;

-- 2. Show the authenticated end user Oracle used for authorization.
SELECT ORA_END_USER_CONTEXT.USERNAME AS END_USER FROM DUAL;

-- 3. Show the active Deep Sec data roles for this session.
SELECT ROLE_NAME AS ACTIVE_DATA_ROLE
  FROM V$END_USER_DATA_ROLE
 ORDER BY ROLE_NAME;
