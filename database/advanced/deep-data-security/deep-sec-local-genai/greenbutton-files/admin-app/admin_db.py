"""Direct ADMIN database access for the fixed Deep Sec administrator console."""

from contextlib import contextmanager

import oracledb

from admin_config import AdminSettings


def _enable_thick_mode(config_dir: str) -> None:
    try:
        # In Thick mode, Oracle Net reads aliases during client initialization.
        # Set the supplied generated wallet directory here instead of letting
        # Instant Client fall back to its own network/admin directory.
        oracledb.init_oracle_client(config_dir=config_dir)
    except oracledb.Error as exc:
        raise RuntimeError("Oracle Instant Client could not be initialized.") from exc


@contextmanager
def database_connection(settings: AdminSettings, username: str, password: str):
    if not password:
        raise ValueError("Database password is required")
    connect_kwargs = dict(
        user=username,
        password=password,
        dsn=settings.dsn,
    )
    if settings.wallet_location:
        _enable_thick_mode(settings.wallet_location)
        connect_kwargs.update(
            config_dir=settings.wallet_location,
            wallet_location=settings.wallet_location,
        )
    connection = oracledb.connect(**connect_kwargs)
    try:
        yield connection
    finally:
        connection.close()


def verify_admin(settings: AdminSettings, password: str) -> str:
    """Authenticate the console user directly as the ADB ADMIN account."""
    with database_connection(settings, "ADMIN", password) as connection:
        with connection.cursor() as cursor:
            cursor.execute("select user from dual")
            return cursor.fetchone()[0]


def completed_setup_actions(settings: AdminSettings, password: str) -> set[str]:
    """Infer the guided setup position from durable Oracle state.

    Browser sessions are deliberately short-lived, so setup progress must never
    depend on a Flask login surviving.
    """
    completed: set[str] = set()
    with database_connection(settings, "ADMIN", password) as connection:
        with connection.cursor() as cursor:
            cursor.execute("select count(*) from all_users where username = 'APPLAB'")
            if cursor.fetchone()[0] != 1:
                return completed
            try:
                cursor.execute("select count(*) from APPLAB.customers")
                customer_count = cursor.fetchone()[0]
            except oracledb.DatabaseError:
                customer_count = 0
            if customer_count >= 22:
                completed.add("prepare_applab")
            cursor.execute("select count(*) from dba_roles where role = 'HOL_DBROLE_CONNECT'")
            if cursor.fetchone()[0] == 1:
                completed.add("create_db_roles")
            cursor.execute(
                """
                select count(*)
                  from dba_data_grants
                 where grantee = 'HOL_DATAROLE_EMPLOYEE_ACCESS'
                   and object_owner = 'APPLAB'
                   and object_name = 'CUSTOMERS'
                """
            )
            if cursor.fetchone()[0] >= 1:
                completed.update({"create_roles", "create_data_grants"})

    try:
        # CREATE END USER is not consistently represented in ordinary user
        # dictionary views across ADB releases. A direct local sign-in is the
        # authoritative test for the MARVIN setup step.
        with database_connection(settings, "MARVIN", password) as connection:
            with connection.cursor() as cursor:
                cursor.execute("select 1 from dual")
                cursor.fetchone()
                cursor.execute("select role_name from v$end_user_data_role")
                active_roles = {row[0] for row in cursor}
        completed.add("marvin_exists")
        if "HOL_DATAROLE_EMPLOYEE_ACCESS" in active_roles:
            completed.add("grant_employee_access")
        if "HOL_DATAROLE_MANAGER_ACCESS" in active_roles:
            completed.add("enable_manager")
    except oracledb.DatabaseError:
        pass

    try:
        # Emma is the fixed comparison user. Authenticate directly because
        # local end users are not reliably represented in ordinary user views.
        with database_connection(settings, "EMMA", password) as connection:
            with connection.cursor() as cursor:
                cursor.execute("select 1 from dual")
                cursor.fetchone()
        completed.add("emma_exists")
    except oracledb.DatabaseError:
        pass

    try:
        with database_connection(settings, "ADMIN", password) as connection:
            with connection.cursor() as cursor:
                cursor.execute("select count(*) from all_tables where owner = 'APPLAB' and table_name = 'MANAGERS'")
                if cursor.fetchone()[0] == 1:
                    completed.add("create_managers")
                cursor.execute("select count(*) from all_objects where owner = 'APPLAB' and object_name = 'MGR_CTX_PKG' and object_type = 'PACKAGE'")
                if cursor.fetchone()[0] == 1:
                    completed.add("create_manager_context")
                cursor.execute("select count(*) from dba_roles where role = 'HOL_DBROLE_MGR_CTX_ADMIN'")
                bridge_role_exists = cursor.fetchone()[0] == 1
                cursor.execute(
                    """
                    select count(*)
                      from dba_data_grants
                     where grant_name = 'MGR_CTX_ACCESS'
                       and object_owner = 'SYS'
                       and object_name = 'END_USER_CONTEXT'
                    """
                )
                if bridge_role_exists and cursor.fetchone()[0] >= 1:
                    completed.add("set_context")
                cursor.execute(
                    """
                    select count(*)
                      from dba_data_grants
                     where grantee = 'HOL_DATAROLE_MANAGER_ACCESS'
                       and object_owner = 'APPLAB'
                       and object_name = 'CUSTOMERS'
                    """
                )
                if cursor.fetchone()[0] >= 1:
                    completed.add("customize_manager_grant")
                cursor.execute(
                    "select count(*) from all_tables where owner = 'APPLAB' and table_name = 'ORDER_HISTORY'"
                )
                if cursor.fetchone()[0] == 1:
                    completed.add("create_order_history")
                cursor.execute(
                    """
                    select count(*)
                      from dba_data_grants
                     where grant_name = 'ORDER_HISTORY_BY_CUSTOMER_ACCESS'
                       and object_owner = 'APPLAB'
                       and object_name = 'ORDER_HISTORY'
                       and cross_table_data_grant = TRUE
                    """
                )
                if cursor.fetchone()[0] >= 1:
                    completed.add("extend_manager_context")
    except oracledb.DatabaseError:
        pass
    if {"marvin_exists", "emma_exists"}.issubset(completed):
        completed.add("create_end_users")
    return completed


def validation_comparison(settings: AdminSettings, password: str) -> dict:
    """Return Oracle-derived roles and grants for the Emma/Marvin comparison."""
    query = "SELECT * FROM APPLAB.customers ORDER BY revenue DESC"
    with database_connection(settings, "ADMIN", password) as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                select grant_name,
                       grantee,
                       predicate,
                       listagg(nvl(column_name, 'ALL COLUMNS'), ', ')
                         within group (order by column_name) as columns
                  from dba_data_grants
                 where object_owner = 'APPLAB'
                   and object_name = 'CUSTOMERS'
                 group by grant_name, grantee, predicate
                 order by grantee, grant_name
                """
            )
            grants = [
                {"name": row[0], "role": row[1], "predicate": row[2] or "All rows", "columns": row[3]}
                for row in cursor
            ]

    personas = []
    for username in ("EMMA", "MARVIN"):
        try:
            with database_connection(settings, username, password) as connection:
                with connection.cursor() as cursor:
                    cursor.execute("select role_name from v$end_user_data_role order by role_name")
                    roles = [row[0] for row in cursor]
                    cursor.execute(query)
                    columns = [column[0].lower() for column in cursor.description]
                    row_count = sum(1 for _ in cursor)
            personas.append(
                {
                    "username": username,
                    "roles": roles,
                    "row_count": row_count,
                    "columns": columns,
                    "grants": [grant for grant in grants if grant["role"] in roles],
                    "available": True,
                }
            )
        except oracledb.DatabaseError as exc:
            personas.append(
                {
                    "username": username,
                    "roles": [],
                    "row_count": None,
                    "columns": [],
                    "grants": [],
                    "available": False,
                    "message": str(exc),
                }
            )
    return {"query": query, "personas": personas}


def lab_state(settings: AdminSettings, password: str) -> dict:
    """Read the current authorization result as MARVIN, never infer it in Flask."""
    with database_connection(settings, "MARVIN", password) as connection:
        with connection.cursor() as cursor:
            cursor.execute("select * from APPLAB.customers order by revenue desc")
            columns = [column[0].lower() for column in cursor.description]
            row_count = sum(1 for _ in cursor)
            cursor.execute("select ora_end_user_context.username from dual")
            (end_user,) = cursor.fetchone()
            try:
                cursor.execute(
                    "select sales_rep from APPLAB.customers "
                    "where manager_id = (select manager_id from APPLAB.managers "
                    "where upper(manager_name) = upper(:username)) "
                    "order by sales_rep",
                    username=end_user,
                )
                direct_reports = sorted({row[0] for row in cursor})
            except oracledb.DatabaseError:
                # The manager context is deliberately created later in the
                # lab. Its absence must not hide Marvin's otherwise valid
                # current authorization result.
                direct_reports = []
            cursor.execute("select role_name from v$end_user_data_role order by role_name")
            data_roles = [row[0] for row in cursor]
    return {
        "end_user": end_user,
        "data_roles": data_roles,
        "row_count": row_count,
        "visible_columns": columns,
        "direct_reports": direct_reports,
    }
