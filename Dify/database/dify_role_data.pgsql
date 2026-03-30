-- 创建用户
CREATE USER dify WITH PASSWORD '${db_password}';
-- 创建数据库并设置owner
CREATE DATABASE dify OWNER dify;
CREATE DATABASE dify_plugin OWNER dify;

\c dify
-- 回收默认的public schema权限
REVOKE ALL ON SCHEMA public FROM PUBLIC;
-- 给owner赋予 public schema 的所有权限，schema 只有 USAGE, CREATE 权限
GRANT USAGE ON SCHEMA public TO dify;
GRANT CREATE ON SCHEMA public TO dify;

\c dify_plugin
-- 回收默认的public schema权限
REVOKE ALL ON SCHEMA public FROM PUBLIC;
-- 给owner赋予 public schema 的所有权限，schema 只有 USAGE, CREATE 权限
GRANT USAGE ON SCHEMA public TO dify;
GRANT CREATE ON SCHEMA public TO dify;
