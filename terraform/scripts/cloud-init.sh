#!/bin/bash
# ==============================================================================
# SQUAD 3 - CLOUD-INIT BOOTSTRAP STRATEGY
# Objetivo: Automatizar o Bootstrap da arquitetura Cloud Ready na OCI
# ==============================================================================

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- [1/5] Atualizando o sistema e instalando dependências ---"
sudo dnf update -y
sudo dnf install -y dnf-utils zip unzip git curl wget

echo "--- [2/5] Instalando Docker (Nativo OCI) ---"
sudo dnf config-manager --enable ol8_addons
sudo dnf install -y docker-engine docker-compose-plugin
sudo systemctl enable --now docker

echo "--- [3/5] Configurando permissões ---"
sudo usermod -aG docker opc

echo "--- [4/5] Preparando estrutura de diretórios ---"
mkdir -p /home/opc/app/hackathon-pod-squad3-ops
mkdir -p /home/opc/app/hackathon-pod-squad3-core
sudo chown -R opc:docker /home/opc/app

echo "--- [5/5] Configurando DuckDB Temp (Compatível com Core) ---"
sudo mkdir -p /mnt/nvme/duckdb_temp
sudo chown -R 1000:0 /mnt/nvme/duckdb_temp
sudo chmod -R 777 /mnt/nvme/duckdb_temp

echo "--- BOOTSTRAP FINALIZADO COM SUCESSO ---"
