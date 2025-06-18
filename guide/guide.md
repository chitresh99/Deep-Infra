# Complete Infrastructure Engineer Learning Path

## What is Infrastructure Engineering?

Infrastructure engineers design, build, and maintain the systems that applications run on. They ensure applications are reliable, scalable, secure, and performant. Modern infra engineers work with cloud platforms, automation tools, and distributed systems.

**Key Responsibilities:**
- Design scalable and reliable systems
- Automate infrastructure provisioning and management
- Monitor and troubleshoot production systems
- Implement security and compliance measures
- Optimize costs and performance
- Enable developer productivity through tooling

---

## Learning Path Overview

### Phase 1: Foundation (2-3 months)
- Linux fundamentals
- Networking basics
- Version control (Git)
- Basic scripting

### Phase 2: Core Infrastructure (3-4 months)
- Cloud platforms (AWS/GCP/Azure)
- Infrastructure as Code
- Containerization (Docker/Kubernetes)
- CI/CD pipelines

### Phase 3: Advanced Topics (4-6 months)
- Monitoring and observability
- Security practices
- Database management
- Performance optimization

### Phase 4: Specialized Areas (Ongoing)
- Site Reliability Engineering
- Platform engineering
- Cost optimization
- Compliance and governance

---

## Phase 1: Foundation

### 1. Linux System Administration

**Essential Skills:**
```bash
# File system navigation and management
ls -la, cd, pwd, find, locate
cp, mv, rm, mkdir, rmdir
chmod, chown, chgrp

# Process management
ps aux, top, htop, kill, killall
nohup, screen, tmux
systemctl, service

# Text processing
grep, sed, awk, sort, uniq, cut
less, more, head, tail
vim/nano text editing

# Network tools
ping, curl, wget, nc
netstat, ss, iptables
ssh, scp, rsync

# System monitoring
df, du, free, iostat, vmstat
lsof, strace, tcpdump
```

**Learning Resources:**
- Practice with Linux VMs or WSL
- Complete "Linux Command Line Bootcamp" exercises
- Set up personal Linux server

### 2. Networking Fundamentals

**Core Concepts:**
- OSI Model and TCP/IP stack
- DNS, DHCP, HTTP/HTTPS
- Load balancing and reverse proxies
- VPNs and security groups
- Subnets, VLANs, routing

**Practical Skills:**
```bash
# DNS troubleshooting
dig google.com
nslookup domain.com
host -t MX domain.com

# Network connectivity
traceroute destination
mtr destination  # Better than traceroute
telnet host port

# SSL/TLS testing
openssl s_client -connect domain.com:443
curl -I https://domain.com
```

### 3. Version Control with Git

**Essential Commands:**
```bash
# Basic workflow
git init, git clone
git add, git commit, git push
git pull, git fetch, git merge

# Branching and collaboration
git branch, git checkout, git switch
git merge, git rebase
git log, git diff, git status

# Advanced operations
git stash, git cherry-pick
git reset, git revert
git bisect for debugging
```

### 4. Scripting Languages

**Bash Scripting:**
```bash
#!/bin/bash
# Variables and conditionals
NAME="infra-engineer"
if [ "$NAME" == "infra-engineer" ]; then
    echo "Welcome to infrastructure!"
fi

# Loops and functions
for server in web1 web2 web3; do
    ssh $server "systemctl status nginx"
done

function deploy_app() {
    local app_name=$1
    echo "Deploying $app_name"
    # Deployment logic here
}
```

**Python for Infrastructure:**
```python
# System administration
import subprocess, os, sys
import requests, json
import paramiko  # SSH connections
import boto3     # AWS SDK

# Example: Server health check
def check_server_health(servers):
    for server in servers:
        response = requests.get(f"http://{server}/health")
        if response.status_code == 200:
            print(f"{server}: OK")
        else:
            print(f"{server}: FAILED")
```

---

## Phase 2: Core Infrastructure

### 1. Cloud Platforms (Choose one to start: AWS recommended)

#### Amazon Web Services (AWS)

**Core Services to Master:**

**Compute:**
```bash
# EC2 (Virtual Machines)
aws ec2 describe-instances
aws ec2 run-instances --image-id ami-12345 --instance-type t3.micro
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Auto Scaling Groups
aws autoscaling create-auto-scaling-group
aws autoscaling update-auto-scaling-group
```

**Storage:**
```bash
# S3 (Object Storage)
aws s3 ls
aws s3 cp file.txt s3://bucket-name/
aws s3 sync ./local-folder s3://bucket-name/folder/

# EBS (Block Storage)
aws ec2 create-volume --size 100 --volume-type gp3
aws ec2 attach-volume --volume-id vol-12345 --instance-id i-12345
```

**Networking:**
```bash
# VPC (Virtual Private Cloud)
aws ec2 create-vpc --cidr-block 10.0.0.0/16
aws ec2 create-subnet --vpc-id vpc-12345 --cidr-block 10.0.1.0/24
aws ec2 create-internet-gateway
```

**Databases:**
```bash
# RDS (Relational Database Service)
aws rds create-db-instance --db-instance-identifier mydb
aws rds describe-db-instances
aws rds create-db-snapshot --db-snapshot-identifier snapshot1
```

**Learning Path:**
1. Complete AWS Cloud Practitioner certification
2. Build a 3-tier web application on AWS
3. Implement auto-scaling and load balancing
4. Set up monitoring with CloudWatch

### 2. Infrastructure as Code (IaC)

#### Terraform (Most Popular)

**Basic Concepts:**
```hcl
# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Resource definition
resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"
  
  tags = {
    Name = "WebServer"
    Environment = "production"
  }
}

# Variables
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 2
}

# Outputs
output "instance_ip" {
  value = aws_instance.web_server.public_ip
}
```

**Essential Commands:**
```bash
# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Format and validate
terraform fmt
terraform validate

# State management
terraform state list
terraform state show resource_name
terraform import resource.name resource_id
```

**Advanced Patterns:**
```hcl
# Modules for reusability
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block = "10.0.0.0/16"
  environment = "production"
}

# Data sources
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Conditional resources
resource "aws_instance" "web" {
  count = var.create_instance ? 1 : 0
  # ... other configuration
}
```

#### Alternative: AWS CloudFormation
```yaml
# CloudFormation template (YAML)
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Web server infrastructure'

Parameters:
  InstanceType:
    Type: String
    Default: t3.micro
    AllowedValues: [t3.micro, t3.small, t3.medium]

Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0c02fb55956c7d316
      InstanceType: !Ref InstanceType
      Tags:
        - Key: Name
          Value: WebServer

Outputs:
  InstanceId:
    Description: 'Instance ID of the web server'
    Value: !Ref WebServer
```

### 3. Containerization and Orchestration

#### Docker (You already know this!)
- Container fundamentals ✓
- Multi-stage builds ✓
- Docker Compose ✓

#### Kubernetes (Container Orchestration)

**Core Concepts:**
- **Pods**: Smallest deployable units
- **Services**: Network abstraction for pods
- **Deployments**: Manage pod replicas
- **ConfigMaps/Secrets**: Configuration management
- **Ingress**: External access to services
- **Namespaces**: Resource isolation

**Essential kubectl Commands:**
```bash
# Cluster info
kubectl cluster-info
kubectl get nodes

# Pod management
kubectl get pods
kubectl describe pod pod-name
kubectl logs pod-name
kubectl exec -it pod-name -- /bin/bash

# Deployments
kubectl create deployment nginx --image=nginx
kubectl get deployments
kubectl scale deployment nginx --replicas=3
kubectl rollout status deployment/nginx

# Services
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl get services

# Configuration
kubectl create configmap app-config --from-file=config.properties
kubectl create secret generic db-secret --from-literal=password=mysecret

# Apply manifests
kubectl apply -f deployment.yaml
kubectl delete -f deployment.yaml
```

**Example Kubernetes Manifests:**

**Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  labels:
    app: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

**Service:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
```

**Learning Path:**
1. Set up local Kubernetes (minikube/kind)
2. Deploy applications with different service types
3. Practice with ConfigMaps and Secrets
4. Learn Helm for package management
5. Explore managed Kubernetes (EKS/GKE/AKS)

### 4. CI/CD Pipelines

#### GitLab CI/CD Example:
```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

test:
  stage: test
  script:
    - npm install
    - npm test
  coverage: '/Coverage: \d+\.\d+%/'

build:
  stage: build
  script:
    - docker build -t $DOCKER_IMAGE .
    - docker push $DOCKER_IMAGE
  only:
    - main

deploy:
  stage: deploy
  script:
    - kubectl set image deployment/web-app web-app=$DOCKER_IMAGE
    - kubectl rollout status deployment/web-app
  environment:
    name: production
    url: https://myapp.com
  only:
    - main
```

#### GitHub Actions Example:
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2
    
    - name: Build Docker image
      run: |
        docker build -t myapp:latest .
        docker tag myapp:latest $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/myapp:latest
    
    - name: Push to ECR
      run: |
        aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com
        docker push $AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/myapp:latest
    
    - name: Deploy to ECS
      run: |
        aws ecs update-service --cluster production --service myapp --force-new-deployment
```

---

## Phase 3: Advanced Topics

### 1. Monitoring and Observability

#### The Three Pillars:
1. **Metrics**: Numerical measurements over time
2. **Logs**: Detailed event records
3. **Traces**: Request flow through distributed systems

#### Prometheus + Grafana Stack:

**Prometheus Configuration:**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'web-servers'
    static_configs:
      - targets: ['web1:8080', 'web2:8080']
  
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
```

**Common Metrics to Monitor:**
```promql
# CPU usage
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

# HTTP request rate
rate(http_requests_total[5m])

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Response time percentiles
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

#### ELK Stack (Elasticsearch, Logstash, Kibana):

**Logstash Configuration:**
```ruby
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][logtype] == "nginx" {
    grok {
      match => { "message" => "%{NGINXACCESS}" }
    }
    date {
      match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
}
```

#### Application Performance Monitoring (APM):
- **Jaeger/Zipkin**: Distributed tracing
- **New Relic/DataDog**: Full-stack monitoring
- **OpenTelemetry**: Vendor-neutral observability

### 2. Security Best Practices

#### Infrastructure Security:

**Network Security:**
```bash
# Security Groups (AWS)
aws ec2 create-security-group --group-name web-sg --description "Web server security group"
aws ec2 authorize-security-group-ingress --group-id sg-12345 --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id sg-12345 --protocol tcp --port 443 --cidr 0.0.0.0/0

# Network ACLs
aws ec2 create-network-acl-entry --network-acl-id acl-12345 --rule-number 100 --protocol tcp --port-range From=80,To=80 --cidr-block 0.0.0.0/0
```

**Secrets Management:**
```bash
# AWS Secrets Manager
aws secretsmanager create-secret --name prod/db/password --secret-string "super-secret-password"
aws secretsmanager get-secret-value --secret-id prod/db/password

# HashiCorp Vault
vault kv put secret/myapp/db password="super-secret"
vault kv get secret/myapp/db
```

**Identity and Access Management (IAM):**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```

#### Container Security:
```dockerfile
# Use non-root user
RUN adduser --disabled-password --gecos '' appuser
USER appuser

# Scan for vulnerabilities
docker scan my-image

# Use minimal base images
FROM alpine:3.15
FROM distroless/java
```

#### Kubernetes Security:
```yaml
# Pod Security Context
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### 3. Database Management

#### Relational Databases:

**PostgreSQL Administration:**
```sql
-- Performance monitoring
SELECT * FROM pg_stat_activity;
SELECT * FROM pg_stat_database;

-- Index optimization
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Backup and restore
pg_dump mydb > backup.sql
psql mydb < backup.sql
```

**MySQL/MariaDB:**
```sql
-- Slow query analysis
SHOW PROCESSLIST;
SELECT * FROM information_schema.processlist;

-- Replication setup
CHANGE MASTER TO MASTER_HOST='master-server', MASTER_USER='replication', MASTER_PASSWORD='password';
START SLAVE;
```

#### NoSQL Databases:

**MongoDB:**
```javascript
// Performance monitoring
db.stats()
db.collection.getIndexes()
db.collection.explain().find({field: "value"})

// Sharding
sh.enableSharding("mydb")
sh.shardCollection("mydb.users", {user_id: 1})
```

**Redis:**
```bash
# Monitoring
redis-cli monitor
redis-cli info memory
redis-cli slowlog get 10

# Clustering
redis-cli --cluster create node1:7000 node2:7000 node3:7000
```

### 4. Performance Optimization

#### Load Testing:
```bash
# Apache Bench
ab -n 1000 -c 10 http://example.com/

# wrk
wrk -t12 -c400 -d30s http://example.com/

# Artillery
artillery quick --count 10 --num 10 http://example.com/
```

#### Caching Strategies:
```yaml
# Redis configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
  redis.conf: |
    maxmemory 2gb
    maxmemory-policy allkeys-lru
    timeout 300
```

#### Content Delivery Networks (CDN):
```bash
# CloudFront (AWS)
aws cloudfront create-distribution --distribution-config file://distribution-config.json

# Invalidate cache
aws cloudfront create-invalidation --distribution-id E12345 --paths "/*"
```

---

## Phase 4: Specialized Areas

### 1. Site Reliability Engineering (SRE)

#### Service Level Objectives (SLOs):
```yaml
# Example SLO definitions
availability_slo:
  target: 99.9%  # 43.8 minutes downtime per month
  measurement_window: 30d

latency_slo:
  target: 95%    # 95% of requests under 200ms
  threshold: 200ms
  measurement_window: 7d

error_rate_slo:
  target: 99.5%  # Error rate under 0.5%
  measurement_window: 7d
```

#### Error Budgets and Alerting:
```yaml
# Prometheus alerting rules
groups:
- name: slo-alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.01
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "High error rate detected"
      description: "Error rate is {{ $value | humanizePercentage }}"

  - alert: HighLatency
    expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.2
    for: 5m
    labels:
      severity: warning
```

#### Chaos Engineering:
```yaml
# Chaos Monkey (Netflix)
# Randomly terminates instances to test resilience

# Litmus (Kubernetes)
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: nginx-chaos
spec:
  appinfo:
    appns: default
    applabel: "app=nginx"
  experiments:
  - name: pod-delete
    spec:
      components:
        env:
        - name: TOTAL_CHAOS_DURATION
          value: "60"
```

### 2. Platform Engineering

#### Internal Developer Platforms:
```yaml
# Platform abstraction example
apiVersion: platform.company.com/v1
kind: Application
metadata:
  name: my-web-app
spec:
  language: nodejs
  resources:
    cpu: 500m
    memory: 512Mi
  replicas: 3
  domains:
    - my-app.company.com
  database:
    type: postgres
    size: small
  cache:
    type: redis
    size: small
```

#### Self-Service Infrastructure:
```bash
# Backstage (Spotify's developer portal)
# Provides service catalog, scaffolding, and documentation

# ArgoCD for GitOps
argocd app create my-app \
  --repo https://github.com/company/my-app \
  --path k8s \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
```

### 3. Cost Optimization

#### AWS Cost Management:
```bash
# Cost and usage reports
aws ce get-cost-and-usage \
  --time-period Start=2023-01-01,End=2023-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# Right-sizing recommendations
aws compute-optimizer get-ec2-instance-recommendations

# Reserved instance recommendations
aws ce get-reservation-coverage
```

#### Resource Optimization:
```yaml
# Kubernetes resource requests and limits
resources:
  requests:
    memory: "64Mi"
    cpu: "250m"
  limits:
    memory: "128Mi"
    cpu: "500m"

# Horizontal Pod Autoscaler
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### 4. Compliance and Governance

#### Infrastructure Compliance:
```hcl
# Terraform Sentinel policy
import "tfplan"

main = rule {
  all tfplan.resource_changes as _, rc {
    rc.type is "aws_instance" implies rc.change.after.instance_type in ["t3.micro", "t3.small"]
  }
}
```

#### Security Scanning:
```yaml
# GitHub Actions security scan
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'my-app:latest'
    format: 'sarif'
    output: 'trivy-results.sarif'

- name: Upload Trivy scan results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'
```

---

## Essential Tools and Technologies

### Core Infrastructure Tools:
- **Cloud Platforms**: AWS, Google Cloud, Azure
- **IaC**: Terraform, CloudFormation, Pulumi
- **Containers**: Docker, Kubernetes, Helm
- **CI/CD**: GitLab CI, GitHub Actions, Jenkins
- **Monitoring**: Prometheus, Grafana, ELK Stack
- **Service Mesh**: Istio, Linkerd, Consul Connect

### Programming and Scripting:
- **Languages**: Python, Go, Bash, PowerShell
- **Configuration**: YAML, JSON, HCL, TOML
- **Markup**: Markdown, reStructuredText

### Databases and Storage:
- **Relational**: PostgreSQL, MySQL, SQL Server
- **NoSQL**: MongoDB, Redis, Elasticsearch
- **Object Storage**: S3, GCS, Azure Blob
- **Block Storage**: EBS, Persistent Disks

### Networking and Security:
- **Load Balancers**: nginx, HAProxy, AWS ALB
- **CDN**: CloudFront, CloudFlare, Fastly
- **VPN**: OpenVPN, WireGuard, IPSec
- **Security**: Vault, AWS KMS, cert-manager

---

## Learning Resources and Certifications

### Hands-On Practice:
1. **Home Lab**: Set up servers with Proxmox/VMware
2. **Cloud Free Tiers**: AWS, GCP, Azure free accounts
3. **Local Development**: minikube, Docker Desktop, Vagrant
4. **Open Source Projects**: Contribute to infrastructure tools

### Recommended Certifications:
1. **AWS Solutions Architect Associate**
2. **Certified Kubernetes Administrator (CKA)**
3. **HashiCorp Certified: Terraform Associate**
4. **Google Cloud Professional Cloud Architect**
5. **Microsoft Azure Solutions Architect Expert**

### Books and Resources:
- "Site Reliability Engineering" by Google
- "The Phoenix Project" by Gene Kim
- "Infrastructure as Code" by Kief Morris
- "Kubernetes: Up and Running" by Kelsey Hightower
- "Designing Data-Intensive Applications" by Martin Kleppmann

### Communities and Learning:
- **Reddit**: r/devops, r/sysadmin, r/kubernetes
- **Discord/Slack**: DevOps communities
- **Conferences**: KubeCon, AWS re:Invent, DockerCon
- **YouTube Channels**: TechWorld with Nana, Cloud Native Computing Foundation

---

## Building Your Portfolio

### Project Ideas:
1. **Multi-tier Web Application**: Deploy on cloud with IaC
2. **Kubernetes Cluster**: Set up monitoring and logging
3. **CI/CD Pipeline**: Automate testing and deployment
4. **Infrastructure Monitoring**: Implement full observability stack
5. **Disaster Recovery**: Design and test backup/restore procedures
6. **Cost Optimization**: Analyze and reduce cloud spending
7. **Security Hardening**: Implement security best practices

### GitHub Portfolio:
- Infrastructure as Code templates
- Kubernetes manifests and Helm charts
- Monitoring and alerting configurations
- CI/CD pipeline examples
- Documentation and runbooks

---

## Career Path and Specializations

### Entry Level (0-2 years):
- Junior DevOps Engineer
- Cloud Support Engineer
- Systems Administrator
- Site Reliability Engineer I

### Mid Level (2-5 years):
- DevOps Engineer
- Cloud Engineer
- Platform Engineer
- Site Reliability Engineer II

### Senior Level (5+ years):
- Senior Infrastructure Engineer
- Principal Site Reliability Engineer
- Cloud Architect
- Platform Engineering Lead
- DevOps Team Lead

### Specialized Roles:
- Security Engineer (DevSecOps)
- Database Reliability Engineer
- Network Engineer
- Cost Optimization Specialist
- Compliance Engineer

This roadmap provides a comprehensive path to becoming a skilled infrastructure engineer. Focus on building practical experience through hands-on projects, and don't try to learn everything at once. Master the fundamentals first, then gradually expand into specialized areas based on your interests and career goals.