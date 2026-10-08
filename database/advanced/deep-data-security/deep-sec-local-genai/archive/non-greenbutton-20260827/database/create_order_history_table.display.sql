-- What this step does. Safe to copy — no live secrets appear here.
-- Run as an ADB administrator.

-- 1. APPLAB owns the external table, so give it the documented DBMS_CLOUD
--    privileges and direct access to DBMS_CLOUD's default directory. APPLAB
--    remains a schema owner and is never granted CREATE SESSION.
GRANT DWROLE TO APPLAB;
GRANT EXECUTE ON DBMS_CLOUD TO APPLAB;
GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO APPLAB;

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

-- 2. Allow the APPLAB owner and the ADMIN setup session to read the regional
--    OCI Object Storage endpoint over HTTPS. This is required for Iceberg
--    metadata and data files; it grants no application user network access.
BEGIN
  FOR l_principal IN (SELECT 'APPLAB' principal_name FROM dual UNION ALL SELECT 'ADMIN' FROM dual) LOOP
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host           => 'objectstorage.<region>.oraclecloud.com',
      lower_port     => 443,
      upper_port     => 443,
      ace            => xs$ace_type(
                          privilege_list => xs$name_list('http'),
                          principal_name => l_principal.principal_name,
                          principal_type => xs_acl.ptype_db
                        )
    );
  END LOOP;
END;
/

-- 3. Verify the generated native metadata URL with the same credential the
--    external table will use. This is a hard bootstrap gate, not a row count.
CREATE OR REPLACE PROCEDURE APPLAB.VERIFY_ORDER_HISTORY_METADATA_ACCESS
AUTHID DEFINER
AS
  l_metadata_blob BLOB;
BEGIN
  l_metadata_blob := DBMS_CLOUD.GET_OBJECT(
    credential_name => 'READER_CREDENTIAL_NAME',
    object_uri      => '<order_history_metadata_url>'
  );

  IF DBMS_LOB.GETLENGTH(l_metadata_blob) = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Iceberg metadata object is empty.');
  END IF;
END;
/
BEGIN
  APPLAB.VERIFY_ORDER_HISTORY_METADATA_ACCESS;
END;
/
DROP PROCEDURE APPLAB.VERIFY_ORDER_HISTORY_METADATA_ACCESS;
/

-- 4. Drop only an existing database external-table definition. This does not
--    delete the Iceberg files in Object Storage.
DROP TABLE APPLAB.ORDER_HISTORY PURGE;

-- 5. Define an Iceberg external table from its root metadata URI. DBMS_CLOUD
--    derives the columns from Iceberg metadata; no manual column list is valid.
--    The live action runs this as a temporary APPLAB definer-rights procedure,
--    so APPLAB owns the table and credential. No data is copied into the database.
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

-- 6. Fetch an actual row as the APPLAB table owner. This catches an external
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
