-- What this step does. Safe to copy — no live secrets appear here.
-- The deployment prepares APPLAB before this step. Run the generated lesson
-- script as APPLAB so its credential and external table are owned by APPLAB.

-- 1. The administrator bootstrap has already granted APPLAB CREATE SESSION,
--    DWROLE, EXECUTE ON DBMS_CLOUD, and direct DATA_PUMP_DIR access.

-- Prove the direct directory grant works in APPLAB definer-rights PL/SQL,
-- the same execution model used for CREATE_EXTERNAL_TABLE below.
CREATE OR REPLACE PROCEDURE APPLAB.VERIFY_DATA_PUMP_DIR
AUTHID DEFINER
AS
  l_directory_path ALL_DIRECTORIES.DIRECTORY_PATH%TYPE;
BEGIN
  SELECT directory_path
    INTO l_directory_path
    FROM all_directories
   WHERE directory_name = 'DATA_PUMP_DIR';
END;
/
BEGIN
  APPLAB.VERIFY_DATA_PUMP_DIR;
END;
/
DROP PROCEDURE APPLAB.VERIFY_DATA_PUMP_DIR;
/

-- 2. The administrator bootstrap has already permitted HTTPS and proxy
--    traversal for the Oracle Cloud endpoints used by Iceberg.

-- 3. Drop only an existing database external-table definition. This does not
--    delete the Iceberg files in Object Storage.
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE APPLAB.ORDER_HISTORY PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 4. Define an Iceberg external table from the published Iceberg metadata JSON.
--    DBMS_CLOUD derives its columns; no manual column list is valid.
--    The metadata JSON is the entry point to the complete Iceberg graph.
BEGIN
  DBMS_CLOUD.CREATE_EXTERNAL_TABLE(
    table_name      => 'ORDER_HISTORY',
    credential_name => 'READER_CREDENTIAL_NAME',
    file_uri_list   => '<order_history_metadata_url>',
    format          => JSON_OBJECT(
                         'access_protocol' VALUE JSON_OBJECT(
                           'protocol_type' VALUE 'iceberg'
                         )
                       )
  );
END;
/

-- 5. Fetch an actual row as the APPLAB table owner. This catches an external
--    table that was created but cannot traverse its Iceberg data files.
CREATE OR REPLACE PROCEDURE APPLAB.VERIFY_ORDER_HISTORY_ROW_ACCESS
AUTHID DEFINER
AS
  l_order_id APPLAB.ORDER_HISTORY.ORDER_ID%TYPE;
BEGIN
  SELECT order_id
    INTO l_order_id
    FROM APPLAB.ORDER_HISTORY
   WHERE ROWNUM = 1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20002, 'Iceberg ORDER_HISTORY returned no rows.');
END;
/
BEGIN
  APPLAB.VERIFY_ORDER_HISTORY_ROW_ACCESS;
END;
/
DROP PROCEDURE APPLAB.VERIFY_ORDER_HISTORY_ROW_ACCESS;
/
