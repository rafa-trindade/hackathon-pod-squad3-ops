# ==============================================================================
# DAG: ingestion_bridge
# Descrição: Sincronização de dados da camada Raw (MinIO) para Object Storage (OCI) simulando a etapa de ingestão inicial do pipeline
# Objetivo: Transferir dados brutos do MinIO para o OCI, preparando-os para processamento em camadas intermediárias
# Agendamento: Mensalmente, no primeiro dia do mês às 4h da manhã (UTC)
# ==============================================================================
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import sys
import os

sys.path.append('/opt/airflow')

from ingestion.minio_to_oci import sync_minio_to_oci

default_args = {
    'owner': 'squad3-ops',
    'depends_on_past': False,
    'start_date': datetime(2026, 2, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'ingestion_bridge',
    default_args=default_args,
    description='Sync de dados Raw: MinIO (VPS) -> Object Storage (OCI)',
    schedule_interval='0 4 1 * *', 
    catchup=False,
    tags=['ops', 'ingestion'],
    max_active_runs=1
) as dag:

    task_ingestion = PythonOperator(
        task_id='sync_raw_layer',
        python_callable=sync_minio_to_oci
    )