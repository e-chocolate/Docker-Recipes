#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# 数据库版本
PostgreSQL_Ver_s='18'
# 数据库密码
DB_Root_Password='pg_password'
# dify 用户密码
# db_password=$(tr -dc 'A-Za-z0-9_+-' < /dev/urandom | head -c 12)
db_password='difyai123456'
# 数据库允许哪个IP连接，这个地方写运行Dify的服务器IP
host='0.0.0.0'

INFO="\e[0;32m[INFO]\e[0m"
ERROR="\e[0;31m[ERROR]\e[0m"

PostgreSQL_Bin=`which psql`' -h 127.0.0.1 -U postgres -d postgres'

Clean_EXIT_Status() {
  [ -s ~/.my.cnf ] && rm -f ~/.my.cnf
  [ -s /tmp/.mysql.tmp ] && rm -f /tmp/.mysql.tmp
  [ -s ~/.pgpass ] && rm -f ~/.pgpass
  [ -s /tmp/.pg.tmp ] && rm -f /tmp/.pg.tmp
  exit $1
}

determine_path() {
  PGSQL_Current_PATH="$(dirname $0)"

  if [[ "$PGSQL_Current_PATH" != /* ]]; then
    echo -e "${ERROR} ${PGSQL_Current_PATH} 不是绝对路径，尝试获取绝对路径"
    PGSQL_Current_PATH="$(pwd)/$(dirname $0)"
  fi

  if [[ "$PGSQL_Current_PATH" == /* ]] && [[ -n "$PGSQL_Current_PATH" ]]; then
    echo -e "${INFO} ${PGSQL_Current_PATH}"
  else
    echo -e "${ERROR} 获取绝对路径失败"
    exit 1
  fi
}

if [ $(id -u) != "0" ]; then
  echo "Error: You must be root to use this function!"
  Clean_EXIT_Status 1
fi

echo "127.0.0.1:5432:postgres:postgres:${DB_Root_Password}" > ~/.pgpass
chmod 600 ~/.pgpass

echo "127.0.0.1:5432:dify:postgres:${DB_Root_Password}" >> ~/.pgpass
echo "127.0.0.1:5432:dify_plugin:postgres:${DB_Root_Password}" >> ~/.pgpass

# printf "%-8s%-16s%-16s%-24s%s\n" 'host' "postgres" "dify" "${host}/32" 'scram-sha-256' >> "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"
printf "%-8s%-16s%-16s%-24s%s\n" 'hostssl' "postgres" "dify" "${host}/32" 'scram-sha-256' >> "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"
# printf "%-8s%-16s%-16s%-24s%s\n" 'host' "dify_plugin" "dify" "${host}/32" 'scram-sha-256' >> "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"
printf "%-8s%-16s%-16s%-24s%s\n" 'hostssl' "dify_plugin" "dify" "${host}/32" 'scram-sha-256' >> "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"
# printf "%-8s%-16s%-16s%-24s%s\n" 'host' "dify" "dify" "${host}/32" 'scram-sha-256' >> "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"
printf "%-8s%-16s%-16s%-24s%s\n" 'hostssl' "dify" "dify" "${host}/32" 'scram-sha-256' >> "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"
acl_rule='SELECT pg_reload_conf();'

cat >/tmp/.pg.tmp<<EOF
${acl_rule}
EOF

${PostgreSQL_Bin} -tf /tmp/.pg.tmp

if [ $? -eq 0 ]; then
  determine_path
  sql0="${PGSQL_Current_PATH}/dify_role_data.pgsql"
  [ -f "${sql0}" ] && {
    cat ${sql0} > /tmp/.pg.tmp
    sed -i "s/\${db_password}/${db_password}/g" /tmp/.pg.tmp
    ${PostgreSQL_Bin} -tf /tmp/.pg.tmp
  } || {
    echo -e "${ERROR}: Cannot create role dify"
    Clean_EXIT_Status 1
  }
  echo "127.0.0.1:5432:dify:dify:${db_password}" >> ~/.pgpass
  echo "127.0.0.1:5432:dify_plugin:dify:${db_password}" >> ~/.pgpass
  sql1="${PGSQL_Current_PATH}/dify_data.pgsql"
  sql2="${PGSQL_Current_PATH}/dify_plugin_data.pgsql"
  [ -f "${sql1}" ] && psql -h 127.0.0.1 -p 5432 -U dify -d dify < "${sql1}"
  [ -f "${sql2}" ] && psql -h 127.0.0.1 -p 5432 -U dify -d dify_plugin < "${sql2}"
fi

echo -e "\e[0;32mYour password\e[0m: ${db_password}"
Clean_EXIT_Status $?
