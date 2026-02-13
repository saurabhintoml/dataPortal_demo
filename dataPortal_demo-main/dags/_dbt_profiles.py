"""
Shared dbt profile generation for Airflow DAGs.
Writes profiles.yml with both jaffle_shop and snowflake (same Snowflake config)
so jaffle_shop and mattermost_analytics projects can use the same connection.
"""
import os

# Paths used by all dbt DAGs (must match docker-compose volume mount)
DBT_PROFILES_DIR = "/usr/local/airflow/dbt"

_PROFILES_TEMPLATE = """jaffle_shop:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{account}"
      user: "{user}"
      password: "{password}"
      role: "{role}"
      warehouse: "{warehouse}"
      database: "{database}"
      schema: "{schema}"
      threads: 4
      client_session_keep_alive: false
      query_tag: "dbt_airflow"

snowflake:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{account}"
      user: "{user}"
      password: "{password}"
      role: "{role}"
      warehouse: "{warehouse}"
      database: "{database}"
      schema: "{schema}"
      threads: 4
      client_session_keep_alive: false
      query_tag: "dbt_airflow"
"""


def generate_dbt_profiles(**context):
    """Generate dbt profiles.yml (jaffle_shop + snowflake) from Airflow Snowflake connection or env."""
    try:
        from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook

        hook = SnowflakeHook(snowflake_conn_id="snowflake_default")
        conn = hook.get_connection("snowflake_default")
        extra = conn.extra_dejson if conn.extra else {}
        password = (
            conn.password
            or extra.get("password")
            or os.environ.get("SNOWFLAKE_PASSWORD", "REPLACE_WITH_STRONG_PASSWORD")
        )
        account = conn.host or extra.get("account", os.environ.get("SNOWFLAKE_ACCOUNT", "KT95190.ap-south-1.aws"))
        user = conn.login or extra.get("user", os.environ.get("SNOWFLAKE_USER", "DBT_USER"))
        role = extra.get("role", os.environ.get("SNOWFLAKE_ROLE", "DBT_ROLE"))
        warehouse = extra.get("warehouse", os.environ.get("SNOWFLAKE_WAREHOUSE", "DBT_WH"))
        database = extra.get("database", os.environ.get("SNOWFLAKE_DATABASE", "ANALYTICS"))
        schema = conn.schema or extra.get("schema", os.environ.get("SNOWFLAKE_SCHEMA", "STAGING"))
    except Exception:
        account = os.environ.get("SNOWFLAKE_ACCOUNT", "KT95190.ap-south-1.aws")
        user = os.environ.get("SNOWFLAKE_USER", "DBT_USER")
        password = os.environ.get("SNOWFLAKE_PASSWORD", "DbtUser#2026!Secure")
        role = os.environ.get("SNOWFLAKE_ROLE", "DBT_ROLE")
        warehouse = os.environ.get("SNOWFLAKE_WAREHOUSE", "DBT_WH")
        database = os.environ.get("SNOWFLAKE_DATABASE", "ANALYTICS")
        schema = os.environ.get("SNOWFLAKE_SCHEMA", "STAGING")

    profiles_dir = os.environ.get("DBT_PROFILES_DIR", DBT_PROFILES_DIR)
    os.makedirs(profiles_dir, exist_ok=True)
    profiles_path = os.path.join(profiles_dir, "profiles.yml")
    content = _PROFILES_TEMPLATE.format(
        account=account,
        user=user,
        password=password,
        role=role,
        warehouse=warehouse,
        database=database,
        schema=schema,
    )
    with open(profiles_path, "w") as f:
        f.write(content)
    print(f"Generated dbt profiles.yml at: {profiles_path}")
    return profiles_path
