### **Étapes pour Mettre en Place l'Authentification dans Airflow**

L’authentification dans Airflow est essentielle pour sécuriser l’accès à l’interface web. Par défaut, Airflow n’active pas l’authentification. Voici les étapes pour configurer l'authentification.

---

### **1. Activer l’Authentification dans le Fichier `airflow.cfg`**
Modifiez le fichier `airflow.cfg` pour activer l'authentification.

#### a) Localisez le Fichier `airflow.cfg`
- Si vous utilisez une installation classique : Le fichier est souvent dans le répertoire `$AIRFLOW_HOME`.
- Si vous utilisez Docker : Il est souvent dans `/opt/airflow/airflow.cfg`.

#### b) Configurez le Backend d'Authentification
Dans la section `[webserver]`, modifiez les paramètres suivants :
```ini
[webserver]
auth_backend = airflow.auth.backends.password_auth
```

- **`auth_backend`** : Définit le système d'authentification utilisé. Ici, on active l'authentification basée sur un mot de passe.

---

### **2. Relancer les Services Airflow**
Après avoir modifié `airflow.cfg`, redémarrez le webserver et le scheduler pour appliquer les changements :
```bash
airflow webserver --daemon
airflow scheduler --daemon
```

---

### **3. Créer des Utilisateurs**
Avec l'authentification activée, vous devez créer des utilisateurs pour accéder à l'interface.

#### a) Utilisez la Commande `airflow users create`
Exécutez la commande suivante pour créer un utilisateur (ou alors utiliser l'UI du serveur web) :
```bash
airflow users create \
    --username admin \
    --firstname Airflow \
    --lastname Admin \
    --role Admin \
    --email admin@example.com \
    --password mypassword
```

- **`--username`** : Nom d'utilisateur.
- **`--role`** : Rôle de l'utilisateur (`Admin`, `User`, `Viewer` ou `Op`).
- **`--password`** : Mot de passe de l'utilisateur.

#### b) Créez d’Autres Utilisateurs
Répétez la commande ci-dessus pour créer des utilisateurs supplémentaires avec des rôles différents, selon vos besoins.

---

### **4. Comprendre les Rôles par Défaut**
Airflow utilise un système de contrôle d’accès basé sur les rôles (RBAC). Voici les rôles principaux :

- **Admin** : Accès complet à toutes les fonctionnalités.
- **User** : Peut visualiser et exécuter des DAGs.
- **Viewer** : Accès en lecture seule.
- **Op** : Accès limité pour exécuter des tâches.

---

### **5. Activer l’Interface RBAC (si ce n’est pas déjà fait)**
Airflow utilise RBAC pour gérer les permissions des utilisateurs.

Dans `airflow.cfg`, vérifiez que le paramètre suivant est activé :
```ini
[webserver]
rbac = True
```
Relancez les services Airflow après cette modification.
```bash
airflow webserver --daemon
airflow scheduler --daemon
```

---

### **6. Configuration Avancée : Authentification via LDAP ou OAuth**

#### a) Authentification LDAP
Pour utiliser un serveur LDAP, configurez `airflow.cfg` comme suit :
```ini
[webserver]
auth_backend = airflow.auth.backends.ldap_auth
```
Ajoutez les paramètres LDAP dans la section `[ldap]` :
```ini
[ldap]
uri = ldap://ldap.example.com
search_filter = (objectClass=person)
bind_user = cn=admin,dc=example,dc=com
bind_password = adminpassword
basedn = dc=example,dc=com
```

#### b) Authentification OAuth
Pour OAuth (par exemple, Google, GitHub) :
1. Installez le package OAuth :
   ```bash
   pip install apache-airflow[google_auth]
   ```
2. Modifiez le fichier `airflow.cfg` :
   ```ini
   [webserver]
   auth_backend = airflow.auth.backends.oauth
   ```

3. Configurez les variables OAuth (client ID, secret, etc.) dans votre environnement ou dans le fichier de configuration.

---

### **7. Tester l’Authentification**
1. Accédez à l’interface web Airflow (par défaut, `http://localhost:8080`).
2. Connectez-vous avec le nom d'utilisateur et le mot de passe créés précédemment.

---

### **8. Résolution des Problèmes**
- **Erreur : Mot de passe oublié ?**
  Recréez l'utilisateur via la commande `airflow users create`.
  
- **Erreur : Impossible de se connecter ?**
  Vérifiez que le backend d'authentification est correctement configuré dans `airflow.cfg`.
