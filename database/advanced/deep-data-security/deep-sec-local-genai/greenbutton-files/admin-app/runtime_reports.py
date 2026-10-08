"""Persistent definitions for Vibe-created Customer Sales App report pages."""

import json
import os
import secrets
import tempfile
from datetime import datetime, timezone
from pathlib import Path


def _reports_path() -> Path:
    return Path(os.getenv("DEEP_SEC_VIBE_REPORTS_PATH", "/var/lib/deep-sec/vibe-reports.json"))


def _read_reports() -> dict[str, dict]:
    path = _reports_path()
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return {}
    except json.JSONDecodeError as exc:
        raise RuntimeError("The Vibe report store is not valid JSON.") from exc
    if not isinstance(data, dict):
        raise RuntimeError("The Vibe report store has an invalid shape.")
    return data


def publish_report(request_text: str, sql: str) -> dict:
    """Atomically publish one report definition for the Customer Sales App to read."""
    report_id = secrets.token_urlsafe(8).replace("-", "").replace("_", "")[:12]
    report = {
        "id": report_id,
        "request": request_text,
        "sql": sql,
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    path = _reports_path()
    reports = _read_reports()
    reports[report_id] = report
    path.parent.mkdir(mode=0o755, parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=path.parent, delete=False) as handle:
        json.dump(reports, handle, indent=2, sort_keys=True)
        handle.write("\n")
        temporary_path = Path(handle.name)
    temporary_path.chmod(0o640)
    temporary_path.replace(path)
    return report
