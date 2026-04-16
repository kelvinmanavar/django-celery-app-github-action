#!/bin/bash
set -e

echo "===== Fix ownership ====="
chown -R django:django /home/django/app

cd /home/django/app

# --------------------------------------------------
echo "===== Ensure virtualenv exists ====="

if [ ! -d "/home/django/venv" ]; then
    echo "Creating virtualenv..."
    sudo -u django python3.9 -m venv /home/django/venv
fi

sudo -u django /home/django/venv/bin/pip install --upgrade pip
sudo -u django /home/django/venv/bin/pip install --no-cache-dir -r requirements.txt

# --------------------------------------------------
echo "===== Django setup ====="

sudo -u django /home/django/venv/bin/python manage.py migrate
sudo -u django /home/django/venv/bin/python manage.py collectstatic --noinput
