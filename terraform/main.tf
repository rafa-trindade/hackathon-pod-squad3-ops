# ==============================================================================
# SQUAD 3 - PROVIDER CONFIGURATION (OPS ENGINE)
# Objetivo: Configurar o provider OCI para autenticação e conexão com a API da Oracle Cloud
# ==============================================================================

# Configuração do provider OCI para autenticação e conexão com a API da Oracle Cloud
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}