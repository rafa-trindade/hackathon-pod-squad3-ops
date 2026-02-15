# ==============================================================================
# SQUAD 3 - NETWORK INFRASTRUCTURE STRATEGY (OPS ENGINE)
# Objetivo: Definir a infraestrutura de rede para o ambiente de orquestração e integração
# ==============================================================================

# Configuração do VCN (Virtual Cloud Network)
resource "oci_core_vcn" "squad3_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "squad3-vcn"
  dns_label      = "squad3"

  freeform_tags = {
    environment = "dev"
    squad       = "3"
  }

}

# Internet Gateway para acesso à Internet
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.squad3_vcn.id
  display_name   = "squad3-igw"
}

# NAT Gateway para tráfego de saída das sub-redes privadas
resource "oci_core_nat_gateway" "nat_gw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.squad3_vcn.id
  display_name   = "squad3-nat-gateway"
}

# Route Table para sub-redes privadas, direcionando tráfego de saída para o NAT Gateway
resource "oci_core_route_table" "private_rt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.squad3_vcn.id
  display_name   = "squad3-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gw.id
  }
}

# Route Table padrão para o VCN, direcionando tráfego de saída para o Internet Gateway
resource "oci_core_default_route_table" "rt" {
  manage_default_resource_id = oci_core_vcn.squad3_vcn.default_route_table_id
  display_name               = "squad3-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# Sub-redes: Uma pública para recursos que precisam de acesso à Internet (ex: Airflow, Streamlit)
resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.squad3_vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "squad3-public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_vcn.squad3_vcn.default_route_table_id
}

# Sub-rede privada para recursos que não precisam de acesso direto à Internet (ex: banco de dados)
resource "oci_core_subnet" "private_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.squad3_vcn.id
  cidr_block        = "10.0.2.0/24"
  display_name      = "squad3-private-subnet"
  dns_label         = "private"
  prohibit_public_ip_on_vnic = true
  route_table_id    = oci_core_route_table.private_rt.id
}

# Security List para a sub-rede pública, permitindo acesso SSH, Airflow e Streamlit
resource "oci_core_default_security_list" "squad3_sl" {
  manage_default_resource_id = oci_core_vcn.squad3_vcn.default_security_list_id
  display_name               = "squad3-security-list"

  # Regra para permitir acesso SSH (porta 22)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22 
      max = 22 
    }
  }

  # Regra para permitir acesso ao Airflow (porta 8080)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8080 
      max = 8080 
    }
  }

  # Regra para permitir acesso ao Streamlit (porta 8501)
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8501 
      max = 8501 
    }
  }

  # Regra para permitir todo o tráfego de saída
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}