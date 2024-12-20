from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.models import Variable  # Importer Variable pour accéder aux variables Airflow
import os

# Configuration des paramètres par défaut du DAG
default_args = {
    'owner': 'airflow',  # Propriétaire du DAG
    'depends_on_past': False,  # Ne dépend pas des exécutions passées
    'email_on_failure': False,  # Pas d'email en cas d'échec
}

# Fonction pour lister les fichiers dans le bucket GCS
def list_gcs_files(bucket_name, prefix):
    # Définir la variable d'environnement pour les credentials
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = Variable.get("GOOGLE_APPLICATION_CREDENTIALS")
    
    # Création d'une instance de GCSHook pour se connecter à GCS
    gcs_hook = GCSHook(gcp_conn_id='my_gcs')  # Connexion à configurer dans Airflow
    # Lister les fichiers dans le bucket
    files = gcs_hook.list(bucket_name, prefix=prefix)    
    # Afficher les fichiers dans les journaux
    print(f"Fichiers dans le bucket {bucket_name}: {files}")
    return files

# Fonction pour télécharger un fichier spécifique
def download_gcs_file(bucket_name, object_name, local_path):
    # Création d'une instance de GCSHook pour se connecter à GCS
    gcs_hook = GCSHook(gcp_conn_id='my_gcs')  # Connexion à configurer dans Airflow
    # Télécharger le fichier
    gcs_hook.download(bucket_name, object_name, local_path)
    # Afficher un message confirmant le téléchargement
    print(f"Fichier téléchargé : {local_path}")

# Création du DAG
with DAG(
    'TP8_Exemple_Hook_GCS',  # Nom du DAG
    default_args=default_args,  # Paramètres par défaut
    schedule_interval=None,  # Exécution manuelle
    start_date=days_ago(1),  # Date de démarrage
    tags=['gcs', 'delivery'],  # Étiquettes
) as dag:

    # Tâche pour lister les fichiers dans le bucket GCS
    list_files_task = PythonOperator(
        task_id='list_files',  # Identifiant de la tâche
        python_callable=list_gcs_files,  # Fonction appelée
        op_args=['tp-dvc-mt', 'airflow-hook-demo/'],  # Bucket et préfixe (répertoire)
    )

    # Tâche pour télécharger un fichier spécifique
    download_file_task = PythonOperator(
        task_id='download_file',  # Identifiant de la tâche
        python_callable=download_gcs_file,  # Fonction appelée
        op_args=[
            'tp-dvc-mt',  # Nom du bucket GCS
            'airflow-hook-demo/titanic.csv',  # Nom du fichier à télécharger (à remplacer si nécessaire)
            '/tmp/titanic.csv',  # Chemin local pour sauvegarder le fichier
        ],
    )

    # Définir la séquence des tâches
    list_files_task >> download_file_task
