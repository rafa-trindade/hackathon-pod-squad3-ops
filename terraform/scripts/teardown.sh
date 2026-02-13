#!/bin/bash
# ==============================================================================
# SQUAD 3 - TEARDOWN & CLEANUP STRATEGY (VERSÃO UBUNTU)
# Objetivo: Reset lógico do ambiente (Parada de motores e limpeza de dados)
# ==============================================================================

echo "--- [1/2] Iniciando limpeza do ambiente (Cloud Readiness) ---"

if command -v docker &> /dev/null; then
    echo "Parando containers do Airflow/App..."
    docker ps -q | xargs -r docker stop
    docker system prune -af --volumes
    echo "✅ Containers interrompidos e volumes limpos."
else
    echo "⚠️ Docker não encontrado, pulando interrupção."
fi

echo "--- [2/2] Limpando diretórios de logs e temporários ---"
rm -rf /home/ubuntu/app/logs/*
rm -rf /home/ubuntu/app/data_temp/*

# O diretório do DuckDB que criamos no cloud-init
sudo rm -rf /mnt/nvme/duckdb_temp/*

echo "--- AMBIENTE RESETADO COM SUCESSO ---"
