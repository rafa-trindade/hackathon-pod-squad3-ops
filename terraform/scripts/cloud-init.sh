#!/bin/bash
# ==============================================================================
# SQUAD 3 - CLOUD-INIT BOOTSTRAP STRATEGY (FINAL VERSION)
# Objetivo: Automatizar o Bootstrap da arquitetura Cloud Ready na OCI
# ==============================================================================

# Redireciona a saída para o log de user-data para debug
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- [1/5] Atualizando o sistema e instalando dependências básicas ---"
sudo dnf update -y
sudo dnf install -y dnf-utils zip unzip git curl wget

echo "--- [2/5] Configurando Repositório e Instalação do Docker (Nativo OCI) ---"
# Habilita o repositório de addons da Oracle que contém o Docker para ARM64 (Oracle Linux 8)
sudo dnf config-manager --enable ol8_addons
sudo dnf install -y docker-engine docker-compose-plugin
sudo systemctl enable --now docker

echo "--- [3/5] Configurando permissões de usuário (opc) ---"
# Adiciona o usuário padrão da OCI ao grupo docker
sudo usermod -aG docker opc

echo "--- [4/5] Preparando estrutura de diretórios da aplicação ---"
# Cria a raiz da aplicação e subpastas necessárias
mkdir -p /home/opc/app/hackathon-pod-squad3-ops
mkdir -p /home/opc/app/hackathon-pod-squad3-core
mkdir -p /home/opc/app/logs
mkdir -p /home/opc/app/plugins
mkdir -p /home/opc/app/dags

# Ajusta permissões para o usuário opc (UID 1000) e grupo docker
sudo chown -R opc:docker /home/opc/app
sudo chmod -R 775 /home/opc/app

echo "--- [5/5] Configurando Cache de Alta Performance (DuckDB) ---"
# Cache Spill-to-disk em /tmp para máxima performance no boot volume (SSD)
sudo mkdir -p /tmp/duckdb_storage
# O Airflow dentro do container roda como UID 1000
sudo chown -R 1000:0 /tmp/duckdb_storage
sudo chmod -R 777 /tmp/duckdb_storage

echo "--- BOOTSTRAP FINALIZADO COM SUCESSO ---"