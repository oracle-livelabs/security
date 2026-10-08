#!/usr/bin/env python3
import os
import sys
import oci

required = ("GENAI_COMPARTMENT_OCID", "GENAI_MODEL_ID")
missing = [name for name in required if not os.getenv(name)]
if missing:
    sys.exit("Missing: " + ", ".join(missing))
try:
    auth_mode = os.getenv("OCI_AUTH_MODE", "profile").lower()
    profile = os.getenv("OCI_PROFILE") or os.getenv("OCI_CLI_PROFILE") or "DEFAULT"
    config_path = os.getenv("OCI_CONFIG_FILE") or os.getenv("OCI_CLI_CONFIG_FILE")
    if auth_mode == "instance_principal":
        signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
        client = oci.generative_ai_inference.GenerativeAiInferenceClient(
            {"region": os.getenv("OCI_REGION", "us-ashburn-1")}, signer=signer
        )
        print("OCI authentication mode: instance_principal")
    elif auth_mode == "profile":
        config = (oci.config.from_file(config_path, profile) if config_path
                  else oci.config.from_file(profile_name=profile))
        config["region"] = os.getenv("OCI_REGION", config.get("region", "us-ashburn-1"))
        client = oci.generative_ai_inference.GenerativeAiInferenceClient(config)
        print(f"OCI authentication mode: profile ({profile})")
    else:
        sys.exit("OCI_AUTH_MODE must be profile or instance_principal")
    request = oci.generative_ai_inference.models.GenericChatRequest(api_format="GENERIC", messages=[oci.generative_ai_inference.models.UserMessage(content=[oci.generative_ai_inference.models.TextContent(text="Reply with: access verified")])], max_tokens=20, temperature=0)
    result = client.chat(oci.generative_ai_inference.models.ChatDetails(compartment_id=os.environ["GENAI_COMPARTMENT_OCID"], serving_mode=oci.generative_ai_inference.models.OnDemandServingMode(model_id=os.environ["GENAI_MODEL_ID"]), chat_request=request))
    print(result.data.chat_response.choices[0].message.content[0].text)
except Exception as exc:
    sys.exit(f"Generative AI access verification failed: {type(exc).__name__}: {exc}")
