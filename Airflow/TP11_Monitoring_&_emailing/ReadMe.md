### **TP : Surveillance Automatisée par Emailing avec Airflow**

Ce TP vous guide pour configurer un workflow Airflow qui surveille un processus ou des données et envoie des alertes par email lorsqu'une condition spécifique est remplie.

---

### **Objectif**
Créer un DAG Airflow qui :
1. Exécute une tâche de surveillance (simulation d'un processus ou d'une vérification de données).
2. Envoie un email automatique en cas de succès ou d'échec.

---

### **Pré-requis**
1. **Airflow installé** : Vous pouvez utiliser une installation locale ou via Docker.
2. **Serveur SMTP** : Une adresse email et un serveur SMTP configurés pour l'envoi (par exemple, Gmail, Outlook).
3. **Variables Airflow configurées** :
   - Adresse email de l'expéditeur (`email_from`).
   - Adresse email du destinataire (`email_to`).

---

### **Étape 1 : Configuration de l’Envoi d’Emails**

#### Configuration SMTP dans Airflow
Ajoutez ou modifiez les paramètres suivants dans votre fichier `airflow.cfg` :

```ini
[email]
email_backend = airflow.utils.email.send_email_smtp
smtp_host = smtp.gmail.com
smtp_starttls = True
smtp_ssl = False
smtp_user = votreadresse@gmail.com
smtp_password = votremotdepasse
smtp_port = 587
```

> **Note** : Si vous utilisez Gmail, vous devrez peut-être activer **l'accès pour les applications moins sécurisées** dans votre compte Google ou utiliser un **mot de passe d'application**.

---

### **Étape 2 : Créer un DAG Airflow**

Créez un fichier Python, par exemple `email_monitoring_dag.py`, dans le dossier `dags/`.

#### Code du DAG
```python
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from airflow.utils.email import send_email

import random

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': ['votreadresse@gmail.com'],  # Email en cas d'échec
    'email_on_retry': False,
    'retries': 1,
}

def monitoring_task():
    """
    Simule une tâche de surveillance. Renvoie une exception aléatoirement pour tester les alertes.
    """
    result = random.choice([True, False])  # Simulation de réussite ou d'échec
    if not result:
        raise ValueError("Erreur détectée dans le processus de surveillance !")
    return "Surveillance réussie !"

def send_alert_email(**context):
    """
    Envoie un email avec des détails du processus en cas de succès.
    """
    subject = "Rapport de Surveillance - Succès"
    body = f"""
    Bonjour,<br><br>
    La tâche de surveillance s'est exécutée avec succès.<br>
    Détails : {context}<br><br>
    Cordialement,<br>
    Votre équipe Airflow.
    """
    send_email(to=['destinataire@example.com'], subject=subject, html_content=body)

with DAG(
    'email_monitoring',
    default_args=default_args,
    description='DAG de surveillance avec alertes par email',
    schedule_interval='@daily',
    start_date=days_ago(1),
    catchup=False,
) as dag:

    # Tâche principale de surveillance
    monitor = PythonOperator(
        task_id='monitor_task',
        python_callable=monitoring_task,
    )

    # Tâche pour envoyer un email de succès
    send_email_task = PythonOperator(
        task_id='send_success_email',
        python_callable=send_alert_email,
        provide_context=True,
    )

    monitor >> send_email_task
```

---

### **Étape 3 : Déployer et Tester le DAG**

1. **Ajoutez le DAG** dans votre dossier Airflow `dags`.
2. **Redémarrez Airflow** si nécessaire :
   ```bash
   airflow webserver --daemon
   airflow scheduler --daemon
   ```
3. **Accédez à l’interface Airflow** :
   - Activez le DAG `email_monitoring`.
   - Lancez-le manuellement ou attendez son exécution automatique.

---

### **Résultats Attendus**

1. **En cas de réussite** :
   - La tâche `send_success_email` s’exécute et envoie un email au destinataire spécifié.
   - Vous recevez un email comme suit :
     ```
     Sujet : Rapport de Surveillance - Succès
     Corps : La tâche de surveillance s'est exécutée avec succès.
     ```

2. **En cas d’échec** :
   - Une alerte automatique est envoyée à l’email spécifié dans `email_on_failure`.

---

### **Étape 4 : Améliorations Possibles**

1. **Surveillance Réelle** :
   - Remplacez la simulation dans `monitoring_task` par une tâche réelle, comme :
     - Vérification d’une base de données.
     - Validation de fichiers dans un répertoire.
     - Appel à une API.

2. **Personnalisation des Emails** :
   - Ajoutez des pièces jointes (par exemple, des rapports).
   - Personnalisez le contenu des emails en fonction des résultats.

3. **Ajout de Notifications pour Toutes les Tâches** :
   - Configurez des notifications pour chaque étape critique du DAG.

---

### **Exercice Final**
- Adaptez ce TP pour surveiller un fichier spécifique dans un répertoire et envoyer une alerte s’il est manquant.
