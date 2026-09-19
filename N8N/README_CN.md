# n8n Docker 部署配方

[🇺🇸 English](README.md) | 🇨🇳 中文

本项目为 [n8n](https://n8n.io/) 的 Docker Compose 部署模板，基于官方推荐架构构建，包含：
- **n8n**：主工作流编辑器与编排服务（可对外暴露 `5678` 端口）。
- **runners**：独立运行 Code 节点（JavaScript / Python）的任务执行器。
- **n8n Assistant 沙箱安全栈**（`sandbox-certs`、`sandbox-api`、`sandbox-runner-1`）：通过 DinD 隔离安全执行 AI 生成的代码。
- **SearXNG**：为 n8n Assistant 提供本地隐私化联网搜索支持。

---

## 💻 环境与硬件要求

- **Docker**：Docker Engine 与 Docker Compose v2（可运行 `docker compose version` 检查）。
- **硬件配置**：至少 **4 GB 内存** 和 **2 vCPU**（沙箱 Runner 容器使用 Docker-in-Docker，需要充足的系统资源）。
- **Windows 用户**：请使用 WSL2，且务必将本项目保存在 WSL 的 Linux 文件系统（如 `~/...`）内，切勿存放在 Windows 挂载盘（如 `/mnt/c/...`）下。

---

## 🚀 快速启动

### 1. 准备配置文件

复制环境变量模板：
```bash
cp .env.example .env
```
使用 `openssl rand -hex 32` 分别生成随机值，替换 `.env` 中所有 `change-me-*`，并按需调整数据库密码与版本。

### 2. 启动服务

```bash
docker compose up -d
```

查看运行状态：
```bash
docker compose ps
```
> **提示**：启动时 `sandbox-certs` 容器会先运行生成 mTLS 证书并正常退出；随后 `sandbox-api` 与 `sandbox-runner-1` 变为 healthy 状态后，`n8n` 将自动就绪。

### 3. 验证与访问

- 检查 n8n 运行状态：
  ```bash
  curl -sf http://localhost:5678/healthz
  ```
- 检查沙箱 API 连通性：
  ```bash
  docker compose exec n8n wget -qO- http://sandbox-api:8080/healthz
  ```
- 访问 Web 界面：在浏览器中打开 **`http://localhost:5678`**（或你在 `.env` 中配置的 `N8N_HOST_PORT`）完成初始管理员账号设置。

---

## ⚙️ 可选配置

### 开启 n8n Assistant (AI 助手)
若需启用 n8n Assistant，可在 `.env` 中配置大语言模型信息（以 DeepSeek 为例）：
```dotenv
N8N_ENABLED_MODULES=instance-ai
N8N_INSTANCE_AI_MODEL=deepseek-flash
N8N_INSTANCE_AI_MODEL_URL=https://api.deepseek.com
N8N_INSTANCE_AI_MODEL_API_KEY=sk-your-key-here
```
然后启动/重载 n8n 服务：
```bash
docker compose up -d n8n
```
*(也可以在登录 Web 界面后，于左下角 **Settings -> AI Settings** 中直接配置)*

---

## 🔒 安全说明

1. **端口暴露**：仅 `5678` 端口（或自定义的 `N8N_HOST_PORT`）映射到宿主机，`sandbox-runner-1`（特权容器）、`sandbox-api`、`runners` 与 `searxng` 等内部服务严禁直接映射到公网。
2. **密钥强度**：上线前请确保 `.env` 中的所有密码和 Token 均为高强度随机字符串。

