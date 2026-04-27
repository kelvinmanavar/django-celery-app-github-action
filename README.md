# Scalable Multi-Tier AWS Architecture: Django, Celery Task Manager with CloudFormation & CI/CD (CodeDeploy, GitHub Actions)

This repository contains the Infrastructure as Code (IaC) and deployment scripts for a scalable, production-ready Django application. The setup utilizes a multi-tier architecture on AWS, automated via CloudFormation nested stacks and GitHub Actions.

# 🏗 Architecture Overview

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

## 🏗️ Basic Diagram

```text
                       Users
                        |
            Application Load Balancer (ALB)
                        |
        ---------------------------------------
        |                                     |
   EC2 (Django App)                  EC2 (Django App)
        |      |                        |      |
        |      +---- ElastiCache (Redis) -------+
        |            (Message Broker)          |
        |                   |                  |
        |            EC2 - Celery Workers            |
        |            (Background Tasks)        |
        |                   |                  |
        +----------- Amazon RDS (Postgres)-----+
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

## 🚀 Deployment Workflow

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

## Video Presentation

https://user-images.githubusercontent.com/51070104/195047490-8de6a109-837f-496e-a832-162aa71aee3a.mp4

<br />

## ✨ Code-base structure

The project is coded using a simple and intuitive structure presented below:

```bash
< PROJECT ROOT >
   |-- .github/
   |    |-- workflows/
   |        |-- deploy.yml
   |
   |-- Infrastructure-CF/
   |    |-- 0-root-stack.yaml
   |    |-- 1-vpc.yaml
   |    |-- 2-s3.yaml
   |    |-- 3-data-tier.yaml
   |    |-- 4-ssm.yaml
   |    |-- 5-app-deploy.yaml
   |
   |-- scripts/
   |    |-- create_env.sh
   |    |-- goldenAMI.sh
   |    |-- install.sh
   |    |-- start.sh
   |    |-- validate.sh
   |
   |-- celery_scripts/
   |    |-- check-db-health.py
   |    |-- check-disk-free.py
   |    |-- clean-database.py
   |
   |-- core/                               # Implements app configuration
   |    |-- settings.py                    # Defines Global Settings
   |    |-- wsgi.py                        # Start the app in production
   |    |-- urls.py                        # Define URLs served by all apps/nodes
   |    |-- celery.py
   |    |-- asgi.py
   |
   |-- apps/
   |    |
   |    |-- tasks/                         # Implements Celery LOGIC
   |    |    |-- views.py                  # Loads INDEX page for tasks
   |    |    |-- urls.py                   # Define Celery routes  
   |    |
   |    |-- home/                          # A simple app that serve HTML files
   |    |    |-- views.py                  # Serve HTML pages for authenticated users
   |    |    |-- urls.py                   # Define some super simple routes  
   |    |
   |    |-- authentication/                # Handles auth routes (login and register)
   |    |    |-- urls.py                   # Define authentication routes  
   |    |    |-- views.py                  # Handles login and registration  
   |    |    |-- forms.py                  # Define auth forms (login and register) 
   |    |
   |    |-- static/
   |    |    |-- <css, JS, images>         # CSS files, Javascripts files
   |    |
   |    |-- templates/                     # Templates used to render pages
   |         |-- includes/                 # HTML chunks and components
   |         |    |-- navigation.html      # Top menu component
   |         |    |-- sidebar.html         # Sidebar component
   |         |    |-- footer.html          # App Footer
   |         |    |-- scripts.html         # Scripts common to all pages
   |         |
   |         |-- layouts/                   # Master pages
   |         |    |-- base-fullscreen.html  # Used by Authentication pages
   |         |    |-- base.html             # Used by common pages
   |         |
   |         |-- accounts/                  # Authentication pages
   |         |    |-- login.html            # Login page
   |         |    |-- register.html         # Register page
   |         |
   |         |-- home/                      # UI Kit Pages
   |              |-- index.html            # Index page
   |              |-- 404-page.html         # 404 page
   |              |-- *.html                # All other pages
   |
   |-- requirements.txt                     # Development modules - SQLite storage
   |-- appspec.yml
   |-- docker-compose.yml
   |-- Dockerfile      
   |-- .env.example                                 # Inject Configuration via Environment
   |-- manage.py                            # Start the app - Django default start script
   |
   |-- ************************************************************************
```

<br />

---
**CREDIT**: 
Django Tasks Manager via `Celery` - Open-source starter RAW aplication code provided by **[AppSeed Generator](https://appseed.us/generator/)**.