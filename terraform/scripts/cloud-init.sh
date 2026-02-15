#!/bin/bash
# ==============================================================================
# SQUAD 3 - CLOUD-INIT PARA CONFIGURAÇÃO AUTOMÁTICA DA INSTÂNCIA EC2 (OPS ENGINE)
# Objetivo: Configurar a instância EC2 automaticamente durante o processo de inicialização
# ==============================================================================

# Redirecionar toda a saída do script para um arquivo de log e também para o console, facilitando a depuração e monitoramento do processo de inicialização
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# --- BOOTSTRAP INICIAL ---
echo "--- [0/6] Aguardando a rede e os repositórios estarem prontos ---"
sleep 20

# --- ATUALIZAÇÃO E INSTALAÇÃO DE DEPENDÊNCIAS ---
echo "--- [1/6] Atualizando o sistema e instalando dependências ---"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -yq
sudo apt-get upgrade -yq
sudo apt-get install -yq ca-certificates curl gnupg zip unzip git wget

# --- CONFIGURAÇÃO DO REPOSITÓRIO DO DOCKER ---
echo "--- [2/6] Adicionando repositório oficial do Docker ---"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture ) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME" ) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- INSTALAÇÃO DO DOCKER ENGINE E COMPOSE ---
echo "--- [3/6] Instalando Docker Engine e Compose ---"
sudo apt-get update -yq

sudo apt-get install -yq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable --now docker

# --- CONFIGURAÇÃO DE PERMISSÕES PARA O USUÁRIO UBUNTU ---
echo "--- [4/6] Configurando permissões ---"
sudo usermod -aG docker ubuntu

# --- PREPARAÇÃO DA ESTRUTURA DE DIRETÓRIOS PARA OS PROJETOS ---
echo "--- [5/6] Preparando estrutura de diretórios ---"
mkdir -p /home/ubuntu/app/hackathon-pod-squad3-ops
mkdir -p /home/ubuntu/app/hackathon-pod-squad3-core
sudo chown -R ubuntu:docker /home/ubuntu/app

# --- CONFIGURAÇÃO DO DIRETÓRIO TEMPORÁRIO PARA O DUCKDB (COMPATÍVEL COM CORE) ---
echo "--- [6/6] Configurando DuckDB Temp (Compatível com Core) ---"
sudo mkdir -p /mnt/nvme/duckdb_temp
sudo chown -R 1000:0 /mnt/nvme/duckdb_temp
sudo chmod -R 777 /mnt/nvme/duckdb_temp

echo "--- BOOTSTRAP FINALIZADO COM SUCESSO ---"
