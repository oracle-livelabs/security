-- Run as an ADB administrator after create_managers.sql.
-- The context resolves the authenticated manager's own ID.

CREATE OR REPLACE END USER CONTEXT APPLAB.MGR_CTX USING JSON SCHEMA '{
  "type": "object",
  "properties": {
    "id": {
      "type": "integer",
      "o:onFirstRead": "APPLAB.MGR_CTX_PKG.INIT_MANAGER_ID"
    }
  }
}';

CREATE OR REPLACE PACKAGE APPLAB.MGR_CTX_PKG AS
  PROCEDURE INIT_MANAGER_ID;
END;

CREATE OR REPLACE PACKAGE BODY APPLAB.MGR_CTX_PKG AS
  PROCEDURE INIT_MANAGER_ID IS
    v_id NUMBER;
    v_id_sql VARCHAR2(40);
  BEGIN
    BEGIN
      SELECT manager_id INTO v_id
        FROM APPLAB.managers
       WHERE UPPER(manager_name) = UPPER(ORA_END_USER_CONTEXT.username);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      v_id := NULL;
    END;
    v_id_sql := CASE
                  WHEN v_id IS NULL THEN 'null'
                  ELSE TO_CHAR(v_id, 'TM9', 'NLS_NUMERIC_CHARACTERS=''.,''')
                END;
    EXECUTE IMMEDIATE
      'UPDATE END_USER_CONTEXT t SET t.context.id = ' || v_id_sql ||
      q'[ WHERE owner = 'APPLAB' AND name = 'MGR_CTX']';
  END;
END;
