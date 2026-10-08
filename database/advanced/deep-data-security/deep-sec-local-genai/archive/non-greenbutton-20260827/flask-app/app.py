"""Flask UI for direct local Oracle Deep Data Security end users."""

import logging
import os
import secrets
import time
from decimal import Decimal
from threading import Lock
from typing import Optional

from dotenv import load_dotenv
from flask import Flask, jsonify, redirect, render_template, request, url_for
from flask_bootstrap import Bootstrap5
from flask_htmx import HTMX
from flask_login import LoginManager, UserMixin, current_user, login_required, login_user, logout_user
from flask_wtf.csrf import CSRFError, CSRFProtect
from werkzeug.exceptions import HTTPException

from ai import answer_customer_question
from config import load_settings
from db import (
    PERSONAS,
    QUERY_TEMPLATE,
    fetch_authorized_customers,
    fetch_order_history,
    oracle_error_code,
    oracle_queries,
    verify_persona_credentials,
)

load_dotenv()
settings = load_settings()
app = Flask(__name__)
app.config["SECRET_KEY"] = settings.secret_key
app.config["SESSION_COOKIE_NAME"] = "deep_sec_customer_session"
app.config["SESSION_COOKIE_HTTPONLY"] = True
app.config["SESSION_COOKIE_SAMESITE"] = "Lax"
Bootstrap5(app)
HTMX(app)
csrf = CSRFProtect(app)
login_manager = LoginManager(app)
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
app.logger.setLevel(getattr(logging, os.getenv("FLASK_LOG_LEVEL", "INFO").upper(), logging.INFO))

# Passwords remain only in this process's memory, keyed by an opaque browser
# session ID. They are never placed in a cookie, written to disk, or logged.
LOGIN_TTL_SECONDS = 30 * 60
_logins: dict[str, dict] = {}
_logins_lock = Lock()


class LabUser(UserMixin):
    """Flask-Login identity; the database password remains server-side only."""

    def __init__(self, login_id: str, persona: str):
        self.id = login_id
        self.persona = persona


@login_manager.user_loader
def load_user(login_id: str):
    with _logins_lock:
        login = _logins.get(login_id)
        if not login or login["expires_at"] <= time.monotonic():
            _logins.pop(login_id, None)
            return None
        return LabUser(login_id, login["persona"])


@login_manager.unauthorized_handler
def unauthorized():
    if request.path.startswith("/api/"):
        return jsonify(error="Sign in as Marvin or Emma first"), 401
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


def _json_value(value):
    return float(value) if isinstance(value, Decimal) else value


def _oracle_access_error(error: Exception, object_label: str) -> Optional[str]:
    """Explain authorization denials without exposing raw Oracle diagnostics."""
    code = oracle_error_code(error)
    oracle_message = str(getattr(error.args[0], "message", "")) if error.args else ""
    if code == 942:
        return (
            f"Oracle does not expose {object_label} to your current data role. "
            "With Deep Sec, a missing matching data grant deliberately appears as "
            "'table or view does not exist'; the object may also genuinely be absent."
        )
    if code == 1031:
        return (
            f"Oracle rejected access to {object_label} because your current data role "
            "lacks a required privilege."
        )
    if code == 6564 or "ORA-06564" in oracle_message:
        return (
            f"Oracle can see {object_label}, but DATA_PUMP_DIR is not accessible to "
            "your database identity. Verify READ on DATA_PUMP_DIR was granted to the "
            "Order History database role, that role was granted to the employee data "
            "role, and the employee data role is active for this user. A missing or "
            "non-matching data grant normally appears instead as 'table or view does "
            "not exist.'"
        )
    return None


def _login_credentials() -> tuple[str, str]:
    login_id = current_user.get_id()
    with _logins_lock:
        login = _logins.get(login_id)
        if not login or login["expires_at"] <= time.monotonic():
            if login_id:
                _logins.pop(login_id, None)
            raise ValueError("Sign in as Marvin or Emma first")
        login["expires_at"] = time.monotonic() + LOGIN_TTL_SECONDS
        return login["persona"], login["password"]


@app.get("/")
def index():
    if current_user.is_authenticated:
        return redirect(url_for("query_page"))
    return render_template("index.html", personas=PERSONAS)


@app.get("/query")
@login_required
def query_page():
    query = QUERY_TEMPLATE.format(schema=settings.db_schema)
    return render_template(
        "query.html",
        persona=PERSONAS[current_user.persona],
        query=" ".join(query.split()),
    )


@app.get("/ai")
@login_required
def ai_page():
    return render_template(
        "ai.html",
        persona=PERSONAS[current_user.persona],
        oracle_queries=oracle_queries(settings),
    )


@app.post("/api/login")
def login():
    payload = request.get_json(silent=True) or {}
    persona = payload.get("persona", "").upper()
    password = payload.get("password", "")
    try:
        context = verify_persona_credentials(settings, persona, password)
    except ValueError as exc:
        return jsonify(error=str(exc)), 400
    except Exception as exc:
        app.logger.info("Database login failed for persona=%s: %s", persona, exc)
        return jsonify(error="Database sign-in failed. Verify the selected user and password."), 401

    login_id = secrets.token_urlsafe(32)
    with _logins_lock:
        _logins[login_id] = {
            "persona": persona,
            "password": password,
            "expires_at": time.monotonic() + LOGIN_TTL_SECONDS,
        }
    login_user(LabUser(login_id, persona))
    return jsonify(persona=persona, context=context)


@app.post("/api/logout")
def logout():
    login_id = current_user.get_id()
    with _logins_lock:
        _logins.pop(login_id, None)
    logout_user()
    return jsonify(status="signed out")


@app.post("/api/customers")
@login_required
def customers():
    try:
        persona, password = _login_credentials()
        rows, context = fetch_authorized_customers(settings, persona, password)
    except ValueError as exc:
        return jsonify(error=str(exc)), 400
    except Exception as exc:
        app.logger.exception("Database query failed for persona=%s", persona)
        if access_error := _oracle_access_error(exc, "Customer Accounts"):
            return jsonify(error=access_error), 403
        return jsonify(error="Oracle could not complete the Customer Report for this database identity. Check the active data role and grant, then sign out and back in after a role change."), 502
    return jsonify(rows=[{key: _json_value(value) for key, value in row.items()} for row in rows],
                    context=context, row_count=len(rows))


@app.post("/api/order-history")
@login_required
def order_history():
    try:
        persona, password = _login_credentials()
        rows = fetch_order_history(settings, persona, password)
    except ValueError as exc:
        return jsonify(error=str(exc)), 400
    except Exception as exc:
        app.logger.exception("Order history query failed for persona=%s", current_user.persona)
        if access_error := _oracle_access_error(exc, "Order History"):
            return jsonify(error=access_error), 403
        return jsonify(error="Order history is unavailable. Check the server log and configuration."), 502
    return jsonify(rows=[{key: _json_value(value) for key, value in row.items()} for row in rows])


@app.post("/api/ai")
@login_required
def ai_insight():
    payload = request.get_json(silent=True) or {}
    question = str(payload.get("question", "")).strip()
    if not question:
        return jsonify(error="Enter a question for Customer Insights."), 400
    if len(question) > 1_000:
        return jsonify(error="Keep the question to 1,000 characters or fewer."), 400
    try:
        persona, password = _login_credentials()
        rows, context = fetch_authorized_customers(settings, persona, password)
        answer = answer_customer_question(settings, question, rows)
    except ValueError as exc:
        return jsonify(error=str(exc)), 400
    except Exception as exc:
        app.logger.exception("Customer Insights request failed for persona=%s", current_user.persona)
        if access_error := _oracle_access_error(exc, "Customer Accounts"):
            return jsonify(error=access_error), 403
        return jsonify(error="Customer Insights is unavailable. Check the server log and OCI Generative AI configuration."), 502
    return jsonify(answer=answer, context=context, row_count=len(rows))


@app.get("/healthz")
def healthcheck():
    return jsonify(status="ok")


if __name__ == "__main__":
    app.run(host=settings.host, port=settings.port, debug=settings.debug)
