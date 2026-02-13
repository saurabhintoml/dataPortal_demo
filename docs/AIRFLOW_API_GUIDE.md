# Airflow API Guide

This guide shows how to interact with the Airflow API at `https://airflow.portal.getzingle.com`.

## Authentication

Airflow API uses **Basic Authentication**:

- **Username**: `airflow`
- **Password**: `airflow`

### Using curl

```bash
curl -u airflow:airflow https://airflow.portal.getzingle.com/api/v1/...
```

### Using Python requests

```python
import requests
from requests.auth import HTTPBasicAuth

auth = HTTPBasicAuth('airflow', 'airflow')
response = requests.get('https://airflow.portal.getzingle.com/api/v1/...', auth=auth)
```

## Common API Endpoints

### 1. Health Check

Check if Airflow is running:

```bash
# No authentication needed
curl -k https://airflow.portal.getzingle.com/api/v1/health
```

**Response:**
```json
{
  "dag_processor": {...},
  "metadatabase": {"status": "healthy"},
  "scheduler": {"status": "healthy"},
  "triggerer": {...}
}
```

### 2. Get Airflow Version

```bash
curl -k -u airflow:airflow \
  https://airflow.portal.getzingle.com/api/v1/version
```

**Response:**
```json
{
  "version": "2.9.3+astro.13",
  "git_version": "..."
}
```

### 3. List All DAGs

```bash
curl -k -u airflow:airflow \
  https://airflow.portal.getzingle.com/api/v1/dags
```

**Response:**
```json
{
  "dags": [
    {
      "dag_id": "dbt_jaffle_shop",
      "is_active": true,
      "is_paused": false,
      ...
    }
  ],
  "total_entries": 1
}
```

### 4. Get Specific DAG

```bash
curl -k -u airflow:airflow \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop
```

### 5. Trigger a DAG Run

**Start a new DAG run:**

```bash
curl -X POST \
  -k -u airflow:airflow \
  -H "Content-Type: application/json" \
  -d '{"conf": {}}' \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns
```

**With configuration:**

```bash
curl -X POST \
  -k -u airflow:airflow \
  -H "Content-Type: application/json" \
  -d '{
    "dag_run_id": "manual_trigger_2026-02-03",
    "conf": {
      "custom_param": "value"
    }
  }' \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns
```

### 6. Get DAG Runs

List all runs for a DAG:

```bash
curl -k -u airflow:airflow \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns
```

### 7. Get Specific DAG Run

```bash
curl -k -u airflow:airflow \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns/manual__2026-02-03T17:48:13.864951+00:00
```

### 8. Get Task Instances

Get all task instances for a DAG run:

```bash
curl -k -u airflow:airflow \
  "https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns/manual__2026-02-03T17:48:13.864951+00:00/taskInstances"
```

### 9. Get Task Instance Logs

```bash
curl -k -u airflow:airflow \
  "https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns/manual__2026-02-03T17:48:13.864951+00:00/taskInstances/generate_dbt_profiles/logs/1"
```

### 10. Pause/Unpause a DAG

**Pause:**
```bash
curl -X PATCH \
  -k -u airflow:airflow \
  -H "Content-Type: application/json" \
  -d '{"is_paused": true}' \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop
```

**Unpause:**
```bash
curl -X PATCH \
  -k -u airflow:airflow \
  -H "Content-Type: application/json" \
  -d '{"is_paused": false}' \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop
```

### 11. Delete a DAG Run

```bash
curl -X DELETE \
  -k -u airflow:airflow \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns/manual__2026-02-03T17:48:13.864951+00:00
```

## Python Examples

### Complete Python Script

```python
import requests
from requests.auth import HTTPBasicAuth
import json
from datetime import datetime

# Configuration
AIRFLOW_URL = "https://airflow.portal.getzingle.com"
USERNAME = "airflow"
PASSWORD = "airflow"
DAG_ID = "dbt_jaffle_shop"

# Authentication
auth = HTTPBasicAuth(USERNAME, PASSWORD)
headers = {"Content-Type": "application/json"}

# 1. Check health
def check_health():
    response = requests.get(f"{AIRFLOW_URL}/api/v1/health", verify=False)
    print("Health:", response.json())
    return response.json()

# 2. List DAGs
def list_dags():
    response = requests.get(
        f"{AIRFLOW_URL}/api/v1/dags",
        auth=auth,
        verify=False
    )
    dags = response.json()
    print(f"Found {dags['total_entries']} DAGs")
    for dag in dags['dags']:
        print(f"  - {dag['dag_id']} (paused: {dag['is_paused']})")
    return dags

# 3. Get DAG details
def get_dag(dag_id):
    response = requests.get(
        f"{AIRFLOW_URL}/api/v1/dags/{dag_id}",
        auth=auth,
        verify=False
    )
    dag = response.json()
    print(f"DAG: {dag['dag_id']}")
    print(f"  Active: {dag['is_active']}")
    print(f"  Paused: {dag['is_paused']}")
    return dag

# 4. Trigger DAG
def trigger_dag(dag_id, conf=None):
    payload = {
        "dag_run_id": f"api_trigger_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        "conf": conf or {}
    }
    response = requests.post(
        f"{AIRFLOW_URL}/api/v1/dags/{dag_id}/dagRuns",
        auth=auth,
        headers=headers,
        json=payload,
        verify=False
    )
    if response.status_code == 200:
        print(f"Successfully triggered DAG: {dag_id}")
        print(f"DAG Run ID: {response.json()['dag_run_id']}")
    else:
        print(f"Error: {response.status_code} - {response.text}")
    return response.json()

# 5. Get DAG runs
def get_dag_runs(dag_id, limit=10):
    response = requests.get(
        f"{AIRFLOW_URL}/api/v1/dags/{dag_id}/dagRuns?limit={limit}",
        auth=auth,
        verify=False
    )
    runs = response.json()
    print(f"\nRecent DAG runs for {dag_id}:")
    for run in runs['dag_runs']:
        print(f"  - {run['dag_run_id']}: {run['state']} ({run['start_date']})")
    return runs

# 6. Get task instance status
def get_task_status(dag_id, dag_run_id, task_id):
    response = requests.get(
        f"{AIRFLOW_URL}/api/v1/dags/{dag_id}/dagRuns/{dag_run_id}/taskInstances/{task_id}",
        auth=auth,
        verify=False
    )
    task = response.json()
    print(f"Task: {task_id}")
    print(f"  State: {task['state']}")
    print(f"  Start: {task.get('start_date')}")
    print(f"  End: {task.get('end_date')}")
    return task

# 7. Get task logs
def get_task_logs(dag_id, dag_run_id, task_id, try_number=1):
    response = requests.get(
        f"{AIRFLOW_URL}/api/v1/dags/{dag_id}/dagRuns/{dag_run_id}/taskInstances/{task_id}/logs/{try_number}",
        auth=auth,
        verify=False
    )
    logs = response.json()
    print(f"\nLogs for {task_id}:")
    print(logs.get('content', ''))
    return logs

# 8. Pause/Unpause DAG
def set_dag_pause(dag_id, is_paused):
    response = requests.patch(
        f"{AIRFLOW_URL}/api/v1/dags/{dag_id}",
        auth=auth,
        headers=headers,
        json={"is_paused": is_paused},
        verify=False
    )
    status = "paused" if is_paused else "unpaused"
    print(f"DAG {dag_id} {status}")
    return response.json()

# Example usage
if __name__ == "__main__":
    # Check health
    check_health()
    
    # List DAGs
    list_dags()
    
    # Get DAG details
    get_dag(DAG_ID)
    
    # Trigger DAG
    result = trigger_dag(DAG_ID)
    dag_run_id = result['dag_run_id']
    
    # Get DAG runs
    get_dag_runs(DAG_ID)
    
    # Get task status
    get_task_status(DAG_ID, dag_run_id, "generate_dbt_profiles")
```

## JavaScript/Node.js Example

```javascript
const axios = require('axios');
const https = require('https');

const AIRFLOW_URL = 'https://airflow.portal.getzingle.com';
const USERNAME = 'airflow';
const PASSWORD = 'airflow';

// Configure axios to ignore SSL verification (for self-signed certs)
const httpsAgent = new https.Agent({
  rejectUnauthorized: false
});

const auth = {
  username: USERNAME,
  password: PASSWORD
};

// Trigger DAG
async function triggerDAG(dagId) {
  try {
    const response = await axios.post(
      `${AIRFLOW_URL}/api/v1/dags/${dagId}/dagRuns`,
      {
        dag_run_id: `api_trigger_${Date.now()}`,
        conf: {}
      },
      {
        auth: auth,
        httpsAgent: httpsAgent
      }
    );
    console.log('DAG triggered:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Get DAG runs
async function getDAGRuns(dagId) {
  try {
    const response = await axios.get(
      `${AIRFLOW_URL}/api/v1/dags/${dagId}/dagRuns`,
      {
        auth: auth,
        httpsAgent: httpsAgent
      }
    );
    console.log('DAG runs:', response.data);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Usage
triggerDAG('dbt_jaffle_shop');
```

## Common Use Cases

### 1. Monitor DAG Status

```bash
#!/bin/bash
DAG_ID="dbt_jaffle_shop"

# Get latest DAG run
curl -s -k -u airflow:airflow \
  "https://airflow.portal.getzingle.com/api/v1/dags/${DAG_ID}/dagRuns?limit=1" \
  | jq -r '.dag_runs[0] | "\(.dag_run_id): \(.state)"'
```

### 2. Wait for DAG Completion

```python
import time
import requests
from requests.auth import HTTPBasicAuth

def wait_for_dag_completion(dag_id, dag_run_id, timeout=3600):
    auth = HTTPBasicAuth('airflow', 'airflow')
    start_time = time.time()
    
    while time.time() - start_time < timeout:
        response = requests.get(
            f"https://airflow.portal.getzingle.com/api/v1/dags/{dag_id}/dagRuns/{dag_run_id}",
            auth=auth,
            verify=False
        )
        dag_run = response.json()
        state = dag_run['state']
        
        if state in ['success', 'failed']:
            return state
        
        print(f"DAG run {dag_run_id} is {state}...")
        time.sleep(10)
    
    return "timeout"
```

### 3. Get Failed Tasks

```bash
DAG_ID="dbt_jaffle_shop"
DAG_RUN_ID="manual__2026-02-03T17:48:13.864951+00:00"

curl -s -k -u airflow:airflow \
  "https://airflow.portal.getzingle.com/api/v1/dags/${DAG_ID}/dagRuns/${DAG_RUN_ID}/taskInstances" \
  | jq '.task_instances[] | select(.state == "failed") | {task_id: .task_id, state: .state}'
```

## API Response Codes

- `200` - Success
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (wrong credentials)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (DAG/task doesn't exist)
- `409` - Conflict (e.g., DAG run already exists)

## Full API Documentation

For complete API documentation, visit:
- Airflow REST API: https://airflow.apache.org/docs/apache-airflow/stable/stable-rest-api-ref.html
- Or check your Airflow instance: `https://airflow.portal.getzingle.com/api/v1/ui/`

## Quick Reference

```bash
# Health check
curl -k https://airflow.portal.getzingle.com/api/v1/health

# List DAGs
curl -k -u airflow:airflow https://airflow.portal.getzingle.com/api/v1/dags

# Trigger DAG
curl -X POST -k -u airflow:airflow \
  -H "Content-Type: application/json" \
  -d '{"conf": {}}' \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns

# Get DAG runs
curl -k -u airflow:airflow \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop/dagRuns

# Pause DAG
curl -X PATCH -k -u airflow:airflow \
  -H "Content-Type: application/json" \
  -d '{"is_paused": true}' \
  https://airflow.portal.getzingle.com/api/v1/dags/dbt_jaffle_shop
```
