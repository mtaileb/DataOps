from datetime import datetime
import pandas as pd
from airflow import Dataset
from airflow.decorators import task, dag
import os

# PENSEZ A APPLIQUER LES PERMISSIONS DE LECTURE ET D'ECRITURE POUR L'UTILISATEUR AIRFLOW AVANT DE LANCER CE SCRIPT: sudo chown 50000:0 output.csv titanic.csv

# Définition des datasets
TITANIC_DATASET = Dataset("titanic.csv")
OUTPUT_DATASET = Dataset("output.csv")

@dag(
    start_date=datetime(2023, 1, 1),
    schedule="0 * * * *",  # ← Toutes les heures à minute 0
    catchup=False,
    tags=["titanic", "producer"],
)
def titanic_producer():
    
    @task(outlets=[TITANIC_DATASET])
    def read_output_file():
        """Lit le fichier output.csv pour récupérer une nouvelle ligne"""
        output_path = "/opt/airflow/dags/output.csv"
        titanic_path = "/opt/airflow/dags/titanic.csv"
        
        # Vérifier si output.csv existe
        if not os.path.exists(output_path):
            print("Fichier output.csv non trouvé")
            return
        
        # Lire le fichier output
        try:
            output_df = pd.read_csv(output_path)
            if len(output_df) == 0:
                print("Aucune donnée dans output.csv")
                return
                
            # Prendre la première ligne
            new_row = output_df.iloc[0]
            
            # Lire le fichier titanic existant
            if os.path.exists(titanic_path):
                titanic_df = pd.read_csv(titanic_path)
            else:
                # Créer un dataframe vide avec les bonnes colonnes
                titanic_df = pd.DataFrame(columns=[
                    'PassengerId', 'Survived', 'Pclass', 'Name', 
                    'Sex', 'Age', 'SibSp', 'Parch', 'Ticket', 
                    'Fare', 'Cabin', 'Embarked'
                ])
            
            # Ajouter la nouvelle ligne
            titanic_df = pd.concat([titanic_df, pd.DataFrame([new_row])], 
                                 ignore_index=True)
            
            # Sauvegarder le nouveau fichier titanic
            titanic_df.to_csv(titanic_path, index=False)
            print(f"Nouvelle ligne ajoutée. Total des passagers: {len(titanic_df)}")
            
            # Supprimer la ligne traitée de output.csv
            output_df = output_df.iloc[1:]
            output_df.to_csv(output_path, index=False)
            
        except Exception as e:
            print(f"Erreur lors de la lecture/écriture: {e}")

    read_output_file()

@dag(
    start_date=datetime(2023, 1, 1),
    schedule=[TITANIC_DATASET],
    catchup=False,
    tags=["titanic", "consumer"],
)
def titanic_consumer():
    
    @task
    def calculate_statistics():
        """Calcule les statistiques de genre sur le fichier titanic.csv"""
        titanic_path = "/opt/airflow/data/titanic.csv"
        
        if not os.path.exists(titanic_path):
            print("Fichier titanic.csv non trouvé")
            return
        
        try:
            # Lire le fichier titanic
            df = pd.read_csv(titanic_path)
            
            if len(df) == 0:
                print("Aucune donnée dans titanic.csv")
                return
            
            # Calculer les statistiques de genre
            total_passengers = len(df)
            male_count = len(df[df['Sex'] == 'male'])
            female_count = len(df[df['Sex'] == 'female'])
            
            male_percentage = (male_count / total_passengers) * 100
            female_percentage = (female_count / total_passengers) * 100
            
            print("=" * 50)
            print("STATISTIQUES TITANIC - RÉPARTITION PAR GENRE")
            print("=" * 50)
            print(f"Total des passagers: {total_passengers}")
            print(f"Hommes/garçons: {male_count} ({male_percentage:.2f}%)")
            print(f"Femmes/filles: {female_count} ({female_percentage:.2f}%)")
            print("=" * 50)
            
            # Statistiques supplémentaires
            survivors = len(df[df['Survived'] == 1])
            survival_rate = (survivors / total_passengers) * 100
            print(f"Taux de survie global: {survival_rate:.2f}%")
            
            # Stats par classe
            for pclass in sorted(df['Pclass'].unique()):
                class_df = df[df['Pclass'] == pclass]
                class_total = len(class_df)
                class_survivors = len(class_df[class_df['Survived'] == 1])
                class_rate = (class_survivors / class_total) * 100 if class_total > 0 else 0
                print(f"Classe {pclass}: {class_survivors}/{class_total} survivants ({class_rate:.2f}%)")
            
        except Exception as e:
            print(f"Erreur lors du calcul des statistiques: {e}")

    calculate_statistics()

# Instanciation des DAGs
producer_dag = titanic_producer()
consumer_dag = titanic_consumer()
