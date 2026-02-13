# Astronomer Airflow image with dbt-snowflake
FROM quay.io/astronomer/astro-runtime:11.20.0

# requirements.txt is typically auto-installed by Astro base; install explicitly for dbt-snowflake
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Copy dbt project (Astronomer only copies dags/, include/, plugins/ by default)
COPY dbt/ /usr/local/airflow/dbt/

# Ensure astro user can write to target/, logs/ in all dbt projects
USER root
RUN mkdir -p /usr/local/airflow/dbt/target /usr/local/airflow/dbt/logs \
    && chown -R astro:astro /usr/local/airflow/dbt \
    && chmod -R 775 /usr/local/airflow/dbt
USER astro
