# ==============================================================================
# SQUAD 3 - TERRAFORM VARIABLES DEFINITION
# Objetivo: Parametrização da infraestrutura para garantir portabilidade (Cloud Ready)
# ==============================================================================

# --- Credenciais e Conexão OCI ---
variable "tenancy_ocid" {
  description = "OCID da sua conta principal (Tenancy)"
  type        = string
}

variable "user_ocid" {
  description = "OCID do seu usuário OCI"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da sua chave de API"
  type        = string
}

variable "private_key_path" {
  description = "Caminho local para a sua chave privada (.pem)"
  type        = string
}

variable "region" {
  description = "Região da OCI (Ex: sa-saopaulo-1)"
  type        = string
  default     = "sa-saopaulo-1"
}

# --- Organização e Recursos ---
variable "compartment_id" {
  description = "OCID do Compartment onde os recursos serão criados"
  type        = string
}

variable "os_namespace" {
  description = "Namespace do Object Storage (Necessário para o Bucket)"
  type        = string
}

# --- Configuração da VM ---
variable "instance_image_id" {
  description = "OCID da Imagem Oracle Linux para a VM"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave SSH pública para acessar a instância via terminal"
  type        = string
}