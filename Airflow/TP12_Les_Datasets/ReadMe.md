#### **1. Création d’un Dataset**
Un Dataset est défini avec le chemin ou la ressource qu’il représente.

```python
from airflow.datasets import Dataset

my_dataset = Dataset('/path/to/data.csv')  # Représente un fichier ou une ressource
```

#### **2. DAG Producer**
Un DAG "producer" met à jour un Dataset, signalant aux DAGs consommateurs qu'une nouvelle version des données est disponible.

```python
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.datasets import Dataset
from airflow.utils.dates import days_ago

my_dataset = Dataset('/path/to/data.csv')

with DAG(
    dag_id='producer_dag',
    start_date=days_ago(1),
    schedule_interval='@daily',
    catchup=False,
) as dag:

    produce_task = DummyOperator(
        task_id='produce_data',
        outlets=[my_dataset],  # Indique que ce Dataset est mis à jour
    )
```

#### **3. DAG Consumer**
Un DAG "consumer" attend qu’un Dataset soit mis à jour avant de s’exécuter.

```python
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.datasets import Dataset
from airflow.utils.dates import days_ago

my_dataset = Dataset('/path/to/data.csv')

with DAG(
    dag_id='consumer_dag',
    start_date=days_ago(1),
    schedule=[my_dataset],  # Déclenchement basé sur le Dataset
    catchup=False,
) as dag:

    consume_task = DummyOperator(
        task_id='consume_data',
    )
```

---

#### **Exemple Complet**
1. **Dataset** :
   ```python
   my_dataset = Dataset('/path/to/data.csv')
   ```

2. **DAG Producer** :
   ```python
   with DAG(
       dag_id='producer_dag',
       start_date=days_ago(1),
       schedule_interval='@daily',
       catchup=False,
   ) as dag:

       produce_task = DummyOperator(
           task_id='produce_data',
           outlets=[my_dataset],
       )
   ```

3. **DAG Consumer** :
   ```python
   with DAG(
       dag_id='consumer_dag',
       start_date=days_ago(1),
       schedule=[my_dataset],
       catchup=False,
   ) as dag:

       consume_task = DummyOperator(
           task_id='consume_data',
       )
   ```

---
