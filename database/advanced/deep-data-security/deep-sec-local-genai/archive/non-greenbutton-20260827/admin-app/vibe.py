"""Vibe Coding: generate and run a standalone end-user Oracle script.

Unlike the archived Vibe app editor, this module never edits application
files. Oracle Data Security remains the authorization boundary for the
generated script's database session.
"""

import os
import subprocess
import sys
import tempfile
from pathlib import Path

import oci

VIBE_TIMEOUT_SECONDS = 60


def generate_script(settings, request_text: str, persona: str) -> str:
    """Ask OCI Generative AI for SQL and place it in a complete local runner."""
    if not settings.genai_compartment_ocid or not settings.genai_model_id or not settings.genai_region:
        raise RuntimeError("OCI Generative AI is not configured for this lab environment.")

    prompt = (
        "Write exactly one Oracle SQL statement, or one anonymous PL/SQL block, that "
        "attempts to fulfill this request. It will run as the local end user "
        f"'{persona}'. Do not include Python, credentials, markdown fences, or an "
        "explanation. Keep it under 2,000 characters.\n\n"
        f"Request: {request_text}\n\n"
        "Output only the SQL or PL/SQL text."
    )
    signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
    client = oci.generative_ai_inference.GenerativeAiInferenceClient(
        {"region": settings.genai_region}, signer=signer
    )
    chat_request = oci.generative_ai_inference.models.GenericChatRequest(
        api_format="GENERIC",
        messages=[
            oci.generative_ai_inference.models.UserMessage(
                content=[oci.generative_ai_inference.models.TextContent(text=prompt)]
            )
        ],
        max_tokens=500,
        temperature=0,
    )
    response = client.chat(
        oci.generative_ai_inference.models.ChatDetails(
            compartment_id=settings.genai_compartment_ocid,
            serving_mode=oci.generative_ai_inference.models.OnDemandServingMode(
                model_id=settings.genai_model_id
            ),
            chat_request=chat_request,
        )
    )
    generated_sql = response.data.chat_response.choices[0].message.content[0].text.strip()
    if generated_sql.startswith("```"):
        generated_sql = "\n".join(generated_sql.splitlines()[1:])
        if generated_sql.rstrip().endswith("```"):
            generated_sql = generated_sql.rstrip()[:-3].rstrip()
    if not generated_sql.lstrip().upper().startswith(("BEGIN", "DECLARE")):
        generated_sql = generated_sql.rstrip(";\n\r \t")
    if not generated_sql:
        raise RuntimeError("OCI Generative AI returned no SQL.")
    return _standalone_script(generated_sql, persona)


def _standalone_script(sql: str, persona: str) -> str:
    """Build dependable Python around the model's short database request."""
    return f'''import os
import traceback
import oracledb

dsn = os.environ["ORACLE_DSN"]
password = os.environ["ORACLE_PASSWORD"]
config_dir = os.environ.get("ORACLE_CONFIG_DIR", "")
sql = {sql!r}

try:
    if config_dir:
        oracledb.init_oracle_client(config_dir=config_dir)
    connect_kwargs = {{"user": {persona!r}, "password": password, "dsn": dsn}}
    if config_dir:
        connect_kwargs.update(config_dir=config_dir, wallet_location=config_dir)
    with oracledb.connect(**connect_kwargs) as connection:
        with connection.cursor() as cursor:
            cursor.execute(sql)
            if cursor.description:
                columns = [column[0] for column in cursor.description]
                print(" | ".join(columns))
                for row in cursor:
                    print(" | ".join("" if value is None else str(value) for value in row))
            else:
                print(f"{{cursor.rowcount}} row(s) affected.")
except Exception:
    traceback.print_exc()
'''


def run_generated_script(script_text: str, dsn: str, password: str, wallet_location: str) -> dict:
    """Run one generated script without retaining it on disk after completion."""
    with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False) as file_handle:
        file_handle.write(script_text)
        script_path = Path(file_handle.name)
    try:
        result = subprocess.run(
            [sys.executable, str(script_path)],
            capture_output=True,
            text=True,
            timeout=VIBE_TIMEOUT_SECONDS,
            env={
                "ORACLE_DSN": dsn,
                "ORACLE_PASSWORD": password,
                "ORACLE_CONFIG_DIR": wallet_location,
                "TNS_ADMIN": wallet_location,
                "LD_LIBRARY_PATH": os.environ.get("LD_LIBRARY_PATH", ""),
                "PATH": "/usr/bin:/bin",
            },
        )
        output = (result.stdout + result.stderr).strip() or "Script ran with no output."
        return {"exit_code": result.returncode, "output": output}
    finally:
        script_path.unlink(missing_ok=True)
