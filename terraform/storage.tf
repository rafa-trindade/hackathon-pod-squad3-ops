# ==============================================================================
# SQUAD 3 - STORAGE STRATEGY (OPS ENGINE)
# Objetivo: Definir a estratégia de armazenamento para o ambiente de orquestração e integração
# ==============================================================================

# Criar um bucket no Object Storage para servir como Data Lake, com versionamento habilitado para garantir a integridade e histórico dos dados
resource "oci_objectstorage_bucket" "lake_squad3" {
  compartment_id = var.compartment_id
  name           = "lake"
  namespace      = var.os_namespace
  storage_tier   = "Standard"
  versioning     = "Enabled"
  access_type    = "NoPublicAccess"
  object_events_enabled = true
}