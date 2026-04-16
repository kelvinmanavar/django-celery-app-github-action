#!/bin/bash
set -e

echo "===== Fix ownership ====="
chown -R django:django /home/django/app

cd /home/django/app

# --------------------------------------------------
echo "===== Ensure virtualenv exists ====="

if [ ! -d "/home/django/venv" ]; then
    echo "Creating virtualenv..."
    sudo -u django python3 -m venv /home/django/venv
fi

# --------------------------------------------------
echo "===== Activate virtualenv ====="
source /home/django/venv/bin/activate

# --------------------------------------------------
echo "===== Install dependencies ====="
pip install --upgrade pip
pip install --no-cache-dir -r requirements.txt

# --------------------------------------------------
echo "===== Django setup ====="
python manage.py migrate
python manage.py collectstatic --noinput