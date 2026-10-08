"""Fixed-action administrator console for the Deep Sec training environment."""

import logging
import json
import os
from pathlib import Path
import secrets
import subprocess
import tempfile
import time
import urllib.request
from urllib.parse import quote, urlparse
from threading import Lock
from typing import Optional

from dotenv import load_dotenv
from flask import Flask, jsonify, redirect, render_template, request, send_file, url_for
from flask_login import LoginManager, UserMixin, current_user, login_required, login_user, logout_user
from flask_wtf.csrf import CSRFError, CSRFProtect
from werkzeug.exceptions import HTTPException

from admin_config import load_admin_settings
from admin_db import completed_setup_actions, lab_state, validation_comparison, verify_admin
from downloads import build_application_zip, build_sql_scripts_zip
from vibe import VIBE_TIMEOUT_SECONDS, generate_script, run_generated_script

load_dotenv()
settings = load_admin_settings()
app = Flask(__name__)
app.config["SECRET_KEY"] = settings.secret_key
app.config["SESSION_COOKIE_NAME"] = "deep_sec_admin_session"
app.config["SESSION_COOKIE_HTTPONLY"] = True
app.config["SESSION_COOKIE_SAMESITE"] = "Lax"
csrf = CSRFProtect(app)
login_manager = LoginManager(app)
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
app.logger.setLevel(getattr(logging, os.getenv("ADMIN_LOG_LEVEL", "INFO").upper(), logging.INFO))

LOGIN_TTL_SECONDS = 90 * 60
_logins: dict[str, dict] = {}
_logins_lock = Lock()

ADMIN_APP_DIR = Path(__file__).resolve().parent
DATABASE_DOWNLOAD_DIR = Path(settings.database_dir)
CUSTOMER_APP_DIR = ADMIN_APP_DIR.parent / "flask-app"
if not CUSTOMER_APP_DIR.is_dir():
    CUSTOMER_APP_DIR = ADMIN_APP_DIR.parent / "deep-sec-customer-sales"


class AdminUser(UserMixin):
    """Opaque browser identity; the ADMIN password remains process-memory only."""

    def __init__(self, login_id: str):
        self.id = login_id


@login_manager.user_loader
def load_user(login_id: str):
    with _logins_lock:
        login = _logins.get(login_id)
        if not login or login["expires_at"] <= time.monotonic():
            _logins.pop(login_id, None)
            return None
        return AdminUser(login_id)


@login_manager.unauthorized_handler
def unauthorized():
    if request.path.startswith("/api/"):
        return jsonify(error="Sign in as ADMIN first"), 401
    return redirect(url_for("index"))


@app.errorhandler(CSRFError)
def handle_csrf_error(error):
    """Keep API failures JSON so the browser can show an actionable message."""
    if request.path.startswith("/api/"):
        return jsonify(
            error="This page's security token expired. Refresh the page and try again.",
            code="csrf_expired",
        ), 400
    return str(error), 400


@app.errorhandler(HTTPException)
def handle_api_http_error(error):
    """Do not send HTML error pages to JavaScript API callers."""
    if not request.path.startswith("/api/"):
        return error
    messages = {
        404: "The requested API action does not exist.",
        405: "That API action does not accept this request method.",
        500: "The server could not complete that request. Check the server log.",
    }
    return jsonify(error=messages.get(error.code, "The request could not be completed.")), error.code


def _admin_password() -> str:
    login_id = current_user.get_id()
    with _logins_lock:
        login = _logins.get(login_id)
        if not login or login["expires_at"] <= time.monotonic():
            if login_id:
                _logins.pop(login_id, None)
            raise ValueError("Sign in as ADMIN first")
        login["expires_at"] = time.monotonic() + LOGIN_TTL_SECONDS
        return login["password"]


def _completed_actions() -> set[str]:
    """Return the guided setup actions completed in this ADMIN session."""
    login_id = current_user.get_id()
    with _logins_lock:
        login = _logins.get(login_id)
        if not login or login["expires_at"] <= time.monotonic():
            raise ValueError("Sign in as ADMIN first")
        return set(login.get("completed_actions", set()))


def _record_completed_action(action: dict) -> list[str]:
    """Advance, reset, or restore the guided setup sequence after success."""
    login_id = current_user.get_id()
    with _logins_lock:
        login = _logins.get(login_id)
        if not login or login["expires_at"] <= time.monotonic():
            raise ValueError("Sign in as ADMIN first")
        if action["resets_setup"]:
            login["completed_actions"] = set()
        if action["restored_actions"]:
            login["completed_actions"].update(action["restored_actions"])
        elif not action["resets_setup"]:
            login.setdefault("completed_actions", set()).add(action["key"])
        return sorted(login["completed_actions"])


def _record_action_output(action_key: str, output: str) -> None:
    """Keep each fixed script's complete SQL*Plus output with this ADMIN session."""
    login_id = current_user.get_id()
    with _logins_lock:
        login = _logins.get(login_id)
        if login and login["expires_at"] > time.monotonic():
            login.setdefault("action_outputs", {})[action_key] = output


def _action_outputs() -> dict[str, str]:
    """Return prior complete script output for rendering in its own step panel."""
    login_id = current_user.get_id()
    with _logins_lock:
        login = _logins.get(login_id)
        if not login or login["expires_at"] <= time.monotonic():
            return {}
        return dict(login.get("action_outputs", {}))


def _database_completed_actions() -> set[str]:
    """Use durable Oracle state to restore setup progress after a re-login."""
    try:
        return completed_setup_actions(settings, _admin_password())
    except Exception as exc:
        app.logger.warning("Could not infer setup progress from Oracle: %s", exc)
        return set()


def _action(
    key: str,
    title: str,
    description: str,
    *scripts: str,
    destructive: bool = False,
    needs_password: bool = False,
    password_scripts: tuple[str, ...] = (),
    database_user: str = "ADMIN",
    requires: tuple[str, ...] = (),
    resets_setup: bool = False,
    restored_actions: tuple[str, ...] = (),
    link_step: bool = False,
    explain_step: bool = False,
    custom_grant_step: bool = False,
    grant_wizard: Optional[dict] = None,
    internal_secret_script: Optional[str] = None,
    link_url: Optional[str] = None,
    link_button_label: Optional[str] = None,
    button_label: Optional[str] = None,
    short_label: Optional[str] = None,
) -> dict:
    resolved = []
    for script in scripts:
        path = Path(settings.database_dir, script).resolve()
        if path.parent != Path(settings.database_dir).resolve() or not path.is_file():
            raise RuntimeError(f"Required lab script is missing: {script}")
        display_path = path.with_suffix(".display.sql")
        if display_path.is_file() and display_path.parent == Path(settings.database_dir).resolve():
            display_sql = display_path.read_text(encoding="utf-8")
        else:
            display_sql = path.read_text(encoding="utf-8")
        resolved.append({"name": script, "path": path, "sql": display_sql})
    return {
        "key": key,
        "title": title,
        "description": description,
        "scripts": resolved,
        "destructive": destructive,
        "needs_password": needs_password,
        "password_scripts": password_scripts,
        "database_user": database_user,
        "requires": requires,
        "resets_setup": resets_setup,
        "restored_actions": restored_actions,
        "link_step": link_step,
        "explain_step": explain_step,
        "custom_grant_step": custom_grant_step,
        "grant_wizard": grant_wizard,
        "internal_secret_script": internal_secret_script,
        "link_url": link_url,
        "link_button_label": link_button_label,
        "button_label": button_label,
        "short_label": short_label or title,
    }


# This is the complete allow-list. Requests can select only these checked-in,
# visible scripts—never a browser-provided SQL statement, path, or command.
ACTIONS = {
    action["key"]: action
    for action in (
        _action("prepare_applab", "Prepare APPLAB", "Creates the APPLAB schema and customer table, then loads the 22 sample records used throughout the lab.", "create_schema.sql", "load_sample_data.sql", destructive=True, internal_secret_script="create_schema.sql", short_label="Prepare App"),
        _action("create_db_roles", "Create database role", "Creates HOL_DBROLE_CONNECT, the ordinary Oracle role that supplies CREATE SESSION through a data role. Data roles cannot receive system privileges directly: grant the system privilege to a traditional database role, then grant that database role to a Deep Data Security data role.", "create_db_roles.sql", destructive=True, requires=("prepare_applab",), short_label="Create DB Role"),
        _action("review_db_setup", "Review", "Confirms the schema, table, and role this page created. No Deep Data Security views here, that starts on the next page.", "db_setup_status.sql", short_label="Review"),
        _action("create_roles", "Create data roles", "Create two data roles that will receive permissions through the upcoming Deep Sec data grants. HOL_DATAROLE_EMPLOYEE_ACCESS is granted to users acting as employees. HOL_DATAROLE_MANAGER_ACCESS is used for employees acting as managers. Grant HOL_DBROLE_CONNECT to HOL_DATAROLE_EMPLOYEE_ACCESS so each user can sign in using the CREATE SESSION system privilege granted in the previous step.", "create_data_roles.sql", destructive=True, requires=("create_db_roles",), short_label="Create data roles"),
        _action("create_data_grants", "Create data grants", "Defines the employee data grant wide open: every row and every column. The Customize Data Grant page narrows it later.", "create_data_grants.sql", destructive=True, requires=("create_roles",), short_label="Create data grants"),
        _action("create_end_users", "Create end users", "Creates Marvin and Emma together. Emma receives HOL_DATAROLE_EMPLOYEE_ACCESS; a separate action grants that data role to Marvin.", "create_end_users.sql", destructive=True, needs_password=True, requires=("create_data_grants",), short_label="Create end users"),
        _action("grant_employee_access", "Grant employee access", "Grants HOL_DATAROLE_EMPLOYEE_ACCESS to Marvin. It begins wide open until you customize its data grant.", "grant_employee_access.sql", destructive=True, requires=("create_end_users",), short_label="Grant employee access"),
        _action("customer_sales", "Customer Sales", "Navigate to the Oracle Customer Sales application to view Marvin's current access.", requires=("grant_employee_access",), link_step=True, short_label="Customer Sales"),
        _action("review_light", "Review", "Confirms the schema, role, and wide-open employee grant exist. The detailed column breakdown is not useful yet because nothing has been customized.", "end_user_status_light.sql", short_label="Review"),
        _action("review_grant", "Review", "Confirms the employee data grant after you customize it, including the selected rows, columns, and privileges.", "end_user_status.sql", short_label="Review"),
        _action("review_context", "Review", "Confirms the manager context, manager data grant, and Marvin's manager role after the End User Context steps.", "end_user_status.sql", short_label="Review"),
        _action("create_managers", "Create managers", "Creates a small lookup table resolving each manager's own numeric ID.", "create_managers.sql", destructive=True, requires=("create_end_users",), short_label="Manager Lookup"),
        _action("create_manager_context", "Create context", "Creates the session-scoped end user context and its package, resolving the authenticated manager's own ID.", "create_manager_context.sql", destructive=True, requires=("create_managers",), short_label="Create Context"),
        _action("set_context", "Set Context", "Grants APPLAB permission to update end user contexts, creates the bridge role, and authorizes both data roles to read the context object.", "set_context.sql", destructive=True, requires=("create_manager_context",), short_label="Set Context"),
        _action("enable_manager", "Grant manager role", "Grants Marvin HOL_DATAROLE_MANAGER_ACCESS. Build his manager data grant separately, nothing is authorized here beyond the role itself.", "promote_marvin_to_manager.sql", destructive=True, requires=("customize_manager_grant",), short_label="Grant manager role"),
        _action("disable_manager", "Revoke manager role", "Revokes HOL_DATAROLE_MANAGER_ACCESS from Marvin. His manager data grant stays defined, just unused until the role is granted again.", "disable_manager_policy.sql", destructive=True, requires=("create_end_users",), short_label="Revoke manager role"),
        _action("customize_employee_grant", "Customize the employee grant", "Choose the columns Marvin's employee data role can retrieve, which selected columns can be updated, whether rows are restricted to his sales_rep, and whether DELETE is allowed.", requires=("create_data_grants", "create_end_users"), short_label="Customize employee", grant_wizard={"api_prefix": "employee-grant", "title": "Columns Marvin's employee data role can see", "row_restriction_option": {"label": "Restrict rows to your own sales_rep"}, "allow_delete_option": {"label": "Also allow deleting rows"}, "columns": [{"key": "customer_id", "label": "customer_id", "required": True, "note": "always included, primary key"}, {"key": "sales_rep", "label": "sales_rep", "required": False, "default": True, "allow_update": True}, {"key": "customer_name", "label": "customer_name", "required": False, "default": True, "allow_update": True}, {"key": "region", "label": "region", "required": False, "default": True, "allow_update": True}, {"key": "revenue", "label": "revenue", "required": False, "default": True, "allow_update": True}, {"key": "credit_limit", "label": "credit_limit", "required": False, "default": True, "allow_update": True}, {"key": "sensitive_identifier", "label": "sensitive_identifier", "required": False, "default": True, "allow_update": True}]}),
        _action("verify_employee_grant", "Check Customer Sales", "You already have Customer Sales open in another tab. Go there now and select Customer Report again.", link_step=True, link_button_label="Mark as viewed", short_label="Check Customer Sales"),
        _action("customize_manager_grant", "Create the manager data grant", "Choose which columns the manager role can see or update, including Credit Limit and Sensitive Identifier, and whether the manager grant allows DELETE. The following step will grant this role to MARVIN.", requires=("create_manager_context", "set_context"), short_label="Manager Data Grant", grant_wizard={"api_prefix": "manager-grant", "title": "Columns Marvin's manager role can see", "allow_delete_option": {"label": "Also allow deleting rows"}, "columns": [{"key": "customer_id", "label": "customer_id", "required": True, "note": "always included, primary key"}, {"key": "customer_name", "label": "customer_name", "required": False, "default": True, "allow_update": True}, {"key": "region", "label": "region", "required": False, "default": True, "allow_update": True}, {"key": "sales_rep", "label": "sales_rep", "required": False, "default": True, "allow_update": True}, {"key": "revenue", "label": "revenue", "required": False, "default": True, "allow_update": True}, {"key": "credit_limit", "label": "credit_limit", "required": False, "default": True, "allow_update": True}, {"key": "sensitive_identifier", "label": "sensitive_identifier", "required": False, "default": True, "allow_update": True}]}),
        _action("explain_iceberg_architecture", "How Iceberg works", "Before you look at the raw files, here's the chain Oracle actually walks to find your data. Every layer is a small index file, only the last hop touches the real rows.", link_step=True, explain_step=True, short_label="How it works"),
        _action("show_iceberg_files", "See the raw data", "Lists the real files behind ORDER_HISTORY and shows the current metadata JSON. This is what the data looks like before Oracle ever gets involved.", short_label="See the raw data"),
        _action("create_order_history", "Create external table", "Points Oracle at the pre-generated Iceberg order history files in Object Storage. No data grant exists yet.", "create_order_history_table.sql", destructive=True, requires=("create_manager_context",), short_label="Create table"),
        _action("show_order_history_data", "See the Iceberg data", "Queries ORDER_HISTORY with plain SQL, same syntax you'd use against any table. No data was ever copied into the database.", "show_order_history_data.sql", short_label="See the data", requires=("create_order_history",)),
        _action("extend_manager_context", "Extend customer access", "Choose which order-history columns the employee data role excludes from SELECT. AMOUNT starts included on purpose: notice it does not belong and check it to exclude it.", requires=("create_order_history", "set_context"), custom_grant_step=True, short_label="Extend access", grant_wizard={"api_prefix": "order-history-grant", "style": "all_except", "columns": [{"key": "order_id", "label": "order_id"}, {"key": "order_date", "label": "order_date"}, {"key": "sales_rep", "label": "sales_rep"}, {"key": "product_category", "label": "product_category"}, {"key": "amount", "label": "amount"}]}),
        _action("review_order_history", "Review", "Confirms the external table and its data grant.", "end_user_status.sql", short_label="Review"),
        _action("validate_as_marvin", "Run Marvin validation queries", "Runs the same validation SQL as Marvin and shows the rows, context, and active data roles.", "validation_queries.sql", database_user="MARVIN", requires=("create_end_users",), short_label="Run validation"),
        _action("restore_db_setup", "Restore to DB Setup", "Drops this lab's objects, then recreates APPLAB, its 22 sample rows, and the ordinary database connect role. The console resumes as though DB Setup has been completed.", "reset_lab.sql", "create_schema.sql", "load_sample_data.sql", "create_db_roles.sql", destructive=True, resets_setup=True, restored_actions=("prepare_applab", "create_db_roles", "review_db_setup"), short_label="Restore DB Setup", button_label="Restore to DB Setup"),
        _action("restore_deep_sec_setup", "Restore to Deep Sec Setup", "Drops this lab's objects, rebuilds DB Setup, then recreates the employee data role, its baseline grant, Marvin, and Emma. The console resumes as though DB Setup and Deep Sec Setup have been completed.", "reset_lab.sql", "create_schema.sql", "load_sample_data.sql", "create_db_roles.sql", "create_data_roles.sql", "create_data_grants.sql", "create_end_users.sql", "grant_employee_access.sql", destructive=True, needs_password=True, password_scripts=("create_end_users.sql",), resets_setup=True, restored_actions=("prepare_applab", "create_db_roles", "review_db_setup", "create_roles", "create_data_grants", "create_end_users", "grant_employee_access", "review_light"), short_label="Restore Deep Sec Setup", button_label="Restore to Deep Sec Setup"),
        _action("download_lab_files", "Downloads", "Build a fresh ZIP from the SQL scripts or the two running application source trees on this VM.", short_label="Downloads"),
        _action("reset_lab", "Reset all lab database objects", "Drops only the APPLAB schema, Marvin, and Deep Sec roles. Rebuild the lab afterward.", "reset_lab.sql", destructive=True, resets_setup=True, short_label="Reset all"),
    )
}

MANAGER_GRANT_REQUIRED_COLUMNS = ("customer_id",)
MANAGER_GRANT_OPTIONAL_COLUMNS = ("customer_name", "region", "sales_rep", "revenue", "credit_limit", "sensitive_identifier")
MANAGER_GRANT_ALL_COLUMNS = MANAGER_GRANT_REQUIRED_COLUMNS + MANAGER_GRANT_OPTIONAL_COLUMNS
MANAGER_GRANT_UPDATABLE_COLUMNS = MANAGER_GRANT_OPTIONAL_COLUMNS

EMPLOYEE_GRANT_REQUIRED_COLUMNS = ("customer_id",)
EMPLOYEE_GRANT_OPTIONAL_COLUMNS = ("sales_rep", "customer_name", "region", "revenue", "credit_limit", "sensitive_identifier")
EMPLOYEE_GRANT_ALL_COLUMNS = EMPLOYEE_GRANT_REQUIRED_COLUMNS + EMPLOYEE_GRANT_OPTIONAL_COLUMNS
EMPLOYEE_GRANT_UPDATABLE_COLUMNS = ("sales_rep", "customer_name", "region", "revenue", "credit_limit", "sensitive_identifier")
EMPLOYEE_ROW_RESTRICTION_PREDICATE = "upper(sales_rep) = upper(ora_end_user_context.username)"

ORDER_HISTORY_GRANT_OPTIONAL_COLUMNS = ("order_id", "order_date", "sales_rep", "product_category", "amount")


def _build_manager_grant_sql(
    selected_optional: list, update_columns: list, allow_delete: bool = False
) -> str:
    """Build the manager data grant from a whitelisted column selection only."""
    invalid = set(selected_optional) - set(MANAGER_GRANT_OPTIONAL_COLUMNS)
    if invalid:
        raise ValueError(f"Unknown column(s): {', '.join(sorted(invalid))}")
    invalid_update = set(update_columns) - set(MANAGER_GRANT_UPDATABLE_COLUMNS)
    if invalid_update:
        raise ValueError(f"Unknown update column(s): {', '.join(sorted(invalid_update))}")
    not_selected_but_updatable = set(update_columns) - set(selected_optional)
    if not_selected_but_updatable:
        raise ValueError(
            "Column(s) must be selected before granting UPDATE: "
            f"{', '.join(sorted(not_selected_but_updatable))}"
        )
    ordered = [
        column
        for column in MANAGER_GRANT_ALL_COLUMNS
        if column in MANAGER_GRANT_REQUIRED_COLUMNS or column in selected_optional
    ]
    ordered_update = [column for column in MANAGER_GRANT_ALL_COLUMNS if column in update_columns]
    privilege_clauses = [f"select ({', '.join(ordered)})"]
    if ordered_update:
        privilege_clauses.append(f"update ({', '.join(ordered_update)})")
    if allow_delete:
        privilege_clauses.append("delete")
    return (
        "create or replace data grant APPLAB.manager_customer_access\n"
        f"  as {', '.join(privilege_clauses)}\n"
        "  on APPLAB.customers\n"
        "  where upper(sales_rep) = upper(ora_end_user_context.username)\n"
        "     or manager_id = ora_end_user_context.APPLAB.MGR_CTX.id\n"
        "  to hol_datarole_manager_access;"
    )


def _build_employee_grant_sql(
    selected_optional: list,
    update_columns: list,
    allow_delete: bool = False,
    restrict_rows: bool = False,
) -> str:
    """Build the employee data grant from whitelisted choices only."""
    invalid_select = set(selected_optional) - set(EMPLOYEE_GRANT_OPTIONAL_COLUMNS)
    if invalid_select:
        raise ValueError(f"Unknown column(s): {', '.join(sorted(invalid_select))}")
    invalid_update = set(update_columns) - set(EMPLOYEE_GRANT_UPDATABLE_COLUMNS)
    if invalid_update:
        raise ValueError(f"Unknown update column(s): {', '.join(sorted(invalid_update))}")
    not_selected_but_updatable = set(update_columns) - set(selected_optional)
    if not_selected_but_updatable:
        raise ValueError(
            "Column(s) must be selected before granting UPDATE: "
            f"{', '.join(sorted(not_selected_but_updatable))}"
        )

    ordered_select = [
        column
        for column in EMPLOYEE_GRANT_ALL_COLUMNS
        if column in EMPLOYEE_GRANT_REQUIRED_COLUMNS or column in selected_optional
    ]
    ordered_update = [column for column in EMPLOYEE_GRANT_ALL_COLUMNS if column in update_columns]
    privilege_clauses = [f"select ({', '.join(ordered_select)})"]
    if ordered_update:
        privilege_clauses.append(f"update ({', '.join(ordered_update)})")
    if allow_delete:
        privilege_clauses.append("delete")

    lines = [
        "create or replace data grant APPLAB.employee_customer_access",
        f"  as {', '.join(privilege_clauses)}",
        "  on APPLAB.customers",
    ]
    if restrict_rows:
        lines.append(f"  where {EMPLOYEE_ROW_RESTRICTION_PREDICATE}")
    lines.append("  to hol_datarole_employee_access;")
    return "\n".join(lines)


def _build_order_history_grant_sql(excluded_select: list) -> str:
    """Build the cross-table order-history grant from whitelisted columns."""
    invalid_exclude = set(excluded_select) - set(ORDER_HISTORY_GRANT_OPTIONAL_COLUMNS)
    if invalid_exclude:
        raise ValueError(f"Unknown column(s): {', '.join(sorted(invalid_exclude))}")
    ordered_exclude = [column for column in ORDER_HISTORY_GRANT_OPTIONAL_COLUMNS if column in excluded_select]
    select_clause = (
        f"select (all columns except {', '.join(ordered_exclude)})"
        if ordered_exclude
        else "select (all columns)"
    )
    return (
        "create or replace data grant APPLAB.order_history_by_customer_access\n"
        f"  as {select_clause}\n"
        "  on APPLAB.order_history\n"
        "  when select (customer_id) granted on APPLAB.customers\n"
        "  where APPLAB.order_history.customer_id = APPLAB.customers.customer_id;"
    )


def _run_data_grant_sql(password: str, sql_statement: str) -> dict:
    """Run a server-generated data grant as ADMIN through SQL*Plus."""
    quoted_password = password.replace('"', '""')
    script = f'whenever oserror exit failure\nconnect admin/"{quoted_password}"@{settings.dsn}\n{sql_statement}\nexit\n'
    result = subprocess.run(
        ["sqlplus", "-s", "-L", "/nolog"],
        input=script,
        text=True,
        capture_output=True,
        timeout=120,
        env={**os.environ, "TNS_ADMIN": settings.wallet_location},
        check=False,
    )
    output = (result.stdout + result.stderr).strip() or "SQL*Plus completed without additional output."
    return {"exit_code": result.returncode, "output": output}

for action in ACTIONS.values():
    action["required_titles"] = [ACTIONS[key]["title"] for key in action["requires"]]

STEP_NOTES = {
    "create_roles": [
        "The best practice is to grant data roles to standard database roles rather than directly to end users. This approach improves scalability and simplifies administration. Later, you can map the data role to a directory group so that all members automatically inherit the mapped data role.",
        "Note that CREATE OR REPLACE is supported for data roles. Standard database roles do not support the REPLACE option; this is a Deep Sec-specific convenience.",
    ],
    "create_data_grants": [
        "The data grant authorizes the table. Revoke it and the role remains, but a query returns table or view does not exist rather than access denied.",
        "WHERE is optional on a data grant. Leaving it out authorizes every row, that's Deep Sec's real syntax for no restriction, not a 1=1 workaround. Leaving SELECT bare grants every column.",
    ],
    "create_users": [
        "In an enterprise IAM environment, people sign in as IAM users. Instead of creating Marvin and Emma as local database users, map the Deep Sec data role to an IAM directory group.",
        "When an IAM user such as Marvin belongs to that IAM directory group, they automatically receive the mapped Deep Sec data role when they sign in to the database.",
    ],
    "customize_employee_grant": [
        "Create a data grant that excludes the credit_limit and sensitive_identifier columns and restricts the rows to only the sales rep's own rows.",
    ],
    "extend_manager_context": [
        "AMOUNT starts included here on purpose. Revenue and financial figures are exactly the kind of column that shouldn't ride along just because it's technically available, the exercise is noticing it and checking it to exclude it, the same instinct as excluding CREDIT_LIMIT on the employee grant.",
        "This grant's predicate reaches into a different table entirely, matching order_history rows to customers an end user already has access to. The row rule stays fixed; only the columns are yours to choose, since the relationship itself is the thing being taught here.",
    ],
    "show_iceberg_files": [
        "This is the actual proof that Iceberg data isn't 'in' Oracle. These files could have been written by Snowflake, Spark, or Databricks, Oracle never copied them, it's reading them where they already live.",
    ],
    "create_order_history": [
        "Compare this to what you just saw. One statement, pointing at files that already existed, turns them into a queryable Oracle object. No ETL, no copy, no second system.",
    ],
}

REVIEW_QUIZZES = {
    "review_setup": {
        "question": "Why does HOL_DBROLE_CONNECT hold CREATE SESSION?",
        "options": (
            {"key": "data_role", "label": "Data roles can hold system privileges only after their first data grant."},
            {"key": "database_role", "label": "Data roles cannot receive system privileges directly, so the standard database role supplies the login privilege through the data role."},
            {"key": "local_user", "label": "Only local database users need CREATE SESSION; IAM users never need it."},
            {"key": "admin", "label": "CREATE SESSION must be granted directly to each end user by ADMIN."},
        ),
        "correct_answer": "database_role",
        "explanation": "Correct. HOL_DBROLE_CONNECT is the standard database-role bridge for CREATE SESSION; the data role carries that database role to the end user.",
    },
    "review": {
        "question": "After the data role and data grant exist, what must happen before Marvin can query APPLAB.CUSTOMERS?",
        "options": (
            {"key": "grant_role", "label": "HOL_DATAROLE_EMPLOYEE_ACCESS must be granted to Marvin."},
            {"key": "create_table", "label": "APPLAB.CUSTOMERS must be copied into Marvin's schema."},
            {"key": "application", "label": "The Customer Sales application must give Marvin access."},
            {"key": "context", "label": "A manager context must be created for Marvin."},
        ),
        "correct_answer": "grant_role",
        "explanation": "Correct. A data role and its grant define possible access, but Marvin receives that access only after the data role is granted to him.",
    },
    "review_grant": {
        "question": "After row restriction and column exclusions are applied, what stops Marvin from seeing unauthorized data?",
        "options": (
            {"key": "database", "label": "Oracle's data grant enforcement."},
            {"key": "application", "label": "The Customer Sales application's page logic."},
            {"key": "browser", "label": "The browser hiding rows and columns."},
            {"key": "password", "label": "A different password for the restricted user."},
        ),
        "correct_answer": "database",
        "explanation": "Correct. The database enforces the data grant, so changing or bypassing the application cannot reveal rows or columns that Oracle did not authorize.",
    },
    "review_context": {
        "question": "What does the manager data grant use to determine which customer rows a manager can access?",
        "options": (
            {"key": "context", "label": "The authenticated user's end-user context and the manager lookup relationship."},
            {"key": "browser", "label": "The manager selected in the Customer Sales browser page."},
            {"key": "all_rows", "label": "Every row in APPLAB.CUSTOMERS, because managers always have full access."},
            {"key": "table_copy", "label": "A private copy of the customer table for each manager."},
        ),
        "correct_answer": "context",
        "explanation": "Correct. The data grant reads the authenticated user's context and the manager lookup to decide which rows Oracle returns.",
    },
    "review_order_history": {
        "question": "When Oracle creates APPLAB.ORDER_HISTORY, what happens to the Iceberg data?",
        "options": (
            {"key": "object_storage", "label": "It remains in Object Storage; Oracle queries the existing Iceberg files without copying them into database storage."},
            {"key": "database_copy", "label": "Oracle copies every Parquet file into an APPLAB table."},
            {"key": "conversion", "label": "Oracle converts the Iceberg files into an Oracle-only format."},
            {"key": "deletion", "label": "Oracle deletes the Iceberg files after importing their rows."},
        ),
        "correct_answer": "object_storage",
        "explanation": "Correct. ORDER_HISTORY is an external table over the existing Iceberg files; the data remains in Object Storage.",
    },
}

STEPS = tuple(
    {**step, "notes": STEP_NOTES.get(step["key"], []), "quiz": REVIEW_QUIZZES.get(step["key"])}
    for step in (
    {"key": "prepare_applab", "title": "Prepare App", "action_keys": ("prepare_applab",), "next_hint": "Run Create database role to set up ordinary Oracle login plumbing before Deep Sec begins."},
    {"key": "create_db_roles", "title": "Create DB Role", "action_keys": ("create_db_roles",), "next_hint": "Continue to Create data roles. This is where Deep Sec starts."},
    {"key": "review_setup", "title": "Review & Quiz", "action_keys": ("review_db_setup",), "next_hint": "Continue to Deep Sec Setup to create the data roles and grants Marvin will use."},
    {"key": "create_roles", "title": "Create data roles", "action_keys": ("create_roles",), "next_hint": "Run Create data grants to give these data roles something to actually authorize."},
    {"key": "create_data_grants", "title": "Create data grants", "action_keys": ("create_data_grants",), "next_hint": "Run Create end users to create Marvin and Emma. The employee data grant starts wide open and can be narrowed later."},
    {"key": "create_users", "title": "Create end users", "action_keys": ("create_end_users",), "next_hint": "The data roles and grants are defined before any people receive them. Continue to Grant Data Role for Marvin's starting state."},
    {"key": "grant_employee_access", "title": "Grant Data Role", "action_keys": ("grant_employee_access",), "next_hint": "Open Customer Sales Demo to see this access from Marvin's side."},
    {"key": "review", "title": "Review & Quiz", "action_keys": ("review_light",), "next_hint": "Continue to Customer Sales to see this access from Marvin's side."},
    {"key": "customer_sales", "title": "Customer Sales Demo", "action_keys": ("customer_sales",), "next_hint": "Continue to Customize Data Grant to narrow the rows and columns Oracle returns to Marvin."},
    {"key": "customize_employee_grant", "title": "Customize Data Grant", "action_keys": ("customize_employee_grant",), "next_hint": "Continue to Check Customer Sales to confirm the change took effect."},
    {"key": "verify_employee_grant", "title": "Check Customer Sales", "action_keys": ("verify_employee_grant",), "next_hint": "Continue to Review to confirm the grant."},
    {"key": "review_grant", "title": "Review & Quiz", "action_keys": ("review_grant",), "next_hint": "Continue to End User Context to prepare Marvin's manager promotion."},
    {"key": "create_managers", "title": "Manager Lookup", "action_keys": ("create_managers",), "next_hint": "Run Manager context to build the session-scoped context that reads this lookup."},
    {"key": "create_manager_context", "title": "Manager context", "action_keys": ("create_manager_context",), "next_hint": "Run Set Context to wire up the bridge role and context access."},
    {"key": "set_context", "title": "Set Context", "action_keys": ("set_context",), "next_hint": "Run Manager Data Grant to define what a manager can see, before granting the role itself."},
    {"key": "customize_manager_grant", "title": "Manager Data Grant", "action_keys": ("customize_manager_grant",), "next_hint": "Run Grant Manager Role to promote Marvin now that his grant is defined."},
    {"key": "grant_manager_role", "title": "Grant Manager Role", "action_keys": ("enable_manager", "disable_manager"), "next_hint": "Open Customer Sales as Marvin to see manager access apply, or Vibe Coding to try querying beyond it."},
    {"key": "review_context", "title": "Review & Quiz", "action_keys": ("review_context",), "next_hint": "Continue to Order History to extend the existing customer authorization to Iceberg-backed data."},
    {"key": "explain_iceberg_architecture", "title": "How it works", "action_keys": ("explain_iceberg_architecture",), "next_hint": "Continue to See the raw data to look at the actual files this diagram describes."},
    {"key": "show_iceberg_files", "title": "See the raw data", "action_keys": ("show_iceberg_files",), "next_hint": "Continue to Create table to see Oracle turn these files into a queryable object."},
    {"key": "create_order_history", "title": "Create table", "action_keys": ("create_order_history",), "next_hint": "Continue to See the data to query it with ordinary SQL."},
    {"key": "show_order_history_data", "title": "See the data", "action_keys": ("show_order_history_data",), "next_hint": "Continue to Extend customer access to authorize what you just saw."},
    {"key": "extend_manager_context", "title": "Extend customer access", "action_keys": ("extend_manager_context",), "next_hint": "Continue to Review to confirm the grant."},
    {"key": "review_order_history", "title": "Review & Quiz", "action_keys": ("review_order_history",), "next_hint": "Continue to Vibe Coding."},
    {"key": "validate_as_marvin", "title": "Run validation", "action_keys": ("validate_as_marvin",), "next_hint": "Use Reset all if you want to start the whole lab over from scratch."},
    {"key": "restore_db_setup", "title": "Restore to DB Setup", "action_keys": ("restore_db_setup",), "next_hint": "Use Restore to Deep Sec Setup to add the baseline data roles, data grant, Marvin, and Emma."},
    {"key": "restore_deep_sec_setup", "title": "Restore to Deep Sec Setup", "action_keys": ("restore_deep_sec_setup",), "next_hint": "Open Customer Sales to continue from the baseline employee access."},
    {"key": "download_lab_files", "title": "Downloads", "action_keys": ("download_lab_files",)},
    {"key": "reset_lab", "title": "Reset all", "action_keys": ("reset_lab",), "next_hint": "Use the secure employee baseline reset once it is available, or run Prepare APPLAB to begin again."},
    )
)

PAGES = (
    {"key": "db_setup", "path": "/db-setup", "nav_label": "DB Setup", "step_keys": ("prepare_applab", "create_db_roles", "review_setup")},
    {"key": "deep_sec_basics", "path": "/deep-sec-basics", "nav_label": "Deep Sec Setup", "step_keys": ("create_roles", "create_data_grants", "create_users", "grant_employee_access", "review")},
    {"key": "customer_sales", "path": "/customer-sales", "nav_label": "Customer Sales", "step_keys": ("customer_sales",)},
    {"key": "build_grant", "path": "/build-grant", "nav_label": "Customize Grant", "step_keys": ("customize_employee_grant", "verify_employee_grant", "review_grant")},
    {"key": "end_user_context", "path": "/end-user-context", "nav_label": "End User Context", "step_keys": ("create_managers", "create_manager_context", "set_context", "customize_manager_grant", "grant_manager_role", "review_context")},
    {"key": "order_history", "path": "/order-history", "nav_label": "Order History", "step_keys": ("explain_iceberg_architecture", "show_iceberg_files", "create_order_history", "show_order_history_data", "extend_manager_context", "review_order_history")},
    {"key": "vibe-coding", "path": "/vibe-coding", "nav_label": "Vibe Coding", "step_keys": ()},
    {"key": "admin", "path": "/admin", "nav_label": "Admin", "step_keys": ("validate_as_marvin", "restore_db_setup", "restore_deep_sec_setup", "download_lab_files", "reset_lab")},
)


def _sqlplus_input(password: str, action: dict) -> str:
    quoted_password = password.replace('"', '""')
    lines = ["whenever oserror exit failure", f'connect {action["database_user"].lower()}/"{quoted_password}"@{settings.dsn}']
    for script in action["scripts"]:
        command = f"@{script['path']}"
        if script["name"] == action.get("internal_secret_script"):
            internal_secret = secrets.token_urlsafe(24).replace('"', '')
            lines.append(f'define APPLAB_PASSWORD = "{internal_secret}"')
            lines.append(command)
            lines.append("undefine APPLAB_PASSWORD")
            continue
        elif script["name"] in action["password_scripts"] or (action["needs_password"] and not action["password_scripts"]):
            command += f' "{quoted_password}"'
        lines.append(command)
    lines.append("exit")
    return "\n".join(lines) + "\n"


def _run_action(password: str, action: dict) -> dict:
    result = subprocess.run(
        ["sqlplus", "-s", "-L", "/nolog"],
        input=_sqlplus_input(password, action),
        text=True,
        capture_output=True,
        timeout=120,
        env={**os.environ, "TNS_ADMIN": settings.wallet_location},
        check=False,
    )
    output = (result.stdout + result.stderr).strip() or "SQL*Plus completed without additional output."
    return {"exit_code": result.returncode, "output": output}


@app.get("/")
def index():
    if current_user.is_authenticated:
        return redirect(url_for("console"))
    return render_template("login.html")


def _render_stepper_page(page_key: str, step_keys: tuple, next_page_path: Optional[str]):
    completed_actions = _completed_actions() | _database_completed_actions()
    action_outputs = _action_outputs()
    customer_sales_url = f"{request.scheme}://{request.host.split(':', 1)[0]}:7777/"
    actions = {
        key: {
            **action,
            "locked": False,
            "output": action_outputs.get(action["key"]),
            "link_url": customer_sales_url if action["key"] == "customer_sales" else action["link_url"],
        }
        for key, action in ACTIONS.items()
    }
    all_keys_in_order = [step["key"] for step in STEPS]
    page_steps = sorted(
        (step for step in STEPS if step["key"] in step_keys),
        key=lambda step: all_keys_in_order.index(step["key"]),
    )
    steps = []
    for index, step in enumerate(page_steps):
        quiz = step["quiz"]
        if quiz:
            # Keep the answer keys stable for client-side validation, but do
            # not train learners to select the first radio button.
            quiz = {
                **quiz,
                "options": tuple(secrets.SystemRandom().sample(quiz["options"], k=len(quiz["options"]))),
            }
        entry = {
            **step,
            "quiz": quiz,
            "actions": [actions[key] for key in step["action_keys"]],
        }
        if index + 1 < len(page_steps):
            entry["next_step_key"] = page_steps[index + 1]["key"]
            entry["next_page_path"] = None
        else:
            entry["next_step_key"] = None
            entry["next_page_path"] = next_page_path
        steps.append(entry)
    return render_template(
        "console.html",
        actions=actions,
        steps=steps,
        completed_actions=sorted(completed_actions),
        pages=PAGES,
        current_page_key=page_key,
    )


@app.get("/db-setup")
@login_required
def db_setup():
    return _render_stepper_page("db_setup", PAGES[0]["step_keys"], PAGES[1]["path"])


@app.get("/console")
@login_required
def console():
    return render_template("overview.html", pages=PAGES, current_page_key="console")


@app.get("/deep-sec-basics")
@login_required
def deep_sec_basics():
    return _render_stepper_page("deep_sec_basics", PAGES[1]["step_keys"], PAGES[2]["path"])


@app.get("/customer-sales")
@login_required
def customer_sales_page():
    return _render_stepper_page("customer_sales", PAGES[2]["step_keys"], PAGES[3]["path"])


@app.get("/build-grant")
@login_required
def build_grant():
    return _render_stepper_page("build_grant", PAGES[3]["step_keys"], PAGES[4]["path"])


@app.get("/end-user-context")
@login_required
def end_user_context():
    return _render_stepper_page("end_user_context", PAGES[4]["step_keys"], PAGES[5]["path"])


@app.get("/order-history")
@login_required
def order_history():
    return _render_stepper_page("order_history", PAGES[5]["step_keys"], PAGES[6]["path"])


@app.get("/admin")
@login_required
def admin_page():
    return _render_stepper_page("admin", PAGES[7]["step_keys"], None)


@app.get("/vibe-coding")
@login_required
def vibe_coding():
    return render_template("vibe_coding.html", pages=PAGES, current_page_key="vibe-coding")


@app.get("/api/download/sql-scripts")
@login_required
def download_sql_scripts():
    output_path = Path(tempfile.gettempdir()) / "deep-sec-sql-scripts.zip"
    build_sql_scripts_zip(DATABASE_DOWNLOAD_DIR, output_path)
    return send_file(output_path, as_attachment=True, download_name="deep-sec-sql-scripts.zip")


@app.get("/api/download/application")
@login_required
def download_application():
    output_path = Path(tempfile.gettempdir()) / "deep-sec-application.zip"
    build_application_zip(ADMIN_APP_DIR, CUSTOMER_APP_DIR, output_path)
    return send_file(output_path, as_attachment=True, download_name="deep-sec-application.zip")


@app.post("/api/login")
def login():
    password = str((request.get_json(silent=True) or {}).get("password", ""))
    if not password:
        return jsonify(error="Enter the ADMIN database password."), 400
    try:
        database_user = verify_admin(settings, password)
    except Exception as exc:
        # Keep the browser response generic, but preserve the Oracle exception
        # and traceback in the protected systemd journal for lab diagnostics.
        # The submitted password is never included in this log message.
        app.logger.exception("ADMIN console sign-in failed: %s", exc)
        return jsonify(error="Database sign-in failed. Verify the ADMIN password."), 401
    login_id = secrets.token_urlsafe(32)
    with _logins_lock:
        _logins[login_id] = {
            "password": password,
            "expires_at": time.monotonic() + LOGIN_TTL_SECONDS,
            "completed_actions": set(),
            "action_outputs": {},
        }
    login_user(AdminUser(login_id))
    return jsonify(database_user=database_user)


@app.post("/api/logout")
def logout():
    with _logins_lock:
        _logins.pop(current_user.get_id(), None)
    logout_user()
    return jsonify(status="signed out")


@app.get("/api/state")
@login_required
def state():
    try:
        return jsonify(available=True, **lab_state(settings, _admin_password()))
    except Exception as exc:
        # Before Create MARVIN this is expected rather than an application error.
        # Return a successful, explicit state so the browser console is not filled
        # with a misleading 409 error during the guided setup sequence. The real
        # Oracle exception remains visible at debug level in journald.
        app.logger.debug("MARVIN state is not available yet: %s", exc)
        return jsonify(
            available=False,
            message="Marvin's current state will appear after Create MARVIN completes.",
        )


@app.get("/api/validation-comparison")
@login_required
def validation_comparison_state():
    try:
        return jsonify(available=True, **validation_comparison(settings, _admin_password()))
    except Exception as exc:
        app.logger.debug("Validation comparison is not available yet: %s", exc)
        return jsonify(available=False, message="Create the comparison users and data roles first."), 200


@app.post("/api/actions/show_iceberg_files")
@login_required
def run_show_iceberg_files():
    try:
        bucket = settings.order_history_bucket
        namespace = settings.order_history_namespace
        region = settings.genai_region
        read_par_url = settings.order_history_read_par_url.rstrip("/")
        prefix = "order_history_iceberg/"
        prefix_url = f"https://objectstorage.{region}.oraclecloud.com/n/{namespace}/b/{bucket}/o/{prefix}"
        # This PAR is already limited to the Iceberg prefix. Supplying a second
        # prefix query makes Object Storage reject the request as ambiguous.
        with urllib.request.urlopen(read_par_url, timeout=10) as resp:
            object_listing = json.loads(resp.read().decode())
        object_names = [item["name"] for item in object_listing.get("objects", [])]
        metadata_paths = sorted(name for name in object_names if name.endswith(".metadata.json"))
        if not metadata_paths:
            raise ValueError("No Iceberg metadata JSON exists in the Order History prefix.")
        metadata_path = metadata_paths[-1]
        metadata_url = f"https://objectstorage.{region}.oraclecloud.com/n/{namespace}/b/{bucket}/o/{metadata_path}"
        file_listing = "\n".join(object_names)
        metadata_read_par_url = settings.order_history_metadata_read_par_url
        if not metadata_read_par_url:
            raise ValueError("The Order History metadata read URL is not configured.")
        with urllib.request.urlopen(metadata_read_par_url, timeout=10) as resp:
            metadata_json = resp.read().decode()
    except Exception:
        app.logger.exception("Could not read Iceberg files.")
        return jsonify(error="Could not reach Object Storage."), 502

    output = (
        f"Real files backing ORDER_HISTORY live under:\n{prefix_url}\n\n"
        f"Iceberg file listing:\n{file_listing}\n\n"
        f"Current metadata file:\n{metadata_url}\n\n"
        f"Metadata JSON (schema, snapshots, current-snapshot-id):\n{metadata_json}"
    )
    selected_action = ACTIONS["show_iceberg_files"]
    completed_actions = _record_completed_action(selected_action)
    _record_action_output(selected_action["key"], output)
    return jsonify(action=selected_action["title"], completed_actions=completed_actions, exit_code=0, output=output)


@app.post("/api/actions/<action_key>")
@login_required
def action(action_key: str):
    selected_action = ACTIONS.get(action_key)
    if not selected_action:
        return jsonify(error="Unknown administrator action."), 404
    if selected_action.get("link_step"):
        completed_actions = _record_completed_action(selected_action)
        _record_action_output(action_key, "Marked as viewed.")
        return jsonify(action=selected_action["title"], completed_actions=completed_actions, output="Marked as viewed.")
    if selected_action.get("custom_grant_step"):
        return jsonify(error="Use the column choices and Apply this grant button."), 400
    try:
        result = _run_action(_admin_password(), selected_action)
    except subprocess.TimeoutExpired:
        return jsonify(error="SQL*Plus did not complete within two minutes."), 504
    except Exception:
        app.logger.exception("Administrator action failed before SQL*Plus completed: %s", action_key)
        return jsonify(error="Could not run the fixed administrator action. Check the server log."), 502
    status = 200 if result["exit_code"] == 0 else 422
    _record_action_output(action_key, result["output"])
    completed_actions = _record_completed_action(selected_action) if status == 200 else sorted(
        _completed_actions() | _database_completed_actions()
    )
    return jsonify(action=selected_action["title"], completed_actions=completed_actions, **result), status


@app.post("/api/manager-grant/preview")
@login_required
def preview_manager_grant():
    payload = request.get_json(silent=True) or {}
    selected = payload.get("columns", [])
    update_columns = payload.get("update_columns", [])
    allow_delete = payload.get("allow_delete", False)
    if (
        not isinstance(selected, list)
        or not isinstance(update_columns, list)
        or not all(isinstance(column, str) for column in selected)
        or not all(isinstance(column, str) for column in update_columns)
        or not isinstance(allow_delete, bool)
    ):
        return jsonify(error="Invalid column selection."), 400
    try:
        return jsonify(sql=_build_manager_grant_sql(selected, update_columns, allow_delete))
    except ValueError as exc:
        return jsonify(error=str(exc)), 400


@app.post("/api/manager-grant/apply")
@login_required
def apply_manager_grant():
    payload = request.get_json(silent=True) or {}
    selected = payload.get("columns", [])
    update_columns = payload.get("update_columns", [])
    allow_delete = payload.get("allow_delete", False)
    if (
        not isinstance(selected, list)
        or not isinstance(update_columns, list)
        or not all(isinstance(column, str) for column in selected)
        or not all(isinstance(column, str) for column in update_columns)
        or not isinstance(allow_delete, bool)
    ):
        return jsonify(error="Invalid column selection."), 400
    try:
        sql = _build_manager_grant_sql(selected, update_columns, allow_delete)
    except ValueError as exc:
        return jsonify(error=str(exc)), 400
    completed_actions = _completed_actions() | _database_completed_actions()
    if not {"create_manager_context", "set_context"}.issubset(completed_actions):
        return jsonify(error="Run Create Context and Set Context before creating this grant."), 409
    try:
        result = _run_data_grant_sql(_admin_password(), sql)
    except subprocess.TimeoutExpired:
        return jsonify(error="The grant update did not complete within two minutes."), 504
    except Exception:
        app.logger.exception("Manager grant customization failed before SQL*Plus completed.")
        return jsonify(error="Could not apply the customized grant. Check the server log."), 502
    status = 200 if result["exit_code"] == 0 else 422
    selected_action = ACTIONS["customize_manager_grant"]
    _record_action_output(selected_action["key"], result["output"])
    completed_actions = _record_completed_action(selected_action) if status == 200 else sorted(
        _completed_actions() | _database_completed_actions()
    )
    return jsonify(action=selected_action["title"], completed_actions=completed_actions, sql=sql, **result), status


@app.post("/api/employee-grant/preview")
@login_required
def preview_employee_grant():
    payload = request.get_json(silent=True) or {}
    selected = payload.get("columns", [])
    update_columns = payload.get("update_columns", [])
    allow_delete = payload.get("allow_delete", False)
    restrict_rows = payload.get("restrict_rows", False)
    if (
        not isinstance(selected, list)
        or not isinstance(update_columns, list)
        or not all(isinstance(column, str) for column in selected)
        or not all(isinstance(column, str) for column in update_columns)
        or not isinstance(allow_delete, bool)
        or not isinstance(restrict_rows, bool)
    ):
        return jsonify(error="Invalid employee grant selection."), 400
    try:
        return jsonify(sql=_build_employee_grant_sql(selected, update_columns, allow_delete, restrict_rows))
    except ValueError as exc:
        return jsonify(error=str(exc)), 400


@app.post("/api/employee-grant/apply")
@login_required
def apply_employee_grant():
    payload = request.get_json(silent=True) or {}
    selected = payload.get("columns", [])
    update_columns = payload.get("update_columns", [])
    allow_delete = payload.get("allow_delete", False)
    restrict_rows = payload.get("restrict_rows", False)
    if (
        not isinstance(selected, list)
        or not isinstance(update_columns, list)
        or not all(isinstance(column, str) for column in selected)
        or not all(isinstance(column, str) for column in update_columns)
        or not isinstance(allow_delete, bool)
        or not isinstance(restrict_rows, bool)
    ):
        return jsonify(error="Invalid employee grant selection."), 400
    try:
        sql = _build_employee_grant_sql(selected, update_columns, allow_delete, restrict_rows)
    except ValueError as exc:
        return jsonify(error=str(exc)), 400
    completed_actions = _completed_actions() | _database_completed_actions()
    if "create_roles" not in completed_actions:
        return jsonify(error="Run Create data roles before building this grant."), 409
    try:
        result = _run_data_grant_sql(_admin_password(), sql)
    except subprocess.TimeoutExpired:
        return jsonify(error="The grant update did not complete within two minutes."), 504
    except Exception:
        app.logger.exception("Employee grant customization failed before SQL*Plus completed.")
        return jsonify(error="Could not apply the customized grant. Check the server log."), 502
    status = 200 if result["exit_code"] == 0 else 422
    selected_action = ACTIONS["customize_employee_grant"]
    _record_action_output(selected_action["key"], result["output"])
    completed_actions = _record_completed_action(selected_action) if status == 200 else sorted(
        _completed_actions() | _database_completed_actions()
    )
    return jsonify(action=selected_action["title"], completed_actions=completed_actions, sql=sql, **result), status


@app.post("/api/order-history-grant/preview")
@login_required
def preview_order_history_grant():
    payload = request.get_json(silent=True) or {}
    excluded = payload.get("excluded_columns", [])
    if not isinstance(excluded, list) or not all(isinstance(column, str) for column in excluded):
        return jsonify(error="Invalid selection."), 400
    try:
        return jsonify(sql=_build_order_history_grant_sql(excluded))
    except ValueError as exc:
        return jsonify(error=str(exc)), 400


@app.post("/api/order-history-grant/apply")
@login_required
def apply_order_history_grant():
    payload = request.get_json(silent=True) or {}
    excluded = payload.get("excluded_columns", [])
    if not isinstance(excluded, list) or not all(isinstance(column, str) for column in excluded):
        return jsonify(error="Invalid selection."), 400
    try:
        sql = _build_order_history_grant_sql(excluded)
    except ValueError as exc:
        return jsonify(error=str(exc)), 400

    completed_actions = _completed_actions() | _database_completed_actions()
    if not {"create_order_history", "set_context"}.issubset(completed_actions):
        return jsonify(error="Run Create table and Set Context before building this grant."), 409
    try:
        result = _run_data_grant_sql(_admin_password(), sql)
    except subprocess.TimeoutExpired:
        return jsonify(error="The grant update did not complete within two minutes."), 504
    except Exception:
        app.logger.exception("Order-history grant customization failed before SQL*Plus completed.")
        return jsonify(error="Could not apply the customized grant. Check the server log."), 502

    status = 200 if result["exit_code"] == 0 else 422
    selected_action = ACTIONS["extend_manager_context"]
    _record_action_output(selected_action["key"], result["output"])
    completed_actions = _record_completed_action(selected_action) if status == 200 else sorted(
        _completed_actions() | _database_completed_actions()
    )
    return jsonify(action=selected_action["title"], completed_actions=completed_actions, sql=sql, **result), status


@app.post("/api/vibe-coding/run")
@login_required
def run_vibe_coding():
    payload = request.get_json(silent=True) or {}
    request_text = str(payload.get("request", "")).strip()
    persona = payload.get("persona", "MARVIN")
    if persona not in ("MARVIN", "EMMA"):
        return jsonify(error="Choose Marvin or Emma."), 400
    if not request_text or len(request_text) > 2000:
        return jsonify(error="Enter a request, up to 2000 characters."), 400
    try:
        script_text = generate_script(settings, request_text, persona)
    except Exception:
        app.logger.exception("Vibe Coding script generation failed.")
        return jsonify(error="Could not generate a script. Check the server log."), 502

    try:
        result = run_generated_script(script_text, settings.dsn, _admin_password(), settings.wallet_location)
    except subprocess.TimeoutExpired:
        return jsonify(script=script_text, error=f"Script did not complete within {VIBE_TIMEOUT_SECONDS} seconds."), 504
    except Exception:
        app.logger.exception("Vibe Coding script execution failed.")
        return jsonify(script=script_text, error="Could not run the generated script."), 502

    status = 200 if result["exit_code"] == 0 else 422
    return jsonify(script=script_text, **result), status


@app.get("/healthz")
def healthcheck():
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(host=settings.host, port=settings.port, debug=False)
