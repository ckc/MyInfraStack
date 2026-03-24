#!/usr/bin/env bash
set -euo pipefail

# 需要事先設定環境變數：
# BACKUP_DIR=/path/to/backups
# PGHOST=infra-postgres
# PGUSER=keycloak
# PGPASSWORD=REPLACE_DB_PASSWORD
# GPG_PASSPHRASE_FILE=/run/secrets/backup_pass
# S3_BUCKET=s3://your-bucket/path (或改成上傳到其他 storage)

TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
OUT="${BACKUP_DIR:-./backups}/keycloak-db-${TIMESTAMP}.sql.gz"
mkdir -p "$(dirname "$OUT")"

echo "Dumping DB to $OUT"
pg_dump -h "${PGHOST:-infra-postgres}" -U "${PGUSER:-keycloak}" keycloak | gzip > "$OUT"

echo "Encrypting backup"
gpg --batch --yes --passphrase-file "${GPG_PASSPHRASE_FILE}" --symmetric --cipher-algo AES256 "$OUT"

# 範例：上傳到 S3（需要 aws cli 與權限）
# aws s3 cp "${OUT}.gpg" "${S3_BUCKET}/"

echo "Backup completed: ${OUT}.gpg"
