from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'squad3-core',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=10),
}

with DAG(
    'dag_core_pipeline',
    default_args=default_args,
    description='Pipeline Principal: Execução unificada via script do Core',
    schedule_interval='0 2 * * *',
    catchup=False,
    tags=['core', 'medallion', 'duckdb'],
) as dag:

    run_full_pipeline = BashOperator(
        task_id='execute_unified_pipeline',
        bash_command='bash /opt/airflow/core/bin/run_pipeline.sh',
    )

    run_full_pipeline