#!/bin/bash
# ==============================================================================
# SQUAD 3 - CLOUD-INIT BOOTSTRAP STRATEGY
# Objetivo: Automatizar o Bootstrap da arquitetura Cloud Ready
# ==============================================================================

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- [1/4] Atualizando o sistema e instalando dependências básicas ---"
sudo dnf update -y
sudo dnf install -y dnf-utils zip unzip git curl wget

echo "--- [2/4] Configurando Repositório e Instalação do Docker ---"
sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker

echo "--- [3/4] Configurando permissões de usuário (opc) ---"
sudo usermod -aG docker opc

echo "--- [4/4] Preparando estrutura de diretórios"
mkdir -p /home/opc/app/logs
mkdir -p /home/opc/app/data_temp
chown -R opc:opc /home/opc/app

echo "--- BOOTSTRAP FINALIZADO COM SUCESSO ---"