"""Configuration for the isolated Deep Sec administrator console."""

from dataclasses import dataclass
import os
import re


def _required(name: str) -> str:
    value = os.getenv(name, "")
    if not value:
        raise RuntimeError(f"{name} must be configured")
    return value


@dataclass(frozen=True)
class AdminSettings:
    host: str
    port: int
    secret_key: str
    dsn: str
    wallet_location: str
    database_dir: str
    genai_region: str
    genai_compartment_ocid: str
    genai_model_id: str
    order_history_bucket: str
    order_history_namespace: str
    order_history_read_par_url: str
    order_history_metadata_read_par_url: str


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


def load_admin_settings() -> AdminSettings:
    genai_defaults = _load_genai_defaults()
    return AdminSettings(
        host=os.getenv("ADMIN_FLASK_HOST", "0.0.0.0"),
        port=int(os.getenv("ADMIN_FLASK_PORT", "7778")),
        secret_key=_required("ADMIN_FLASK_SECRET_KEY"),
        dsn=_required("ADMIN_DB_DSN"),
        wallet_location=_required("ADMIN_WALLET_LOCATION"),
        database_dir=_required("DEEP_SEC_DATABASE_DIR"),
        genai_region=os.getenv("OCI_REGION", genai_defaults.get("OCI_REGION", "")),
        genai_compartment_ocid=os.getenv("GENAI_COMPARTMENT_OCID", genai_defaults.get("GENAI_COMPARTMENT_OCID", "")),
        genai_model_id=os.getenv("GENAI_MODEL_ID", genai_defaults.get("GENAI_MODEL_ID", "")),
        order_history_bucket=_required("ORDER_HISTORY_BUCKET"),
        order_history_namespace=_required("ORDER_HISTORY_NAMESPACE"),
        order_history_read_par_url=_required("ORDER_HISTORY_READ_PAR_URL"),
        order_history_metadata_read_par_url=os.getenv("ORDER_HISTORY_METADATA_READ_PAR_URL", ""),
    )
