# ==============================================================================
# DAG: core_pipeline
# Descrição: Pipeline principal do Core com ingestão da camada Raw (MinIO → OCI)
# Objetivo: Sincronizar dados brutos para OCI e executar o full pipeline Medallion (Bronze → Silver → Gold)
# Agendamento: Mensalmente, todo dia 1 às 3h da manhã (UTC)
# ==============================================================================
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import pendulum
import sys

local_tz = pendulum.timezone("America/Sao_Paulo")

sys.path.append('/opt/airflow')

from ingestion.minio_to_oci import sync_minio_to_oci

default_args = {
    'owner': 'squad3-ops',
    'depends_on_past': False,
    'start_date': datetime(2026, 2, 1, tzinfo=local_tz),
    'retries': 1,
    'retry_delay': timedelta(minutes=10),
}

with DAG(
    'core_pipeline',
    default_args=default_args,
    description='Pipeline Principal + Ingestão Raw',
    schedule_interval='0 3 1 * *',
    catchup=False,
    tags=['medallion', 'ingestion'],
    max_active_runs=1
) as dag:

    # ------------------------------------------------------------------
    # 1️⃣ Ingestão MinIO → OCI
    # ------------------------------------------------------------------
    sync_raw_layer = PythonOperator(
        task_id='sync_raw_layer',
        python_callable=sync_minio_to_oci
    )

    # ------------------------------------------------------------------
    # 2️⃣ Pipeline principal
    # ------------------------------------------------------------------
    run_full_pipeline = BashOperator(
        task_id='execute_unified_pipeline',
        env={
            'TERM': 'xterm',
            'HOME': '/tmp',
            'PYTHONPATH': '/home/airflow/.local/lib/python3.10/site-packages:/opt/airflow/core',
        },
        bash_command='cd /opt/airflow/core && bash bin/run_pipeline.sh || exit 1',
    )

    # ------------------------------------------------------------------
    # Ordem de execução
    # ------------------------------------------------------------------
    sync_raw_layer >> run_full_pipeline
