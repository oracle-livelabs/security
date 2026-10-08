"""Direct local-end-user database access. No application-side authorization."""

from contextlib import contextmanager
import re
from typing import Optional
import oracledb

from config import Settings


def _enable_thick_mode(wallet_location: str) -> None:
    """Use Thick mode only for the legacy mTLS wallet deployment."""
    try:
        oracledb.init_oracle_client(config_dir=wallet_location)
    except oracledb.Error as exc:
        raise RuntimeError(
            "Oracle Instant Client could not be initialized. "
            "Run bash verify_app_server.sh and confirm the client is installed."
        ) from exc


PERSONAS = {
    "MARVIN": {"label": "Marvin — Sales", "role": "Database-managed"},
    "EMMA": {"label": "Emma — Sales", "role": "Database-managed"},
}

QUERY_TEMPLATE = """
    SELECT *
      FROM {schema}.customers
     ORDER BY revenue DESC
"""

END_USER_QUERY = "select ora_end_user_context.username from dual"
DATA_ROLES_QUERY = "select role_name from v$end_user_data_role order by role_name"
AUTHORIZATION_GRANTS_QUERY = """
    SELECT grant_name,
           privilege,
           column_name,
           granted_with_all_columns_except,
           object_owner,
           object_name,
           predicate,
           grantee,
           grantee_type,
           cross_table_data_grant
      FROM all_data_grants
     WHERE object_owner = 'APPLAB'
       AND object_name = :object_name
       AND privilege = 'SELECT'
     ORDER BY grant_name, grantee, column_name, granted_with_all_columns_except
"""
ORDER_HISTORY_QUERY = """
    SELECT *
      FROM APPLAB.order_history
     ORDER BY order_date DESC
     FETCH FIRST 50 ROWS ONLY
"""

RED_TEAM_MAX_ROWS = 50
_READ_ONLY_SQL_START = re.compile(r"^\s*(SELECT|WITH)\b", re.IGNORECASE)
_READ_ONLY_SQL_FORBIDDEN = re.compile(
    r"\b(FOR\s+UPDATE|INSERT|UPDATE|DELETE|MERGE|ALTER|DROP|TRUNCATE|GRANT|REVOKE|BEGIN|DECLARE|EXECUTE|CALL)\b",
    re.IGNORECASE,
)


def oracle_queries(settings: Settings) -> list[str]:
    """Return the Oracle statements used by a customer or AI request."""
    return [
        " ".join(QUERY_TEMPLATE.format(schema=settings.db_schema).split()),
        END_USER_QUERY,
        DATA_ROLES_QUERY,
    ]


@contextmanager
def _connection(settings: Settings, username: str, password: str):
    """Open one direct local end-user session and close it after the request."""
    if not password:
        raise ValueError("Database password is required")
    kwargs = {"user": username, "password": password, "dsn": settings.dsn}
    if settings.wallet_location:
        _enable_thick_mode(settings.wallet_location)
        kwargs.update({"config_dir": settings.wallet_location, "wallet_location": settings.wallet_location})
    connection = oracledb.connect(**kwargs)
    try:
        yield connection
    finally:
        connection.close()


def _validate_red_team_sql(sql: str) -> str:
    """Keep the model's database challenge to one bounded read-only statement."""
    if not isinstance(sql, str):
        raise ValueError("The database tool requires a SQL string.")
    statement = sql.strip()
    if statement.endswith(";"):
        statement = statement[:-1].rstrip()
    if not statement:
        raise ValueError("The database tool requires a SQL statement.")
    if ";" in statement:
        raise ValueError("The database tool accepts one SQL statement only.")
    if "--" in statement or "/*" in statement or "*/" in statement:
        raise ValueError("SQL comments are not accepted by the database tool.")
    if not _READ_ONLY_SQL_START.match(statement):
        raise ValueError("The database tool accepts SELECT or WITH statements only.")
    if _READ_ONLY_SQL_FORBIDDEN.search(statement):
        raise ValueError("The database tool accepts read-only SQL only.")
    return statement


def execute_red_team_sql(settings: Settings, persona: str, password: str, sql: str) -> dict:
    """Execute one model-requested read-only query as the current local end user."""
    if persona not in PERSONAS:
        raise ValueError("Choose Marvin or Emma")
    try:
        statement = _validate_red_team_sql(sql)
    except ValueError as exc:
        return {"status": "tool_rejected", "executed_as": persona, "reason": str(exc), "rows": []}

    bounded_statement = f"SELECT * FROM ({statement}) FETCH FIRST {RED_TEAM_MAX_ROWS + 1} ROWS ONLY"
    try:
        with _connection(settings, persona, password) as connection:
            with connection.cursor() as cursor:
                cursor.execute(bounded_statement)
                columns = [column[0].lower() for column in cursor.description or []]
                raw_rows = cursor.fetchmany(RED_TEAM_MAX_ROWS + 1)
                rows = [dict(zip(columns, row)) for row in raw_rows[:RED_TEAM_MAX_ROWS]]
                cursor.execute(END_USER_QUERY)
                (end_user,) = cursor.fetchone()
                cursor.execute(DATA_ROLES_QUERY)
                data_roles = ", ".join(row[0] for row in cursor) or "No active data role"
    except oracledb.DatabaseError as exc:
        code = oracle_error_code(exc)
        return {
            "status": "oracle_rejected",
            "executed_as": persona,
            "oracle_error": f"ORA-{code}" if code else "Oracle database error",
            "rows": [],
        }

    return {
        "status": "ok",
        "executed_as": persona,
        "context": {"end_user": end_user, "data_role": data_roles},
        "rows": rows,
        "row_count": len(rows),
        "truncated": len(raw_rows) > RED_TEAM_MAX_ROWS,
    }


def verify_persona_credentials(settings: Settings, persona: str, password: str) -> dict:
    """Authenticate directly as the chosen local database end user."""
    if persona not in PERSONAS:
        raise ValueError("Choose Marvin or Emma")
    with _connection(settings, persona, password) as connection:
        with connection.cursor() as cursor:
            cursor.execute(END_USER_QUERY)
            (end_user,) = cursor.fetchone()
            cursor.execute(DATA_ROLES_QUERY)
            data_roles = ", ".join(row[0] for row in cursor) or "No active data role"
    return {"end_user": end_user, "data_role": data_roles}


def _normalise_identifier(value: Optional[str]) -> str:
    return str(value or "").strip().upper()


def _is_true(value: object) -> bool:
    return value is True or _normalise_identifier(value) in {"TRUE", "YES", "Y"}


GRANT_PAGE_LABELS = {
    "EMPLOYEE_CUSTOMER_ACCESS": "Customize Grant",
    "MANAGER_CUSTOMER_ACCESS": "End User Context",
    "ORDER_HISTORY_ACCESS": "Iceberg",
    "ORDER_HISTORY_BY_CUSTOMER_ACCESS": "Iceberg",
}


def _grant_page_label(grant_name: str) -> str:
    normalized_name = _normalise_identifier(grant_name).rsplit(".", 1)[-1]
    return GRANT_PAGE_LABELS.get(normalized_name, "Data Grants")


def _grant_covers_column(grant: dict, column: str) -> bool:
    normalized_column = _normalise_identifier(column)
    if grant["columns"]:
        return normalized_column in grant["columns"]
    if grant["excluded_columns"]:
        return normalized_column not in grant["excluded_columns"]
    return True


def _grant_summary(grant: dict) -> dict:
    """Return only the grant facts needed to explain a cell in the browser."""
    return {
        "grant_name": grant["name"],
        "page_label": _grant_page_label(grant["name"]),
        "columns": sorted(grant["columns"]),
        "excluded_columns": sorted(grant["excluded_columns"]),
        "cross_table": grant["cross_table"],
    }


def _grant_matches_row(grant: dict, row: dict, persona: str) -> Optional[bool]:
    """Match the lab's published predicates without evaluating arbitrary SQL."""
    if grant["cross_table"]:
        return True
    if not grant["predicate"]:
        return True

    predicate = _normalise_identifier(grant["predicate"])
    grant_name = _normalise_identifier(grant["name"]).rsplit(".", 1)[-1]
    if grant_name == "EMPLOYEE_CUSTOMER_ACCESS" or (
        "SALES_REP" in predicate and "ORA_END_USER_CONTEXT.USERNAME" in predicate
    ):
        return _normalise_identifier(row.get("sales_rep")) == _normalise_identifier(persona)
    if grant_name == "MANAGER_CUSTOMER_ACCESS" or (
        "MANAGER_ID" in predicate and "MGR_CTX" in predicate
    ):
        # manager_id is required by the manager grant in this lab. Employee
        # rows therefore have NULL here, while manager-context rows do not.
        return row.get("manager_id") is not None
    return None


def build_authorization_metadata(
    grant_rows: list[dict],
    active_roles: list[str],
    persona: str,
    columns: list[str],
    rows: Optional[list[dict]] = None,
    row_key: Optional[str] = None,
) -> dict:
    """Describe the Deep Sec grants that explain each returned column value."""
    applicable_grantees = {_normalise_identifier(persona), "PUBLIC"}
    applicable_grantees.update(_normalise_identifier(role) for role in active_roles)
    grouped: dict[tuple, dict] = {}

    for row in grant_rows:
        grantee = row.get("grantee")
        normalized_grantee = _normalise_identifier(grantee)
        is_cross_table = _is_true(row.get("cross_table_data_grant"))
        if normalized_grantee and normalized_grantee not in applicable_grantees and not is_cross_table:
            continue
        key = (
            row.get("grant_name") or "Unnamed data grant",
            grantee,
            row.get("grantee_type"),
            row.get("predicate"),
            is_cross_table,
        )
        grant = grouped.setdefault(
            key,
            {
                "name": key[0],
                "grantee": grantee,
                "predicate": row.get("predicate"),
                "cross_table": is_cross_table,
                "columns": set(),
                "excluded_columns": set(),
            },
        )
        if row.get("column_name"):
            grant["columns"].add(_normalise_identifier(row["column_name"]))
        if row.get("granted_with_all_columns_except"):
            grant["excluded_columns"].add(_normalise_identifier(row["granted_with_all_columns_except"]))

    metadata = {"available": True, "columns": {}}
    for column in columns:
        normalized_column = _normalise_identifier(column)
        covering_grants = [
            grant for grant in grouped.values() if _grant_covers_column(grant, normalized_column)
        ]
        excluded_grants = [
            grant for grant in grouped.values() if not _grant_covers_column(grant, normalized_column)
        ]
        metadata["columns"][column.lower()] = {
            "authorized": bool(covering_grants),
            "reasons": [_grant_summary(grant) for grant in excluded_grants],
            "other_grants": [_grant_summary(grant) for grant in covering_grants],
        }

    if rows is not None and row_key:
        metadata["row_key"] = row_key
        metadata["row_grants"] = {}
        for row in rows:
            matched_grants = [
                _grant_summary(grant)
                for grant in grouped.values()
                if _grant_matches_row(grant, row, persona) is True
            ]
            metadata["row_grants"][str(row.get(row_key, ""))] = matched_grants
    return metadata


def _fetch_authorization_metadata(
    cursor,
    object_name: str,
    active_roles: list[str],
    persona: str,
    columns: list[str],
    rows: Optional[list[dict]] = None,
    row_key: Optional[str] = None,
) -> dict:
    """Read only the current end user's accessible Deep Sec grant metadata."""
    try:
        cursor.execute(AUTHORIZATION_GRANTS_QUERY, object_name=object_name)
        names = [column[0].lower() for column in cursor.description]
        grant_rows = [dict(zip(names, row)) for row in cursor]
        return build_authorization_metadata(grant_rows, active_roles, persona, columns, rows, row_key)
    except oracledb.DatabaseError:
        # The report remains usable on environments where the end user cannot
        # query ALL_DATA_GRANTS; it simply does not make an authorization claim.
        return {"available": False, "columns": {}}


def fetch_authorized_customers(
    settings: Settings,
    persona: str,
    password: str,
    include_authorization: bool = False,
) -> tuple[list[dict], dict, dict]:
    """Run the identical query before and after the Deep Sec role change."""
    if persona not in PERSONAS:
        raise ValueError("Choose Marvin or Emma")
    query = QUERY_TEMPLATE.format(schema=settings.db_schema)
    with _connection(settings, persona, password) as connection:
        with connection.cursor() as cursor:
            cursor.execute(query)
            names = [column[0].lower() for column in cursor.description]
            rows = [dict(zip(names, row)) for row in cursor]
            cursor.execute(END_USER_QUERY)
            (end_user,) = cursor.fetchone()
            cursor.execute(DATA_ROLES_QUERY)
            active_roles = [row[0] for row in cursor]
            data_roles = ", ".join(active_roles) or "No active data role"
            authorization = (
                _fetch_authorization_metadata(
                    cursor,
                    "CUSTOMERS",
                    active_roles,
                    end_user or persona,
                    names,
                    rows,
                    "customer_id",
                )
                if include_authorization
                else {"available": False, "columns": {}}
            )
    return rows, {"end_user": end_user, "data_role": data_roles}, authorization


def fetch_order_history(
    settings: Settings,
    persona: str,
    password: str,
) -> tuple[list[dict], int, dict[str, str], dict]:
    """Return Order History rows, their authorized count, and session context."""
    if persona not in PERSONAS:
        raise ValueError("Choose Marvin or Emma")
    with _connection(settings, persona, password) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) FROM APPLAB.order_history")
            row_count = int(cursor.fetchone()[0])
            cursor.execute(ORDER_HISTORY_QUERY)
            columns = [column[0].lower() for column in cursor.description]
            rows = [dict(zip(columns, row)) for row in cursor]
            cursor.execute(END_USER_QUERY)
            (end_user,) = cursor.fetchone()
            cursor.execute(DATA_ROLES_QUERY)
            active_roles = [row[0] for row in cursor]
            data_roles = ", ".join(active_roles) or "No active data role"
            authorization = _fetch_authorization_metadata(
                cursor,
                "ORDER_HISTORY",
                active_roles,
                end_user or persona,
                columns,
                rows,
                "order_id",
            )
    return rows, row_count, {"end_user": end_user, "data_role": data_roles}, authorization


def execute_vibe_statement(settings: Settings, persona: str, password: str, sql: str) -> dict:
    """Run one published Vibe statement as the Customer Sales App end user, never as ADMIN."""
    if persona not in PERSONAS:
        raise ValueError("Choose Marvin or Emma")
    operation = sql.lstrip().split(None, 1)[0].upper()
    # A WITH clause is a query in the Vibe contract. DML starts with its own
    # keyword, so it remains unambiguous to present in the browser.
    if operation == "WITH":
        operation = "SELECT"
    with _connection(settings, persona, password) as connection:
        with connection.cursor() as cursor:
            if operation == "SELECT":
                cursor.execute(f"SELECT COUNT(*) FROM ({sql})")
                row_count = int(cursor.fetchone()[0])
                cursor.execute(sql)
                if not cursor.description:
                    raise ValueError("The published Vibe query did not return rows.")
                columns = [column[0].lower() for column in cursor.description]
                rows = [dict(zip(columns, row)) for row in cursor.fetchmany(100)]
                affected_rows = None
            elif operation in {"INSERT", "UPDATE", "DELETE"}:
                cursor.execute(sql)
                affected_rows = max(cursor.rowcount, 0)
                connection.commit()
                row_count = affected_rows
                rows = []
            else:
                raise ValueError("Vibe statements must start with SELECT, INSERT, UPDATE, or DELETE.")
            cursor.execute(END_USER_QUERY)
            (end_user,) = cursor.fetchone()
            cursor.execute(DATA_ROLES_QUERY)
            data_roles = ", ".join(row[0] for row in cursor) or "No active data role"
    return {
        "operation": operation,
        "rows": rows,
        "row_count": row_count,
        "affected_rows": affected_rows,
        "context": {"end_user": end_user, "data_role": data_roles},
    }


def oracle_error_code(error: Exception) -> Optional[int]:
    """Return an Oracle error number without exposing Oracle text to callers."""
    if not isinstance(error, oracledb.DatabaseError) or not error.args:
        return None
    return getattr(error.args[0], "code", None)
