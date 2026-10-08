-- Run as an ADB administrator. This fixed lab uses the APPLAB schema.

-- 1. Drop the APPLAB schema if a previous run left one behind, so every
--    lab starts from a clean, predictable state.
DROP USER APPLAB CASCADE;

-- 2. Create the APPLAB lab schema. The deployment prepares it before the
--    lesson begins; it owns the lab objects and can create external objects
--    such as the Iceberg table.
CREATE USER APPLAB IDENTIFIED BY <protected setup password>;
PROMPT Grant ADMIN and APPLAB outbound HTTPS access to Object Storage.
PROMPT This will be used when Apache Iceberg is configured as an external table.
DECLARE
  PROCEDURE grant_oraclecloud_https(p_host VARCHAR2, p_principal VARCHAR2) IS
  BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host           => p_host,
      lower_port     => 443,
      upper_port     => 443,
      ace            => XS$ACE_TYPE(
                          privilege_list => XS$NAME_LIST('http', 'http_proxy'),
                          principal_name => p_principal,
                          principal_type => XS_ACL.PTYPE_DB
                        )
    );
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -24243 THEN RAISE; END IF;
  END;
BEGIN
  grant_oraclecloud_https('*.oraclecloud.com', 'ADMIN');
  grant_oraclecloud_https('*.oraclecloud.com', 'APPLAB');
END;
/
GRANT CREATE SESSION, CREATE TABLE, CREATE PROCEDURE, CREATE SEQUENCE TO APPLAB;
GRANT DWROLE TO APPLAB;
GRANT EXECUTE ON DBMS_CLOUD TO APPLAB;
GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO APPLAB;
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
