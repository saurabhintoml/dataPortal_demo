# Airflow + dbt Deployment Guide

This document provides step-by-step instructions for deploying the Airflow + dbt pipeline.

## Quick Start

### 1. Start Airflow

```bash
cd airflow_dbt
export AIRFLOW_UID=50000
sudo docker-compose up -d --build
```

### 2. Access Airflow UI

- **URL**: https://airflow.portal.getzingle.com
- **Username**: `airflow`
- **Password**: `airflow`

### 3. Run the DAG

1. Navigate to the Airflow UI
2. Find the `dbt_jaffle_shop` DAG
3. Unpause it (toggle switch on the left)
4. Click the "Play" button to trigger it manually
5. Monitor execution in the Graph or Tree view

## Architecture

```
Internet
   ↓
Nginx (Port 80/443) → HTTPS with Let's Encrypt
   ↓
Airflow Webserver (127.0.0.1:8080)
   ↓
Airflow Scheduler
   ↓
dbt Tasks → Snowflake
```

## Components

### Docker Services

- **postgres**: Airflow metadata database
- **airflow-webserver**: Airflow web UI (bound to localhost:8080)
- **airflow-scheduler**: Airflow task scheduler
- **airflow-init**: Initialization service (runs once on startup)

### DAG Tasks

1. **generate_dbt_profiles**: Creates `profiles.yml` from environment variables
2. **dbt_seed**: Loads seed data into Snowflake
3. **dbt_run**: Executes dbt models
4. **dbt_test**: Runs dbt tests

## Configuration

### Snowflake Credentials

Credentials are configured in `docker-compose.yml` as environment variables:

```yaml
SNOWFLAKE_ACCOUNT: "KT95190.ap-south-1.aws"
SNOWFLAKE_USER: "DBT_USER"
SNOWFLAKE_PASSWORD: "DbtUser#2026!Secure"
SNOWFLAKE_ROLE: "DBT_ROLE"
SNOWFLAKE_WAREHOUSE: "DBT_WH"
SNOWFLAKE_DATABASE: "ANALYTICS"
SNOWFLAKE_SCHEMA: "STAGING"
```

### Airflow Configuration

- **Base URL**: `https://airflow.portal.getzingle.com` (set in docker-compose.yml)
- **Executor**: LocalExecutor
- **Database**: PostgreSQL (in Docker container)

## Maintenance

### View Logs

```bash
# All services
sudo docker-compose logs -f

# Specific service
sudo docker-compose logs -f airflow-scheduler
sudo docker-compose logs -f airflow-webserver
```

### Restart Services

```bash
# Restart all
sudo docker-compose restart

# Restart specific service
sudo docker-compose restart airflow-scheduler
```

### Stop Services

```bash
# Stop (keeps data)
sudo docker-compose down

# Stop and remove volumes (deletes database)
sudo docker-compose down -v
```

### Update DAGs

DAG files are mounted as volumes, so changes are automatically detected:
1. Edit DAG file in `dags/` directory
2. Airflow scheduler will auto-reload (usually within 30-60 seconds)
3. Or restart scheduler: `sudo docker-compose restart airflow-scheduler`

## Troubleshooting

### Permission Errors

If you see permission errors:
```bash
sudo docker exec -u root airflow_dbt_airflow-scheduler_1 \
  chown -R astro:astro /usr/local/airflow/dbt
```

### DAG Not Appearing

1. Check DAG syntax: `sudo docker exec airflow_dbt_airflow-scheduler_1 python -m py_compile /usr/local/airflow/dags/dbt_jaffle_shop_dag.py`
2. Check scheduler logs: `sudo docker-compose logs airflow-scheduler | grep -i error`
3. Restart scheduler: `sudo docker-compose restart airflow-scheduler`

### Database Connection Issues

1. Check postgres health: `sudo docker-compose ps postgres`
2. Check connection string in docker-compose.yml
3. Restart postgres: `sudo docker-compose restart postgres`

### Nginx Issues

1. Test Nginx config: `sudo nginx -t`
2. Check Nginx logs: `sudo tail -f /var/log/nginx/airflow_error.log`
3. Restart Nginx: `sudo systemctl restart nginx`

### SSL Certificate Renewal

Certbot is configured to auto-renew certificates. To manually renew:
```bash
sudo certbot renew
sudo systemctl reload nginx
```

## File Structure

```
airflow_dbt/
├── dags/
│   └── dbt_jaffle_shop_dag.py    # Main DAG file
├── dbt/
│   └── jaffle_shop/               # dbt project
│       ├── dbt_project.yml
│       ├── models/
│       ├── seeds/
│       └── ...
├── docker-compose.yml             # Docker services configuration
├── Dockerfile                     # Airflow image with dbt
├── requirements.txt               # Python dependencies
└── logs/                          # Airflow logs (mounted volume)
```

## Security Notes

- Airflow is bound to `127.0.0.1:8080` (localhost only)
- Nginx handles all external traffic
- HTTPS is enforced via Let's Encrypt
- Credentials are in docker-compose.yml (not encrypted - as per requirements)
- Default Airflow credentials should be changed in production

## Next Steps

1. Change default Airflow password
2. Set up proper backup strategy for PostgreSQL
3. Configure DAG scheduling as needed
4. Monitor Airflow metrics and logs
5. Set up alerts for failed DAG runs
