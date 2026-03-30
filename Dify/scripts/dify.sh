#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

INFO="\e[0;32m[INFO]\e[0m"
ERROR="\e[0;31m[ERROR]\e[0m"

determine_path() {
  Dify_Parent_PATH="$(dirname $0)/.."

  if [[ "$Dify_Parent_PATH" != /* ]]; then
    echo -e "${ERROR} ${Dify_Parent_PATH} 不是绝对路径，尝试获取绝对路径"
    Dify_Parent_PATH="$(pwd)/$(dirname $0)/.."
  fi

  if [[ "$Dify_Parent_PATH" == /* ]] && [[ -n "$Dify_Parent_PATH" ]]; then
    echo -e "${INFO} ${Dify_Parent_PATH}"
  else
    echo -e "${ERROR} 获取绝对路径失败"
    exit 1
  fi
  cd "${Dify_Parent_PATH}"
  Dify_Parent_PATH=$(pwd)
  cd -
}

enter_domain() {
  echo -en "\e[0;33mPlease enter the domain(default '$(hostname)'): \e[0m"
  read -r dify_domain
  [ -z "${dify_domain}" ] && dify_domain=$(hostname)
  echo -en "\e[0;33mPlease enter the PostgreSQL host domain(default '${dify_domain}'): \e[0m"
  read -r pg_host
  [ -z "${pg_host}" ] && pg_host="${dify_domain}"
  echo -en "\e[0;33mPlease enter the PostgreSQL host IP(default '127.0.0.1', aka host-gateway for Docker): \e[0m"
  read -r pg_ip
  [ -z "${pg_ip}" ] && pg_ip='host-gateway'
}

enter_path() {
  local dify_path=$(pwd)
  echo -en "\e[0;33mPlease enter the absolute installation path for Dify (default $dify_path): \e[0m"
  read -r dify_path
  [ -z "${dify_path}" ] && dify_path=$(pwd)
  if [[ "${dify_path}" != /* ]]; then
    echo -e "${ERROR} ${dify_path} 不是绝对路径"
    exit 1
  fi
  if [ "${dify_path}" = "${Dify_Parent_PATH}" ]; then
    echo -e "${ERROR} Cannot clone dify in '${dify_path}'"
    exit 1
  fi
  [ ! -d "${dify_path}" ] && mkdir -p "${dify_path}"
  cd "${dify_path}"
  [ $? -ne 0 ] && {
    echo -e "${ERROR} Invaild path."
    exit 1
  } || {
    echo -e "${INFO} Use $(pwd) as the Dify installation path."
  }
}

checkout_stable() {
  git clone --filter=blob:none --sparse https://github.com/langgenius/dify.git $(pwd)
  [ $? -ne 0 ] && return 1
  git sparse-checkout set docker
  [ $? -ne 0 ] && return 1
  echo -e "${INFO} Successfully clone Dify in '$(pwd)'"
}

delete() {
  # 启用匹配隐藏文件
  shopt -s dotglob nullglob

  for file in *; do
    [[ "$file" == "docker" ]] && continue
    
    echo "Deleting: $file"
    rm -rf "$file"
  done

  cd docker
  for file in *; do
    [[ "$file" == "docker-compose-template.yaml" ]] && continue
    [[ "$file" == ".env.example" ]] && continue
    [[ "$file" == "generate_docker_compose" ]] && continue
    [[ "$file" == "volumes" ]] && continue
    [[ "$file" == "ssrf_proxy" ]] && continue

    echo "Deleting: $file"
    rm -rf "$file"
  done

  # 恢复默认设置
  shopt -u dotglob
  cd ..
}

init() {
  local temp_path=$(tr -dc 'A-Za-z' < /dev/urandom | head -c 8)
  local parent_path=$(pwd | awk -F '/' '{print $NF}')
  mv "../${parent_path}" "../${temp_path}"
  mv "../${temp_path}/docker" "../${parent_path}"
  rm -rf "../${temp_path}"
  cd "../${parent_path}"
  cp -a .env.example .env
  mkdir database
  [ $? -ne 0 ] && {
    echo -e "${ERROR} Something wrong when copying schema files."
    exit 1
  }
  cp -a "${Dify_Parent_PATH}/database/"*data.pgsql ./database
  cp -a "${Dify_Parent_PATH}/database/"*sh ./database
  git init && git add .
  local_ip=$(curl -4 ifconfig.me)
  sed -i "s/^host=.*/host='${local_ip}'/g" ./database/schema.sh
  sed -i "s/^host=.*/host='${local_ip}'/g" ./database/drop.sh
  cat "${Dify_Parent_PATH}/docker-compose-template.yaml" > docker-compose-template.yaml
  cat "${Dify_Parent_PATH}/.env.example" > .env
  sed -i "s/dify.example.org/${dify_domain}/g" docker-compose-template.yaml
  sed -i "s/dify.example.org/${dify_domain}/g" .env
  sed -i "s#^WEB_API_CORS_ALLOW_ORIGINS=.*#WEB_API_CORS_ALLOW_ORIGINS=https://${dify_domain}#g" .env
  sed -i "s#^CONSOLE_CORS_ALLOW_ORIGINS=.*#CONSOLE_CORS_ALLOW_ORIGINS=https://${dify_domain}#g" .env
  sed -i "s/db.example.org/${pg_host}/g" docker-compose-template.yaml
  sed -i "s/db.example.org/${pg_host}/g" .env
  sed -i "s/^DB_HOST_IP.*$/DB_HOST_IP=${pg_ip}/g" .env
  sed -i "s/^SMTP_LOCAL_HOSTNAME=.*/SMTP_LOCAL_HOSTNAME=$(hostname -f)/g" .env
  sed -i 's/postgres/dify/g' "$(pwd)/database/dify_data.pgsql"
  sed -i 's/postgres/dify/g' "$(pwd)/database/dify_plugin_data.pgsql"
}

reminder() {
  cat <<EOF
Use the following commands to verify which default configurations have been modified:
cd $(pwd)
git diff docker-compose-template.yaml
git diff .env
EOF
  echo
  cat <<EOF
Before u starting Dify, check the following services. Ensure they are consistent with the .env file.:
1. Nginx
2. PostgreSQL (Checking $(pwd)/database/*.sh)
3. Redis
EOF
  echo
  cat <<EOF
If u think everything is fine, running the following commands to start Dify:
cd $(pwd)
./generate_docker_compose
docker compose up -d
docker compose ps
EOF
}

determine_path
enter_path
enter_domain
checkout_stable
[ $? -ne 0 ] && {
  echo -e "${ERROR} Something wrong occurred when cloning Dify, check the install path"
  exit 1
}
delete
init
reminder
