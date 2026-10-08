output "adb_console_url" {
  value       = "https://cloud.oracle.com/db/adbs/${oci_database_autonomous_database.lab.id}?region=${var.region}&cloudshell=true&bdcstate=minimized"
  description = "Always Free Autonomous AI Database in the OCI Console."
}

output "adb_ocid" {
  value       = oci_database_autonomous_database.lab.id
  description = "OCID used by the ADB dynamic-group matching rule."
}

output "compute_instance_ocid" {
  value       = oci_core_instance.flask.id
  description = "OCID used by the Compute dynamic-group matching rule."
}

output "compute_public_ip" {
  value       = oci_core_instance.flask.public_ip
  description = "Public IP of the Always Free verification instance."
}

output "ssh_command" {
  value       = var.assign_public_ip ? "ssh opc@${oci_core_instance.flask.public_ip}" : null
  description = "SSH command for the platform-image verification instance."
}

output "genai_dynamic_group_name" {
  value       = var.genai_dynamic_group_name
  description = "Dynamic group tied to the verification instance."
}

output "genai_policy_name" {
  value       = var.genai_policy_name
  description = "Policy granting the verification instance Generative AI chat access."
}

output "deep_sec_free_iam_summary" {
  value = {
    compute_dynamic_group = var.create_genai_iam ? oci_identity_dynamic_group.compute[0].name : null
    compute_policy        = var.create_genai_iam ? oci_identity_policy.compute_genai[0].name : null
    adb_dynamic_group     = var.create_genai_iam ? oci_identity_dynamic_group.adb[0].name : null
    adb_object_policy     = var.create_genai_iam ? oci_identity_policy.adb_object_storage[0].name : null
    upload_policy         = oci_identity_policy.order_history_upload.name
  }
  description = "IAM resources created by this Always Free verification stack."
}
