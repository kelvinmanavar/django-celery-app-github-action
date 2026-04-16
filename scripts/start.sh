#!/bin/bash
set -e

source /etc/environment

echo "APP_ROLE = $APP_ROLE"

if [ "$APP_ROLE" = "web" ]; then
    echo "Starting WEB services..."

    # Stop celery if running
    systemctl stop celery || true
    systemctl stop celery-beat || true

    systemctl restart gunicorn
    sleep 6
    systemctl restart nginx

elif [ "$APP_ROLE" = "celery" ]; then
    echo "Starting CELERY services..."

    # Stop web services if running
    systemctl stop gunicorn || true
    systemctl stop nginx || true

    systemctl restart celery
    sleep 6
    systemctl restart celery-beat

else
    echo "Invalid APP_ROLE"
    exit 1
fi