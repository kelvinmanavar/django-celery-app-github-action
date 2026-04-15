#!/bin/bash
set -e

source /etc/environment

echo "APP_ROLE = $APP_ROLE"

if [ "$APP_ROLE" = "web" ]; then
    echo "Starting WEB services..."
    systemctl restart gunicorn
    systemctl restart nginx

elif [ "$APP_ROLE" = "celery" ]; then
    echo "Starting CELERY services..."
    systemctl restart celery
    systemctl restart celery-beat

else
    echo "Invalid APP_ROLE"
    exit 1
fi