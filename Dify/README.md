# Introduction

[🇨🇳 中文](README_CN.md) | 🇺🇸 English

The files in this folder contain the essential files for self-hosted dify, but may not be suitable for everyone.

# Background

Deploy Dify on a host where Nginx, PostgreSQL, and Redis are pre-installed, rather than provisioning these services via Docker.

> For more info, check the [blog](https://blogs.echocolate.xyz/dify)

# How to install

```shell
git clone --filter=blob:none --sparse https://github.com/e-chocolate/Docker-Recipes.git
cd Docker-Recipes
git sparse-checkout set Dify
cd Dify

# It is recommended to let the user who will launch the Dify Docker container run the following script.
./scripts/dify.sh
```

> Last Updated: 2026-03-31
