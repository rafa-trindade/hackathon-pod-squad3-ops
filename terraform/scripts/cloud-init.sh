#!/bin/bash
# ==============================================================================
# SQUAD 3 - CLOUD-INIT BOOTSTRAP STRATEGY
# Objetivo: Automatizar o Bootstrap da arquitetura Cloud Ready
# ==============================================================================

# Redireciona a saída para o log de user-data para debug
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- [1/4] Atualizando o sistema e instalando dependências básicas ---"
sudo dnf update -y
sudo dnf install -y dnf-utils zip unzip git curl wget

echo "--- [2/4] Configurando Repositório e Instalação do Docker (Nativo OCI) ---"
# Habilita o repositório de addons da Oracle que contém o Docker para ARM64
sudo dnf config-manager --enable ol8_addons
sudo dnf install -y docker-engine docker-compose-plugin
sudo systemctl enable --now docker

echo "--- [3/4] Configurando permissões de usuário (opc) ---"
sudo usermod -aG docker opc

echo "--- [4/4] Preparando estrutura de diretórios e Cache DuckDB ---"
# Pastas da aplicação no diretório do usuário
mkdir -p /home/opc/app/logs
mkdir -p /home/opc/app/data_temp
chown -R opc:opc /home/opc/app

# Cache de alta performance para o DuckDB (Spill-to-disk)
# Criado na raiz /tmp para máxima performance no boot volume
sudo mkdir -p /tmp/duckdb_storage
sudo chown -R 1000:0 /tmp/duckdb_storage
sudo chmod -R 777 /tmp/duckdb_storage

echo "--- BOOTSTRAP FINALIZADO COM SUCESSO ---"