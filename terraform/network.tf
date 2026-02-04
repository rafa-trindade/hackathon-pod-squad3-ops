# ==============================================================================
# SQUAD 3 - NETWORK STRATEGY
# Objetivo: Provisionar a infraestrutura de rede (VCN)
# ==============================================================================

resource "oci_core_vcn" "squad3_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "squad3-vcn"
  dns_label      = "squad3"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.squad3_vcn.id
  display_name   = "squad3-igw"
}

resource "oci_core_default_route_table" "rt" {
  manage_default_resource_id = oci_core_vcn.squad3_vcn.default_route_table_id
  display_name               = "squad3-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.squad3_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "squad3-public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_vcn.squad3_vcn.default_route_table_id
}

resource "oci_core_default_security_list" "squad3_sl" {
  manage_default_resource_id = oci_core_vcn.squad3_vcn.default_security_list_id
  display_name               = "squad3-security-list"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22 
      max = 22 
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8080 
      max = 8080 
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}