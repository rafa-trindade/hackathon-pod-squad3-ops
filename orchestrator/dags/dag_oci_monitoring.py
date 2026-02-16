from airflow import DAG
from airflow.operators.python import PythonOperator
import subprocess
import sys
from datetime import datetime, timedelta

def install_deps():
    try:
        import oci
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "oci"])

def run_extraction():
    sys.path.append('/opt/airflow')
    from ingestion.oci_costs import extract_and_upload_costs
    extract_and_upload_costs()

default_args = {
    'owner': 'squad3-ops',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    'oci_costs_monitor',
    default_args=default_args,
    schedule_interval='0 */12 * * *',
    start_date=datetime(2026, 2, 1),
    catchup=False,
    tags=['oci', 'monitoring'],
    max_active_runs=1
) as dag:

    t1 = PythonOperator(task_id='install_oci_sdk', python_callable=install_deps)
    t2 = PythonOperator(task_id='process_costs', python_callable=run_extraction)

    t1 >> t2