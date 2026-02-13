"""
Cosmos DAG for jaffle_shop dbt project.

Each model and its tests are separate tasks (AFTER_EACH). Run/retry/inspect
per model and test in the Airflow UI.

Prerequisites:
- Snowflake connection: conn_id="snowflake_default".
- dbt project at /usr/local/airflow/dbt.
"""
from datetime import datetime
from pathlib import Path

from cosmos import DbtDag, ProjectConfig, ProfileConfig, RenderConfig, ExecutionConfig
from cosmos.constants import LoadMode, ExecutionMode, TestBehavior
from cosmos.profiles.snowflake import SnowflakeUserPasswordProfileMapping

AIRFLOW_HOME = Path("/usr/local/airflow")
DBT_PROJECT_PATH = AIRFLOW_HOME / "dbt"

profile_config = ProfileConfig(
    profile_name="jaffle_shop",
    target_name="dev",
    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_default",
        profile_args={"schema": "STAGING", "database": "ANALYTICS", "warehouse": "DBT_WH", "role": "DBT_ROLE"},
    ),
)

render_config = RenderConfig(
    test_behavior=TestBehavior.AFTER_EACH,
    load_method=LoadMode.DBT_LS,
)

execution_config = ExecutionConfig(
    execution_mode=ExecutionMode.LOCAL,
    dbt_executable_path="dbt",
)

cosmos_jaffle_shop_dag = DbtDag(
    dag_id="cosmos_dbt_jaffle_shop",
    project_config=ProjectConfig(dbt_project_path=str(DBT_PROJECT_PATH)),
    profile_config=profile_config,
    render_config=render_config,
    execution_config=execution_config,
    schedule=None,
    start_date=datetime(2024, 1, 1),
    catchup=False,
    max_active_runs=1,
    tags=["cosmos", "dbt", "jaffle_shop", "snowflake"],
)
