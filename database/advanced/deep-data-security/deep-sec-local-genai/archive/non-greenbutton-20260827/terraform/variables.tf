variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID. Required for provider authentication and optional IAM resources."
}

variable "compartment_ocid" {
  type        = string
  description = "Compartment that receives ADB, compute, and the private wallet delivery bucket."
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
  description = "Custom-image OCID for the Flask compute instance. Override when using a different tenancy or region."
  default     = "ocid1.image.oc1.iad.aaaaaaaaftfqwqdkerxwrqjjssmwvog6kohczmfhfj2i2kmjmqorteybgp2a"
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

  validation {
    condition     = can(cidrhost(var.allowed_ingress_home_ip_address, 0)) || can(cidrhost("${var.allowed_ingress_home_ip_address}/32", 0))
    error_message = "Enter a valid IPv4 address or IPv4 CIDR, for example 203.0.113.10, 203.0.113.10/32, or 0.0.0.0/0."
  }
}

variable "allowed_ingress_description" {
  type        = string
  description = "Description attached to the trusted ingress security rule."
  default     = "My Home IP"
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
  description = "SSH public key injected into the compute instance."
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP to the compute instance. Set false when using a bastion or private access path."
  default     = true
}

variable "wallet_bucket_name" {
  type        = string
  description = "Optional private wallet bucket name override. Leave blank to generate a unique name for this Stack build."
  default     = ""
}

variable "wallet_object_name" {
  type        = string
  description = "Object name used for the automatically generated ADB wallet ZIP."
  default     = "deep-sec-wallet.zip"
}

variable "wallet_par_ttl_hours" {
  type        = number
  description = "Hours that the one-object wallet download link remains valid after the Stack first applies."
  default     = 24

  validation {
    condition     = var.wallet_par_ttl_hours >= 1 && var.wallet_par_ttl_hours <= 168
    error_message = "wallet_par_ttl_hours must be between 1 and 168 hours."
  }
}

variable "order_history_access_key" {
  type        = string
  description = "Existing OCI Customer Secret Key access key for the NO-IAM Iceberg variant. The regular Stack creates its own service identity instead."
  default     = ""
}

variable "order_history_secret_key" {
  type        = string
  description = "Existing OCI Customer Secret Key secret for the NO-IAM Iceberg variant."
  default     = ""
  sensitive   = true
}

variable "order_history_oci_username" {
  type        = string
  description = "OCI username, including identity domain, used by the database to read Iceberg metadata and data through the native Object Storage endpoint. Required by both archive variants."
  default     = ""
  sensitive   = true

  validation {
    condition     = trimspace(var.order_history_oci_username) != ""
    error_message = "order_history_oci_username is required for the native Iceberg reader credential."
  }
}

variable "order_history_oci_auth_token" {
  type        = string
  description = "OCI auth token used by the database to read Iceberg metadata and data through the native Object Storage endpoint. Required by both archive variants."
  default     = ""
  sensitive   = true

  validation {
    condition     = trimspace(var.order_history_oci_auth_token) != ""
    error_message = "order_history_oci_auth_token is required for the native Iceberg reader credential."
  }
}

variable "create_genai_iam" {
  type        = bool
  description = "Create the dynamic group and policy that lets the Vibe coding assistant on the compute instance invoke OCI Generative AI. Requires tenancy IAM permission."
  default     = true
}

variable "genai_policy_compartment_ocid" {
  type        = string
  description = "Compartment where the compute instance may use Generative AI. Defaults to compartment_ocid when blank."
  default     = ""
}

variable "genai_dynamic_group_name" {
  type        = string
  description = "Dynamic group name when create_genai_iam is true."
  default     = "DEEP_SEC_COMPUTE"
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
