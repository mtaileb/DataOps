Voici quelques bonnes pratiques de nomenclature de DAGs dans Airflow:
- Mettre des noms exlicites par rapport à l'action du DAG
- Préciser le projet ou le domaine concerné
- Préciser la version si besoin (par exemple si plusieurs versions peuvent coexister)
- Préciser la fréquence du DAG 
- Pour toutes les recommendations ci-dessus, utiliser des termes ou mots-clés génériques (documentés dans un référentiel à la dispotion des créateurs de DAG) afin de pouvoir filtrer le(s) DAG concerné(s) via le moteur de recherche de l'UI

Exemples:

| Bons exemples                              | Mauvais exemples    |
|-------------------------------------------|---------------------|
| analytique_utilisateur_quotidien          | analytique          |
| reconciliation_financiere_mensuelle_v1    | rapport_mensuel     |
| analyse_campagne_marketing_hebdomadaire   | analyse_campagne    |
| ingestion_donnees_projetx_v2              | ingestion_v2        |
| sauvegarde_logs_horaire                   | sauvegarde          |



Voici un exemple de référentiel pour les termes ou mots-clés à utiliser dans la nomenclature des DAGs Airflow :

### Référentiel des mots-clés pour la nomenclature des DAGs Airflow

| **Catégorie**      | **Mots-clés recommandés**                                                                                       | **Exemples d'utilisation**                     |
|---------------------|----------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| **Fréquence**       | `daily`, `hourly`, `weekly`, `monthly`, `quarterly`, `yearly`                                                  | `daily_user_report`, `monthly_backup`         |
| **Action**          | `ingestion`, `transformation`, `aggregation`, `export`, `analysis`, `backup`, `monitoring`                    | `data_ingestion_sales`, `hourly_backup_logs`  |
| **Projet ou Domaine** | `finance`, `marketing`, `sales`, `inventory`, `hr`, `projectx`, `etl`                                        | `finance_reconciliation_v1`, `etl_pipeline`   |
| **Version**         | `v1`, `v2`, `final`, `test`                                                                                   | `ingestion_projectx_v2`, `backup_test`        |
| **Type de données** | `user`, `transaction`, `logs`, `metrics`, `campaign`, `report`                                                | `transaction_aggregation_daily`, `logs_backup`|
| **Région ou Zone**  | `eu`, `us`, `apac`, `global`, `region1`, `zone2`                                                              | `sales_report_eu`, `metrics_global`           |
| **Système ou outil**| `bigquery`, `s3`, `redshift`, `postgres`, `spark`                                                             | `s3_data_ingestion`, `redshift_export`        |

### Exemple d'application
1. **DAG pour l'ingestion quotidienne des données utilisateurs dans un projet marketing**  
   Nom : `daily_user_ingestion_marketing_v1`

2. **DAG pour une sauvegarde mensuelle des logs système à destination d'un cluster S3**  
   Nom : `monthly_logs_backup_s3_v2`

3. **DAG pour un rapport hebdomadaire des ventes en Europe**  
   Nom : `weekly_sales_report_eu`

Ce référentiel peut être partagé sous forme de documentation interne pour guider les équipes dans la création de noms standardisés et facilement filtrables.
