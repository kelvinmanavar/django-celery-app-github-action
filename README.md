# Scalable Multi-Tier AWS Architecture: Django, Celery Task Manager with CloudFormation & CI/CD (CodeDeploy, GitHub Actions)

This repository contains the Infrastructure as Code (IaC) and deployment scripts for a scalable, production-ready Django application. The setup utilizes a multi-tier architecture on AWS, automated via CloudFormation nested stacks and GitHub Actions.

## 🏗 Architecture Overview

The infrastructure is deployed in a custom VPC across multiple Availability Zones to ensure high availability and fault tolerance.

### 🧱 Architecture Layers

#### 🌐 Network Tier
- Custom **VPC** spanning multiple Availability Zones
- **Public Subnets** for internet-facing resources (ALB)
- **Private Subnets** for application servers
- **Isolated Subnets** for databases and Redis cache layers

#### ⚙️ Application Tier
- **Django** web application
- **Celery workers** for background processing
- Hosted on EC2 instances inside an Auto Scaling Group
- Uses a custom Golden AMI for consistent deployments

#### 🗄️ Data Tier
- **Amazon RDS (PostgreSQL)** for relational database
- **Amazon ElastiCache (Redis)** for caching and Celery broker

#### ⚖️ Load Balancing
- Application Load Balancer (ALB)
- Routes traffic to Django web instances
- Health checks enabled for high availability

#### 🔄 CI/CD Pipeline
- **GitHub Actions** for build and deployment automation
- **AWS CodeDeploy** for application deployment
- Secure authentication using **IAM OIDC** (no static credentials)

### 🗺️ Basic Diagram

```text
                         Users
                           |
              Application Load Balancer (ALB)
                           |
          +----------------+----------------+
          |                                 |
   EC2 (Django App)                  EC2 (Django App)
          |                                 |
          +----------------+----------------+
                           |
          +----------------+----------------+
          |                                 |
 ElastiCache (Redis)               Amazon RDS (PostgreSQL)
 (Celery message broker)           (Application database)
          |                                 |
          v                                 |
   EC2 (Celery Workers)                     |
   (Background tasks)  --------------------+
```

## 🛠 Tech Stack
- Framework: Django
- Task Queue: Celery
- Broker: Redis (ElastiCache)
- Database: PostgreSQL (RDS)
- IaC: AWS CloudFormation (Nested Stacks)
- CI/CD: GitHub Actions & AWS CodeDeploy
- SSM: Storing secrets

## 🚀 Deployment Guide
### 1. Prerequisites
- AWS CLI configured with appropriate permissions.
- An S3 bucket to host nested CloudFormation templates.
- A **Golden AMI** ID pre-loaded with:
    - Python 3.x, Nginx, Gunicorn.
    - Ensuring AWS SSM Agent.
    - Installing AWS CLI.
    - Installing CloudWatch Agent.
    - Install AWS CodeDeploy Agent
    - Project-specific system dependencies.
    - **Refer**: goldenAMI.sh file located at scripts directory in project code.

### 2. Infrastructure Provisioning
The deployment uses a Root Stack strategy. You must upload the nested templates to S3 bucket before launching the root stack.
- Upload all infrastructure related cloudformation stacks in to this source s3 bucket.
- **Refer** : cloudformation stacks are available at Infrastructure-CF directory at project code base.
- Deploy Root Stack: Use the AWS Console and create stack in cloudformation and Provide 0-root-stack.yaml S3 URLs and configure the child stacks (VPC, RDS, Redis, App) as parameters.

### 3. CI/CD Integration (GitHub Actions)
We use IAM OIDC to allow GitHub Actions to communicate with AWS without storing long-lived secret keys.
- OIDC Provider: Ensure token.actions.githubusercontent.com is configured in IAM.
- GitHub Secrets:
    - AWS_ROLE_TO_ASSUME: The ARN of the IAM role for GitHub Actions.
    - AWS_REGION: e.g., ap-south-1
    - S3_ARTIFACT_BUCKET: Bucket for application revisions.

### 🔁 Deployment Workflow

1. Code is pushed to GitHub repository
2. GitHub Actions workflow is triggered
3. OIDC authentication with AWS IAM
4. Build artifacts are created and stored in to artifact bucket in S3.
5. Deployment initiated via AWS CodeDeploy
6. CodeDeploy updates EC2 instances in the Auto Scaling Group

## 🔐 Security Best Practices

- No hardcoded AWS credentials
- IAM roles used for secure access
- Private subnets for application layer
- Isolated subnets for database and cache
- Secure CI/CD using OIDC

## 📈 Key Features

- ✅ High availability across multiple AZs  
- ✅ Auto Scaling for dynamic workloads  
- ✅ Background processing with Celery  
- ✅ Fully automated CI/CD pipeline  
- ✅ Infrastructure as Code (CloudFormation) 

## 📡 Monitoring & Troubleshooting

- Logs are located in to the custom cloudwatch log groups. 
- Metrics are available in to cloudwatch metrics.

## ✨ Code-base Structure

The project is coded using a simple and intuitive structure presented below:

```bash
< PROJECT ROOT >
   |-- .github/
   |    |-- workflows/
   |         |-- deploy.yml                 # GitHub Actions CI/CD workflow
   |
   |-- Infrastructure-CF/                  # CloudFormation nested stacks
   |    |-- 0-root-stack.yaml
   |    |-- 1-vpc.yaml
   |    |-- 2-s3.yaml
   |    |-- 3-data-tier.yaml
   |    |-- 4-ssm.yaml
   |    |-- 5-app-deploy.yaml
   |
   |-- scripts/                            # CodeDeploy hooks and AMI setup
   |    |-- create_env.sh
   |    |-- goldenAMI.sh
   |    |-- install.sh
   |    |-- start.sh
   |    |-- validate.sh
   |
   |-- celery_scripts/                     # Periodic Celery maintenance tasks
   |    |-- check-db-health.py
   |    |-- check-disk-free.py
   |    |-- clean-database.py
   |
   |-- nginx/
   |    |-- appseed-app.conf               # Nginx reverse-proxy config
   |
   |-- core/                               # App configuration
   |    |-- settings.py                    # Global settings
   |    |-- urls.py                        # URLs served by all apps
   |    |-- celery.py                      # Celery app definition
   |    |-- wsgi.py                        # Production entry point
   |    |-- asgi.py
   |
   |-- apps/
   |    |-- tasks/                         # Celery logic
   |    |    |-- views.py                  # Loads the tasks index page
   |    |    |-- urls.py                   # Celery routes
   |    |
   |    |-- home/                          # Serves HTML pages
   |    |    |-- views.py                  # Pages for authenticated users
   |    |    |-- urls.py
   |    |
   |    |-- authentication/                # Login and registration
   |    |    |-- views.py
   |    |    |-- urls.py
   |    |    |-- forms.py
   |    |
   |    |-- static/
   |    |    |-- assets/                   # CSS, JS, fonts, images
   |    |
   |    |-- templates/
   |         |-- includes/                 # Navigation, sidebar, footer, scripts
   |         |-- layouts/                  # base.html, base-fullscreen.html, base-rtl.html
   |         |-- accounts/                 # login.html, register.html
   |         |-- home/                     # UI kit pages (index, profile, tables, error pages)
   |         |-- tasks/                    # index.html for the tasks page
   |
   |-- appspec.yml                         # AWS CodeDeploy spec
   |-- Dockerfile
   |-- docker-compose.yml
   |-- gunicorn-cfg.py                     # Gunicorn configuration
   |-- env.sample                          # Sample environment variables
   |-- manage.py                           # Django management script
   |-- package.json
   |-- requirements.txt                    # Python dependencies
   |-- LOCALSETUP.md                       # Local setup guide
   |-- CHANGELOG.md
   |-- LICENSE.md
```

<br />

---
**CREDIT**: 
Django Tasks Manager via `Celery` - Open-source starter RAW aplication code provided by **[AppSeed Generator](https://appseed.us/generator/)**.