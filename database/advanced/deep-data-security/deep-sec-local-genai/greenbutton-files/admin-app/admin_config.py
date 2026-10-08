"""Configuration for the isolated Deep Sec administrator console."""

from dataclasses import dataclass
import json
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
    oci_region: str
    genai_region: str
    genai_compartment_ocid: str
    genai_model_id: str
    order_history_bucket: str
    order_history_namespace: str
    order_history_prefix: str
    order_history_read_par_url: str
    order_history_metadata_read_par_url: str
    order_history_object_read_par_urls: dict[str, str]


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
    object_read_par_urls_raw = os.getenv("ORDER_HISTORY_OBJECT_READ_PAR_URLS", "").strip()
    if object_read_par_urls_raw:
        try:
            object_read_par_urls_value = json.loads(object_read_par_urls_raw)
        except json.JSONDecodeError as exc:
            raise RuntimeError("ORDER_HISTORY_OBJECT_READ_PAR_URLS must be valid JSON") from exc
        if not isinstance(object_read_par_urls_value, dict) or not all(
            isinstance(key, str) and isinstance(value, str) and value
            for key, value in object_read_par_urls_value.items()
        ):
            raise RuntimeError("ORDER_HISTORY_OBJECT_READ_PAR_URLS must map object names to URLs")
        object_read_par_urls = object_read_par_urls_value
    else:
        object_read_par_urls = {}
    return AdminSettings(
        host=os.getenv("ADMIN_FLASK_HOST", "0.0.0.0"),
        port=int(os.getenv("ADMIN_FLASK_PORT", "7778")),
        secret_key=_required("ADMIN_FLASK_SECRET_KEY"),
        dsn=_required("ADMIN_DB_DSN"),
        # Empty selects python-oracledb Thin mode with a walletless TLS DSN.
        # The existing wallet deployment continues to set this value.
        wallet_location=os.getenv("ADMIN_WALLET_LOCATION", ""),
        oci_region=os.getenv("OCI_REGION", genai_defaults.get("OCI_REGION", "")),
        # LiveLabs can assign GenAI to a different region from Compute/ADB.
        # A dedicated GenAI setting takes precedence over the resource region.
        genai_region=(
            os.getenv("GENAI_REGION", "").strip()
            or genai_defaults.get("GENAI_REGION", "").strip()
            or os.getenv("OCI_REGION", "").strip()
            or genai_defaults.get("OCI_REGION", "").strip()
        ),
        genai_compartment_ocid=os.getenv("GENAI_COMPARTMENT_OCID", genai_defaults.get("GENAI_COMPARTMENT_OCID", "")),
        genai_model_id=os.getenv("GENAI_MODEL_ID", genai_defaults.get("GENAI_MODEL_ID", "")),
        order_history_bucket=_required("ORDER_HISTORY_BUCKET"),
        order_history_namespace=_required("ORDER_HISTORY_NAMESPACE"),
        order_history_prefix=os.getenv("ORDER_HISTORY_PREFIX", "order_history_iceberg/"),
        order_history_read_par_url=_required("ORDER_HISTORY_READ_PAR_URL"),
        order_history_metadata_read_par_url=os.getenv("ORDER_HISTORY_METADATA_READ_PAR_URL", ""),
        order_history_object_read_par_urls=object_read_par_urls,
    )
