from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import sys
import os

sys.path.append('/opt/airflow')

from ingestion.minio_to_oci import sync_minio_to_oci

default_args = {
    'owner': 'squad3',
    'depends_on_past': False,
    'start_date': datetime(2026, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'bridge_minio_to_oci_raw',
    default_args=default_args,
    description='Sync de dados Raw: MinIO (VPS) -> Object Storage (OCI)',
    schedule_interval='@daily',
    catchup=False,
    tags=['ops', 'ingestion', 's3'],
) as dag:

    task_ingestion = PythonOperator(
        task_id='sync_raw_layer',
        python_callable=sync_minio_to_oci
    )