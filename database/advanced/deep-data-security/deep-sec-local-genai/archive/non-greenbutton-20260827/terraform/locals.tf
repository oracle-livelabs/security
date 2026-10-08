locals {
  home_ip_cidr             = can(cidrhost(var.allowed_ingress_home_ip_address, 0)) ? var.allowed_ingress_home_ip_address : "${var.allowed_ingress_home_ip_address}/32"
  wallet_bucket_name       = var.wallet_bucket_name != "" ? var.wallet_bucket_name : "deep-sec-wallet-${random_id.wallet_bucket_suffix.hex}"
  adb_db_name              = var.adb_db_name != "" ? var.adb_db_name : "DEEPSEC${upper(random_id.adb_name_suffix.hex)}"
  adb_actual_service_alias = "${lower(local.adb_db_name)}_low"
  adb_service_alias        = "deepsec_low"

  common_tags = {
    lab        = "deep-sec"
    managed_by = "terraform"
  }
}
