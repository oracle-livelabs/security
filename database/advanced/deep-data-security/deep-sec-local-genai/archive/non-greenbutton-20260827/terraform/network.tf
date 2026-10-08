data "oci_identity_availability_domains" "available" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_vcn" "lab" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "Deep Sec VCN"
  dns_label      = var.vcn_dns_label

  freeform_tags = local.common_tags
}

resource "oci_core_internet_gateway" "lab" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "Deep Sec IGW"
  enabled        = true

  freeform_tags = local.common_tags
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "Deep Sec Public Route Table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.lab.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = local.common_tags
}

resource "oci_core_security_list" "public_app" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.lab.id
  display_name   = "Deep Sec Public Security List"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    description = var.allowed_ingress_description
    protocol    = "all"
    source      = local.home_ip_cidr
  }

  freeform_tags = local.common_tags
}

resource "oci_core_subnet" "public_app" {
  availability_domain        = data.oci_identity_availability_domains.available.availability_domains[0].name
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.lab.id
  cidr_block                 = var.public_subnet_cidr
  display_name               = "Deep Sec Public Subnet"
  dns_label                  = "app"
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public_app.id]
  prohibit_public_ip_on_vnic = false

  freeform_tags = local.common_tags
}
