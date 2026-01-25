# ==============================================================================
# SQUAD 3 - IDENTITY & ACCESS MANAGEMENT (IAM) STRATEGY
# Objetivo: Instance Principal para a VM e Gestão de Usuários Reais
# ==============================================================================

# ==============================================================================
# 1. AUTOMAÇÃO: INSTANCE PRINCIPAL (VM -> BUCKET)
# ==============================================================================

resource "oci_identity_dynamic_group" "compute_dg" {
  compartment_id = var.tenancy_ocid
  name           = "squad3-compute-dg"
  description    = "Grupo dinamico para a instancia do Airflow Squad 3"
  matching_rule  = "ALL {instance.id = '${oci_core_instance.airflow_instance.id}'}"
}

resource "oci_identity_policy" "lake_access_policy" {
  compartment_id = var.compartment_id
  name           = "squad3-vm-to-lake-policy"
  description    = "Permissoes automaticas para a VM gerenciar o Data Lake"

  statements = [
    "Allow dynamic-group squad3-compute-dg to manage objects in bucket lake-squad3",
    "Allow dynamic-group squad3-compute-dg to read buckets in compartment id ${var.compartment_id}"
  ]
}

# ==============================================================================
# 2. HUMANOS: GRUPOS E MEMBROS
# ==============================================================================

# --- GRUPOS ---
resource "oci_identity_group" "eng_group" {
  name        = "squad3-eng-group"
  description = "Engenheiros de Dados - Squad 3"
}

resource "oci_identity_group" "analytics_group" {
  name        = "squad3-analytics-group"
  description = "Cientistas e Analistas de Dados - Squad 3"
}

# --- MAPEAMENTO DE USUÁRIOS (ENGENHARIA) ---
locals {
  membros_eng = {
    "rafael"  = "eng-rafael-squad3"
    "fred"    = "eng-fred-squad3"
    "ronaldo" = "eng-ronaldo-squad3"
  }
}

resource "oci_identity_user" "engineers" {
  for_each    = local.membros_eng
  name        = each.value
  description = "Engenheiro de Dados - Membro Squad 3"
}

resource "oci_identity_user_group_membership" "add_engineers" {
  for_each = local.membros_eng
  group_id = oci_identity_group.eng_group.id
  user_id  = oci_identity_user.engineers[each.key].id
}

# --- MAPEAMENTO DE USUÁRIOS (ANALYTICS) ---
locals {
  membros_analytics = {
    "lucas"   = "analytics-lucas-squad3"
    "carlos"  = "analytics-carlos-squad3"
    "gabriel" = "analytics-gabriel-squad3"
    "lazza"   = "analytics-lazza-squad3"
    "gustavo" = "analytics-gustavo-squad3"
    "michele" = "analytics-michele-squad3"
  }
}

resource "oci_identity_user" "analysts" {
  for_each    = local.membros_analytics
  name        = each.value
  description = "Analista/Cientista de Dados - Membro Squad 3"
}

resource "oci_identity_user_group_membership" "add_analysts" {
  for_each = local.membros_analytics
  group_id = oci_identity_group.analytics_group.id
  user_id  = oci_identity_user.analysts[each.key].id
}

# ==============================================================================
# 3. POLÍTICAS DE ACESSO HUMANO (ENGENHARIA E ANALYTICS)
# ==============================================================================

resource "oci_identity_policy" "human_access_policy" {
  compartment_id = var.compartment_id
  name           = "squad3-human-access-policy"
  description    = "Politica de acesso para os membros humanos da Squad 3"

  statements = [
    # Engenheiros mandam em tudo no compartimento do projeto
    "Allow group squad3-eng-group to manage all-resources in compartment id ${var.compartment_id}",
    
    # Analistas apenas leem os dados brutos e processados no Lake
    "Allow group squad3-analytics-group to read objects in bucket lake-squad3",
    "Allow group squad3-analytics-group to inspect buckets in compartment id ${var.compartment_id}"
  ]
}

# ==============================================================================
# 4. GERAÇÃO DE API KEYS (PARA ACESSO VIA NOTEBOOK/PYTHON)
# ==============================================================================

locals {
  todos_membros = merge(local.membros_eng, local.membros_analytics)
}

resource "tls_private_key" "all_user_keys" {
  for_each  = local.todos_membros
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "oci_identity_api_key" "all_api_keys" {
  for_each  = local.todos_membros
  key_value = tls_private_key.all_user_keys[each.key].public_key_pem
  
  user_id   = contains(keys(local.membros_eng), each.key) ? oci_identity_user.engineers[each.key].id : oci_identity_user.analysts[each.key].id
}

resource "local_file" "save_pem_keys" {
  for_each = local.todos_membros
  content  = tls_private_key.all_user_keys[each.key].private_key_pem
  filename = "${path.module}/acessos_squad3/${each.value}.pem"
}

# ==============================================================================
# 5. CREDENCIAIS S3 COMPAT (DUCKDB / MASTER)
# ==============================================================================

resource "oci_identity_customer_secret_key" "rafael_s3_key" {
  display_name = "s3-compat-key-rafael"
  user_id      = oci_identity_user.engineers["rafael"].id
}

resource "local_file" "s3_credentials_file" {
  content  = <<EOT
# --- CREDENCIAIS PARA O .ENV DO CORE (DUCKDB) ---
# Gerado para: eng-rafael-squad3
AWS_ACCESS_KEY_ID=${oci_identity_customer_secret_key.rafael_s3_key.id}
AWS_SECRET_ACCESS_KEY=${oci_identity_customer_secret_key.rafael_s3_key.key}
S3_ENDPOINT=https://${var.os_namespace}.compat.objectstorage.${var.region}.oraclecloud.com
EOT
  filename = "${path.module}/acessos_squad3/S3_COMPAT_RAFAEL.txt"
}