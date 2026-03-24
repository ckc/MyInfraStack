# 災難復原 (DR) 簡要手冊

## 目標
在 GitHub 或 GitLab 無法使用時，能從另一端快速還原整個 stack。

## 前提
- 最新加密備份在 S3 或 Release artifact
- 映像已推到 GHCR 與 GitLab Registry 或有 tarball

## 還原步驟（概要）
1. 從 GitLab clone repo： `git clone git@gitlab.com:ORG/stack.git`
2. 下載最近的加密備份並解密：
   `gpg --batch --yes --passphrase-file /run/secrets/backup_pass -o keycloak-db.sql.gz -d keycloak-db-...sql.gz.gpg`
3. 還原 DB：
   `gunzip -c keycloak-db.sql.gz | psql -h infra-postgres -U keycloak -d keycloak`
4. 啟動 docker-compose：
   `docker compose up -d`
5. 檢查 Keycloak 與 Caddy logs，驗證 openid config 與 login 流程。

## 測試與驗證
- 每月在隔離環境做一次完整還原測試。
- 定期比對 GitHub/GitLab commit hash。
