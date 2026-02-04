from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'squad3-core',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 0,
}

with DAG(
    'dag_core_bootstrap',
    default_args=default_args,
    description='Bootstrap do Repositório Core e Dependências',
    schedule_interval=None,
    catchup=False,
    tags=['core', 'setup'],
) as dag:

    # Sincroniza o repositório Core caso haja atualizações
    sync_core = BashOperator(
        task_id='sync_core_repository',
        bash_command='cd /opt/airflow/core && git pull origin main || echo "Core já atualizado"',
    )

    # Instala dependências específicas do Core (se houver um requirements.txt no core)
    install_deps = BashOperator(
        task_id='install_core_dependencies',
        bash_command='pip install -r /opt/airflow/core/requirements.txt || echo "Sem requirements no core"',
    )

    sync_core >> install_deps