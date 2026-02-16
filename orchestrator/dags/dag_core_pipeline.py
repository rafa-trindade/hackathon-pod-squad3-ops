# ==============================================================================
# DAG: core_pipeline
# Descrição: Execução do pipeline principal do Core (ingestão, processamento e medallion) via script unificado
# Objetivo: Garantir a execução integrada de todas as etapas do pipeline principal utilizando o script bin/run_pipeline.sh do repositório Core, com monitoramento centralizado e controle de falhas
# Agendamento: Mensalmente, no primeiro dia do mês às 6h da manhã (UTC)
# ==============================================================================
from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import pendulum

local_tz = pendulum.timezone("America/Sao_Paulo")

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
    description='Pipeline Principal: Execução unificada via script do Core',
    schedule_interval='0 3 1 * *',
    catchup=False,
    tags=['core', 'medallion'],
    max_active_runs=1
) as dag:

    run_full_pipeline = BashOperator(
        task_id='execute_unified_pipeline',
        env={
            'TERM': 'xterm',
            'HOME': '/tmp',
            'PYTHONPATH': '/home/airflow/.local/lib/python3.10/site-packages:/opt/airflow/core',
        },
        bash_command='cd /opt/airflow/core && bash bin/run_pipeline.sh || exit 1',
    )

    run_full_pipeline