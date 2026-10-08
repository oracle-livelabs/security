"""Build fresh SQL and application ZIP archives from the running lab files."""

import zipfile
from pathlib import Path


EXCLUDE_DIR_NAMES = {"__pycache__", ".venv", ".git"}
EXCLUDE_FILE_NAMES = {".env"}


def _add_dir_to_zip(zip_file: zipfile.ZipFile, source_dir: Path, archive_prefix: str) -> None:
    """Add checked-in source while excluding local runtimes and credentials."""
    if not source_dir.is_dir():
        raise RuntimeError(f"Download source directory is missing: {source_dir}")
    for path in source_dir.rglob("*"):
        if path.is_dir() or any(part in EXCLUDE_DIR_NAMES for part in path.parts):
            continue
        if path.name in EXCLUDE_FILE_NAMES or path.suffix in {".pyc", ".pem"}:
            continue
        archive_name = f"{archive_prefix}/{path.relative_to(source_dir)}"
        zip_file.write(path, archive_name)


def build_sql_scripts_zip(database_dir: Path, output_path: Path) -> None:
    """Build a fresh archive containing only the installed SQL scripts."""
    with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as zip_file:
        _add_dir_to_zip(zip_file, database_dir, "database")


def build_application_zip(admin_app_dir: Path, customer_app_dir: Path, output_path: Path) -> None:
    """Build a fresh archive containing both running Flask application sources."""
    with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as zip_file:
        _add_dir_to_zip(zip_file, admin_app_dir, "admin-app")
        _add_dir_to_zip(zip_file, customer_app_dir, "flask-app")
