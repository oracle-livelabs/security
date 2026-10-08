"""Exercise real SDK exception shapes without any OCI or database requests."""

import json
import os
import time
import unittest
from datetime import datetime, timedelta, timezone
from email.utils import format_datetime
from types import SimpleNamespace
from unittest.mock import patch

import oci
from circuitbreaker import CircuitBreaker, CircuitBreakerError

from ai_diagnostics import CHAT_QUOTA, LOGGING_URL, build_ai_error

with patch.dict(os.environ, {"FLASK_SECRET_KEY": "diagnostics-test-only", "DB_DSN": "unused-test-dsn", "GENAI_DEFAULTS_FILE": "/nonexistent/diagnostics-test"}):
    import app as application

SETTINGS = SimpleNamespace(genai_region="us-ashburn-1", genai_model_id="google.gemini-2.5-flash")
PRIVATE = "PRIVATE-PAYLOAD-MARKER"


def service_error(status=429, headers=None, quota=True):
    return oci.exceptions.TransientServiceError(
        status, "429" if status == 429 else "ServiceFailure",
        headers if headers is not None else {"opc-request-id": "TEST-REQUEST/ABC/123"},
        f"{CHAT_QUOTA if quota else 'Capacity unavailable'} {PRIVATE} <script>alert(1)</script>",
        operation_name="chat", client_version="Oracle-PythonSDK/2.185.2",
        request_endpoint=f"https://example.invalid/{PRIVATE}",
    )


def circuit_error(cause):
    breaker = CircuitBreaker(failure_threshold=1, recovery_timeout=30)
    try:
        with breaker:
            raise cause
    except Exception:
        pass
    return CircuitBreakerError(breaker)


class DiagnosticTests(unittest.TestCase):
    def test_quota_details_exclude_raw_exception_and_credentials(self):
        error, status, delay = build_ai_error(service_error(headers={
            "opc-request-id": "TEST-REQUEST/ABC/123", "authorization": PRIVATE,
        }), SETTINGS)
        self.assertEqual((status, delay), (429, 60))
        self.assertEqual(error["code"], "rate_limited")
        data = json.dumps(error)
        self.assertIn(CHAT_QUOTA, data)
        self.assertIn("TEST-REQUEST/ABC/123", data)
        self.assertIn(LOGGING_URL, data)
        self.assertNotIn(PRIVATE, data)
        self.assertNotIn("<script>", data)
        self.assertIn(error["reference"], error["commands"][0]["command"])

    def test_other_429_is_not_described_as_compartment_quota(self):
        error, _, _ = build_ai_error(service_error(quota=False), SETTINGS)
        self.assertNotIn("compartment", error["summary"])

    def test_retry_after_seconds_and_http_date(self):
        headers = [
            {"Retry-After": "120"},
            {"retry-after": format_datetime(datetime.now(timezone.utc) + timedelta(seconds=120), usegmt=True)},
        ]
        for value in headers:
            with self.subTest(headers=value):
                _, _, delay = build_ai_error(service_error(headers=value), SETTINGS)
                self.assertGreaterEqual(delay, 119)
                self.assertLessEqual(delay, 120)

    def test_invalid_retry_after_has_safe_fallback(self):
        for value in ["not-a-date", "NaN", "Wed, 01 Oct 2025 12:00:00"]:
            with self.subTest(value=value):
                _, _, delay = build_ai_error(service_error(headers={"Retry-After": value}), SETTINGS)
                self.assertEqual(delay, 60)

    def test_circuit_preserves_last_failure_and_uses_503(self):
        error, status, delay = build_ai_error(circuit_error(service_error()), SETTINGS)
        self.assertEqual((status, delay), (503, 60))
        self.assertEqual(error["code"], "temporarily_paused")
        details = {item["label"]: item["value"] for item in error["diagnostics"]}
        self.assertEqual(details["Last OCI HTTP status"], "429")
        self.assertEqual(details["Last OCI request ID"], "TEST-REQUEST/ABC/123")
        self.assertNotIn(PRIVATE, json.dumps(error))

    def test_circuit_without_service_failure_does_not_invent_request_id(self):
        error, status, delay = build_ai_error(circuit_error(RuntimeError(PRIVATE)), SETTINGS)
        self.assertEqual(status, 503)
        self.assertGreater(delay, 0)
        self.assertNotIn("request ID", json.dumps(error))
        self.assertNotIn(PRIVATE, json.dumps(error))

    def test_categories_and_generic_fallback(self):
        for exc, category in [
            (service_error(401), "authentication_failed"),
            (service_error(403), "access_or_resource"),
            (service_error(404), "access_or_resource"),
            (service_error(500), "service_unavailable"),
            (RuntimeError(PRIVATE), "request_failed"),
        ]:
            with self.subTest(category=category):
                error, status, _ = build_ai_error(exc, SETTINGS)
                self.assertEqual(status, 502)
                self.assertEqual(error["code"], category)
                self.assertNotIn(PRIVATE, json.dumps(error))

    def test_malformed_request_id_not_forwarded(self):
        error, _, _ = build_ai_error(service_error(headers={"opc-request-id": "<img src=x onerror=alert(1)>"}), SETTINGS)
        self.assertNotIn("<img", json.dumps(error))


class AiRouteTests(unittest.TestCase):
    def setUp(self):
        application.app.config.update(TESTING=True, WTF_CSRF_ENABLED=False)
        self.client = application.app.test_client()
        application._logins["diagnostics-test"] = {
            "persona": "MARVIN", "password": "unused-test-password", "expires_at": time.monotonic() + 60,
        }
        with self.client.session_transaction() as session:
            session["_user_id"] = "diagnostics-test"
            session["_fresh"] = True
        self.fetch = patch.object(application, "fetch_authorized_customers", return_value=([], {}, None)).start()
        self.addCleanup(patch.stopall)
        self.addCleanup(application._logins.pop, "diagnostics-test", None)

    def test_rate_limit_reference_matches_log_and_header(self):
        with patch.object(application, "answer_customer_question", side_effect=service_error()), self.assertLogs(application.app.logger, "ERROR") as logs:
            response = self.client.post("/api/ai", json={"question": "Summarize customers"})
        self.assertEqual(response.status_code, 429)
        self.assertEqual(response.headers["Retry-After"], "60")
        error = response.json["error"]
        self.assertIn(f"reference={error['reference']}", logs.output[0])
        self.assertNotIn(PRIVATE, response.get_data(as_text=True))
        self.assertIn("two Terminal tabs already open", json.dumps(error["terminal_steps"]))

    def test_circuit_is_structured_and_auth_failure_does_not_log_user_out(self):
        for exc, expected in [(circuit_error(service_error()), 503), (service_error(401), 502)]:
            with self.subTest(status=expected), patch.object(application, "answer_customer_question", side_effect=exc), self.assertLogs(application.app.logger, "ERROR"):
                response = self.client.post("/api/ai", json={"question": "Summarize customers"})
                self.assertEqual(response.status_code, expected)
                self.assertIsInstance(response.json["error"], dict)

    def test_sdk_value_error_does_not_expose_raw_message(self):
        with patch.object(application, "answer_customer_question", side_effect=ValueError(PRIVATE)), self.assertLogs(application.app.logger, "ERROR"):
            response = self.client.post("/api/ai", json={"question": "Summarize customers"})
        self.assertEqual(response.status_code, 502)
        self.assertNotIn(PRIVATE, response.get_data(as_text=True))

    def test_success_contract_is_preserved(self):
        result = {"answer": "No customers returned", "ai_exchange": {"request": {}, "response": {}}}
        with patch.object(application, "answer_customer_question", return_value=result):
            response = self.client.post("/api/ai", json={"question": "Summarize customers"})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["answer"], result["answer"])
        self.assertNotIn("Retry-After", response.headers)

    def test_unauthenticated_requests_do_not_reach_genai(self):
        with self.client.session_transaction() as session:
            session.clear()
        with patch.object(application, "answer_customer_question") as answer:
            response = self.client.post("/api/ai", json={"question": "Summarize customers"})
        self.assertEqual(response.status_code, 401)
        answer.assert_not_called()
        self.fetch.assert_not_called()


if __name__ == "__main__":
    unittest.main()
