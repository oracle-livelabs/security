data "oci_identity_availability_domains" "available" {
  compartment_id = var.tenancy_ocid
}

# Keep database traffic on the VCN and bootstrap, authentication, and GenAI
# traffic limited to Oracle service CIDRs. The Internet Gateway and default
# route provide the required inbound path for the public application IP. The
# security list below deliberately has no general Internet egress rule, so the
# VM cannot initiate arbitrary Internet connections.
data "oci_core_services" "object_storage" {
  filter {
    name   = "name"
    values = ["OCI .* Object Storage"]
    regex  = true
  }
}

data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_vcn" "lab" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "Deep Sec VCN ${local.stack_suffix}"
  dns_label      = "${substr(var.vcn_dns_label, 0, 7)}${local.stack_suffix}"

  freeform_tags = local.common_tags
}

resource "oci_core_service_gateway" "lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "Deep Sec Service Gateway ${local.stack_suffix}"

  services {
    service_id = data.oci_core_services.object_storage.services[0].id
  }

  freeform_tags = local.common_tags
}

resource "oci_core_internet_gateway" "lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "Deep Sec Internet Gateway ${local.stack_suffix}"
  enabled        = true

  freeform_tags = local.common_tags
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "Deep Sec Public Route Table ${local.stack_suffix}"

  # A public IP requires an enabled Internet Gateway and a route to it for
  # inbound internet connectivity. The security list has no matching general
  # egress rule, so this route does not grant the VM general outbound access.
  route_rules {
    network_entity_id = oci_core_internet_gateway.lab.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  # Route the supported OCI service privately through the Oracle Services
  # Network.
  route_rules {
    network_entity_id = oci_core_service_gateway.lab.id
    destination       = data.oci_core_services.object_storage.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
  }

  freeform_tags = local.common_tags
}

resource "oci_core_security_list" "public_app" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "Deep Sec Public Security List ${local.stack_suffix}"

  # Permit traffic only within this VCN. This is required for the VM to use
  # the ADB private endpoint and is not Internet egress.
  egress_security_rules {
    description      = "Allow VCN-local traffic only"
    protocol         = "all"
    destination      = var.vcn_cidr
    destination_type = "CIDR_BLOCK"
  }

  # Permit bootstrap and OCI SDK paths to reach Object Storage through the
  # Service Gateway.
  egress_security_rules {
    description      = "Allow Object Storage through Service Gateway only"
    protocol         = "all"
    destination      = data.oci_core_services.object_storage.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
  }

  # The public application subnet retains its Internet Gateway route for the
  # public IP. Restrict outbound HTTPS to regional OCI service CIDRs so
  # instance-principal token exchange and OCI Generative AI work without a
  # general 0.0.0.0/0 egress security rule.
  egress_security_rules {
    description      = "Allow regional OCI Services Network HTTPS"
    protocol         = "6"
    destination      = data.oci_core_services.all_services.services[0].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"

    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    description = "Allow VCN-local traffic to the private ADB endpoint"
    protocol    = "6"
    source      = var.vcn_cidr
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 1522
      max = 1522
    }
  }

  # Public IP is for inbound access only. Keep this source restricted to the
  # operator's address or CIDR; stateful rules allow response traffic without
  # creating a general Internet egress path.
  ingress_security_rules {
    description = "${var.allowed_ingress_description}: SSH"
    protocol    = "6"
    source      = local.home_ip_cidr
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "${var.allowed_ingress_description}: Customer Sales App"
    protocol    = "6"
    source      = local.home_ip_cidr
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 7777
      max = 7777
    }
  }

  ingress_security_rules {
    description = "${var.allowed_ingress_description}: Admin Console"
    protocol    = "6"
    source      = local.home_ip_cidr
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 7778
      max = 7778
    }
  }

  ingress_security_rules {
    description = "${var.allowed_ingress_description}: JupyterLab"
    protocol    = "6"
    source      = local.home_ip_cidr
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 8888
      max = 8888
    }
  }

  freeform_tags = local.common_tags
}

resource "oci_core_subnet" "public_app" {
  availability_domain        = data.oci_identity_availability_domains.available.availability_domains[0].name
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.lab.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "Deep Sec Public Subnet ${local.stack_suffix}"
  dns_label                  = "app${local.stack_suffix}"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public_app.id]
  prohibit_public_ip_on_vnic = false

  freeform_tags = local.common_tags
}
