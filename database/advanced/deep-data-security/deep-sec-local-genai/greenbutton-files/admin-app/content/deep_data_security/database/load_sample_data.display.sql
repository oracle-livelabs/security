-- Run as ADB admin after create_schema.sql. Fixed sample data
-- makes the employee and manager row counts predictable for every lab run.

-- 1. Work in APPLAB and replace prior rows so this reruns safely.
ALTER SESSION SET CURRENT_SCHEMA = APPLAB;
DELETE FROM APPLAB.CUSTOMERS;

-- 2. Load the 22 customers. MARVIN owns three CENTRAL rows, EMMA owns six
--    WEST rows, and the FINANCE rows remain outside the sales hierarchy.
INSERT ALL
  INTO CUSTOMERS VALUES ( 1, 'Acme East',       'EAST', 'PRIYA',   2,  920000, 180000, 'E-1001-SSN')
  INTO CUSTOMERS VALUES ( 2, 'Beacon Health',   'EAST', 'PRIYA',   2,  870000, 160000, 'E-1002-SSN')
  INTO CUSTOMERS VALUES ( 3, 'Cedar Retail',    'EAST', 'PRIYA',   2,  760000, 150000, 'E-1003-SSN')
  INTO CUSTOMERS VALUES ( 4, 'Delta Foods',     'EAST', 'PRIYA',   2,  650000, 125000, 'E-1004-SSN')
  INTO CUSTOMERS VALUES ( 5, 'Evergreen Labs',  'EAST', 'PRIYA',   2,  590000, 115000, 'E-1005-SSN')
  INTO CUSTOMERS VALUES ( 6, 'Frontier Goods',  'WEST', 'EMMA',    1,  980000, 190000, 'W-2001-SSN')
  INTO CUSTOMERS VALUES ( 7, 'Granite Media',   'WEST', 'EMMA',    1,  840000, 165000, 'W-2002-SSN')
  INTO CUSTOMERS VALUES ( 8, 'Harbor Systems',  'WEST', 'EMMA',    1,  720000, 145000, 'W-2003-SSN')
  INTO CUSTOMERS VALUES ( 9, 'Ironwood Bank',   'WEST', 'EMMA',    1,  680000, 130000, 'W-2004-SSN')
  INTO CUSTOMERS VALUES (10, 'Juniper Works',   'WEST', 'EMMA',    1,  610000, 120000, 'W-2005-SSN')
  INTO CUSTOMERS VALUES (11, 'Keystone Energy', 'CENTRAL', 'MARVIN', NULL, 1030000, 200000, 'C-3001-SSN')
  INTO CUSTOMERS VALUES (12, 'Lumen Freight',   'CENTRAL', 'MARVIN', NULL,  810000, 155000, 'C-3002-SSN')
  INTO CUSTOMERS VALUES (13, 'Meridian Hotel',  'CENTRAL', 'MARVIN', NULL,  740000, 140000, 'C-3003-SSN')
  INTO CUSTOMERS VALUES (14, 'Northstar Co',    'SOUTH', 'PRIYA',   2,  690000, 135000, 'S-4001-SSN')
  INTO CUSTOMERS VALUES (15, 'Oak & Pine',      'SOUTH', 'PRIYA',   2,  560000, 110000, 'S-4002-SSN')
  INTO CUSTOMERS VALUES (16, 'Pioneer Group',   'NORTH', 'PRIYA',   2,  520000, 105000, 'N-5001-SSN')
  INTO CUSTOMERS VALUES (17, 'Quartz Design',   'NORTH', 'PRIYA',   2,  490000, 100000, 'N-5002-SSN')
  INTO CUSTOMERS VALUES (18, 'Redwood Travel',  'EAST', 'PRIYA',   2,  430000,  90000, 'E-1006-SSN')
  INTO CUSTOMERS VALUES (19, 'Summit Auto',     'WEST', 'EMMA',    1,  410000,  85000, 'W-2006-SSN')
  INTO CUSTOMERS VALUES (20, 'Tidal Markets',   'SOUTH', 'PRIYA',  2,  390000,  80000, 'S-4003-SSN')
  INTO CUSTOMERS VALUES (21, 'Apex Treasury',   'NORTH', 'FINANCE', NULL, 1110000, 275000, 'F-6001-TAX')
  INTO CUSTOMERS VALUES (22, 'Crown Capital',   'SOUTH', 'FINANCE', NULL, 1200000, 310000, 'F-6002-TAX')
SELECT 1 FROM DUAL;

-- 3. Commit the deterministic dataset used by the later data grants.
COMMIT;

-- 4. Gather statistics so NUM_ROWS and other optimizer stats are accurate
--    immediately, not left stale until the next scheduled stats job.
EXEC DBMS_STATS.GATHER_TABLE_STATS('APPLAB', 'CUSTOMERS');
