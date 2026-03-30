# Docker-Recipes

[🇺🇸 English](README.md) | 🇨🇳 中文

🐳 即开即用的 docker-compose 模板，快速启动常见服务。

## 🚀 快速开始

方式1：克隆整个目录，按需部署

```shell
git clone
cd Docker-Recipes
# 进入你想要部署的应用文件夹内，如 EasyNode
cd EasyNode
docker-compose up -d
```

方式2：按需克隆目录，然后部署

```shell
# 确保你的 Git 版本在 2.25 以上（建议 2.28+)
git --version
# 克隆仓库指定目录
git clone --filter=blob:none --sparse https://github.com/e-chocolate/Docker-Recipes.git
cd Docker-Recipes
git sparse-checkout set EasyNode
cd EasyNode
docker-compose up -d
```

# ⚠️ 免责声明

- 本项目提供的 Docker Compose 文件旨在快速启动服务，仅供研究使用。
- 不用做任何商业用途，请尊重所有镜像提供者的合法权益。
- 默认配置可能未开启安全加固（如默认密码、开放端口）。
- 使用前请务必修改 `.env` 中的敏感信息。
- 请根据实际网络环境调整端口映射和防火墙策略。
- 作者不对因使用本项目导致的任何数据丢失或安全漏洞承担责任。

> **请勿直接在生产环境中使用默认配置！**

# 索引

| 名称                                              | 功能简介                         | 最后更新                          |
| ------------------------------------------------- | -------------------------------- | --------------------------------- |
| [EasyNode](https://github.com/chaos-zhu/easynode) | 一个多功能Linux服务器WEB终端面板 | 2026-03-19                        |
| [Dify](https://dify.ai/)                          | 一个开源的 LLM 应用开发平台      | [2026-03-31](./Dify/README_CN.md) |
