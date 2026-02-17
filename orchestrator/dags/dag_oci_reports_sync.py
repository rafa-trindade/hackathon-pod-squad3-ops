# ==============================================================================
# DAG: oci_reports_sync
# Descrição: Sincronização de relatórios de custos e inventário (OCI)
# Objetivo: Garantir que os relatórios de custos e inventário da OCI estejam atualizados e disponíveis no ambiente
# Agendamento: A cada 6 horas
# ==============================================================================
from airflow import DAG
from airflow.operators.python import PythonOperator
import subprocess
import sys
from datetime import datetime, timedelta
import pendulum

local_tz = pendulum.timezone("America/Sao_Paulo")

def install_deps():
    try:
        import oci
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "oci"])

def run_extraction():
    sys.path.append('/opt/airflow')
    from ingestion.oci_reports import extract_and_upload_reports
    extract_and_upload_reports()

default_args = {
    'owner': 'squad3-ops',
    'depends_on_past': False,
    'start_date': datetime(2026, 2, 1, tzinfo=local_tz),
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    'oci_reports_sync',
    default_args=default_args,
    description='Sincronização de relatórios de custos e inventário (OCI)',
    schedule_interval='0 */6 * * *',
    catchup=False,
    tags=['oci', 'reports'],
    max_active_runs=1
) as dag:

    t1 = PythonOperator(
        task_id='install_oci_sdk', 
        python_callable=install_deps
    )

    t2 = PythonOperator(
        task_id='process_reports', 
        python_callable=run_extraction
    )

    t1 >> t2