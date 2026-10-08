output "adb_ocid" {
  value       = oci_database_autonomous_database.lab.id
  description = "ADB OCID."
}

output "adb_db_name" {
  value       = oci_database_autonomous_database.lab.db_name
  description = "ADB DB name."
}

output "adb_display_name" {
  value       = oci_database_autonomous_database.lab.display_name
  description = "ADB display name."
}

output "lab_admin_jupyter_password" {
  value       = random_password.lab_admin.result
  description = "Terraform-generated shared password for ADB ADMIN, JupyterLab, and MARVIN. Select Unlock, then copy it before opening either service and entering Marvin's password in Task 2."
  sensitive   = true
}

output "adb_tls_connection_string" {
  value       = local.adb_tls_connection_string
  description = "ADB LOW TLS connection descriptor used by SQL*Plus 26ai and the walletless applications."
}

output "adb_console_url" {
  value       = "https://cloud.oracle.com/db/adbs/${oci_database_autonomous_database.lab.id}?region=${var.region}&cloudshell=true&bdcstate=minimized"
  description = "Open this OCI Console URL to inspect the Autonomous AI Database. Marketplace uses TLS without an ADB wallet."
}

output "compute_instance_ocid" {
  value       = oci_core_instance.flask.id
  description = "Deep Data Security App compute instance OCID."
}

output "compute_public_ip" {
  value       = oci_core_instance.flask.public_ip
  description = "Application-server public IP used for inbound SSH and application review access."
}

output "compute_private_ip" {
  value       = oci_core_instance.flask.private_ip
  description = "Application-server private IP address in the Deep Sec public-IP subnet."
}

output "flask_url" {
  value       = var.assign_public_ip ? "http://${oci_core_instance.flask.public_ip}:7777/" : null
  description = "Open this URL from the trusted ingress IP to use the Flask web application."
}

output "admin_console_url" {
  value       = var.assign_public_ip ? "http://${oci_core_instance.flask.public_ip}:7778/" : null
  description = "Deep Sec Administrator Console. It starts automatically and authenticates directly as ADB ADMIN."
}

output "jupyter_url" {
  value       = var.assign_public_ip ? "http://${oci_core_instance.flask.public_ip}:8888/" : null
  description = "Open this URL from the trusted ingress IP to use JupyterLab."
}

output "ssh_command" {
  value       = var.assign_public_ip ? "ssh opc@${oci_core_instance.flask.public_ip}" : null
  description = "SSH command template. Add -i <private-key-path> when required."
}

output "application_ports" {
  value = {
    flask         = 7777
    admin_console = 7778
    jupyter       = 8888
  }
  description = "Application ports permitted from trusted_ingress_cidr on the public application IP."
}

output "operational_debug" {
  value = {
    full_status       = "sudo /usr/local/sbin/deep-sec-status"
    bootstrap_status  = "sudo cat /var/lib/deep-sec/bootstrap-status"
    bootstrap_log     = "sudo tail -n 200 /var/log/deep-sec-bootstrap.log"
    cloud_init_log    = "sudo journalctl -u cloud-final.service -b -n 200 --no-pager -o short-iso"
    admin_status      = "sudo systemctl status deep-sec-admin-console.service --no-pager -l"
    customer_status   = "sudo systemctl status deep-sec-customer-sales.service --no-pager -l"
    admin_journal     = "sudo journalctl -fu deep-sec-admin-console.service -o short-iso"
    customer_journal  = "sudo journalctl -fu deep-sec-customer-sales.service -o short-iso"
    all_boot_warnings = "sudo journalctl -p warning..alert -b --no-pager -o short-iso"
  }
  description = "Copy-ready reliability diagnostics available on the disposable compute instance. Application and bootstrap logs are deliberately verbose; generated passwords are never logged."
}

output "trusted_ingress_cidr" {
  value       = local.home_ip_cidr
  description = "Only this source CIDR is permitted into the disposable lab VCN."
}

output "vcn_ocid" {
  value       = oci_core_vcn.lab.id
  description = "Disposable lab VCN OCID."
}

output "public_subnet_ocid" {
  value       = oci_core_subnet.public_app.id
  description = "Disposable public-IP application subnet OCID used by the Flask VM. The output name is retained for compatibility."
}

output "order_history_bucket_name" {
  value       = local.order_history_target_bucket
  description = "Dedicated Stack-created bucket containing the published Order History Iceberg dataset."
}

output "order_history_bucket_namespace" {
  value       = data.oci_objectstorage_namespace.current.namespace
  description = "Object Storage namespace containing the active Order History bucket."
}

output "order_history_bucket_prefix" {
  value       = local.order_history_target_prefix
  description = "Object Storage prefix containing the active Order History Iceberg table."
}

output "genai_dynamic_group_name" {
  value       = var.create_genai_iam ? var.genai_dynamic_group_name : null
  description = "Dynamic group that represents this Flask compute instance."
}

output "genai_policy_name" {
  value       = var.create_genai_iam ? var.genai_policy_name : null
  description = "Policy granting the compute instance permission to use Generative AI chat."
}

output "genai_model_id" {
  value       = var.genai_model_id
  description = "Default on-demand OCI Generative AI model configured for the lab."
}

output "genai_app_configuration" {
  value = {
    compartment_ocid = local.genai_compartment_ocid
    model_id         = var.genai_model_id
    defaults_file    = "/home/opc/.deep-sec-genai-defaults"
  }
  description = "Default GenAI values placed on the compute instance for Customer Insights and the Vibe CLI."
}

output "deep_sec_lab_summary" {
  value = {
    adb = {
      db_name       = oci_database_autonomous_database.lab.db_name
      display_name  = oci_database_autonomous_database.lab.display_name
      ocid          = oci_database_autonomous_database.lab.id
      console_url   = "https://cloud.oracle.com/db/adbs/${oci_database_autonomous_database.lab.id}?region=${var.region}&cloudshell=true&bdcstate=minimized"
      version       = oci_database_autonomous_database.lab.db_version
      workload      = oci_database_autonomous_database.lab.db_workload
      license_model = oci_database_autonomous_database.lab.license_model
    }
    compute = {
      display_name      = oci_core_instance.flask.display_name
      ocid              = oci_core_instance.flask.id
      public_ip         = oci_core_instance.flask.public_ip
      private_ip        = oci_core_instance.flask.private_ip
      flask_url         = var.assign_public_ip ? "http://${oci_core_instance.flask.public_ip}:7777/" : null
      admin_console_url = var.assign_public_ip ? "http://${oci_core_instance.flask.public_ip}:7778/" : null
      jupyter_url       = var.assign_public_ip ? "http://${oci_core_instance.flask.public_ip}:8888/" : null
    }
    network = {
      vcn_ocid             = oci_core_vcn.lab.id
      public_subnet_ocid   = oci_core_subnet.public_app.id
      trusted_ingress_cidr = local.home_ip_cidr
    }
    wallet_bucket = oci_objectstorage_bucket.wallet.name
    genai = {
      dynamic_group    = var.create_genai_iam ? var.genai_dynamic_group_name : null
      policy           = var.create_genai_iam ? var.genai_policy_name : null
      compartment_ocid = local.genai_compartment_ocid
      model_id         = var.genai_model_id
    }
  }
  description = "Student-facing deployment summary for the Deep Sec lab."
}
