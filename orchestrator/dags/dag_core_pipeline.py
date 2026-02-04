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
    description='Pipeline Principal: Bronze -> Silver -> Gold (DuckDB Engine)',
    schedule_interval='0 2 * * *',
    catchup=False,
    tags=['core', 'medallion', 'duckdb'],
) as dag:

    # Exemplo de execução dos módulos do Core
    # Assume-se que o Core tem um entrypoint ou scripts específicos
    
    run_bronze = BashOperator(
        task_id='process_bronze_layer',
        bash_command='python3 /opt/airflow/core/main.py --layer bronze',
    )

    run_silver = BashOperator(
        task_id='process_silver_layer',
        bash_command='python3 /opt/airflow/core/main.py --layer silver',
    )

    run_gold = BashOperator(
        task_id='process_gold_layer',
        bash_command='python3 /opt/airflow/core/main.py --layer gold',
    )

    run_bronze >> run_silver >> run_gold