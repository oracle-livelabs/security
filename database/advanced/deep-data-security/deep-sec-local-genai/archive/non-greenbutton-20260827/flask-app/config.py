"""Runtime configuration for the direct-local-user Flask demonstration."""

from dataclasses import dataclass
import os
import re


@dataclass(frozen=True)
class Settings:
    host: str
    port: int
    debug: bool
    secret_key: str
    dsn: str
    db_schema: str
    wallet_location: str
    wallet_password: str
    genai_region: str
    genai_compartment_ocid: str
    genai_model_id: str


def _required(name: str) -> str:
    value = os.getenv(name, "")
    if not value:
        raise RuntimeError(f"{name} must be configured")
    return value


def _load_genai_defaults() -> dict[str, str]:
    """Read Terraform's non-secret OCI Generative AI settings when present."""
    path = os.getenv("GENAI_DEFAULTS_FILE", "/home/opc/.deep-sec-genai-defaults")
    values: dict[str, str] = {}
    try:
        with open(path, encoding="utf-8") as defaults_file:
            for raw_line in defaults_file:
                match = re.fullmatch(r'\s*([A-Z_]+)="?(.*?)"?\s*', raw_line)
                if match:
                    values[match.group(1)] = match.group(2)
    except FileNotFoundError:
        pass
    return values


def load_settings() -> Settings:
    genai_defaults = _load_genai_defaults()
    db_schema = os.getenv("DB_SCHEMA", "APPLAB").upper()
    if not re.fullmatch(r"[A-Z][A-Z0-9_$#]{0,127}", db_schema):
        raise RuntimeError("DB_SCHEMA must be a simple Oracle identifier")
    return Settings(
        host=os.getenv("FLASK_HOST", "0.0.0.0"),
        port=7777,
        debug=os.getenv("FLASK_DEBUG", "false").lower() == "true",
        secret_key=_required("FLASK_SECRET_KEY"),
        dsn=_required("DB_DSN"),
        db_schema=db_schema,
        wallet_location=os.getenv("DB_WALLET_LOCATION", ""),
        wallet_password=os.getenv("DB_WALLET_PASSWORD", ""),
        genai_region=os.getenv("OCI_REGION", genai_defaults.get("OCI_REGION", "")),
        genai_compartment_ocid=os.getenv("GENAI_COMPARTMENT_OCID", genai_defaults.get("GENAI_COMPARTMENT_OCID", "")),
        genai_model_id=os.getenv("GENAI_MODEL_ID", genai_defaults.get("GENAI_MODEL_ID", "")),
    )
