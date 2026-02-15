# ==============================================================================
# SQUAD 3 - OUTPUTS STRATEGY (OPS ENGINE)
# Objetivo: Definir os outputs essenciais para acesso, monitoramento e integração
# ==============================================================================

# --- INFRAESTRUTURA ---
# Exibir o IP público da instância do Airflow para acesso SSH e interface web
output "instancia_ip_publico" {
  description = "IP Público da VM para acesso SSH e Airflow"
  value       = oci_core_instance.airflow_instance.public_ip
}

# Exibir o comando SSH pronto para uso, facilitando o acesso à VM sem precisar montar o comando manualmente
output "comando_ssh" {
  description = "Comando pronto para copiar e acessar a VM via terminal"
  value       = "ssh -i ~/.ssh/id_rsa opc@${oci_core_instance.airflow_instance.public_ip}"
}

# --- GESTÃO DE ACESSOS (ENGENHARIA) ---
# Exibir os dados de OCID, Fingerprint e caminho da chave privada para os engenheiros de dados, facilitando a configuração de acesso e integração com a API da Oracle Cloud
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
# Exibir os dados de OCID, Fingerprint e caminho da chave privada para os analistas e cientistas de dados, facilitando a configuração de acesso e integração com a API da Oracle Cloud
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
# Exibir as credenciais de acesso S3 compatível com DuckDB para o usuário Rafael (Engenheiro de Dados), facilitando a configuração do .env do Airflow e DuckDB para acesso ao Object Storage
output "credenciais_s3_compativel_rafael" {
  description = "IMPORTANTE: Use estes dados no .env do Airflow/DuckDB"
  value = {
    AWS_ACCESS_KEY_ID     = oci_identity_customer_secret_key.rafael_s3_key.id
    AWS_SECRET_ACCESS_KEY = oci_identity_customer_secret_key.rafael_s3_key.key
    S3_ENDPOINT           = "https://${var.os_namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
  }
  sensitive = true
}