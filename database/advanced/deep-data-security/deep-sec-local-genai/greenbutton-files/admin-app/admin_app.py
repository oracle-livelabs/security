"""Lesson-driven administrator console for Oracle security training."""

import logging
import json
import os
from pathlib import Path
import re
import secrets
import subprocess
import tempfile
import time
import urllib.request
from urllib.parse import quote, urlparse
from threading import Lock
from typing import Optional

from dotenv import load_dotenv
from flask import Flask, jsonify, redirect, render_template, request, send_file, session, url_for
from flask_login import LoginManager, UserMixin, current_user, login_required, login_user, logout_user
from flask_wtf.csrf import CSRFError, CSRFProtect
from markupsafe import Markup, escape
from werkzeug.exceptions import HTTPException

from admin_config import load_admin_settings
from admin_db import completed_setup_actions, lab_state, validation_comparison, verify_admin
from content_loader import ContentValidationError, load_lesson
from content_runtime import build_runtime_content
from downloads import build_application_zip, build_sql_scripts_zip
from handlers import HANDLERS
from runtime_reports import publish_report
from vibe import generate_report_query

load_dotenv()
settings = load_admin_settings()
app = Flask(__name__)


_ALLOWED_NOTE_TAGS = (
    "b",
    "br",
    "code",
    "em",
    "i",
    "li",
    "ol",
    "p",
    "pre",
    "strong",
    "sub",
    "sup",
    "u",
    "ul",
)
_NOTE_TAG_PATTERN = re.compile(
    rf"</?(?:{'|'.join(_ALLOWED_NOTE_TAGS)})(?:\s*/?)?>",
    re.IGNORECASE,
)
_HTML_TAG_PATTERN = re.compile(r"</?[A-Za-z][^>]*>")
_NOTE_TAG_PARTS = re.compile(r"<(/?)([A-Za-z][A-Za-z0-9]*)(?:\s*/?)?>")
_VOID_NOTE_TAGS = {"br"}


def render_note(value: object) -> Markup:
    """Render common note formatting while escaping all other markup."""
    text = "" if value is None else str(value)
    chunks = []
    cursor = 0
    open_tags = []
    for match in _HTML_TAG_PATTERN.finditer(text):
        chunks.append(str(escape(text[cursor : match.start()])))
        candidate = match.group()
        note_tag = _NOTE_TAG_PATTERN.fullmatch(candidate)
        parts = _NOTE_TAG_PARTS.fullmatch(candidate) if note_tag else None
        if not parts:
            chunks.append(str(escape(candidate)))
        else:
            closing, tag = parts.groups()
            tag = tag.lower()
            self_closing = candidate.rstrip().endswith("/>") or tag in _VOID_NOTE_TAGS
            if closing:
                if open_tags and open_tags[-1] == tag:
                    chunks.append(candidate)
                    open_tags.pop()
                else:
                    chunks.append(str(escape(candidate)))
            else:
                chunks.append(candidate)
                if not self_closing:
                    open_tags.append(tag)
        cursor = match.end()
    chunks.append(str(escape(text[cursor:])))
    return Markup("".join(chunks))


app.jinja_env.filters["render_note"] = render_note
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
_content_id = os.getenv("LAB_CONTENT_ID", "deep_data_security")
_content_manifest = os.getenv(
    "LAB_CONTENT_MANIFEST",
    str(ADMIN_APP_DIR / "content" / _content_id / "lab.yaml"),
)
try:
    LESSON = load_lesson(_content_manifest)
except ContentValidationError as exc:
    raise RuntimeError(f"Invalid lesson content: {exc}") from exc

ACTIONS, STEPS, PAGES = build_runtime_content(LESSON)
DATABASE_DOWNLOAD_DIR = LESSON.script_root
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


@app.after_request
def prevent_authenticated_page_caching(response):
    """Do not let Back show a protected page after a user signs out."""
    if current_user.is_authenticated or request.path.startswith("/api/"):
        response.headers["Cache-Control"] = "no-store, max-age=0"
        response.headers["Pragma"] = "no-cache"
    return response


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
            login.pop("customize_before", None)
        if action["restored_actions"]:
            login["completed_actions"].update(action["restored_actions"])
            login.pop("customize_before", None)
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


def _navigation_state(completed_actions: set[str]) -> tuple[list[dict], dict[str, int]]:
    """Add page completion metadata for the shared navigation and progress bar."""
    steps_by_key = {step["key"]: step for step in STEPS}
    pages = []
    total = 0
    completed = 0
    for page in PAGES:
        progress_steps = []
        for step_key in page["step_keys"]:
            step = steps_by_key[step_key]
            action_keys = [
                action_key
                for action_key in step["action_keys"]
                if ACTIONS[action_key]["type"] != "download"
            ]
            if action_keys:
                progress_steps.append(action_keys)
        excluded = page["key"] == "best_practices"
        is_completed = bool(progress_steps) and all(
            any(action_key in completed_actions for action_key in action_keys)
            for action_keys in progress_steps
        )
        if not excluded:
            total += 1
            if is_completed:
                completed += 1
        pages.append(
            {
                **page,
                "progress_steps": progress_steps,
                "progress_excluded": excluded,
                "completed": is_completed,
            }
        )
    return pages, {"completed": completed, "total": total}


def _database_completed_actions() -> set[str]:
    """Use durable Oracle state to restore setup progress after a re-login."""
    try:
        return completed_setup_actions(settings, _admin_password())
    except Exception as exc:
        app.logger.warning("Could not infer setup progress from Oracle: %s", exc)
        return set()


def _sqlplus_environment() -> dict[str, str]:
    """Use the wallet only for the legacy mTLS deployment."""
    environment = os.environ.copy()
    if settings.wallet_location:
        environment["TNS_ADMIN"] = settings.wallet_location
    else:
        environment.pop("TNS_ADMIN", None)
    return environment


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
        env=_sqlplus_environment(),
        check=False,
    )
    output = (result.stdout + result.stderr).strip() or "SQL*Plus completed without additional output."
    return {"exit_code": result.returncode, "output": output}


def _build_configured_grant(action_key: str, payload: dict) -> str:
    action = ACTIONS.get(action_key)
    if action is None:
        raise ValueError(f"Unknown administrator action: {action_key}")
    handler_name = action.get("handler")
    handler = HANDLERS.get(handler_name)
    if handler is None:
        raise ValueError(f"Action {action_key!r} has no registered handler")
    return handler(action["config"], payload)


def _sqlplus_input(password: str, action: dict) -> str:
    quoted_password = password.replace('"', '""')
    lines = ["whenever oserror exit failure", f'connect {action["database_user"].lower()}/"{quoted_password}"@{settings.dsn}']
    for script in action["scripts"]:
        command = f"@{script['path']}"
        if script["name"] == action.get("internal_secret_script"):
            # APPLAB is a prepared lab login now. create_schema.sql receives
            # the same password entered for the ADMIN setup session so later
            # APPLAB-owned actions can connect without a second learner input.
            if script["name"] == "create_schema.sql":
                internal_secret = quoted_password
            else:
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
        env=_sqlplus_environment(),
        check=False,
    )
    output = (result.stdout + result.stderr).strip() or "SQL*Plus completed without additional output."
    return {"exit_code": result.returncode, "output": output}


@app.get("/")
def index():
    if current_user.is_authenticated:
        return redirect(url_for("console"))
    return render_template("login.html", lesson=LESSON)


def _render_stepper_page(page_key: str, step_keys: tuple, next_page_path: Optional[str]):
    completed_actions = _completed_actions() | _database_completed_actions()
    navigation_pages, progress = _navigation_state(completed_actions)
    action_outputs = _action_outputs()
    customer_sales_url = f"{request.scheme}://{request.host.split(':', 1)[0]}:7777/"
    actions = {
        key: {
            **action,
            "locked": False,
            "output": action_outputs.get(action["key"]),
            "link_url": (
                customer_sales_url
                if action.get("link_target") == "customer_sales_app"
                else action["link_url"]
            ),
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
        pages=navigation_pages,
        progress=progress,
        current_page_key=page_key,
        lesson=LESSON,
        current_page_ordered=_page_by_key(page_key)["ordered"],
    )


@app.get("/console")
@login_required
def console():
    completed_actions = _completed_actions() | _database_completed_actions()
    navigation_pages, progress = _navigation_state(completed_actions)
    return render_template(
        "overview.html",
        pages=navigation_pages,
        progress=progress,
        completed_actions=sorted(completed_actions),
        current_page_key="console",
        lesson=LESSON,
    )


def _page_by_key(page_key: str) -> dict:
    for page in PAGES:
        if page["key"] == page_key:
            return page
    raise KeyError(f"Unknown lesson page: {page_key}")


def _render_configured_page(page: dict):
    if page.get("renderer") == "vibe_coding":
        return render_template(
            "vibe_coding.html",
            pages=PAGES,
            current_page_key=page["key"],
            lesson=LESSON,
        )
    page_index = next(index for index, item in enumerate(PAGES) if item["key"] == page["key"])
    next_page_path = PAGES[page_index + 1]["path"] if page_index + 1 < len(PAGES) else None
    return _render_stepper_page(page["key"], page["step_keys"], next_page_path)


def _register_configured_pages() -> None:
    for index, page in enumerate(PAGES):
        endpoint = f"lesson_page_{index}"

        def configured_page(page=page):
            return _render_configured_page(page)

        configured_page.__name__ = endpoint
        app.add_url_rule(
            page["path"],
            endpoint=endpoint,
            view_func=login_required(configured_page),
            methods=["GET"],
        )


_register_configured_pages()


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
@login_required
@csrf.exempt
def logout():
    with _logins_lock:
        _logins.pop(current_user.get_id(), None)
    logout_user()
    session.clear()
    response = jsonify(status="signed out")
    response.delete_cookie(app.config["SESSION_COOKIE_NAME"], samesite=app.config["SESSION_COOKIE_SAMESITE"])
    # The menu tour and DeeBee greeting are browser cookies, not session data.
    # Clear both so a new sign-in starts the lab tour from the beginning.
    response.delete_cookie("hol_tour_seen", samesite="Lax")
    response.delete_cookie("hol_deebee_greeted", samesite="Lax")
    return response


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


def _marvin_comparison_snapshot(comparison: dict) -> Optional[dict]:
    for persona in comparison.get("personas", []):
        if persona.get("username") == "MARVIN" and persona.get("available"):
            return {
                "row_count": persona.get("row_count"),
                "columns": persona.get("columns", []),
            }
    return None


@app.route("/api/customize-grant-comparison", methods=["GET", "POST"])
@login_required
def customize_grant_comparison():
    """Capture Marvin before the wizard and return the post-apply snapshot."""
    try:
        comparison = validation_comparison(settings, _admin_password())
    except Exception as exc:
        app.logger.debug("Customize-grant comparison is not available yet: %s", exc)
        return jsonify(available=False, message="Create Marvin and the employee grant before customizing it."), 200

    current = _marvin_comparison_snapshot(comparison)
    if current is None:
        return jsonify(available=False, message="Marvin's authorized query is not available yet."), 200

    login_id = current_user.get_id()
    with _logins_lock:
        login = _logins.get(login_id)
        if not login or login["expires_at"] <= time.monotonic():
            return jsonify(error="Sign in as ADMIN first"), 401
        before = login.get("customize_before")
        if (
            before is None
            and request.method == "GET"
            and "customize_employee_grant" not in login.get("completed_actions", set())
        ):
            before = current
            login["customize_before"] = before

    return jsonify(
        available=True,
        query=comparison["query"],
        before=before,
        after=current if request.method == "POST" else None,
    )


@app.post("/api/actions/show_iceberg_files")
@login_required
def run_show_iceberg_files():
    try:
        bucket = settings.order_history_bucket
        namespace = settings.order_history_namespace
        region = settings.oci_region
        read_par_url = settings.order_history_read_par_url.rstrip("/")
        prefix = settings.order_history_prefix
        prefix_url = f"https://objectstorage.{region}.oraclecloud.com/n/{namespace}/b/{bucket}/o/{prefix}"
        object_read_par_urls = settings.order_history_object_read_par_urls
        if object_read_par_urls:
            # Bundle mode uses exact-object PARs because OCI object_name grants
            # are not recursive. The map is the complete checked-in table.
            object_names = sorted(object_read_par_urls)
        else:
            with urllib.request.urlopen(read_par_url, timeout=10) as resp:
                object_listing = json.loads(resp.read().decode())
            object_names = [item["name"] for item in object_listing.get("objects", [])]
        metadata_paths = sorted(name for name in object_names if name.endswith(".metadata.json"))
        if not metadata_paths:
            raise ValueError("No Iceberg metadata JSON exists in the Order History prefix.")
        metadata_path = metadata_paths[-1]
        metadata_url = f"https://objectstorage.{region}.oraclecloud.com/n/{namespace}/b/{bucket}/o/{metadata_path}"
        file_listing = "\n".join(object_names)
        if object_read_par_urls:
            metadata_object_read_url = object_read_par_urls.get(metadata_path, "")
            if not metadata_object_read_url:
                raise ValueError(f"No exact-object PAR exists for {metadata_path}.")
        else:
            # A prefix PAR's access URI ends at /o/; append the object name
            # for a prefix-scoped metadata read.
            metadata_object_read_url = f"{read_par_url}/{quote(metadata_path, safe='/')}"
        with urllib.request.urlopen(metadata_object_read_url, timeout=10) as resp:
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
        return jsonify(error="Could not run the configured administrator action. Check the server log."), 502
    status = 200 if result["exit_code"] == 0 else 422
    _record_action_output(action_key, result["output"])
    completed_actions = _record_completed_action(selected_action) if status == 200 else sorted(
        _completed_actions() | _database_completed_actions()
    )
    return jsonify(action=selected_action["title"], completed_actions=completed_actions, **result), status


def _configured_wizard(action_key: str) -> dict:
    selected_action = ACTIONS.get(action_key)
    if not selected_action or selected_action.get("type") != "wizard" or not selected_action.get("handler"):
        raise ValueError("That action is not a configured data-grant wizard.")
    return selected_action


def _grant_payload() -> dict:
    payload = request.get_json(silent=True)
    if not isinstance(payload, dict):
        raise ValueError("Invalid grant selection.")
    return payload


@app.post("/api/actions/<action_key>/preview")
@login_required
def preview_configured_grant(action_key: str):
    try:
        _configured_wizard(action_key)
        return jsonify(sql=_build_configured_grant(action_key, _grant_payload()))
    except ValueError as exc:
        return jsonify(error=str(exc)), 400


@app.post("/api/actions/<action_key>/apply")
@login_required
def apply_configured_grant(action_key: str):
    try:
        selected_action = _configured_wizard(action_key)
        sql = _build_configured_grant(action_key, _grant_payload())
    except ValueError as exc:
        return jsonify(error=str(exc)), 400

    completed_actions = _completed_actions() | _database_completed_actions()
    missing = [
        ACTIONS[key]["title"]
        for key in selected_action["requires"]
        if key not in completed_actions
    ]
    if missing:
        return jsonify(error=f"Complete {', '.join(missing)} before applying this grant."), 409
    try:
        result = _run_data_grant_sql(_admin_password(), sql)
    except subprocess.TimeoutExpired:
        return jsonify(error="The grant update did not complete within two minutes."), 504
    except Exception:
        app.logger.exception("Configured data grant failed before SQL*Plus completed: %s", action_key)
        return jsonify(error="Could not apply the customized grant. Check the server log."), 502
    status = 200 if result["exit_code"] == 0 else 422
    _record_action_output(selected_action["key"], result["output"])
    completed_actions = _record_completed_action(selected_action) if status == 200 else sorted(
        _completed_actions() | _database_completed_actions()
    )
    return jsonify(action=selected_action["title"], completed_actions=completed_actions, sql=sql, **result), status


@app.post("/api/vibe-coding/publish")
@login_required
def publish_vibe_coding_report():
    payload = request.get_json(silent=True) or {}
    request_text = str(payload.get("request", "")).strip()
    if not request_text or len(request_text) > 2000:
        return jsonify(error="Enter a request, up to 2000 characters."), 400
    try:
        sql = generate_report_query(settings, request_text)
        report = publish_report(request_text, sql)
    except Exception:
        app.logger.exception("Vibe Coding report publication failed.")
        return jsonify(error="Could not create the Customer Sales App report page. Check the server log."), 502
    return jsonify(report_id=report["id"], report_path=f"/vibe-report/{report['id']}", sql=sql), 201


@app.get("/healthz")
def healthcheck():
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(host=settings.host, port=settings.port, debug=False)
