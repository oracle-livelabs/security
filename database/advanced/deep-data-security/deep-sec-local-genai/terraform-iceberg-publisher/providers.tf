provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_profile != "" ? var.oci_profile : null
}

data "oci_objectstorage_namespace" "current" {
  compartment_id = var.compartment_ocid
}
