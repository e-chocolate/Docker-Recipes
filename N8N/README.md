# n8n Docker Recipe

🇨🇳 [中文](README_CN.md) | 🇺🇸 English

This recipe provides a production-ready Docker Compose deployment for [n8n](https://n8n.io/), configured according to official guidelines:
- **n8n**: Workflow editor and orchestration engine (exposing port `5678`).
- **runners**: Standalone task runner for Code nodes (JavaScript / Python).
- **n8n Assistant Sandbox Stack** (`sandbox-certs`, `sandbox-api`, `sandbox-runner-1`): Safely executes AI-generated code inside DinD isolation.
- **SearXNG**: Privacy-respecting web search backend for the n8n Assistant.

---

## 💻 Requirements

- **Docker**: Docker Engine and Docker Compose v2 (`docker compose version`).
- **Hardware**: At least **4 GB RAM** and **2 vCPUs** (due to the privileged Docker-in-Docker sandbox runner).
- **Windows Users**: Use WSL2 and keep files within the Linux filesystem (`~/...`), not under `/mnt/c/...`.

---

## 🚀 Quick Start

### 1. Configure Environment

Copy the example environment variables:
```bash
cp .env.example .env
```
Open `.env` and replace all `change-me-*` placeholders with secure random strings.

### 2. Start Services

```bash
docker compose up -d
```

Verify service status:
```bash
docker compose ps
```
> **Note**: `sandbox-certs` will run once to generate certificates and exit normally. Once `sandbox-api` and `sandbox-runner-1` become healthy, `n8n` will be ready.

### 3. Verify & Access

- Verify n8n health:
  ```bash
  curl -sf http://localhost:5678/healthz
  ```
- Verify sandbox API connectivity:
  ```bash
  docker compose exec n8n wget -qO- http://sandbox-api:8080/healthz
  ```
- Open in browser: Navigate to **`http://localhost:5678`** (or your configured `N8N_HOST_PORT`) to complete setup.

---

## ⚙️ Optional Configuration

### Enable n8n Assistant
To use the n8n Assistant, configure your AI model in `.env` (DeepSeek example):
```dotenv
N8N_ENABLED_MODULES=instance-ai
N8N_INSTANCE_AI_MODEL=deepseek-flash
N8N_INSTANCE_AI_MODEL_URL=https://api.deepseek.com
N8N_INSTANCE_AI_MODEL_API_KEY=sk-your-key-here
```
Then restart n8n:
```bash
docker compose up -d n8n
```
*(You can also configure this directly in the n8n UI under **Settings -> AI Settings**.)*

---

## 🔒 Security Notes

1. **Port Exposure**: Only port `5678` (or your configured `N8N_HOST_PORT`) is mapped to the host. Never publish ports for internal services like `sandbox-runner-1`, `sandbox-api`, `runners`, or `searxng` to the public internet.
2. **Secrets**: Ensure all default credentials and tokens are changed before running in production.

