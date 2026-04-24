#!/bin/bash
set -e

echo "===== Updating System ====="
sudo apt update && apt upgrade -y

echo "===== Installing Base Packages ====="
sudo apt update
sudo apt install -y software-properties-common

sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update

# sudo apt install -y python3.9 python3.9-venv python3.9-dev

sudo apt install -y \
    python3.9 \
    python3.9-venv \
    python3.9-dev \
    python3-pip \
    nginx \
    git \
    unzip \
    curl \
    wget \
    build-essential \
    libpq-dev \
    postgresql-client \
    redis-tools \
    ruby-full

# --------------------------------------------------
echo "===== Creating Application User ====="
# id -u django &>/dev/null || useradd -m -s /bin/bash django
id -u django &>/dev/null || sudo useradd -m -s /bin/bash django
sudo mkdir -p /home/django/app
sudo mkdir -p /var/log/my-django-app
# mkdir -p /home/django/venv

sudo chmod o+rx /home/django
sudo chmod o+rx /home/django/app

sudo mkdir -p /home/django/app/celery_logs
sudo chown -R django:django /home/django/app/celery_logs

sudo chown -R django:django /home/django
sudo chown -R django:django /var/log/my-django-app

# --------------------------------------------------
echo "===== Create Base Virtualenv (EMPTY) ====="

sudo rm -rf /home/django/venv
sudo -u django python3.9 -m venv /home/django/venv

# --------------------------------------------------

echo "===== Installing AWS CLI ====="
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# --------------------------------------------------
echo "===== Install CodeDeploy Agent ====="
cd /home/ubuntu
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x install
sudo ./install auto

sudo systemctl enable codedeploy-agent
sudo systemctl start codedeploy-agent
sudo systemctl status codedeploy-agent
# --------------------------------------------------

echo "===== Installing CloudWatch Agent ====="
cd /tmp
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
    ## Manual Steps##
    # sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

    # sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl status amazon-cloudwatch-agent
# --------------------------------------------------

echo "===== Ensuring SSM Agent ====="
sudo snap install amazon-ssm-agent --classic || true
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

# --------------------------------------------------
echo "===== Gunicorn Service ====="

sudo tee /etc/systemd/system/gunicorn.service > /dev/null <<EOF
[Unit]
Description=Gunicorn daemon
After=network.target

[Service]
User=django
Group=www-data
WorkingDirectory=/home/django/app
EnvironmentFile=/etc/environment

# ensure socket dir exists
# ExecStartPre=/bin/mkdir -p /run
# ExecStartPre=/bin/chown django:www-data /run

# Create runtime dir safely
RuntimeDirectory=gunicorn
RuntimeDirectoryMode=0755

ExecStart=/home/django/venv/bin/gunicorn core.wsgi:application --workers 3 --bind unix:/run/gunicorn/gunicorn.sock

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# --------------------------------------------------
echo "===== Celery Service ====="
sudo tee /etc/systemd/system/celery.service > /dev/null <<EOF
[Unit]
Description=Celery Worker
After=network.target

[Service]
User=django
Group=django
WorkingDirectory=/home/django/app
EnvironmentFile=/etc/environment

ExecStart=/home/django/venv/bin/celery -A core worker --loglevel=info
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# --------------------------------------------------
echo "===== Celery Beat Service ====="
sudo tee /etc/systemd/system/celery-beat.service > /dev/null <<EOF
[Unit]
Description=Celery Beat
After=network.target

[Service]
User=django
Group=django
WorkingDirectory=/home/django/app
EnvironmentFile=/etc/environment

ExecStart=/home/django/venv/bin/celery -A core beat --loglevel=info
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# --------------------------------------------------
echo "===== Nginx Config ====="
sudo tee /etc/nginx/sites-available/django > /dev/null <<EOF
server {
    listen 80;

    location /static/ {
        alias /home/django/app/staticfiles/;
    }

    location / {
        proxy_pass http://unix:/run/gunicorn/gunicorn.sock;
        include proxy_params;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/django /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t

# --------------------------------------------------
echo "===== Enable services ====="

sudo systemctl daemon-reload
sudo systemctl enable nginx
sudo systemctl enable gunicorn
sudo systemctl enable celery
sudo systemctl enable celery-beat

echo "===== AMI READY ====="