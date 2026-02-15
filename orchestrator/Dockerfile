# ==============================================================================
# SQUAD 3 - DOCKERFILE PARA ORQUESTRAÇÃO DE PIPELINES (OPS ENGINE)
# Objetivo: Criar uma imagem Docker personalizada baseada no Apache Airflow
# ==============================================================================
FROM apache/airflow:2.7.1-python3.10

USER root

RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER airflow

RUN git config --global --add safe.directory /opt/airflow/core

COPY requirements.txt /requirements_ops.txt
RUN pip install --no-cache-dir -r /requirements_ops.txt