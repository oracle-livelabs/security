-- A compact lookup maps each manager to the ID number used by the context.

-- 1. Recreate the manager lookup for a predictable lab reset.
DROP TABLE APPLAB.MANAGERS PURGE;
CREATE TABLE APPLAB.MANAGERS (
  MANAGER_NAME VARCHAR2(100) PRIMARY KEY,
  MANAGER_ID   NUMBER NOT NULL UNIQUE
);

-- 2. Record the IDs used for manager context resolution.
INSERT INTO APPLAB.MANAGERS (MANAGER_NAME, MANAGER_ID) VALUES ('MARVIN', 1);
INSERT INTO APPLAB.MANAGERS (MANAGER_NAME, MANAGER_ID) VALUES ('PRIYA', 2);
COMMIT;
