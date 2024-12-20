### **Airflow : Opérateurs pour BigQuery**

Airflow fournit plusieurs opérateurs et hooks pour interagir avec **Google BigQuery**, principalement via le package `apache-airflow-providers-google`. Ces opérateurs permettent d'exécuter des requêtes, de charger des données, d'exporter des résultats, et de gérer des tables ou des datasets dans BigQuery.

---

### **1. Installer le Package du Provider BigQuery**

Assurez-vous d’avoir installé le package BigQuery pour Airflow :
```bash
pip install apache-airflow-providers-google
```

Ce package contient les opérateurs, hooks, et dépendances nécessaires pour BigQuery.

---

### **2. Opérateurs Courants pour BigQuery**

#### **BigQueryInsertJobOperator**
Permet d'exécuter des requêtes SQL dans BigQuery.

**Exemple : Exécution d'une Requête**
```python
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.utils.dates import days_ago

with DAG(
    dag_id="bigquery_query_example",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
) as dag:

    execute_query = BigQueryInsertJobOperator(
        task_id="run_bigquery_query",
        configuration={
            "query": {
                "query": "SELECT * FROM `projet.dataset.table` LIMIT 10",
                "useLegacySql": False,
            }
        },
        gcp_conn_id="google_cloud_default",  # ID de connexion configuré dans Airflow
    )
```

#### **BigQueryExecuteQueryOperator**
Un opérateur simplifié pour exécuter des requêtes SQL.

**Exemple : Exécution Simple d'une Requête**
```python
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryExecuteQueryOperator
from airflow.utils.dates import days_ago

with DAG(
    dag_id="bigquery_execute_query_example",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
) as dag:

    execute_query = BigQueryExecuteQueryOperator(
        task_id="execute_query",
        sql="SELECT COUNT(*) FROM `projet.dataset.table`",
        use_legacy_sql=False,
        gcp_conn_id="google_cloud_default",
    )
```

---

### **3. Chargement et Exportation des Données**

#### **BigQueryInsertJobOperator pour Charger des Données**
Permet de charger des données depuis Google Cloud Storage (GCS) vers BigQuery.

**Exemple : Charger un Fichier CSV depuis GCS**
```python
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.utils.dates import days_ago

with DAG(
    dag_id="bigquery_load_data_example",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
) as dag:

    load_data = BigQueryInsertJobOperator(
        task_id="load_gcs_to_bigquery",
        configuration={
            "load": {
                "sourceUris": ["gs://mon-bucket/data.csv"],
                "destinationTable": {
                    "projectId": "mon-projet",
                    "datasetId": "mon_dataset",
                    "tableId": "ma_table",
                },
                "sourceFormat": "CSV",
                "writeDisposition": "WRITE_TRUNCATE",
            }
        },
        gcp_conn_id="google_cloud_default",
    )
```

#### **BigQueryToGCSOperator**
Permet d’exporter des données de BigQuery vers Google Cloud Storage.

**Exemple : Exporter des Résultats de Requête vers GCS**
```python
from airflow import DAG
from airflow.providers.google.cloud.transfers.bigquery_to_gcs import BigQueryToGCSOperator
from airflow.utils.dates import days_ago

with DAG(
    dag_id="bigquery_export_example",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
) as dag:

    export_data = BigQueryToGCSOperator(
        task_id="export_to_gcs",
        source_project_dataset_table="mon-projet.mon_dataset.ma_table",
        destination_cloud_storage_uris=["gs://mon-bucket/data_export.json"],
        export_format="JSON",
        gcp_conn_id="google_cloud_default",
    )
```

---

### **4. Gestion des Tables BigQuery**

#### **BigQueryCreateEmptyTableOperator**
Permet de créer une nouvelle table vide dans BigQuery.

**Exemple : Créer une Table**
```python
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateEmptyTableOperator
from airflow.utils.dates import days_ago

with DAG(
    dag_id="bigquery_create_table_example",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
) as dag:

    create_table = BigQueryCreateEmptyTableOperator(
        task_id="create_table",
        dataset_id="mon_dataset",
        table_id="ma_table",
        schema_fields=[
            {"name": "id", "type": "INTEGER", "mode": "REQUIRED"},
            {"name": "nom", "type": "STRING", "mode": "NULLABLE"},
        ],
        gcp_conn_id="google_cloud_default",
    )
```

#### **BigQueryDeleteTableOperator**
Permet de supprimer une table dans BigQuery.

**Exemple : Supprimer une Table**
```python
from airflow import DAG
from airflow.providers.google.cloud.operators.bigquery import BigQueryDeleteTableOperator
from airflow.utils.dates import days_ago

with DAG(
    dag_id="bigquery_delete_table_example",
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
) as dag:

    delete_table = BigQueryDeleteTableOperator(
        task_id="delete_table",
        deletion_dataset_table="mon-projet.mon_dataset.ma_table",
        gcp_conn_id="google_cloud_default",
        ignore_if_missing=True,
    )
```

---

### **5. Configuration de la Connexion Google Cloud**

1. **Créer une Connexion** :
   - Dans l'interface Airflow, accédez à **Admin > Connections**.
   - Ajoutez une nouvelle connexion :
     - **Conn ID** : `google_cloud_default`
     - **Conn Type** : `Google Cloud`.
     - **Keyfile Path** : Chemin vers le fichier JSON de compte de service.
     - **Project ID** : ID de votre projet Google Cloud.

2. **Tester la Connexion** :
   - Assurez-vous que la connexion fonctionne en testant une tâche qui en dépend.

---

### **6. Résumé**

| **Opérateur**                     | **Usage**                                                                    |
|-----------------------------------|------------------------------------------------------------------------------|
| **BigQueryInsertJobOperator**     | Exécute des requêtes SQL ou des jobs BigQuery (chargement, export, etc.).    |
| **BigQueryExecuteQueryOperator**  | Simplifie l’exécution de requêtes SQL dans BigQuery.                        |
| **BigQueryToGCSOperator**         | Exporte des données de BigQuery vers Google Cloud Storage.                  |
| **BigQueryCreateEmptyTableOperator** | Crée une table vide dans BigQuery.                                           |
| **BigQueryDeleteTableOperator**   | Supprime une table BigQuery existante.                                       |
