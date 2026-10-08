"""Selected GenAI diagnostics for the browser; full exceptions stay in server logs."""

import math
import re
from datetime import datetime, timezone
from email.utils import parsedate_to_datetime
from uuid import uuid4

import oci
from circuitbreaker import CircuitBreakerError


LOGGING_URL = "https://docs.oracle.com/en-us/iaas/tools/python/latest/logging.html"
API_ERRORS_URL = "https://docs.oracle.com/en-us/iaas/Content/API/References/apierrors.htm"
CHAT_QUOTA = "max-on-demand-chat-request-per-minute-count"


def _identifier(value):
    """Accept bounded identifiers only, never arbitrary exception messages or URLs."""
    if isinstance(value, str) and re.fullmatch(r"[A-Za-z0-9_./:+ -]{1,256}", value):
        return value
    return None


def _retry_after(headers, now):
    value = next((value for key, value in headers.items() if key.lower() == "retry-after"), None)
    if value is None:
        return None
    try:
        seconds = int(value)
    except (TypeError, ValueError):
        try:
            date = parsedate_to_datetime(str(value))
            seconds = math.ceil((date - now).total_seconds())
        except (TypeError, ValueError, OverflowError):
            return None
    return max(1, min(seconds, 86400))


def build_ai_error(exc, settings):
    """Return a browser-safe error, HTTP status, and optional retry delay."""
    now = datetime.now(timezone.utc)
    reference = uuid4().hex[:16]
    is_circuit = isinstance(exc, CircuitBreakerError)
    # circuitbreaker 2.x exposes its last failure through the wrapped breaker.
    breaker = getattr(exc, "_circuit_breaker", None) if is_circuit else None
    cause = getattr(breaker, "last_failure", None) if is_circuit else exc
    service_error = cause if isinstance(cause, oci.exceptions.ServiceError) else None
    status = service_error.status if service_error else None
    quota_hit = status == 429 and CHAT_QUOTA in (service_error.message or "")
    retry_seconds = _retry_after(service_error.headers or {}, now) if service_error else None
    http_status = 502
    category = "request_failed"
    summary = "AI Insights could not complete this request."
    next_step = "Open Troubleshooting below to find the matching server log and check the GenAI configuration."

    if is_circuit:
        http_status = 503
        category = "temporarily_paused"
        summary = "AI Insights is temporarily paused after repeated service failures."
        remaining = getattr(breaker, "open_remaining", 30)
        retry_seconds = max(1, math.ceil(remaining), retry_seconds or 0, 60 if status == 429 else 0)
        reason = " The last service failure was the compartment's chat request quota." if quota_hit else ""
        next_step = f"Wait at least {retry_seconds} seconds before trying again.{reason} Waiting does not guarantee that shared capacity is available."
    elif status == 429:
        http_status = 429
        category = "rate_limited"
        retry_seconds = retry_seconds or 60
        summary = "The compartment's GenAI chat request quota has been reached." if quota_hit else "OCI Generative AI is limiting requests."
        next_step = f"Wait at least {retry_seconds} seconds before trying again. Other learners and applications may share this capacity; avoid repeated submissions."
    elif status == 401:
        category = "authentication_failed"
        summary = "OCI could not authenticate the AI Insights request."
        next_step = "Ask the lab administrator to check the application's instance-principal authentication."
    elif status in {403, 404}:
        category = "access_or_resource"
        summary = "OCI could not authorize the request or find the requested resource."
        next_step = "Ask the lab administrator to check GenAI IAM policies, the configured compartment, region, and model."
    elif isinstance(status, int) and status >= 500:
        category = "service_unavailable"
        summary = "OCI Generative AI could not complete the request."
        next_step = "Try again later. If the error continues, share the diagnostic reference and OCI request ID with the lab administrator."

    diagnostics = [
        {"label": "Diagnostic reference", "value": reference},
        {"label": "Time (UTC)", "value": now.strftime("%Y-%m-%d %H:%M:%S UTC")},
        {"label": "Error type", "value": type(exc).__name__},
    ]
    fields = [
        ("Region", settings.genai_region),
        ("Model", settings.genai_model_id),
    ]
    if service_error:
        prefix = "Last OCI" if is_circuit else "OCI"
        fields.extend([
            (f"{prefix} HTTP status", str(status)),
            (f"{prefix} error code", service_error.code),
            (f"{prefix} request ID", service_error.request_id),
            ("OCI operation", service_error.operation_name),
            ("SDK version", service_error.client_version),
        ])
    if quota_hit:
        fields.append(("Quota", CHAT_QUOTA))
    for label, value in fields:
        if safe_value := _identifier(value):
            diagnostics.append({"label": label, "value": safe_value})

    return {
        "code": category,
        "reference": reference,
        "summary": summary,
        "next_step": next_step,
        "diagnostics": diagnostics,
        "terminal_steps": [
            "Switch to this lab's JupyterLab window. Its URL is in the stack's Application Information.",
            "Select either of the two Terminal tabs already open by default in JupyterLab. If both have been closed, choose File → New → Terminal.",
            "Run the commands below in that Terminal tab, not in a Python notebook cell or a terminal on your own computer.",
        ],
        "commands": [
            {"label": "Find this error in the service log", "command": f"sudo journalctl -u deep-sec-customer-sales.service -b --no-pager -o short-iso --grep='{reference}'"},
            {"label": "Read recent errors and their stack traces", "command": "sudo journalctl -u deep-sec-customer-sales.service -b -n 200 --no-pager -o short-iso"},
            {"label": "Watch live errors (press Ctrl+C to stop)", "command": "sudo journalctl -fu deep-sec-customer-sales.service -o short-iso"},
        ],
        "note": "Ask the lab administrator to verify GENAI_REGION, GENAI_COMPARTMENT_OCID, and GENAI_MODEL_ID in /home/opc/.deep-sec-genai-defaults. GENAI_REGION must match the reservation's assigned GenAI region (LiveLabs ociGenAiRegion), which can differ from OCI_REGION for Compute, ADB, and Object Storage. The app reads that path through GENAI_DEFAULTS_FILE in /etc/deep-sec/customer-sales.env.",
        "logging_note": "The diagnostic reference connects this screen to the server log. OCI SDK DEBUG/request logging can include request headers and bodies; a maintainer should use it only for controlled server-side troubleshooting. Review logs before sharing them.",
        "links": [
            {"label": "Oracle Python SDK logging guidance", "url": LOGGING_URL},
            {"label": "Oracle API errors and troubleshooting", "url": API_ERRORS_URL},
        ],
    }, http_status, retry_seconds
