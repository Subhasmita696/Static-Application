# 🚀 Static Web Application with Complete DevOps Pipeline

A production-ready static web application featuring User Management, deployed with complete Infrastructure-as-Code, CI/CD pipelines, Kubernetes orchestration, and GitOps automation.

## 📊 Project Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                    COMPLETE DEVOPS STACK                         │
├──────────────────────────────────────────────────────────────────┤
│  Frontend: HTML/CSS/JavaScript (Static)                          │
│  Container: Docker + Nginx (Alpine)                              │
│  Orchestration: Kubernetes (AKS/EKS)                             │
│  Infrastructure: Terraform (AWS/Azure)                           │
│  CI/CD: GitHub Actions + Azure Pipelines                         │
│  GitOps: ArgoCD (Automated Deployments)                          │
│  Monitoring: Prometheus + Grafana                                │
│  Code Quality: SonarQube + TRIVY Scanning                        │
│  Registry: ACR (Azure) + ECR (AWS)                               │
└──────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Features

### Application
- ✅ **Responsive UI** - Works on desktop, tablet, mobile
- ✅ **User Management** - Create, read, update, delete users
- ✅ **Search Functionality** - Find users by name/email
- ✅ **Local Storage** - No backend required, data persists in browser
- ✅ **Modern Design** - Gradient UI, smooth animations
- ✅ **Security** - XSS protection, input validation

### Infrastructure
- ✅ **Multi-Cloud** - Deploy to AWS (EKS) or Azure (AKS)
- ✅ **Infrastructure as Code** - 100% Terraform provisioned
- ✅ **Network Isolation** - VPC/vNet with proper security
- ✅ **Container Registry** - ACR (Azure) or ECR (AWS)
- ✅ **Logging** - CloudWatch or Log Analytics

### Kubernetes
- ✅ **High Availability** - 3+ replicas with pod disruption budgets
- ✅ **Auto Scaling** - Horizontal Pod Autoscaler (CPU/Memory based)
- ✅ **Health Checks** - Liveness & readiness probes
- ✅ **Security** - Non-root users, read-only filesystem
- ✅ **Resource Limits** - Memory and CPU constraints

### CI/CD
- ✅ **Build** - Automated npm build process
- ✅ **Code Quality** - SonarQube static analysis
- ✅ **Container Scanning** - TRIVY vulnerability scanning
- ✅ **Image Push** - Automatic push to ACR/ECR
- ✅ **Deployment** - Rolling updates to K8s
- ✅ **ArgoCD Sync** - Automated GitOps sync

### Monitoring
- ✅ **Prometheus** - Metrics collection
- ✅ **Grafana** - Dashboard visualization
- ✅ **Alerts** - AlertManager for notifications
- ✅ **Node Exporter** - System metrics

---

## 📁 Project Structure

```
Test-Static-Application/
├── app/                     # Frontend (HTML, CSS, JS)
├── Terraform/               # Infrastructure as Code (AWS/Azure)
├── K8s/                      # Kubernetes manifests (consolidated)
├── Argocd/                   # ArgoCD configuration (GitOps)
├── monitoring/               # Prometheus & Grafana setup
├── Pipeline/                 # CI/CD pipelines (GitHub/Azure)
├── Dockerfile                # Container image definition
├── nginx.conf                # Web server configuration
├── .gitignore                # Git ignore rules
├── COMBINED_DOC_2.md         # This file
└── COMBINED_DOC_1.md         # This file
```

**[View Complete Structure →](STRUCTURE.md)**

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites
```bash
# Install required tools
brew install terraform docker git kubectl

# Verify installations
terraform version
docker --version
git --version
kubectl version --client
```

### 1. Configure Infrastructure
```bash
cd Terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your values
```

### 2. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply  # Wait 15-20 minutes
```

### 3. Configure kubectl
```bash
# For AWS:
aws eks update-kubeconfig --name static-app-eks-dev --region eu-west-1

# For Azure:
az aks get-credentials --resource-group static-app-rg-dev --name static-app-aks-dev

kubectl get nodes  # Verify connection
```

### 4. Deploy Application
```bash
cd ../K8s
kubectl apply -f deployment.yml
kubectl get svc -n static-app  # Get external IP
```

### 5. Push to GitHub & Run Pipeline
```bash
git add .
git commit -m "Initial deployment"
git push origin main  # Pipeline runs automatically
```

**[Detailed Setup Guide →](SETUP_GUIDE.md)**

---

## 📋 Configuration Files

### Terraform (`Terraform/`)

| File | Purpose |
|------|---------|
| `terraform.tfvars` | 🔑 **CONFIGURE THIS** - Your environment variables |
| `terraform.tfvars.example` | Template (copy to above) |
| `providers.tf` | Cloud provider setup |
| `variables.tf` | Input variables (40+) |
| `Azure-main.tf` | AKS cluster + networking |
| `AWS-main.tf` | EKS cluster + security |
| `outputs.tf` | AWS output values |
| `Azure-outputs.tf` | Azure output values |
| `backend.tf` | Terraform state backend |

**[Terraform Setup Guide →](TERRAFORM_GUIDE.md)**

### Kubernetes (`K8s/`)

| File | Contains |
|------|----------|
| `deployment.yml` | Namespace, Deployment (3 replicas), Service, HPA, PDB, ConfigMap |

All K8s resources consolidated in one file for easy deployment.

### ArgoCD (`Argocd/`)

| File | Purpose |
|------|---------|
| `appproject.yaml` | Permissions & allowed repositories |
| `application.yaml` | 🔑 **UPDATE GitHub URL** - GitOps sync config |

### Pipelines (`Pipeline/`)

| File | Cloud Platform |
|------|----------------|
| `github-actions.yml` | GitHub (7 stages) |
| `azure-pipelines.yml` | Azure DevOps (7 stages) |

**[Pipeline Details →](PIPELINE_QUICK_REFERENCE.md)**

---

## 🔄 CI/CD Pipeline

### Workflow
```
Push to main → Build → Test → SonarQube → Docker → TRIVY → ACR/ECR → AKS/EKS → ArgoCD
```

### Stages

| # | Step | Tools | Time |
|---|------|-------|------|
| 1 | Build Code | npm, Node.js | 2 min |
| 2 | Code Quality | SonarQube | 3 min |
| 3 | Docker Build | Docker | 2 min |
| 4 | Security Scan | TRIVY | 2 min |
| 5 | Push Image | ACR/ECR | 1 min |
| 6 | Deploy K8s | kubectl | 2 min |
| 7 | ArgoCD Sync | ArgoCD | 1 min |
| | **Total** | | **13 min** |

---

## 🛠️ Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Frontend** | HTML/CSS/JavaScript | Latest |
| **Runtime** | Node.js | 18+ |
| **Container** | Docker | Latest |
| **Web Server** | Nginx | 1.25-alpine |
| **Orchestration** | Kubernetes | 1.29 |
| **Infrastructure** | Terraform | 1.0+ |
| **Cloud - Container** | ACR (Azure) / ECR (AWS) | Latest |
| **Cloud - Cluster** | AKS (Azure) / EKS (AWS) | 1.29 |
| **CI/CD** | GitHub Actions / Azure Pipelines | Latest |
| **GitOps** | ArgoCD | Latest |
| **Code Quality** | SonarQube | Latest |
| **Scanning** | TRIVY | Latest |
| **Monitoring** | Prometheus + Grafana | Latest |

---

## 📊 Architecture

### High-Level
```
Internet
   ↓
LoadBalancer (K8s Service)
   ↓
Nginx (Port 80)
   ↓
Static App (HTML/CSS/JS)
   ↓
Browser LocalStorage
```

### Infrastructure
```
GitHub / Azure DevOps
   ↓
CI/CD Pipeline
   ↓
Container Registry (ACR/ECR)
   ↓
Kubernetes Cluster (AKS/EKS)
   ↓
Pods (app replicas)
   ↓
LoadBalancer Service
   ↓
Public IP
```

### GitOps
```
Git Repo (main branch)
   ↓
ArgoCD (watches git)
   ↓
Kubernetes Manifests
   ↓
Auto-sync to cluster
```

---

## 🔐 Security Features

### Application
- ✅ XSS protection via HTML escaping
- ✅ Input validation
- ✅ CORS configured

### Container
- ✅ Non-root user (UID 101)
- ✅ Read-only root filesystem
- ✅ No privileged capabilities
- ✅ Alpine base (minimal attack surface)

### Kubernetes
- ✅ Security context enforced
- ✅ Resource limits & requests
- ✅ Pod disruption budgets
- ✅ Network policies (optional)

### Infrastructure
- ✅ VPC/vNet isolation
- ✅ IAM roles with least privilege
- ✅ Encryption in transit & at rest
- ✅ Secrets management

### Pipeline
- ✅ TRIVY container scanning
- ✅ SonarQube code analysis
- ✅ Signed commits (optional)
- ✅ Artifact scanning

---

## 📈 Scaling

### Automatic (Pod Level)
```yaml
HPA: 3-10 pods based on:
- CPU utilization > 70%
- Memory utilization > 80%
```

### Manual (Node Level)
```hcl
# Update Terraform variables
eks_desired_size = 3  # Default: 2
eks_max_size = 10
```

### Cluster Expansion
```bash
terraform apply  # Updates cluster definition
# Nodes scale up automatically
```

---

## 🆘 Troubleshooting

### Quick Checks
```bash
# Cluster health
kubectl get nodes
kubectl get pods -A

# Pod status
kubectl describe pod -n static-app

# Service IP
kubectl get svc -n static-app

# Logs
kubectl logs -l app=static-app -n static-app --tail=50
```

**[Full Troubleshooting Guide →](TROUBLESHOOTING.md)**

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **README.md** | Overview (you are here) |
| **STRUCTURE.md** | Folder organization & file descriptions |
| **SETUP_GUIDE.md** | Step-by-step setup instructions |
| **TERRAFORM_GUIDE.md** | Terraform configuration in detail |
| **TROUBLESHOOTING.md** | Common issues & solutions |
| **PIPELINE_QUICK_REFERENCE.md** | CI/CD pipeline reference |

---

## ✅ Verification Checklist

After setup, verify:

- [ ] Terraform cluster deployed successfully
- [ ] kubectl can connect to cluster (`kubectl get nodes`)
- [ ] K8s manifests deployed (`kubectl get pods -n static-app`)
- [ ] Service has external IP (`kubectl get svc -n static-app`)
- [ ] App accessible via external IP
- [ ] ArgoCD installed and syncing
- [ ] Pipeline triggered on git push
- [ ] All pipeline stages completed successfully
- [ ] App accessible via LoadBalancer IP
- [ ] Monitoring stack running (if enabled)

---

## 🎓 Next Steps

1. **Customize**: Modify app for your requirements
2. **Security**: Add network policies, RBAC, SSL certificates
3. **Monitoring**: Create custom Grafana dashboards
4. **Backup**: Configure cluster backups
5. **Cost Optimization**: Review and optimize resource usage
6. **Service Mesh**: Add Istio for advanced networking
7. **Multi-Region**: Deploy to multiple cloud regions

---

## 💡 Key Concepts

### Static Application
No backend server - everything runs in the browser using JavaScript and LocalStorage.

### Infrastructure as Code
All infrastructure (VPC, cluster, nodes) defined in Terraform - version controlled and reproducible.

### GitOps
Kubernetes state stored in Git - ArgoCD automatically syncs cluster to match repository.

### CI/CD Pipeline
Automated flow: Code → Build → Test → Container → Registry → Kubernetes → Monitoring

### Kubernetes
Container orchestration - handles deployment, scaling, and management of pods.

### GitOps vs Traditional Deployment
```
Traditional:    Developer → Push → CI/CD Server → Alert → Manual Approval → Deploy
GitOps:         Developer → Push → CI/CD Build → Auto Push → Git Watches → Auto Deploy
```

---

## 🐛 Common Issues

### Can't connect to cluster
```bash
# Reconfigure kubeconfig
aws eks update-kubeconfig --name <cluster> --region eu-west-1
# OR
az aks get-credentials --resource-group <rg> --name <cluster>
```

### Pod won't start
```bash
# Check logs
kubectl logs <pod> -n static-app
kubectl describe pod <pod> -n static-app
```

### Service has no external IP
```bash
# Check load balancer
kubectl get svc -n static-app
kubectl describe svc static-app-service -n static-app
```

### ArgoCD not syncing
```bash
# Check application status
kubectl describe app static-app-app -n argocd
# Verify git repo access
```

**[More Issues →](TROUBLESHOOTING.md)**

---

## 📞 Support

- **Documentation**: See links above
- **Logs**: `kubectl logs -n static-app -l app=static-app`
- **Events**: `kubectl get events -n static-app`
- **GitHub Issues**: Create an issue in the repository

---

## 📜 License

This project is provided as-is for educational and commercial use.

---

## 👨‍💻 Author

Created as a complete example of modern DevOps practices for static web applications.

---

## 🎉 Ready to Deploy?

Start with: **[SETUP_GUIDE.md](SETUP_GUIDE.md)**

Good luck! 🚀

