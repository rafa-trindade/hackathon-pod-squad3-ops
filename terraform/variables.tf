# ==============================================================================
# SQUAD 3 - VARIABLES CONFIGURATION (OPS ENGINE)
# Objetivo: Definir as variáveis essenciais para a configuração e provisionamento

# --- Credenciais e Conexão OCI ---
# Variáveis para autenticação e conexão com a API da Oracle Cloud, garantindo que as credenciais sensíveis sejam mantidas fora do código-fonte e possam ser facilmente configuradas em diferentes ambientes
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
# Variáveis para configuração de recursos específicos, como o Compartment onde os recursos serão criados, o namespace do Object Storage e detalhes da instância de VM, permitindo flexibilidade e reutilização do código em diferentes contextos
variable "compartment_id" {
  description = "OCID do Compartment onde os recursos serão criados"
  type        = string
}

variable "os_namespace" {
  description = "Namespace do Object Storage (Necessário para o Bucket)"
  type        = string
}

# --- Configuração da VM ---
# Variáveis para configuração da instância de VM, como a imagem a ser utilizada e a chave SSH para acesso, permitindo que a infraestrutura seja facilmente adaptada para diferentes necessidades e ambientes
variable "instance_image_id" {
  description = "OCID da Imagem Oracle Linux para a VM"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave SSH pública para acessar a instância via terminal"
  type        = string
}