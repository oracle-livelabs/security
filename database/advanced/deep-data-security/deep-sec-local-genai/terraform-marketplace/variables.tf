variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID. Required for provider authentication and optional IAM resources."
}

variable "compartment_ocid" {
  type        = string
  description = "Compartment that receives ADB, compute, and the Stack-created Order History bucket. Select DBSec_Rich in Resource Manager for the intended Marketplace deployment."
}

variable "region" {
  type        = string
  description = "OCI region for all resources. The supplied custom image is in Ashburn."
  default     = "us-ashburn-1"
}

variable "oci_profile" {
  type        = string
  description = "OCI CLI profile used by the Terraform provider. terraform.sh sets this from OCI_PROFILE or OCI_CLI_PROFILE."
  default     = ""
}

variable "adb_db_name" {
  type        = string
  description = "Optional Autonomous Database name override. Leave blank to generate a unique DEEPSEC-prefixed name for this Stack build."
  default     = ""
}

variable "adb_display_name" {
  type        = string
  description = "Autonomous Database display name."
  default     = "Deep Sec"
}

variable "adb_compute_count" {
  type        = number
  description = "ECPU count for Autonomous Database Serverless."
  default     = 2
}

variable "adb_storage_tbs" {
  type        = number
  description = "ADB storage in TB. OCI Terraform API uses TB rather than the Cloud Shell GB option."
  default     = 1
}

variable "adb_license_model" {
  type        = string
  description = "ADB license model."
  default     = "BRING_YOUR_OWN_LICENSE"
}

variable "compute_image_ocid" {
  type        = string
  description = "Custom-image OCID fallback used only when use_marketplace_image is false."
  default     = ""

  validation {
    condition     = trimspace(var.compute_image_ocid) == "" || can(regex("^ocid1\\.image\\.", trimspace(var.compute_image_ocid)))
    error_message = "The custom image OCID must be an OCI image OCID when supplied."
  }
}

variable "use_marketplace_image" {
  type        = bool
  description = "Subscribe to and launch the published Marketplace image. Set false only for an internal custom-image deployment."
  default     = true
}

variable "marketplace_listing_id" {
  type        = string
  description = "Consumer-facing App Catalog listing OCID for the published Deep Sec application image. Do not use the publisher mktpublisting OCID."
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaaczjoa6swtlfcx3hmvw2wj4xpebjnrsh5w3eh46ytvxi4nyeiy32q"

  validation {
    condition     = can(regex("^ocid1\\.appcataloglisting\\.", trimspace(var.marketplace_listing_id)))
    error_message = "Provide the consumer-facing App Catalog listing OCID beginning with ocid1.appcataloglisting."
  }
}

variable "marketplace_resource_version" {
  type        = string
  description = "Marketplace package version reference. Confirm this value on the published package; the initial listing version is 1.0."
  default     = "1.0"

  validation {
    condition     = trimspace(var.marketplace_resource_version) != ""
    error_message = "Provide the published Marketplace package version reference."
  }
}

variable "vcn_cidr" {
  type        = string
  description = "CIDR block for the disposable lab VCN."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public Flask application subnet. Must be inside vcn_cidr."
  default     = "10.0.1.0/24"
}

variable "vcn_dns_label" {
  type        = string
  description = "DNS label for the disposable lab VCN."
  default     = "deepsec"
}

variable "allowed_ingress_home_ip_address" {
  type        = string
  description = "Your public home IPv4 address or IPv4 CIDR. Terraform treats a bare address as /32 and preserves a supplied CIDR."
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.allowed_ingress_home_ip_address, 0)) || can(cidrhost("${var.allowed_ingress_home_ip_address}/32", 0))
    error_message = "Enter a valid IPv4 address or IPv4 CIDR, for example 203.0.113.10, 203.0.113.10/32, or 0.0.0.0/0."
  }
}

variable "allowed_ingress_description" {
  type        = string
  description = "Description attached to the trusted ingress security rule."
  default     = "Wide Open"
}

variable "compute_shape" {
  type        = string
  description = "Compute shape compatible with the supplied custom image."
  default     = "VM.Standard.E5.Flex"
}

variable "compute_ocpus" {
  type        = number
  description = "OCPU count for a Flex compute shape."
  default     = 1
}

variable "compute_memory_in_gbs" {
  type        = number
  description = "Memory in GB for a Flex compute shape."
  default     = 16
}

variable "compute_display_name" {
  type        = string
  description = "Display name for the Flask compute instance."
  default     = "deep-sec-app-server"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key injected into the compute instance. Supply the deployer's public key; a shared package must not inject a lab maintainer's key."

  validation {
    condition     = trimspace(var.ssh_public_key) != ""
    error_message = "Provide an SSH public key for the person who will operate this stack."
  }
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP to the compute instance for inbound application and SSH access. The subnet uses an Internet Gateway route for inbound reachability, while its security list has no general Internet egress rule."
  default     = true

  validation {
    condition     = var.assign_public_ip == true
    error_message = "assign_public_ip must remain true so the application server is reachable for review."
  }
}

variable "wallet_bucket_name" {
  type        = string
  description = "Optional private Stack bucket name override. This bucket stores the application package, logs, and built-in sample. Leave blank to generate a unique name for this Stack build."
  default     = ""
}

variable "order_history_bucket_name" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; the Marketplace bundle path ignores it and creates its dedicated private Iceberg bucket."
  default     = ""
}

variable "order_history_bucket_prefix" {
  type        = string
  description = "Object Storage prefix for the pre-created Order History table in the dedicated Stack-created bucket."
  default     = "order_history_iceberg"

  validation {
    condition     = can(regex("^[A-Za-z0-9][A-Za-z0-9._/-]*[A-Za-z0-9]$", trimspace(var.order_history_bucket_prefix)))
    error_message = "order_history_bucket_prefix must contain letters, numbers, dots, underscores, hyphens, and slashes, and must not start or end with a slash."
  }
}

variable "order_history_delivery_mode" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; the Marketplace deployment always publishes the pre-created Iceberg bundle."
  default     = "bundle"

  validation {
    condition     = contains(["auto", "bundle", "sample", "copy", "dataflow"], lower(trimspace(var.order_history_delivery_mode)))
    error_message = "order_history_delivery_mode must be auto, bundle, sample, copy, or dataflow."
  }
}

variable "wallet_par_ttl_hours" {
  type        = number
  description = "Hours that the private bootstrap and Order History links remain valid. Defaults to two years for the lab; reduce it for a stricter environment."
  default     = 17520

  validation {
    condition     = var.wallet_par_ttl_hours >= 1 && var.wallet_par_ttl_hours <= 17520
    error_message = "wallet_par_ttl_hours must be between 1 and 17520 hours (two years)."
  }
}

variable "order_history_access_key" {
  type        = string
  description = "Retained compatibility input. Not used by the normal Marketplace bundle path."
  default     = ""
}

variable "order_history_secret_key" {
  type        = string
  description = "Retained compatibility input. Not used by the normal Marketplace bundle path."
  default     = ""
  sensitive   = true
}

variable "order_history_oci_username" {
  type        = string
  description = "Optional OCI DBMS_CLOUD username in <identity-domain>/<username> form. This is needed only when you later run the ADB Iceberg reader probe; Resource Manager cannot derive it from a user OCID."
  default     = ""
}

variable "order_history_oci_auth_token" {
  type        = string
  description = "Existing OCI auth token for order_history_oci_username. Required to create the ADB external table against a shared or per-stack Iceberg metadata file."
  default     = ""
  sensitive   = true
}

variable "use_shared_order_history_dataset" {
  type        = bool
  description = "Legacy Resource Manager input retained for upgraded stacks; the Marketplace deployment always uses its own pre-created bundle."
  default     = false
}

variable "shared_order_history_bucket" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored by the Marketplace deployment."
  default     = ""
}

variable "shared_order_history_namespace" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored by the Marketplace deployment."
  default     = ""
}

variable "shared_order_history_metadata_url" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored by the Marketplace deployment."
  default     = ""
}

variable "shared_order_history_read_par_url" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored by the Marketplace deployment."
  default     = ""
  sensitive   = true
}

variable "shared_order_history_metadata_read_par_url" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored by the Marketplace deployment."
  default     = ""
  sensitive   = true
}

variable "current_user_ocid" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; not used by the Marketplace bundle path."
  default     = ""
}

variable "create_iceberg_resources" {
  type        = bool
  description = "Legacy Resource Manager input retained for upgraded stacks; no automatic Iceberg credential resources are created."
  default     = false

  validation {
    condition     = !var.create_iceberg_resources
    error_message = "create_iceberg_resources is unsupported for Oracle-SSO. Leave it false and provide order_history_oci_username and order_history_oci_auth_token as sensitive Stack input."
  }
}

variable "enable_dataflow_iceberg_experiment" {
  type        = bool
  description = "Legacy Resource Manager input retained for upgraded stacks; Data Flow is not provisioned or used by Marketplace."
  default     = false
}

variable "dataflow_run_on_apply" {
  type        = bool
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored because Data Flow is not provisioned."
  default     = true
}

variable "dataflow_iceberg_operator_group_name" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored because Data Flow is not provisioned."
  default     = ""
}

variable "dataflow_iceberg_operator_identity_domain" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored because Data Flow is not provisioned."
  default     = "Oracle-SSO"
}

variable "dataflow_iceberg_spark_version" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored because Data Flow is not provisioned."
  default     = "3.5.0"
}

variable "dataflow_iceberg_runtime_package" {
  type        = string
  description = "Legacy Resource Manager input retained for upgraded stacks; ignored because Data Flow is not provisioned."
  default     = "org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.7.1"
}

variable "create_genai_iam" {
  type        = bool
  description = "Create a compute dynamic group and its GenAI policy. Default false avoids exhausting the tenancy dynamic-group quota."
  default     = false
}

variable "genai_policy_compartment_ocid" {
  type        = string
  description = "Compartment where the compute instance may use Generative AI. Defaults to compartment_ocid when blank."
  default     = ""
}

variable "genai_dynamic_group_name" {
  type        = string
  description = "Dynamic group name when create_genai_iam is true."
  default     = "DEEP_SEC_GREENBUTTON"
}

variable "genai_policy_name" {
  type        = string
  description = "IAM policy name when create_genai_iam is true."
  default     = "DEEP_SEC_COMPUTE_GENAI"
}

variable "genai_model_id" {
  type        = string
  description = "Default on-demand OCI Generative AI chat model written to the Vibe CLI setup defaults. Override only with a model available in the selected OCI region."
  default     = "google.gemini-2.5-flash"
}
