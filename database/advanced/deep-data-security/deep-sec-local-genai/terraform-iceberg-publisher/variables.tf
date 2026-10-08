variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID."
}

variable "compartment_ocid" {
  type        = string
  description = "Compartment for the durable Iceberg publisher resources."
}

variable "region" {
  type        = string
  description = "OCI region for Object Storage and Data Flow."
  default     = "us-ashburn-1"
}

variable "oci_profile" {
  type        = string
  description = "Optional OCI CLI profile name."
  default     = ""
}

variable "shared_bucket_name" {
  type        = string
  description = "Optional globally unique permanent bucket name. Leave blank to generate one."
  default     = ""
}

variable "dataflow_operator_identity_domain" {
  type        = string
  description = "Identity domain containing the group allowed to submit the one-time writer run."
  default     = "Oracle-SSO"
}

variable "dataflow_operator_group_name" {
  type        = string
  description = "Existing group allowed to submit the one-time Data Flow Iceberg writer."
}

variable "spark_version" {
  type        = string
  description = "OCI Data Flow Spark version for the validated writer."
  default     = "3.5.0"
}

variable "iceberg_runtime_package" {
  type        = string
  description = "Iceberg Spark runtime compatible with spark_version."
  default     = "org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.7.1"
}

variable "raw_files_par_ttl_hours" {
  type        = number
  description = "Lifetime of the prefix-scoped raw-files PAR. Two years by default."
  default     = 17520
}
