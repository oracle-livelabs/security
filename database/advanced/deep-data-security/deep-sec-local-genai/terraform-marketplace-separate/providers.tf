provider "oci" {
  tenancy_ocid        = var.tenancy_ocid
  region              = var.region
  config_file_profile = var.oci_profile != "" ? var.oci_profile : null
}

# IAM user credentials are tenancy-scoped.  Resolve the tenancy home region
# instead of assuming the lab's deployment region is also the home region.
data "oci_identity_tenancy" "current" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "all" {}

provider "oci" {
  alias               = "home"
  tenancy_ocid        = var.tenancy_ocid
  region              = data.oci_identity_regions.all.regions[index(data.oci_identity_regions.all.regions.*.key, data.oci_identity_tenancy.current.home_region_key)].name
  config_file_profile = var.oci_profile != "" ? var.oci_profile : null
}
