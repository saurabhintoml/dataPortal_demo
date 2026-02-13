Overview
========

Welcome to Astronomer! This project was generated after you ran 'astro dev init' using the Astronomer CLI. This readme describes the contents of the project, as well as how to run Apache Airflow on your local machine.

Documentation
=============

Additional guides are in the **docs/** folder:

- **docs/AIRFLOW_API_GUIDE.md** – Airflow REST API usage (curl, Python, Node.js)
- **docs/DBT_DEVELOPMENT.md** – dbt project development and workflow
- **docs/DEPLOYMENT.md** – Deployment and maintenance

Project Contents
================

Your Astro project contains the following files and folders:

- dags: This folder contains the Python files for your Airflow DAGs. By default, this directory includes one example DAG:
    - `example_astronauts`: This DAG shows a simple ETL pipeline example that queries the list of astronauts currently in space from the Open Notify API and prints a statement for each astronaut. The DAG uses the TaskFlow API to define tasks in Python, and dynamic task mapping to dynamically print a statement for each astronaut. For more on how this DAG works, see our [Getting started tutorial](https://www.astronomer.io/docs/learn/get-started-with-airflow).
- Dockerfile: This file contains a versioned Astro Runtime Docker image that provides a differentiated Airflow experience. If you want to execute other commands or overrides at runtime, specify them here.
- include: This folder contains any additional files that you want to include as part of your project. It is empty by default.
- packages.txt: Install OS-level packages needed for your project by adding them to this file. It is empty by default.
- requirements.txt: Install Python packages needed for your project by adding them to this file. It is empty by default.
- plugins: Add custom or community plugins for your project to this file. It is empty by default.
- airflow_settings.yaml: Use this local-only file to specify Airflow Connections, Variables, and Pools instead of entering them in the Airflow UI as you develop DAGs in this project.

Deploy Your Project Locally
===========================

Start Airflow on your local machine by running 'astro dev start'.

This command will spin up five Docker containers on your machine, each for a different Airflow component:

- Postgres: Airflow's Metadata Database
- Scheduler: The Airflow component responsible for monitoring and triggering tasks
- DAG Processor: The Airflow component responsible for parsing DAGs
- API Server: The Airflow component responsible for serving the Airflow UI and API
- Triggerer: The Airflow component responsible for triggering deferred tasks

When all five containers are ready the command will open the browser to the Airflow UI at http://localhost:8080/. You should also be able to access your Postgres Database at 'localhost:5432/postgres' with username 'postgres' and password 'postgres'.

Note: If you already have either of the above ports allocated, you can either [stop your existing Docker containers or change the port](https://www.astronomer.io/docs/astro/cli/troubleshoot-locally#ports-are-not-available-for-my-local-airflow-webserver).

**Avoid needing sudo for dags/dbt/logs/plugins:** Before `docker-compose up`, set `export AIRFLOW_UID=$(id -u)` so files created in those folders are owned by your user. Or run once: `sudo chown -R $(whoami):$(id -gn) dags dbt logs plugins`.

Deploy Your Project to Astronomer
=================================

If you have an Astronomer account, pushing code to a Deployment on Astronomer is simple. For deploying instructions, refer to Astronomer documentation: https://www.astronomer.io/docs/astro/deploy-code/

Local dbt environment (run dbt outside Docker)
==============================================

To run dbt locally (e.g. `dbt run --select tag:nightly` for mattermost-analytics):

1. **Prerequisites** (if needed):
   - Ubuntu/Debian: `sudo apt install python3-venv python3-pip`
   - macOS: Python 3 usually includes venv

2. **Create venv and install dbt + dbt-snowflake** (from this directory):
   ```bash
   ./scripts/setup_dbt_env.sh
   ```

3. **Activate and run**:
   ```bash
   source .venv/bin/activate
   cd dbt/mattermost-analytics
   export DBT_PROFILES_DIR="$(pwd)/.."   # so profiles.yml in dbt/ is used
   dbt run --select tag:nightly
   ```
   Or in one line from `airflow_dbt`:
   ```bash
   source .venv/bin/activate && cd dbt/mattermost-analytics && DBT_PROFILES_DIR="$PWD/.." dbt run --select tag:nightly
   ```

Profiles (Snowflake) are read from `dbt/profiles.yml`; use the same connection as in Airflow/docker-compose.

4. **If you see "Permission denied" on `logs/` or `target/`** (e.g. after cloning or when dbt dir was created by root):
   ```bash
   ./scripts/fix_dbt_permissions.sh
   ```
   Run once; it uses sudo to give your user ownership of `dbt/` so you never need sudo for dbt again.

5. **Cosmos DAGs (per-model / per-test):** The project uses [Astronomer Cosmos](https://github.com/astronomer/astronomer-cosmos) to expose dbt as Airflow DAGs where each model and its tests are separate tasks:
   - **cosmos_dbt_jaffle_shop** – jaffle_shop project
   - **cosmos_dbt_mattermost** – mattermost_analytics (filtered by `tag:utilities` and `tag:nightly` by default; edit `select` in the DAG to run all)
   Ensure the Snowflake connection `snowflake_default` exists in Airflow (Admin → Connections). Rebuild the image after adding `astronomer-cosmos[dbt-snowflake]` to `requirements.txt`.

6. **Mattermost-analytics dbt: "Insufficient privileges" or "TELEMETRY_DAYS does not exist"**
   - **Hook error:** The project’s `on-run-start` creates UDFs in the profile schema (e.g. STAGING). If your Snowflake role can’t `CREATE FUNCTION` there, set in `dbt/mattermost-analytics/dbt_project.yml` under `vars`: `skip_run_start_hooks: true` (already set for demo), or pass `--vars '{"skip_run_start_hooks": true}'`. To use the UDFs, grant the dbt role `CREATE` on that schema and set `skip_run_start_hooks: false`.
   - **Missing TELEMETRY_DAYS:** Build the date spine first, then other models:
     ```bash
     cd dbt/mattermost-analytics && DBT_PROFILES_DIR="$PWD/.."
     dbt run --select telemetry_days
     dbt run --select dim_date
     # or dbt run --select tag:nightly
     ```

Contact
=======

The Astronomer CLI is maintained with love by the Astronomer team. To report a bug or suggest a change, reach out to our support.
