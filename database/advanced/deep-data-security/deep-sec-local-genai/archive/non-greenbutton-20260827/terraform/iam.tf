locals {
  genai_compartment_ocid = var.genai_policy_compartment_ocid != "" ? var.genai_policy_compartment_ocid : var.compartment_ocid
}

resource "oci_identity_dynamic_group" "compute" {
  count          = var.create_genai_iam ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = var.genai_dynamic_group_name
  description    = "Deep Sec Flask compute instance"
  matching_rule  = "ALL {instance.id = '${oci_core_instance.flask.id}'}"
}

resource "oci_identity_policy" "compute_genai" {
  count          = var.create_genai_iam ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = var.genai_policy_name
  description    = "Allow the Deep Sec compute instance to invoke chat"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.compute[0].name} to use generative-ai-chat in compartment id ${local.genai_compartment_ocid}"
  ]
}

resource "oci_identity_user" "order_history_uploader" {
  compartment_id = var.tenancy_ocid
  name           = "${var.genai_dynamic_group_name}-order-history-uploader"
  description    = "Service identity for the one-time Iceberg sample data upload. Not a person's account."
}

resource "oci_identity_group" "order_history_uploaders" {
  compartment_id = var.tenancy_ocid
  name           = "${var.genai_dynamic_group_name}-order-history-uploaders"
  description    = "Members can write the Iceberg sample data into the wallet bucket."
}

resource "oci_identity_user_group_membership" "order_history_uploader" {
  user_id  = oci_identity_user.order_history_uploader.id
  group_id = oci_identity_group.order_history_uploaders.id
}

resource "oci_identity_policy" "order_history_upload" {
  compartment_id = var.compartment_ocid
  name           = "${var.genai_dynamic_group_name}-order-history-upload"
  description    = "Allows the order-history service user to write Iceberg sample data into the wallet bucket."
  statements = [
    "Allow group ${oci_identity_group.order_history_uploaders.name} to manage objects in compartment id ${var.compartment_ocid} where target.bucket.name = '${local.wallet_bucket_name}'"
  ]
}

resource "oci_identity_customer_secret_key" "order_history_upload" {
  user_id      = oci_identity_user.order_history_uploader.id
  display_name = "deep-sec-order-history-upload"
}

resource "oci_identity_dynamic_group" "adb" {
  count          = var.create_genai_iam ? 1 : 0
  compartment_id = var.tenancy_ocid
  name           = "${var.genai_dynamic_group_name}-adb"
  description    = "Deep Sec Autonomous Database"
  matching_rule  = "resource.id = '${oci_database_autonomous_database.lab.id}'"
}

resource "oci_identity_policy" "adb_object_storage" {
  count          = var.create_genai_iam ? 1 : 0
  compartment_id = var.compartment_ocid
  name           = "${var.genai_dynamic_group_name}-adb-object-storage"
  description    = "Allow the Deep Sec Autonomous Database to read Iceberg files in its wallet bucket"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.adb[0].name} to read objects in compartment id ${var.compartment_ocid} where target.bucket.name = '${local.wallet_bucket_name}'"
  ]
}
