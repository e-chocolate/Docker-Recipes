# Docker-Recipes

[🇨🇳 中文](README_CN.md) | 🇺🇸 English

🐳 Spin up your favorite stacks in seconds with these ready-to-run docker-compose recipes.

## 🚀 Quick Start

Clone the whole repo, then start the applications u need: 

```shell
git clone
cd Docker-Recipes
# change directory to specific application(e.g., EasyNode)
cd EasyNode
docker-compose up -d
```

Or just clone the applications that u need: 

```shell
# ensure the version of git is higher than 2.25(better 2.28+)
git --version
# clone specific directory
git clone --filter=blob:none --sparse https://github.com/e-chocolate/Docker-Recipes.git
cd Docker-Recipes
git sparse-checkout set EasyNode
cd EasyNode
docker-compose up -d
```

# ⚠️ Disclaimer

- The Docker Compose files in this project are provided for quick deployment, for learning purposes only.
- Commercial use is strictly prohibited; users shall respect the rights of the container image providers.
- Default configurations may not be secure (e.g., default credentials, exposed ports).
- It is imperative to modify all sensitive information in the `.env` file.
- Port mappings and firewall policies must be adjusted in accordance with the actual network environment.
- The author assumes no liability for any data loss or security issues arising from the configuration in this project.

> **Do not use default configurations directly in production environments!**

# Index

| Name                                              | Introduction                           |
| ------------------------------------------------- | -------------------------------------- |
| [EasyNode](https://github.com/chaos-zhu/easynode) | a multifunctional web terminal console |
