"""
DAG to run dbt jaffle_shop project: dbt seed, dbt run, dbt test.

Prerequisites:
1. Add Snowflake connection in Airflow UI:
   Admin → Connections → Add
   - Conn Id: snowflake_default
   - Conn Type: Snowflake
   - Account, User, Password, Role, Warehouse, Database, Schema

2. Or set environment variables (used when connection not configured):
   SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD,
   SNOWFLAKE_ROLE, SNOWFLAKE_WAREHOUSE, SNOWFLAKE_DATABASE, SNOWFLAKE_SCHEMA
"""
import os
import sys
from datetime import datetime, timedelta

_this_dir = os.path.dirname(os.path.abspath(__file__))
if _this_dir not in sys.path:
    sys.path.insert(0, _this_dir)

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

from _dbt_profiles import DBT_PROFILES_DIR, generate_dbt_profiles

DBT_PROJECT_DIR = "/usr/local/airflow/dbt"


default_args = {
    "depends_on_past": False,
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
    "start_date": datetime(2024, 1, 1, 0, 0, 0),
}

with DAG(
    dag_id="dbt_jaffle_shop",
    default_args=default_args,
    schedule_interval=None,  # Manual or cron: "0 2 * * *" for 2 AM daily
    catchup=False,
    max_active_runs=1,
    tags=["dbt", "jaffle_shop", "snowflake"],
) as dag:

    generate_profiles = PythonOperator(
        task_id="generate_dbt_profiles",
        python_callable=generate_dbt_profiles,
    )

    # Skip dbt deps - jaffle_shop has no external packages (packages: [])
    # dbt deps can fail with exit 2 in Airflow's subprocess context
    dbt_seed = BashOperator(
        task_id="dbt_seed",
        bash_command=f"cd {DBT_PROJECT_DIR} && export DBT_PROFILES_DIR={DBT_PROFILES_DIR} && dbt seed",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {DBT_PROJECT_DIR} && export DBT_PROFILES_DIR={DBT_PROFILES_DIR} && dbt run",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_PROJECT_DIR} && export DBT_PROFILES_DIR={DBT_PROFILES_DIR} && dbt test",
    )

    generate_profiles >> dbt_seed >> dbt_run >> dbt_test
