import os
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from datetime import timedelta

LOGS_FOLDER = "/path/to/airflow/logs"  # Emplacement des logs
RETENTION_DAYS = 30  # Durée de conservation des logs en jours

def purge_old_logs():
    now = timedelta(days=RETENTION_DAYS)
    for root, dirs, files in os.walk(LOGS_FOLDER):
        for file in files:
            file_path = os.path.join(root, file)
            if os.path.isfile(file_path) and (os.stat(file_path).st_mtime < now.total_seconds()):
                os.remove(file_path)
                print(f"Deleted: {file_path}")

with DAG(
    dag_id="purge_logs",
    schedule_interval="0 0 * * *",  # Tous les jours à minuit
    start_date=days_ago(1),
    catchup=False,
) as dag:

    purge_logs_task = PythonOperator(
        task_id="purge_logs_task",
        python_callable=purge_old_logs,
    )
