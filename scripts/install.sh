#!/bin/bash
set -e

echo "===== Setting permissions ====="
chown -R django:django /home/django/app

cd /home/django/app

echo "===== Creating virtualenv ====="
python3 -m venv venv

echo "===== Activating venv ====="
source venv/bin/activate

echo "===== Installing dependencies ====="
pip install --upgrade pip
pip install -r requirements.txt

echo "===== Running migrations ====="
python manage.py migrate

echo "===== Collecting static ====="
python manage.py collectstatic --noinput