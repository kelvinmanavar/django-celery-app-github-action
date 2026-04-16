#!/bin/bash
set -e

echo "===== Generating .env from SSM ====="

ENV_FILE="/home/django/app/.env"
REGION="ap-south-1"

get_param() {
  aws ssm get-parameter \
    --name "$1" \
    --with-decryption \
    --region $REGION \
    --query "Parameter.Value" \
    --output text
}

cat <<EOT > $ENV_FILE
DEBUG=False

ALLOWED_HOSTS=$(get_param ALLOWED_HOSTS)
CSRF_TRUSTED_ORIGINS=$(get_param CSRF_TRUSTED_ORIGINS)

SECRET_KEY=$(get_param SECRET_KEY)

DB_ENGINE=postgres
DB_NAME=$(get_param DB_NAME)
DB_USERNAME=$(get_param DB_USERNAME)
DB_PASS=$(get_param DB_PASS)
DB_HOST=$(get_param DB_HOST)
DB_PORT=5432

CELERY_BROKER=$(get_param CELERY_BROKER)
EOT

chmod 600 $ENV_FILE
chown django:django $ENV_FILE

echo ".env created successfully"