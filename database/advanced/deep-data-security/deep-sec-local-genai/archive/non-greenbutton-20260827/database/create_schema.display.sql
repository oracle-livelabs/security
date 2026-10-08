-- Run as an ADB administrator. This fixed lab uses the APPLAB schema.

-- 1. Drop the APPLAB schema if a previous run left one behind, so every
--    lab starts from a clean, predictable state.
DROP USER APPLAB CASCADE;

-- 2. Create the APPLAB schema owner. This is an internal schema-owner
--    account only, no one signs in to the application as APPLAB, and its
--    password is generated fresh each run, never displayed or stored.
CREATE USER APPLAB IDENTIFIED BY <randomly generated at run time>;
-- APPLAB owns objects but never signs in, so it gets no CREATE SESSION.
GRANT CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE TO APPLAB;
ALTER USER APPLAB QUOTA 500M ON DATA;

-- 3. Create the customer table APPLAB owns. Data roles and data grants,
--    created in a later step, determine what MARVIN and EMMA can retrieve
--    from this table, this step only creates the table itself.
CREATE TABLE APPLAB.CUSTOMERS (
  CUSTOMER_ID           NUMBER PRIMARY KEY,
  CUSTOMER_NAME         VARCHAR2(100) NOT NULL,
  REGION                VARCHAR2(20)  NOT NULL,
  SALES_REP             VARCHAR2(100) NOT NULL,
  MANAGER_ID            NUMBER,
  REVENUE               NUMBER NOT NULL,
  CREDIT_LIMIT          NUMBER NOT NULL,
  SENSITIVE_IDENTIFIER  VARCHAR2(50)  NOT NULL
);

CREATE INDEX APPLAB.CUSTOMERS_SALES_REP_IX ON APPLAB.CUSTOMERS (SALES_REP);
