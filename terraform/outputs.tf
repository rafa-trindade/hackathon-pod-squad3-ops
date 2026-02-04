# ==============================================================================
# SQUAD 3 - OUTPUTS (INFORMAÇÕES PÓS-DEPLOY)
# Objetivo: Exibir dados de conexão, gerenciar credenciais e facilitar o acesso SSH
# ==============================================================================

# --- INFRAESTRUTURA ---

output "instancia_ip_publico" {
  description = "IP Público da VM para acesso SSH e Airflow"
  value       = oci_core_instance.airflow_instance.public_ip
}

output "comando_ssh" {
  description = "Comando pronto para copiar e acessar a VM via terminal"
  value       = "ssh -i ~/.ssh/id_rsa opc@${oci_core_instance.airflow_instance.public_ip}"
}

# --- GESTÃO DE ACESSOS (ENGENHARIA) ---

output "lista_acessos_engenheiros" {
  description = "Dados de OCID e Fingerprint para os Engenheiros"
  value = {
    for k, p in oci_identity_user.engineers : k => {
      usuario     = p.name
      user_ocid   = p.id
      fingerprint = oci_identity_api_key.all_api_keys[k].fingerprint
      key_path    = "./acessos_squad3/${p.name}.pem"
    }
  }
}

# --- GESTÃO DE ACESSOS (CIÊNCIA/ANALYTICS) ---

output "lista_acessos_analistas" {
  description = "Dados de OCID e Fingerprint para os Analistas"
  value = {
    for k, p in oci_identity_user.analysts : k => {
      usuario     = p.name
      user_ocid   = p.id
      fingerprint = oci_identity_api_key.all_api_keys[k].fingerprint
      key_path    = "./acessos_squad3/${p.name}.pem"
    }
  }
}

# --- CREDENCIAIS COMPATÍVEIS S3 (DUCKDB) ---

output "credenciais_s3_compativel_rafael" {
  description = "IMPORTANTE: Use estes dados no .env do Airflow/DuckDB"
  value = {
    AWS_ACCESS_KEY_ID     = oci_identity_customer_secret_key.rafael_s3_key.id
    AWS_SECRET_ACCESS_KEY = oci_identity_customer_secret_key.rafael_s3_key.key
    S3_ENDPOINT           = "https://${var.os_namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
  }
  sensitive = true
}