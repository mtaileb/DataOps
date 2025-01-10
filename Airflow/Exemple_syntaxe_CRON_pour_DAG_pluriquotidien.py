from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

# Définir les paramètres par défaut du DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2
}

# Fonction Python à exécuter
def process_data(**kwargs):
    print("Traitement des données...")
    # Simuler une tâche
    return "Données traitées avec succès."

# Définir le DAG
with DAG(
    dag_id='traitement_donnees_pluriquotidien_7h_13h_17h',
    default_args=default_args,
    description='DAG exécutant une tâche Python plusieurs fois par jour',
    schedule_interval='0 7,13,17 * * *',  # CRON : À 7h, 13h et 17h chaque jour
    start_date=datetime(2025, 1, 1),      # Début des exécutions
    catchup=False,                        # Désactiver le rattrapage
    tags=['data_processing', 'example']
) as dag:
    
    # Définir une tâche avec PythonOperator
    process_task = PythonOperator(
        task_id='tache_traitement_donnees',
        python_callable=process_data,  # Appeler la fonction définie
        provide_context=True           # Passer les paramètres Airflow (kwargs)
    )
