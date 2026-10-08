locals {
  marketplace_image_source_id = var.use_marketplace_image ? data.oci_core_app_catalog_listing_resource_version.marketplace_image[0].listing_resource_id : var.compute_image_ocid
}

# A consuming tenancy must accept the Marketplace terms before it can launch
# the published image. Resource Manager runs these resources in the target
# tenancy, so this works for the other team's tenancy once it is allowed on
# the private listing.
resource "oci_core_app_catalog_listing_resource_version_agreement" "marketplace_image" {
  count                    = var.use_marketplace_image ? 1 : 0
  listing_id               = var.marketplace_listing_id
  listing_resource_version = var.marketplace_resource_version
}

resource "oci_core_app_catalog_subscription" "marketplace_image" {
  count                    = var.use_marketplace_image ? 1 : 0
  compartment_id           = var.compartment_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.marketplace_image[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.marketplace_image[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.marketplace_image[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.marketplace_image[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.marketplace_image[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.marketplace_image[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

# The consuming tenancy receives the launchable image OCID for the subscribed
# package. Resolve it only after the subscription exists; the publisher's
# artifact OCID is not a valid compute source ID in the consuming tenancy.
data "oci_core_app_catalog_listing_resource_version" "marketplace_image" {
  count            = var.use_marketplace_image ? 1 : 0
  listing_id       = var.marketplace_listing_id
  resource_version = var.marketplace_resource_version

  depends_on = [oci_core_app_catalog_subscription.marketplace_image]
}
