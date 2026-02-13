# ==============================================================================
# SQUAD 3 - DATA LAKE STORAGE STRATEGY (OBJECT STORAGE)
# Objetivo: Provisionar o Bucket para suporte à Arquitetura Medallion
# ==============================================================================

resource "oci_objectstorage_bucket" "lake_squad3" {
  compartment_id = var.compartment_id
  name           = "lake"
  namespace      = var.os_namespace
  storage_tier   = "Standard"
  versioning     = "Enabled"
  access_type    = "NoPublicAccess"
  object_events_enabled = true
}