# dags/example_dag.py
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from datetime import datetime

def print_hello():
    return 'Hello world!'

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2021, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1
}

with DAG('example_dag', default_args=default_args, schedule_interval='@daily') as dag:
    hello_task = PythonOperator(
        task_id='hello_task',
        python_callable=print_hello
    )

    create_table = PostgresOperator(
        task_id='create_table',
        postgres_conn_id='postgres_default',
        sql='''
        CREATE TABLE IF NOT EXISTS test (
            id SERIAL PRIMARY KEY,
            value VARCHAR(50)
        );
        '''
    )

    hello_task >> create_table
