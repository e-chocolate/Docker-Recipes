# 简介

[🇺🇸 English](README.md) | 🇨🇳 中文

此文件夹中的文件包含自托管 dify 所需的必要文件，但并非适用于所有用户。

# 背景

在已经安装`Nginx`, `PostgreSQL`, `Redis`的宿主机上安装Dify，而不是通过 Docker 创建这些服务。

> 更多信息，查看[博客](https://blogs.echocolate.xyz/dify)

# 如何安装

```shell
git clone --filter=blob:none --sparse https://github.com/e-chocolate/Docker-Recipes.git
cd Docker-Recipes
git sparse-checkout set Dify
cd Dify

# 建议由启动 Dify 容器的用户运行以下脚本
./scripts/dify.sh
```

> 最后更新：2026-03-31
