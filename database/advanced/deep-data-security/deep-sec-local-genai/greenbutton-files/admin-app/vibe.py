"""Vibe Coding: generate one bounded Oracle statement for the Customer Sales App."""

import re

import oci


def validate_vibe_statement(sql: str) -> str:
    """Accept one SELECT or supported data-change statement, never a script."""
    sql = sql.strip().rstrip(";").strip()
    normalized_sql = sql.lower()
    if (
        not sql
        or len(sql) > 2_000
        or ";" in sql
        or "--" in sql
        or "/*" in sql
        or "*/" in sql
        or not normalized_sql.startswith(("select", "with", "insert", "update", "delete"))
    ):
        raise RuntimeError("OCI Generative AI did not return one supported SQL statement.")
    if normalized_sql.startswith("with") and re.search(r"\b(insert|update|delete)\b", normalized_sql):
        raise RuntimeError("Use SELECT with a WITH clause, or start a data-change statement with INSERT, UPDATE, or DELETE.")
    forbidden = r"\b(merge|alter|create|drop|grant|revoke|execute|begin|declare|commit|rollback|truncate)\b"
    if re.search(forbidden, sql, flags=re.IGNORECASE):
        raise RuntimeError("OCI Generative AI returned a statement that is not safe for a report page.")
    return sql


def generate_report_query(settings, request_text: str) -> str:
    """Generate one Oracle query or data-change statement for the lab."""
    if not settings.genai_compartment_ocid or not settings.genai_model_id or not settings.genai_region:
        raise RuntimeError("OCI Generative AI is not configured for this lab environment.")
    prompt = (
        "Write exactly one Oracle SQL SELECT, INSERT, UPDATE, or DELETE statement for a Customer Sales App page. "
        "The statement will run as whichever local database end user opens the page, so do not "
        "embed credentials or assume broader access. You may query APPLAB objects and Oracle "
        "dictionary, role, privilege, and end-user-context views. Oracle, including Deep Sec data "
        "grants where applicable, will enforce the current end user's actual privileges. Do not use PL/SQL, "
        "DDL, MERGE, SQL*Plus commands, comments, or markdown. Keep it under 2,000 characters. "
        "Output only the SQL.\n\n"
        f"Request: {request_text}"
    )
    signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
    client = oci.generative_ai_inference.GenerativeAiInferenceClient({"region": settings.genai_region}, signer=signer)
    chat_request = oci.generative_ai_inference.models.GenericChatRequest(
        api_format="GENERIC",
        messages=[oci.generative_ai_inference.models.UserMessage(content=[oci.generative_ai_inference.models.TextContent(text=prompt)])],
        max_tokens=500,
        temperature=0,
    )
    response = client.chat(oci.generative_ai_inference.models.ChatDetails(
        compartment_id=settings.genai_compartment_ocid,
        serving_mode=oci.generative_ai_inference.models.OnDemandServingMode(model_id=settings.genai_model_id),
        chat_request=chat_request,
    ))
    sql = response.data.chat_response.choices[0].message.content[0].text.strip()
    if sql.startswith("```"):
        sql = "\n".join(sql.splitlines()[1:])
        if sql.rstrip().endswith("```"):
            sql = sql.rstrip()[:-3].rstrip()
    return validate_vibe_statement(sql)
