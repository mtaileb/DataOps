#!/bin/bash

# Générer une clé SSH si elle n'existe pas
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Génération d'une clé SSH..."
    ssh-keygen -o
else
    echo "Clé SSH déjà existante."
fi

# Afficher la clé SSH publique
echo "Voici votre clé SSH publique (copiez-la pour la VM) :"
cat ~/.ssh/id_rsa.pub

# Connexion à la VM (remplacez <username> et <adresse_ip_publique_vm>)
echo "Connexion à la VM..."
ssh <username>@<adresse_ip_publique_vm> << 'EOF'
    # Installer Python
    sudo apt-get update
    sudo apt-get install -y python3.10 python3-pip python3.8-venv
    
    # Créer le dossier pour les environnements et entrer dans ce dossier
    mkdir -p ~/environments_folder
    cd ~/environments_folder
    
    # Créer un environnement virtuel
    pip3 install virtualenv
    python3 -m venv my_env
    source my_env/bin/activate
    
    # Installer MLflow dans l'environnement virtuel
    pip3 install mlflow
    
    # Créer le dossier pour le projet et le dossier du traqueur MLflow
    mkdir -p ~/environments_folder/project_folder/mlflow_tracker
    cd ~/environments_folder/project_folder
    
    # Lancer le serveur MLflow en arrière-plan
    mlflow server --backend-store-uri /home/<username>/environments_folder/project_folder --host 0.0.0.0 --port 5000 &
EOF

# Redirection du port pour accéder au serveur MLflow depuis la machine locale
echo "Configuration de la redirection de port pour le service MLflow..."
ssh -N -L 5000:localhost:5000 <username>@<adresse_ip_publique_vm> &

# Test de connexion au serveur MLflow
echo "Test de connexion au serveur MLflow..."
curl http://localhost:5000

# Connexion à la VM pour installer Jupyter Notebook et les bibliothèques nécessaires
ssh <username>@<adresse_ip_publique_vm> << 'EOF'
    # Activer l'environnement virtuel
    source ~/environments_folder/my_env/bin/activate
    
    # Installer Jupyter et les bibliothèques supplémentaires
    pip3 install jupyter ipykernel
    ipython kernel install --user --name=my_env
    pip install sklearn azure-common
    
    # Lancer Jupyter Notebook sur le port 1212
    jupyter notebook --no-browser --port=1212 &
EOF

# Redirection du port pour accéder à Jupyter Notebook depuis la machine locale
echo "Configuration de la redirection de port pour Jupyter Notebook..."
ssh -N -L 1212:localhost:1212 <username>@<adresse_ip_publique_vm> &
