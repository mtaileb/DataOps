import pendulum

from airflow.decorators import dag, task
from airflow.operators.python import get_current_context

@dag(
    schedule="@daily",  # Planification quotidienne
    start_date=pendulum.datetime(2021, 1, 1, tz="UTC"),  # Date de début avec fuseau horaire UTC
    catchup=False,  # Désactive l'exécution des dates manquées
    tags=["example"],  # Tags pour identifier le DAG
    params={"foobar": "param_from_dag", "other_param": "from_dag"},  # Paramètres passés au DAG
)
def TP7_tutorial_taskflow_templates():
    """
    ### Documentation du tutoriel TaskFlow API
    Exemple de pipeline de données simple qui démontre l'utilisation
    des templates dans l'API TaskFlow.
    La documentation associée à ce tutoriel est disponible
    [ici](https://airflow.apache.org/docs/apache-airflow/stable/tutorial_taskflow_api.html)
    """
    @task(
        # Permet de lire les fichiers avec l'extension `.sql` et de
        # rendre les templates qu'ils contiennent.
        templates_exts=[".sql"],
    )
    def template_test(sql, test_var, data_interval_end):
        context = get_current_context()

        # Affichera...
        # select * from test_data
        # where 1=1
        #     and run_id = 'scheduled__2024-10-09T00:00:00+00:00'
        #     and something_else = 'param_from_task'
        print(f"sql: {sql}")

        # Affichera `scheduled__2024-10-09T00:00:00+00:00`
        print(f"test_var: {test_var}")

        # Affichera `2024-10-10 00:00:00+00:00`.
        # Notez que cette valeur n'a pas été transmise lors de l'appel de la tâche.
        # Elle a été passée automatiquement par le décorateur à partir du contexte.
        print(f"data_interval_end: {data_interval_end}")

        # Affichera...
        # run_id: scheduled__2024-10-09T00:00:00+00:00; params.other_param: from_dag
        template_str = "run_id: {{ run_id }}; params.other_param: {{ params.other_param }}"
        rendered_template = context["task"].render_template(
            template_str,
            context,
        )
        print(f"rendered template: {rendered_template}")

        # Affichera le dictionnaire complet du contexte
        print(f"context: {context}")
    template_test.override(
        # Sera fusionné avec le dictionnaire défini dans le DAG
        # et remplacera les paramètres existants.
        #
        # Doit être passé dans les paramètres du décorateur
        # via `.override()` et non dans la fonction de tâche elle-même.
        params={"foobar": "param_from_task"},
    )(
        sql="sql/test.sql",  # Chemin vers le fichier SQL utilisé comme template
        test_var="{{ run_id }}",  # Template pour le paramètre test_var
    )
TP7_tutorial_taskflow_templates()
