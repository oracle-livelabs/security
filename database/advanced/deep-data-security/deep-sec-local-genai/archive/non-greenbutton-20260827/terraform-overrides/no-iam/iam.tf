# This archive deliberately creates no tenancy IAM resources. It uses a
# pre-existing Customer Secret Key supplied as sensitive Stack inputs.
locals {
  genai_compartment_ocid = var.genai_policy_compartment_ocid != "" ? var.genai_policy_compartment_ocid : var.compartment_ocid
}
