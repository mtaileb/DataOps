Voici comment exécuter un DAG **Airflow** dans **GitLab CI/CD**. Cela permet principalement de tester ou simuler l'exécution du DAG dans un environnement d'intégration continue.

---

### **1. Prérequis**
1. **Installer Docker** : Assurez-vous que le runner GitLab dispose de Docker installé et configuré.
2. **DAG Airflow** : Vous avez un fichier DAG de base (exemple : `my_dag.py`) dans votre dépôt GitLab.
3. **Image Docker** : Utilisez l’image officielle d’Apache Airflow.

---

### **2. Exemple de DAG Airflow**
Créez un fichier nommé `my_dag.py` contenant un DAG très simple pour tester :

```python
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.utils.dates import days_ago

with DAG(
    dag_id='simple_test_dag',
    start_date=days_ago(1),
    schedule_interval=None,
    catchup=False,
    tags=['example'],
) as dag:

    start = DummyOperator(task_id='start')
    end = DummyOperator(task_id='end')

    start >> end
```

Placez ce fichier dans un dossier nommé `dags/` dans votre dépôt.

---

### **3. Créer le fichier `.gitlab-ci.yml`**
Ajoutez un fichier `.gitlab-ci.yml` à la racine de votre dépôt avec la configuration suivante :

```yaml
image: apache/airflow:2.6.1  # Utilise l'image officielle Apache Airflow

stages:
  - test

variables:
  AIRFLOW_HOME: /airflow  # Définit le répertoire de base d'Airflow
  AIRFLOW__CORE__LOAD_EXAMPLES: "False"  # Désactive les exemples de DAGs

before_script:
  # Installe les dépendances nécessaires
  - pip install apache-airflow-providers-dummy  # Fournisseurs additionnels si besoin
  # Crée les répertoires Airflow
  - mkdir -p $AIRFLOW_HOME/dags
  # Copie les DAGs dans le répertoire Airflow
  - cp -r dags/* $AIRFLOW_HOME/dags/
  # Initialise la base de données Airflow
  - airflow db init

test_airflow_dag:
  stage: test
  script:
    # Liste les DAGs pour vérifier qu'ils sont bien chargés
    - airflow dags list
    # Déclenche le DAG pour le tester
    - airflow dags trigger simple_test_dag
    # Vérifie les tâches du DAG
    - airflow tasks list simple_test_dag
  only:
    - main  # Exécute ce job uniquement sur la branche `main`
```

---

### **4. Explications du fichier `.gitlab-ci.yml`**

1. **`image`** :
   - Spécifie l’image Docker officielle d’Apache Airflow utilisée pour exécuter les jobs.

2. **`before_script`** :
   - Prépare l’environnement :
     - Installe les dépendances nécessaires.
     - Copie les fichiers DAG dans le répertoire `$AIRFLOW_HOME/dags`.
     - Initialise la base de données Airflow avec `airflow db init`.

3. **`test_airflow_dag`** :
   - Liste les DAGs disponibles (`airflow dags list`).
   - Déclenche le DAG (`airflow dags trigger`).
   - Vérifie les tâches du DAG (`airflow tasks list`).

4. **`only`** :
   - Définit que ce job doit s’exécuter uniquement sur la branche `main`.

---

### **5. Déployer et Tester**
1. **Ajoutez les fichiers au dépôt GitLab** :
   - Placez le fichier `my_dag.py` dans le dossier `dags/`.
   - Placez le fichier `.gitlab-ci.yml` à la racine du dépôt.

2. **Commit et push** :
   ```bash
   git add dags/my_dag.py .gitlab-ci.yml
   git commit -m "Ajout d'un DAG Airflow et configuration GitLab CI"
   git push
   ```

3. **Vérifiez le pipeline dans GitLab** :
   - Accédez à **CI/CD > Pipelines** dans l’interface GitLab.
   - Vous devriez voir le pipeline s’exécuter avec succès.

---

### **6. Résultats Attendus**
- **Liste des DAGs** : Le job affiche une liste des DAGs disponibles, incluant `simple_test_dag`.
- **Déclenchement du DAG** : Le DAG `simple_test_dag` est déclenché et exécuté dans l’environnement Docker.
- **Liste des tâches** : Le job affiche les tâches définies dans le DAG (par exemple, `start` et `end`).

---

### **Améliorations Possibles**
1. **Tester plusieurs DAGs** :
   - Ajoutez d’autres DAGs dans le dossier `dags/` et modifiez le pipeline pour les tester tous.

2. **Authentification** :
   - Ajoutez des tests pour des connexions ou intégrations spécifiques (Google Cloud, AWS, etc.).

3. **Environnement de Production** :
   - Utilisez GitLab CI pour déployer les DAGs dans un environnement Airflow de production via SSH ou API.
