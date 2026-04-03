# ===== FILE: PIPELINE_SETUP.md =====

# CI/CD Pipeline Setup Guide

Complete guide to set up the Build → SonarQube → TRIVY → Registry → Deploy → ArgoCD pipeline.

## 📋 Pipeline Stages Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  1. BUILD              │  2. SCAN CODE       │  3. SHORT IMAGE  │
│  - Npm install         │  - SonarQube        │  - TRIVY         │
│  - Build app           │                     │  - Report        │
└─────────────────────────────────────────────────────────────────┘
           ↓                      ↓                       ↓
┌─────────────────────────────────────────────────────────────────┐
│  4. PUSH IMAGE         │  5. DEPLOY K8S      │  6. ARGOCD SYNC  │
│  - ACR or ECR          │  - AKS or EKS       │  - Auto sync     │
│  - Latest & Tag        │  - Rolling Update   │  - Verification  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔐 GitHub Actions Secrets (Settings → Secrets)

Add these secrets to your GitHub repository:

### Azure (for ACR & AKS)
```
ACR_USERNAME              → Your ACR username
ACR_PASSWORD              → Your ACR password
AZURE_CREDENTIALS         → Azure service principal JSON
AZURE_RESOURCE_GROUP      → Your resource group name
AKS_CLUSTER_NAME          → Your AKS cluster name
```

### AWS (for ECR & EKS) - Use instead of Azure if needed
```
AWS_ACCESS_KEY            → AWS access key ID
AWS_SECRET_KEY            → AWS secret access key
EKS_CLUSTER_NAME          → Your EKS cluster name
```

### SonarQube
```
SONARQUBE_TOKEN           → SonarQube authentication token
```

### ArgoCD
```
ARGOCD_SERVER             → ArgoCD server URL (e.g., https://argocd.example.com)
ARGOCD_TOKEN              → ArgoCD API token
```

### How to get these secrets:

#### Azure Credentials JSON:
```bash
az ad sp create-for-rbac --name "github-actions" --role Contributor \
  --scopes /subscriptions/{subscription-id}
```

#### SonarQube Token:
1. Go to SonarQube → User Settings → Security
2. Generate new token for CI/CD

#### ArgoCD Token:
```bash
argocd account generate-token --account github-actions
```

---

## 🎯 Azure Pipelines Variables (Pipeline Settings)

Add these pipeline variables:

### ACR/Registry
```
SONARQUBE_ORG             → Your SonarQube organization
kubernetesServiceConnection → Name of your K8s service connection
argoCDServer              → ArgoCD server URL
argoCDToken               → ArgoCD API token (secret)
eksClusterName            → EKS cluster name (if using AWS)
```

---

## 🏗️ Prerequisites

### 1. Create SonarQube Project
```bash
# Login to SonarQube
# Go to Projects → Create Project
# Project Key: static-app
# Organization: your-org
```

### 2. Create ACR (Azure Container Registry)
```bash
az acr create \
  --resource-group my-rg \
  --name myacr \
  --sku Basic
```

**Or create ECR (AWS)**:
```bash
aws ecr create-repository \
  --repository-name static-app \
  --region eu-west-1
```

### 3. Setup AKS Cluster
```bash
az aks create \
  --resource-group my-rg \
  --name my-aks \
  --node-count 3 \
  --enable-addons monitoring
```

**Or setup EKS**:
```bash
eks create cluster \
  --name my-eks \
  --version 1.27
```

### 4. Install ArgoCD
```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Port forward to access
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### 5. Create ArgoCD Application
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: static-app-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo/test-static-app
    targetRevision: main
    path: K8s
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

---

## 📝 Configuration Files

### 1. Dockerfile (already exists)
Make sure your Dockerfile is optimized:
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY app/ .
RUN npm install --production

FROM nginx:alpine
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx
COPY --from=builder /app /usr/share/nginx/html
RUN chmod -R 755 /usr/share/nginx/html
EXPOSE 80
USER nginx
```

### 2. K8s Deployment (created in K8s/deployment.yml)
Includes:
- Deployment with 3 replicas
- Service (LoadBalancer)
- HorizontalPodAutoscaler
- PodDisruptionBudget
- Security best practices

---

## 🚀 How to Use

### GitHub Actions Workflow

1. **Commit & Push** to main branch
   ```bash
   git add .
   git commit -m "feat: update app"
   git push origin main
   ```

2. **Pipeline Runs Automatically**:
   - ✅ Build & test code
   - ✅ SonarQube scan
   - ✅ Docker build
   - ✅ TRIVY vulnerability scan
   - ✅ Push to ACR/ECR
   - ✅ Update deployment on AKS/EKS
   - ✅ Trigger ArgoCD sync

3. **Monitor in GitHub Actions**:
   - Go to Actions tab
   - View logs in real-time
   - Check security scanning results

### Azure Pipelines Workflow

Same as above, but monitor in Azure DevOps:
- Pipelines → View runs
- Click build number for details

---

## 🔍 Verification Steps

### 1. Check SonarQube Results
```bash
curl "https://sonarqube.example.com/api/qualitygates/project_status?projectKey=static-app"
```

### 2. Check TRIVY Scan Results
- GitHub: Security → Code scanning
- Azure: Artifacts → Trivy reports

### 3. Check Docker Image in Registry
```bash
# ACR
az acr repository list --name myacr --output table

# ECR
aws ecr describe-repositories --region eu-west-1
```

### 4. Check Deployment Status
```bash
kubectl get deployments -n default
kubectl get pods -n default
kubectl logs -f deployment/static-app -n default
```

### 5. Check ArgoCD Sync
```bash
# Port forward to ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Check via CLI
argocd app get static-app-app
```

---

## 🐛 Troubleshooting

### Pipeline Fails at SonarQube
- Check `SONARQUBE_TOKEN` is valid
- Ensure SonarQube project exists
- Verify network connectivity to SonarQube

### TRIVY Scan Fails
- Image not found: Check ACR/ECR login credentials
- High vulnerabilities detected: Update base image or dependencies

### Deployment Fails
- K8s connection issue: Verify kubeconfig and credentials
- Image pull error: Check ACR/ECR credentials in K8s

### ArgoCD Sync Fails
- Server unreachable: Check ARGOCD_SERVER URL
- Authentication failed: Regenerate ARGOCD_TOKEN
- Application not found: Create application in ArgoCD first

---

## 📊 Pipeline Timing

Expected pipeline duration:
- **Build & Test**: 2-3 minutes
- **SonarQube Scan**: 3-5 minutes
- **Docker Build**: 2-3 minutes
- **TRIVY Scan**: 1-2 minutes
- **Push to Registry**: 1-2 minutes
- **Deploy**: 2-3 minutes
- **ArgoCD Sync**: 1-2 minutes

**Total**: ~15-20 minutes

---

## 🔒 Security Best Practices

✅ **Implemented in this setup:**
- Pod security context (non-root, read-only)
- Resource limits and requests
- Network policies ready
- Health checks (liveness & readiness)
- Container scanning with TRIVY
- Code quality with SonarQube
- Pod disruption budgets
- High availability setup (3+ replicas)

---

## 📚 Additional Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Azure Pipelines Docs](https://docs.microsoft.com/en-us/azure/devops/pipelines)
- [SonarQube Docs](https://docs.sonarqube.org/)
- [TRIVY Docs](https://aquasecurity.github.io/trivy/)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)
- [Kubernetes Docs](https://kubernetes.io/docs/)


# ===== FILE: SETUP_GUIDE.md =====

# 🚀 Complete Setup Guide

## 📋 Table of Contents
1. [Pre-requisites](#pre-requisites)
2. [Project Organization](#project-organization)
3. [Step-by-Step Setup](#step-by-step-setup)
4. [Verification](#verification)
5. [Troubleshooting](#troubleshooting)

---

## Pre-requisites

### Required Software
```bash
# Check versions
terraform --version          # >= 1.0
docker --version             # Any recent
git --version                # Any recent
kubectl version --client     # Any recent

# For AWS/EKS
aws --version                # >= 2.0
aws sts get-caller-identity  # Verify credentials

# For Azure/AKS
az --version                 # >= 2.0
az account show              # Verify login
```

### Required Accounts
- [ ] AWS account with EC2, VPC, EKS permissions (for EKS)
- [ ] Azure account with subscription (for AKS)
- [ ] GitHub account (for repository & CI/CD)
- [ ] SonarQube account (optional, for code quality)

---

## Project Organization

### Folder Structure (Complete)
```
Test-Static-Application/
├── app/                          ← Frontend code
├── Terraform/                    ← Infrastructure (AWS/Azure)
├── K8s/                          ← Kubernetes manifests
├── Argocd/                       ← GitOps deployment
├── monitoring/                   ← Prometheus & Grafana
├── Pipeline/                     ← CI/CD (GitHub/Azure)
│   ├── github-actions.yml        ← GitHub Actions
│   └── azure-pipelines.yml       ← Azure DevOps
├── Dockerfile                    ← Container image
├── nginx.conf                    ← Web server config
├── STRUCTURE.md                  ← This structure
├── SETUP_GUIDE.md                ← Setup instructions (you are here)
├── TERRAFORM_GUIDE.md            ← Terraform detailed guide
└── PIPELINE_QUICK_REFERENCE.md   ← Pipeline quick help
```

---

## Step-by-Step Setup

### PHASE 1: Infrastructure Setup (15-20 minutes)

#### Step 1.1: Configure Terraform Variables
```bash
cd Terraform

# Copy template
cp terraform.tfvars.example terraform.tfvars

# Edit for YOUR environment
nano terraform.tfvars

# For AWS (pick ONE):
# Option A: Default VPC
vpc_id = ""          # Leave empty, uses default
subnet_ids = []      # Leave empty, uses default subnets

# Option B: Your VPC
vpc_id = "vpc-xxxxx"
subnet_ids = ["subnet-aaa", "subnet-bbb"]

# For Azure:
azure_subscription_id = "xxxxx-xxxxx-xxxxx"
azure_location = "westeurope"
```

#### Step 1.2: Initialize & Deploy Terraform
```bash
# Inside Terraform/ directory

# Download providers
terraform init

# Review what will be created
terraform plan

# Deploy infrastructure
terraform apply

# Wait 15-20 minutes for cluster to be ready...
```

#### Step 1.3: Configure kubectl
```bash
# Get command from terraform output, then run it

# AWS:
aws eks update-kubeconfig --name static-app-eks-dev --region eu-west-1

# Azure:
az aks get-credentials --resource-group static-app-rg-dev --name static-app-aks-dev

# Verify connection
kubectl get nodes
kubectl get namespaces
```

---

### PHASE 2: Kubernetes Setup (5 minutes)

#### Step 2.1: Deploy K8s Manifests
```bash
cd ../K8s

# Deploy everything (namespace + deployment + service + HPA + PDB)
kubectl apply -f deployment.yml

# Verify
kubectl get ns
kubectl get pods -n static-app
kubectl get svc -n static-app
```

#### Step 2.2: Verify Deployment
```bash
# Wait for pods to be ready
kubectl get pods -n static-app -w

# Once all pods are Running, exit (Ctrl+C)

# Check pod details
kubectl describe pods -n static-app

# View logs
kubectl logs -n static-app -l app=static-app --tail=50
```

---

### PHASE 3: ArgoCD Setup (10 minutes)

#### Step 3.1: Install ArgoCD
```bash
# Create argocd namespace and install
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for argocd pods to start
kubectl get pods -n argocd -w

# Get initial admin password
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD Password: $PASSWORD"
```

#### Step 3.2: Configure ArgoCD Application
```bash
cd ../Argocd

# UPDATE THE FILE FIRST!
# Edit application.yaml:
# - Change "YOUR_USERNAME" to your GitHub username
# - Change repo URL to your actual repo

nano application.yaml

# Deploy ArgoCD app and project
kubectl apply -f appproject.yaml
kubectl apply -f application.yaml

# Verify
kubectl get applications -n argocd
```

#### Step 3.3: Access ArgoCD UI
```bash
# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Open browser: https://localhost:8080
# Login with: admin / $PASSWORD
```

---

### PHASE 4: GitHub Setup (5 minutes)

#### Step 4.1: Create Repository
```bash
# On GitHub.com:
# 1. Create new repository: "Test-Static-Application"
# 2. Initialize with README
# 3. Get clone URL
```

#### Step 4.2: Push Code to GitHub
```bash
cd /Users/subhasmitadas/Desktop/Test-Static-Application

# Initialize git (if not done)
git init
git add .
git commit -m "Initial commit: complete static app with DevOps pipeline"

# Add remote
git remote add origin https://github.com/YOUR_USERNAME/Test-Static-Application.git

# Push to main
git branch -M main
git push -u origin main
```

#### Step 4.3: Add GitHub Secrets
```
On GitHub > Settings > Secrets and variables > Actions

Add these secrets:
- ACR_USERNAME: <your_acr_username>
- ACR_PASSWORD: <your_acr_password>
- AZURE_CREDENTIALS: {your_azure_sp_json}
- AZURE_RESOURCE_GROUP: <your_rg_name>
- AKS_CLUSTER_NAME: static-app-aks-dev
- SONARQUBE_TOKEN: <your_sonarqube_token> (optional)
- ARGOCD_SERVER: https://<argocd_server>
- ARGOCD_TOKEN: <your_argocd_token>
```

---

### PHASE 5: CI/CD Setup (5 minutes)

#### Step 5.1: Add GitHub Actions Workflow

Already created! File: `Pipeline/github-actions.yml`

```bash
# Copy to git workflows directory
mkdir -p .github/workflows
cp Pipeline/github-actions.yml .github/workflows/

# Commit and push
git add .github/
git commit -m "Add GitHub Actions CI/CD pipeline"
git push origin main
```

#### Step 5.2: Monitor Pipeline
```
Go to: GitHub > Actions tab

Watch the pipeline run:
1. Build & Code Quality ✅
2. TRIVY Scan ✅
3. Docker Push ✅
4. Kubernetes Deploy ✅
5. ArgoCD Sync ✅
```

---

### PHASE 6: Monitoring Setup (Optional, 5 minutes)

#### Step 6.1: Deploy Monitoring Stack
```bash
# Add Prometheus Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Deploy using values.yaml
cd monitoring

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -f values.yaml \
  -n monitoring \
  --create-namespace

# Wait for pods
kubectl get pods -n monitoring -w
```

#### Step 6.2: Access Grafana
```bash
# Port forward
kubectl port-forward -n monitoring \
  svc/kube-prometheus-stack-grafana 3000:80 &

# Open browser: http://localhost:3000
# Default credentials: admin/changeme123!
```

---

## Verification

### Quick Health Check (5 minutes)

```bash
# 1. Kubernetes
kubectl get nodes
kubectl get pods -A
kubectl get svc -A

# 2. Deployment status
kubectl rollout status deployment/static-app -n static-app

# 3. Get external IP
kubectl get svc -n static-app

# 4. Access your app (replace EXTERNAL_IP)
curl http://<EXTERNAL_IP>

# 5. Check ArgoCD sync status
kubectl get app -n argocd

# 6. View logs
kubectl logs -n static-app -l app=static-app --tail=20
```

### Detailed Verification

```bash
# Pod details
kubectl describe pod -n static-app

# Container logs
kubectl logs -n static-app deployment/static-app

# Events
kubectl get events -n static-app

# Storage
kubectl get pvc -A

# Network
kubectl get netpol -A
```

---

## Configuration Files Quick Reference

### File: `Terraform/terraform.tfvars`
```hcl
# MUST EDIT:
environment = "dev"                    # dev/staging/prod
project_name = "static-app"

# For AWS:
vpc_id = "vpc-xxxxx"                   # Your VPC
subnet_ids = ["subnet-aaa", "subnet-bb"]

# For Azure:
azure_subscription_id = "xxxxx-xxxxx"
azure_location = "westeurope"
```

### File: `Argocd/application.yaml`
```yaml
# MUST EDIT on line ~13:
repoURL: https://github.com/YOUR_USERNAME/Test-Static-Application
```

### File: `Pipeline/github-actions.yml`
```yaml
# Already configured, just ensure secrets are set
# Change line 10 if using ECR instead of ACR:
REGISTRY: ecr.aws.amazon.com    # For AWS
REGISTRY: acr.azurecr.io        # For Azure
```

---

## 🆘 Troubleshooting

### Cluster not creating
```bash
# Check quota
aws service-quotas list-service-quotas --service-code ec2

# Check VPC/Subnets
aws ec2 describe-vpcs
aws ec2 describe-subnets
```

### kubectl can't connect
```bash
# Reconfigure kubeconfig
# AWS: aws eks update-kubeconfig --name <cluster> --region eu-west-1
# Azure: az aks get-credentials --resource-group <rg> --name <cluster>

# Verify:
kubectl get nodes
```

### Container won't start
```bash
# Check image
kubectl describe pod -n static-app

# Pull secrets issue:
kubectl create secret docker-registry acr-secret \
  --docker-server=acr.azurecr.io \
  --docker-username=<user> \
  --docker-password=<pass>
```

### ArgoCD sync fails
```bash
# Check app status
kubectl describe app static-app-app -n argocd

# Check logs
kubectl logs -n argocd deployment/argocd-application-controller

# Verify git access
argocd repo list --server <ARGOCD_SERVER>
```

### Pipeline fails
```bash
GitHub Actions:
1. Go to Actions tab
2. Click failed workflow
3. Expand step to see error

Azure DevOps:
1. Go to Pipelines
2. Click failed run
3. Click failed stage for details
```

---

## 📊 Success Criteria

When complete, you should have:

✅ **Infrastructure**
- [ ] AKS/EKS cluster running with 2+ nodes
- [ ] Container registry (ACR/ECR) created
- [ ] VPC/Network properly configured

✅ **Kubernetes**
- [ ] static-app namespace created
- [ ] 3 pods running of static-app
- [ ] LoadBalancer service with external IP
- [ ] HPA configured (scales 3-10)
- [ ] PDB ensures min 2 pods available

✅ **ArgoCD**
- [ ] ArgoCD installed and accessible
- [ ] Application synced automatically
- [ ] git repo linked

✅ **CI/CD**
- [ ] GitHub Actions or Azure DevOps workflows active
- [ ] Pipeline runs on push to main
- [ ] Builds, scans, pushes image, deploys

✅ **Monitoring**
- [ ] Prometheus collects metrics
- [ ] Grafana dashboards available
- [ ] Cluster monitoring enabled

✅ **Application**
- [ ] App accessible at LoadBalancer IP
- [ ] Can create/edit/delete users
- [ ] Data persists

---

## 🎓 Next Steps

1. **Customize**: Update app for your needs
2. **Security**: Add network policies, RBAC
3. **Scaling**: Configure HPA thresholds
4. **Backup**: Setup cluster backups
5. **Monitoring**: Create custom dashboards
6. **Advanced**: Add Istio for service mesh

---

## 📞 Support Files

- **STRUCTURE.md** - Folder organization
- **TERRAFORM_GUIDE.md** - Terraform detailed guide
- **PIPELINE_QUICK_REFERENCE.md** - CI/CD quick reference
- **TROUBLESHOOTING.md** - Common issues (create this)

Good luck! 🚀


# ===== FILE: TERRAFORM_GUIDE.md =====

# 🏗️ Terraform Complete Setup Guide

## Prerequisites

### Required Tools
```bash
# Install Terraform
brew install terraform

# Install AWS CLI (if using AWS)
brew install awscli

# Install Azure CLI (if using Azure)
brew install azure-cli

# Verify installations
terraform version
aws --version
az --version
```

### Required Credentials

#### For AWS (EKS)
```bash
# Configure AWS CLI
aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region (eu-west-1)

# Verify
aws sts get-caller-identity
```

#### For Azure (AKS)
```bash
# Login to Azure
az login

# Verify
az account show
```

---

## Step-by-Step Setup

### Step 1: Get Your AWS/Azure Information

#### If using AWS (EKS):
```bash
# Get default VPC ID
aws ec2 describe-vpcs --filters "Name=is-default,Values=true" \
  --query 'Vpcs[0].VpcId' --output text

# Get subnets in default VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxx" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone]' --output table
```

#### If using Azure (AKS):
```bash
# Get subscription ID
az account show --query id

# Get available regions
az account list-locations --query "[].name"
```

### Step 2: Copy and Configure terraform.tfvars

```bash
cd Terraform

# Copy example to actual file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
# OR
code terraform.tfvars
```

### Step 3: Fill in terraform.tfvars

#### For AWS Users:
```hcl
environment  = "dev"
project_name = "static-app"
aws_region   = "eu-west-1"

# Get these from step 1
vpc_id       = "vpc-0123456789abcdef0"
subnet_ids   = ["subnet-0abc123def", "subnet-0xyz789ghi"]

eks_node_instance_types = ["t3.medium"]
eks_desired_size        = 2
eks_min_size            = 2
eks_max_size            = 5
```

#### For Azure Users:
```hcl
environment       = "dev"
project_name      = "static-app"
azure_location    = "westeurope"

# Get from: az account show --query id
azure_subscription_id = "xxxxx-xxxxx-xxxxx-xxxxx"

aks_node_count    = 2
aks_vm_size       = "Standard_B2s"
```

### Step 4: Initialize Terraform

```bash
# Initialize Terraform (download providers)
terraform init

# You should see:
# ✓ Terraform has been successfully configured!
```

### Step 5: Review the Plan

```bash
# See what will be created (DRY RUN)
terraform plan

# Review the output for:
# - Resource count
# - Any errors
# - VPC, subnet, cluster names
```

### Step 6: Deploy Infrastructure

```bash
# Deploy to cloud
terraform apply

# Review and confirm: "yes"
# Wait 10-20 minutes for cluster creation
```

### Step 7: Get Cluster Credentials

#### For AWS (EKS):
```bash
# Get command from output
terraform output eks_configure_kubectl

# Example output:
# aws eks update-kubeconfig --name static-app-eks-dev --region eu-west-1

# Run that command
aws eks update-kubeconfig --name static-app-eks-dev --region eu-west-1
```

#### For Azure (AKS):
```bash
# Get command from output
terraform output aks_configure_kubectl

# Example output:
# az aks get-credentials --resource-group static-app-rg-dev --name static-app-aks-dev

# Run that command
az aks get-credentials --resource-group static-app-rg-dev --name static-app-aks-dev
```

### Step 8: Verify Cluster Access

```bash
# Test kubectl connection
kubectl get nodes

# You should see your worker nodes listed
NAME                           STATUS   ROLES    AGE
ip-10-0-1-100.ec2.internal    Ready    <none>   5m
ip-10-0-1-101.ec2.internal    Ready    <none>   5m
```

---

## 🔧 Troubleshooting Terraform

### Issue: "VPC ID not found"
**Solution:**
```bash
# Verify VPC exists
aws ec2 describe-vpcs

# Update terraform.tfvars with correct VPC ID
vpc_id = "vpc-xxxxx"
```

### Issue: "Subnets in different AZ"
**Solution:**
Ensure subnets are in different availability zones for HA.
```bash
# Check AZs
aws ec2 describe-subnets \
  --subnet-ids subnet-xxx subnet-yyy \
  --query 'Subnets[*].AvailabilityZone'
```

### Issue: "Insufficient IAM permissions"
**Solution:**
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Ensure user has:
# - EC2FullAccess
# - IAMFullAccess
# - VPCFullAccess
# - EKSFullAccess (for AWS)
```

### Issue: "Insufficient quota"
**Solution:**
```bash
# Check quota in region
aws service-quotas list-service-quotas \
  --service-code ec2 \
  --region eu-west-1
```

---

## 📊 Terraform File Structure

```
Terraform/
├── providers.tf              # ✅ Cloud provider config
├── variables.tf              # ✅ All input variables (40+)
├── AWS-main.tf               # ✅ EKS cluster (commented for Azure)
├── Azure-main.tf             # ✅ AKS cluster (commented for AWS)
├── outputs.tf                # ✅ AWS outputs
├── Azure-outputs.tf          # ✅ Azure outputs
├── backend.tf                # ✅ State storage (commented)
├── terraform.tfvars          # ⚠️ Your values (GITIGNORE THIS!)
└── terraform.tfvars.example  # ✅ Template (DO NOT EDIT)
```

---

## 🔐 Best Practices

### 1. Never Commit Sensitive Files
```bash
# Add to .gitignore
echo "terraform.tfvars" >> .gitignore
echo "terraform.tfstate*" >> .gitignore
echo "*.backup" >> .gitignore
echo "crash.log" >> .gitignore
```

### 2. Use Remote State (For Teams)

#### AWS S3:
```hcl
# In backend.tf, uncomment S3 backend section
# Create bucket first:
aws s3 mb s3://your-terraform-state-bucket --region eu-west-1
```

#### Azure Storage:
```bash
# Create storage account
az group create --name terraform-rg --location westeurope

az storage account create \
  --resource-group terraform-rg \
  --name tfstatestorage \
  --sku Standard_LRS
```

### 3. Lock State for Concurrent Operations
```hcl
# Already configured in backend.tf with DynamoDB (AWS) or built-in (Azure)
```

### 4. Always Use terraform.tfvars.example Template
Never edit the `.example` file. Copy it first.

---

## 🎯 Common Tasks

### Update Cluster Size
```bash
# Edit terraform.tfvars
eks_desired_size = 3  # Change from 2 to 3

# Apply
terraform plan
terraform apply
```

### Update Node Instance Type
```bash
# Edit terraform.tfvars
eks_node_instance_types = ["t3.large"]

# Apply (will recreate nodes)
terraform apply
```

### Add Monitoring
Edit `terraform.tfvars`:
```
azure_subscription_id = "xxxxx"
aks_kubernetes_version = "1.29"  # Update as needed
```

### Destroy Resources (Clean Up)
```bash
# WARNING: This deletes everything!
terraform destroy

# Confirm: "yes"
```

---

## 📈 Scaling Guide

### Vertical Scaling (More powerful nodes)
```hcl
# AWS
eks_node_instance_types = ["t3.large"]  # t3.medium → t3.large

# Azure
aks_vm_size = "Standard_B4ms"  # Standard_B2s → Standard_B4ms
```

### Horizontal Scaling (More nodes)
```hcl
# AWS
eks_desired_size = 5  # 2 → 5
eks_max_size = 10

# Azure
aks_node_count = 5
```

### Auto Scaling
Already configured in K8s/deployment.yml:
- AWS: ASG managed
- Azure: Virtual Machine Scale Sets

---

## 💰 Cost Optimization

### Recommended for Dev:
```hcl
# AWS
eks_node_instance_types = ["t3.small"]
eks_desired_size = 1
eks_min_size = 1

# Azure
aks_vm_size = "Standard_B2s"
aks_node_count = 1
```

### Recommended for Production:
```hcl
# AWS
eks_node_instance_types = ["t3.large"]
eks_desired_size = 3
eks_min_size = 2

# Azure
aks_vm_size = "Standard_D2s_v3"
aks_node_count = 3
```

---

## 🆘 Getting Help

### Check Terraform Logs
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply

# Disable
unset TF_LOG
```

### Validate Configuration
```bash
# Check for syntax errors
terraform validate

# Format files properly
terraform fmt -recursive
```

### View Current State
```bash
# Show all resources
terraform state list

# Show specific resource details
terraform state show aws_eks_cluster.main
```

---

## ✅ Verification Checklist

After `terraform apply`:

- [ ] Cluster created (check AWS/Azure console)
- [ ] Nodes are running (kubectl get nodes)
- [ ] kubectl configured successfully
- [ ] Can run: `kubectl get pods -A`
- [ ] LoadBalancer IPs available (kubectl get svc)
- [ ] All outputs displayed correctly
- [ ] Container registry created (ACR/ECR)


# ===== FILE: TROUBLESHOOTING.md =====

# 🐛 Troubleshooting Guide

## Common Issues & Solutions

### 🔴 Terraform Issues

#### Issue: "Error: error validating provider credentials"
```
Problem: AWS credentials not set up correctly
Solution:
aws configure
# Enter your Access Key ID and Secret Access Key
aws sts get-caller-identity  # Verify
```

#### Issue: "error: VPC vpc-xxxxx does not exist"
```
Problem: VPC ID is incorrect or doesn't exist
Solution:
aws ec2 describe-vpcs --filters "Name=is-default,Values=true"
# Copy the VPC ID to terraform.tfvars
```

#### Issue: "error: The subnet 'subnet-xxxxx' is invalid"
```
Problem: Subnets don't exist in specified VPC
Solution:
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxx"
# Update terraform.tfvars with correct subnet IDs
```

#### Issue: "Error: error creating EKS Cluster: InvalidParameterException"
```
Problem: Cluster name or configuration is invalid
Solution:
terraform destroy  # Clean up
# Review terraform.tfvars for naming issues (>63 chars, invalid chars)
terraform apply
```

#### Issue: "NoCredentialProviders: no valid providers in chain"
```
Problem: AWS credentials not found
Solution:
export AWS_PROFILE=default
aws sts get-caller-identity
terraform apply
```

---

### 🔴 Kubernetes Issues

#### Issue: "No such file or directory" when running kubectl
```
Problem: kubectl not installed
Solution:
brew install kubectl
kubectl version --client
```

#### Issue: "Unable to connect to the server"
```
Problem: kubectl not configured for cluster
Solution:
# AWS:
aws eks update-kubeconfig --name static-app-eks-dev --region eu-west-1

# Azure:
az aks get-credentials --resource-group static-app-rg-dev --name static-app-aks-dev

# Verify:
kubectl get nodes
```

#### Issue: "error: You must be logged in to the server (Unauthorized)"
```
Problem: kubeconfig credentials expired
Solution:
# AWS:
aws eks update-kubeconfig --name static-app-eks-dev --region eu-west-1 --force-update

# Azure:
az aks get-credentials --resource-group static-app-rg-dev --name static-app-aks-dev --overwrite-existing
```

#### Issue: "persistent volume claim is not bound"
```
Problem: Storage class not available
Solution:
# Check available storage classes
kubectl get storageclass

# For AWS:
kubectl get pvc --all-namespaces

# For Azure:
kubectl get pvc --all-namespaces
```

#### Issue: "tried to read secret but got error 'secret not found'"
```
Problem: Secret not created in namespace
Solution:
# For registry secret:
kubectl create secret docker-registry acr-secret \
  --docker-server=acr.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password> \
  -n static-app

# For imagePullSecrets in deployment:
# Add to deployment.yml:
imagePullSecrets:
  - name: acr-secret
```

---

### 🔴 Pod Issues

#### Issue: "CrashLoopBackOff"
```
Problem: Container crashing repeatedly
Solution:
kubectl describe pod <pod-name> -n static-app
kubectl logs <pod-name> -n static-app
# Check logs for errors
# Common causes: bad image, missing volume, port conflict
```

#### Issue: "ImagePullBackOff"
```
Problem: Can't pull container image
Solution:
# Check image exists
docker pull acr.azurecr.io/static-app:latest

# Check credentials
kubectl get secret -n static-app
kubectl describe secret acr-secret -n static-app

# Recreate secret if needed
kubectl delete secret acr-secret -n static-app
kubectl create secret docker-registry acr-secret \
  --docker-server=acr.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password> \
  -n static-app
```

#### Issue: "OOMKilled" (Out of Memory)
```
Problem: Pod exceeds memory limit
Solution:
# Check memory usage
kubectl top pods -n static-app

# Increase memory limit in deployment.yml:
resources:
  limits:
    memory: "256Mi"  # Increase from 128Mi
  requests:
    memory: "128Mi"
```

#### Issue: "Pending" - Pod won't start
```
Problem: Can't schedule pod (no resources)
Solution:
# Check node resources
kubectl describe nodes

# Check pod events
kubectl describe pod <pod-name> -n static-app

# Common causes:
# 1. Node doesn't have enough memory
# 2. Node doesn't have enough CPU
# 3. Node selector mismatch
# Solution: Add more nodes or reduce resource request
```

---

### 🔴 Service Issues

#### Issue: "LoadBalancer service stuck in 'pending'"
```
Problem: External IP not assigned
Solution:
# Check service status
kubectl describe svc static-app-service -n static-app

# For AWS ELB:
aws elb describe-load-balancers

# For Azure LB:
az network lb list
```

#### Issue: "Connection refused" when accessing service
```
Problem: Service not routing to pods correctly
Solution:
# Test connectivity:
kubectl port-forward svc/static-app-service 8080:80 -n static-app
curl http://localhost:8080

# Check endpoints:
kubectl get endpoints -n static-app

# Check service selector:
kubectl get svc static-app-service -n static-app -o yaml
# Should match pod labels (app: static-app)
```

#### Issue: "No endpoints for service"
```
Problem: No pods are matching the service selector
Solution:
# Check service selector
kubectl get svc static-app-service -n static-app -o yaml | grep -A5 selector

# Check pod labels
kubectl get pods -n static-app --show-labels

# Labels must match! If not:
# Edit deployment and update labels to match service selector
```

---

### 🔴 ArgoCD Issues

#### Issue: "Application sync failed"
```
Problem: ArgoCD can't apply K8s manifests
Solution:
# Check application status
kubectl describe app static-app-app -n argocd

# Check argocd logs
kubectl logs -n argocd deployment/argocd-application-controller

# Check Git access
argocd repo list --server <ARGOCD_SERVER>

# Re-sync:
argocd app sync static-app-app --server <ARGOCD_SERVER>
```

#### Issue: "repository git@xxx not accessible"
```
Problem: SSH key not configured for GitHub
Solution:
# Generate SSH key if needed
ssh-keygen -t ed25519 -C "argocd"

# Add public key to GitHub:
# Settings > SSH and GPG keys > New SSH key
cat ~/.ssh/id_ed25519.pub

# Configure in ArgoCD:
argocd repo add git@github.com:USERNAME/Test-Static-Application.git \
  --ssh-private-key-path ~/.ssh/id_ed25519
```

#### Issue: "Authentication failed"
```
Problem: HTTPS access token invalid
Solution:
# Create GitHub token:
# Settings > Developer settings > Personal access tokens > New token
# Scopes: repo, read:user

# Add repo with token:
argocd repo add https://github.com/USERNAME/Test-Static-Application \
  --username USERNAME \
  --password <TOKEN>
```

#### Issue: "resource differs from version in git"
```
Problem: Live cluster differs from git repository
Solution:
# Option 1: Sync to git version
argocd app sync static-app-app --server <ARGOCD_SERVER>

# Option 2: Ignore specific fields
# Add to application.yaml:
ignoreDifferences:
  - group: "apps"
    kind: "Deployment"
    jsonPointers:
    - /spec/replicas
```

#### Issue: "Can't access ArgoCD UI"
```
Problem: ArgoCD server not accessible
Solution:
# Check if running
kubectl get pods -n argocd

# Port forward again
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Access: https://localhost:8080
```

---

### 🔴 Pipeline Issues (GitHub Actions)

#### Issue: "No secrets found in GitHub"
```
Problem: Secrets not added to repository
Solution:
GitHub > Settings > Secrets and variables > Actions

Add:
- ACR_USERNAME
- ACR_PASSWORD
- AZURE_CREDENTIALS
- AZURE_RESOURCE_GROUP
- AKS_CLUSTER_NAME
- ARGOCD_SERVER
- ARGOCD_TOKEN
```

#### Issue: "Docker login failed"
```
Problem: ACR credentials are wrong
Solution:
# Get correct credentials
az acr credential show --resource-group <RG> --name <ACR>

# Update secrets in GitHub
# Verify base URL: acr.azurecr.io (not <name>.azurecr.io)
```

#### Issue: "SonarQube scan failed"
```
Problem: SonarQube token invalid or missing
Solution:
# Optional: Skip SonarQube in github-actions.yml if not using

# Or create token:
# SonarQube > User > Security > Generate Token

# Add to GitHub secrets:
SONARQUBE_TOKEN: <token>
```

#### Issue: "TRIVY scan blocked by vulnerabilities"
```
Problem: Container image has HIGH/CRITICAL vulnerabilities
Solution:
# Option 1: Fix vulnerabilities in app
# Option 2: Update base image (Dockerfile)
# Option 3: Allow in pipeline (not recommended)

# See TRIVY scan results:
# GitHub > Security > Code scanning
```

---

### 🔴 Container Issues

#### Issue: "Dockerfile build fails"
```
Problem: Base image not found or syntax error
Solution:
# Test locally:
docker build -f Dockerfile -t test .

# Check syntax:
docker buildx build --check -f Dockerfile .

# Verify base image:
docker pull nginx:1.25-alpine
```

#### Issue: "Container runs locally but not in K8s"
```
Problem: Different environment (permissions, volumes, etc.)
Solution:
# Test with same security context:
docker run --user 101:101 --read-only \
  -v /tmp --v /var/cache/nginx \
  -p 8080:80 <image>

# Check logs:
kubectl logs <pod> -n static-app
```

---

### 🟡 Performance Issues

#### Issue: "Slow deployments"
```
Solutions:
1. Check pod readiness time:
   kubectl describe pod <pod> -n static-app

2. Increase initial delay:
   # In deployment.yml:
   initialDelaySeconds: 30 -> 60

3. Check image size:
   docker images
   # Optimize Dockerfile - use Alpine base

4. Cache dependencies:
   # In Dockerfile RUN commands
```

#### Issue: "High memory usage"
```
Solution:
# Monitor:
kubectl top pods -n static-app
kubectl top nodes

# Adjust limits in deployment.yml:
resources:
  limits:
    memory: "256Mi"  # Increase
    cpu: "1000m"

# Or reduce max replicas in HPA
maxReplicas: 5  # Reduce from 10
```

#### Issue: "CPU throttling"
```
Solution:
# Check:
kubectl describe pod <pod> -n static-app

# Increase CPU:
resources:
  limits:
    cpu: "1000m"  # Increase
```

---

### 🟡 Network Issues

#### Issue: "DNS resolution fails"
```
Problem: CoreDNS not working properly
Solution:
# Check CoreDNS
kubectl get pods -n kube-system | grep coredns

# Test DNS:
kubectl run -it --rm dns-test --image=busybox /bin/sh
# Inside: nslookup kubernetes.default

# Restart CoreDNS if needed:
kubectl rollout restart deployment/coredns -n kube-system
```

#### Issue: "Service discovery not working"
```
Problem: DNS names like "service-name" resolve outside pod
Solution:
# Use full DNS name:
http://static-app-service.static-app.svc.cluster.local

# Or ensure DNS works:
kubectl exec -it <pod> -n static-app /bin/sh
# nslookup static-app-service
```

---

### 🟡 Storage Issues

#### Issue: "PersistentVolume not provisioning"
```
Problem: No storage class available
Solution:
# List storage classes:
kubectl get storageclass

# Check if default is marked:
kubectl get storageclass -o yaml | grep "metadata/default"

# If not found, create one (AWS):
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: default
provisioner: ebs.csi.aws.com
EOF
```

---

## 🆘 Getting Help

### 1. Check Logs
```bash
# Application logs
kubectl logs <pod> -n static-app

# Previous logs (if crashed)
kubectl logs <pod> -n static-app --previous

# Real-time logs
kubectl logs -f <pod> -n static-app

# All pods in namespace
kubectl logs -l app=static-app -n static-app --tail=50
```

### 2. Describe Resources
```bash
# Pod details
kubectl describe pod <pod-name> -n static-app

# Service details
kubectl describe svc <svc-name> -n static-app

# Deployment details
kubectl describe deployment static-app -n static-app
```

### 3. Check Events
```bash
# Namespace events
kubectl get events -n static-app

# Watch events
kubectl get events -n static-app -w
```

### 4. Debug Pod
```bash
# Execute command in pod
kubectl exec -it <pod> -n static-app /bin/sh

# Copy file from pod
kubectl cp static-app/<pod>:/path/to/file ./local-file
```

---

## ✅ Verification Commands

Run these to verify everything is working:

```bash
# 1. Cluster health
kubectl get nodes
kubectl get namespaces
kubectl cluster-info

# 2. Deployment
kubectl rollout status deployment/static-app -n static-app
kubectl get pods -n static-app

# 3. Service
kubectl get svc -n static-app
curl http://<EXTERNAL_IP>

# 4. ArgoCD
kubectl get apps -n argocd
argocd app get static-app-app --server <SERVER>

# 5. Monitoring
kubectl get pods -n monitoring
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80

# 6. Logs (if any issues)
kubectl logs -l app=static-app -n static-app --tail=20
```

---

*Last Updated: 2026-04-03*
