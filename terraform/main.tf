# ==============================================================================
# SQUAD 3 - PROVIDOR STRATEGY
# Objetivo: Configurar a conexão com a API da Oracle Cloud
# ==============================================================================

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}