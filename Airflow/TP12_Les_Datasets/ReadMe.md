#### **1. Création d’un Dataset**
Un Dataset est défini avec le chemin ou la ressource qu’il représente.

Nota: le code ci-dessous doit être placé à un emplacement commun accessible par tous les DAGs qui interagissent avec ce Dataset (les DAGs producers et consumers): soit le mettre dans un fichier my_datasets et l'importer dans les DAGs avec from datasets import my_dataset; ou alors le déclarer dirctement dans chaque DAG après les imports. Cela garantit que le même objet Dataset est utilisé pour établir la relation entre les DAGs.

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
        outlets=[my_dataset],  # Indique que ce Dataset est mis à jour, et donc ce DAG est Producer
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

### **Résumé des Différences entre DAG Producer et Consumer**

| **Aspect**                 | **DAG Producer**                                | **DAG Consumer**                                |
|-----------------------------|------------------------------------------------|------------------------------------------------|
| **Interaction avec le Dataset** | Produit ou met à jour un Dataset (via `outlets`) | Consomme un Dataset mis à jour (via `schedule`) |
| **Paramètre clé**           | `outlets=[Dataset(...)]`                       | `schedule=[Dataset(...)]`                      |
| **Déclenchement**           | S'exécute selon son propre planning (ex. `@daily`) | Déclenché automatiquement lorsqu'un Dataset est mis à jour |
| **Rôle**                   | Informe qu'un Dataset est prêt ou a été mis à jour | Attend qu'un Dataset soit disponible pour démarrer |
| **Relation**                | Produit un Dataset pour un ou plusieurs Consumers | Dépend d'un ou plusieurs Producers via le Dataset |

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

Exemple de création initiale d'un CSV dans le cadre d'une tâche producer:

```python
import os

def create_csv_file():
    file_path = '/path/to/my_dataset.csv'
    # Check if the file exists
    if not os.path.exists(file_path):
        # Create the file and write a header
        with open(file_path, 'w') as f:
            f.write("id,name,age\n")
        print(f"CSV file created at {file_path}")
    else:
        print(f"CSV file already exists at {file_path}")
```
