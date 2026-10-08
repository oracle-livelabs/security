"""Direct local-end-user database access. No application-side authorization."""

from contextlib import contextmanager
from typing import Optional
import oracledb

from config import Settings


def _enable_thick_mode() -> None:
    """Use the preinstalled Instant Client and its cwallet.sso support."""
    try:
        oracledb.init_oracle_client()
    except oracledb.Error as exc:
        raise RuntimeError(
            "Oracle Instant Client could not be initialized. "
            "Run bash verify_app_server.sh and confirm the client is installed."
        ) from exc


_enable_thick_mode()

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
        kwargs.update({"config_dir": settings.wallet_location, "wallet_location": settings.wallet_location})
    connection = oracledb.connect(**kwargs)
    try:
        yield connection
    finally:
        connection.close()


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


def fetch_authorized_customers(settings: Settings, persona: str, password: str) -> tuple[list[dict], dict]:
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
            data_roles = ", ".join(row[0] for row in cursor) or "No active data role"
    return rows, {"end_user": end_user, "data_role": data_roles}


def fetch_order_history(settings: Settings, persona: str, password: str) -> list[dict]:
    """Return Order History rows visible to the authenticated database user."""
    if persona not in PERSONAS:
        raise ValueError("Choose Marvin or Emma")
    query = (
        "SELECT order_id, order_date, sales_rep, product_category, amount, customer_id "
        "FROM APPLAB.order_history ORDER BY order_date DESC FETCH FIRST 50 ROWS ONLY"
    )
    with _connection(settings, persona, password) as connection:
        with connection.cursor() as cursor:
            cursor.execute(query)
            columns = [column[0].lower() for column in cursor.description]
            rows = [dict(zip(columns, row)) for row in cursor]
    return rows


def oracle_error_code(error: Exception) -> Optional[int]:
    """Return an Oracle error number without exposing Oracle text to callers."""
    if not isinstance(error, oracledb.DatabaseError) or not error.args:
        return None
    return getattr(error.args[0], "code", None)
