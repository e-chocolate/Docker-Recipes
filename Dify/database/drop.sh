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

if [ $(id -u) != "0" ]; then
  echo "Error: You must be root to use this function!"
  Clean_EXIT_Status 1
fi

echo "127.0.0.1:5432:postgres:postgres:${DB_Root_Password}" > ~/.pgpass
chmod 600 ~/.pgpass

echo "127.0.0.1:5432:dify:postgres:${DB_Root_Password}" >> ~/.pgpass
echo "127.0.0.1:5432:dify_plugin:postgres:${DB_Root_Password}" >> ~/.pgpass

# 清理 pg_hba.conf（防止配置残留）
role_pattern=$(printf "%-16s%-16s" "postgres" "dify")
sed -i "/$role_pattern/d" "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"
role_pattern=$(printf "%-16s%-16s" "dify" "dify")
sed -i "/$role_pattern/d" "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"
role_pattern=$(printf "%-16s%-16s" "dify_plugin" "dify")
sed -i "/$role_pattern/d" "/etc/postgresql/${PostgreSQL_Ver_s}/main/pg_hba.conf"

# 删除用户并重载配置
cat > /tmp/.pg.tmp<<EOF
-- 终止数据库的所有活跃会话
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'dify' AND pid <> pg_backend_pid();
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'dify_plugin' AND pid <> pg_backend_pid();
-- 删除数据库
DROP DATABASE IF EXISTS dify;
DROP DATABASE IF EXISTS dify_plugin;
-- 删除专属用户（角色）在**所有数据库**中拥有的对象
DROP OWNED BY dify;
-- 删除专属用户
DROP USER IF EXISTS dify;
-- 重载配置
SELECT pg_reload_conf();
EOF

${PostgreSQL_Bin} -tf /tmp/.pg.tmp
Clean_EXIT_Status $?
