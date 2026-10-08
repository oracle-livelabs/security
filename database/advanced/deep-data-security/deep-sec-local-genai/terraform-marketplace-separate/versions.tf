terraform {
  # Compatible with the documented OCI Resource Manager version and newer
  # Terraform 1.x releases. Terraform 2.x requires a separate compatibility review.
  required_version = ">= 1.5.7, < 2.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.0.0, < 9.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0, < 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0, < 3.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.10.0, < 1.0.0"
    }
  }
}
