"""Read Vibe-created Customer Sales App report definitions without restarting Flask."""

import json
import os
import re
from pathlib import Path
from typing import Optional


REPORT_ID_PATTERN = re.compile(r"^[A-Za-z0-9]{8,32}$")


def get_report(report_id: str) -> Optional[dict]:
    """Return a validated report definition, or None for an unknown report."""
    if not REPORT_ID_PATTERN.fullmatch(report_id):
        return None
    path = Path(os.getenv("DEEP_SEC_VIBE_REPORTS_PATH", "/var/lib/deep-sec/vibe-reports.json"))
    try:
        reports = json.loads(path.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        return None
    report = reports.get(report_id) if isinstance(reports, dict) else None
    if not isinstance(report, dict):
        return None
    sql = report.get("sql")
    request = report.get("request")
    if not isinstance(sql, str) or not isinstance(request, str):
        return None
    return {"id": report_id, "sql": sql, "request": request, "created_at": report.get("created_at", "")}
