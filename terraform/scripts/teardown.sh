#!/bin/bash
# ==============================================================================
# SQUAD 3 - TEARDOWN AUTOMATIZADO PARA AMBIENTE CLOUD READY (OPS ENGINE)
# Objetivo: Automatizar a limpeza do ambiente Cloud Ready na OCI
# ==============================================================================

# Redirecionar toda a saída do script para um arquivo de log e também para o console, facilitando a depuração e monitoramento do processo de teardown
echo "--- [1/2] Iniciando limpeza do ambiente (Cloud Readiness) ---"

# --- PARADA DE CONTAINERS E LIMPEZA DE VOLUMES ---
if command -v docker &> /dev/null; then
    echo "Parando containers do Airflow/App..."
    docker ps -q | xargs -r docker stop
    docker system prune -af --volumes
    echo "✅ Containers interrompidos e volumes limpos."
else
    echo "⚠️ Docker não encontrado, pulando interrupção."
fi

# --- LIMPEZA DE LOGS E DADOS TEMPORÁRIOS ---
echo "--- [2/2] Limpando diretórios de logs e temporários ---"
rm -rf /home/ubuntu/app/logs/*
rm -rf /home/ubuntu/app/data_temp/*

sudo rm -rf /mnt/nvme/duckdb_temp/*

echo "--- AMBIENTE RESETADO COM SUCESSO ---"
