# DevOps Capstone Project - Installation Guide

## Overview

This guide provides step-by-step instructions to implement a complete DevOps pipeline for a microservices application using modern tools and best practices.

## Prerequisites

### System Requirements
- Ubuntu 20.04 LTS or later (Windows users can use WSL2)
- Minimum 8GB RAM (16GB recommended)
- 50GB free disk space
- Internet connection for downloads

### Required Tools Installation

Run the following commands to install all prerequisites:

```bash
# Update system
sudo apt update 

# Install essential tools
sudo apt install -y curl wget git vim unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update && sudo apt install helm

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install Ansible
sudo apt install -y ansible

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update && sudo apt install -y openjdk-11-jdk jenkins
sudo systemctl start jenkins && sudo systemctl enable jenkins

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

## Quick Start

### 1. Clone and Setup Project

```bash
# Clone the project (or create from scratch)
git clone https://github.com/your-org/capstone-01
cd capstone-01

# Make scripts executable
chmod +x scripts/*.sh
```

### 2. Start Minikube

```bash
# Start Minikube with adequate resources
minikube start --driver=docker --cpus=4 --memory=6144

# Verify installation
minikube status
kubectl cluster-info
```

### 3. Deploy Everything

```bash
# Run the complete deployment script
./scripts/deploy-all.sh
```

This single command will:
- ✅ Set up infrastructure with Terraform
- ✅ Configure cluster with Ansible  
- ✅ Build and push Docker images
- ✅ Deploy services with Helm
- ✅ Install monitoring stack (Prometheus, Grafana)
- ✅ Setup ArgoCD for GitOps
- ✅ Configure ingress and networking
- ✅ Run health checks

### 4. Verify Installation

```bash
# Run comprehensive health checks
./scripts/health-check.sh
```

## Step-by-Step Implementation

If you prefer manual implementation or want to understand each step:

### Phase 1: Infrastructure Setup

```bash
# Apply Terraform configuration
cd infrastructure/terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
cd ../..

# Run Ansible playbook
cd infrastructure/ansible
ansible-playbook setup.yml
cd ../..
```

### Phase 2: Build Applications

```bash
# Configure Docker for Minikube
eval $(minikube docker-env)

# Build frontend
cd services/frontend
docker build -t capstone/frontend:latest .
cd ../..

# Build backend  
cd services/backend
docker build -t capstone/backend:latest .
cd ../..
```

### Phase 3: Deploy Services

```bash
# Install MongoDB
helm upgrade --install mongodb \
    --repo https://charts.bitnami.com/bitnami mongodb \
    --namespace capstone \
    --create-namespace \
    --set auth.enabled=false \
    --set service.nameOverride=mongodb-service

# Deploy backend
helm upgrade --install backend helm-charts/backend --namespace capstone

# Deploy frontend
helm upgrade --install frontend helm-charts/frontend --namespace capstone
```

### Phase 4: Setup Monitoring

```bash
# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus stack
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    -f monitoring/prometheus/values.yaml
```

### Phase 5: Setup ArgoCD

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply ArgoCD applications
kubectl apply -f ci-cd/argocd/application.yaml
```

## Access Information

After deployment, access your services:

### Frontend Application
```bash
kubectl port-forward -n capstone service/frontend-service 8080:80
# Open: http://localhost:8080
```

### Backend API  
```bash
kubectl port-forward -n capstone service/backend-service 3000:3000
# Test: curl http://localhost:3000/health
```

### Grafana Dashboard
```bash
kubectl port-forward -n monitoring service/prometheus-grafana 3000:80
# Open: http://localhost:3000
# Login: admin / admin123
```

### ArgoCD UI
```bash
kubectl port-forward -n argocd service/argocd-server 8080:80
# Open: http://localhost:8080  
# Login: admin / password
```

### Prometheus
```bash
kubectl port-forward -n monitoring service/prometheus-kube-prometheus-prometheus 9090:9090
# Open: http://localhost:9090
```

## Verification Steps

### 1. Check All Pods
```bash
kubectl get pods --all-namespaces
```

### 2. Test Application Health
```bash
# Test backend
curl -f http://localhost:3000/health

# Check frontend
curl -f http://localhost:8080
```

### 3. Verify Monitoring
```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Verify Grafana login
curl -u admin:admin123 http://localhost:3000/api/health
```

### 4. Test ArgoCD
```bash
# Check ArgoCD applications
kubectl get applications -n argocd
```

## Jenkins Pipeline Setup

### 1. Access Jenkins
```bash
# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Access Jenkins at http://localhost:8080
```

### 2. Configure Pipeline
1. Create new Pipeline job
2. Configure GitHub repository
3. Use `ci-cd/jenkins/Jenkinsfile`
4. Add required credentials:
   - `kubeconfig`: Kubernetes config file
   - `github-token`: GitHub personal access token

### 3. Required Jenkins Plugins
- Docker Pipeline
- Kubernetes
- Git
- Pipeline
- Blue Ocean (optional)

## Troubleshooting

### Common Issues

#### 1. Minikube won't start
```bash
minikube delete
minikube start --driver=docker --cpus=4 --memory=6144
```

#### 2. Images not found
```bash
eval $(minikube docker-env)
# Rebuild images
docker build -t capstone/frontend:latest services/frontend/
docker build -t capstone/backend:latest services/backend/
```

#### 3. Pods stuck in Pending
```bash
kubectl describe pod <pod-name> -n <namespace>
# Check resource limits and node capacity
```

#### 4. Services not accessible
```bash
kubectl get svc -n capstone
minikube tunnel  # For LoadBalancer services
```

#### 5. Jenkins can't access Docker
```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Debug Commands

```bash
# Check cluster info
kubectl cluster-info
kubectl get nodes

# Check all resources
kubectl get all --all-namespaces

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check logs
kubectl logs -f deployment/<name> -n <namespace>

# Describe resources
kubectl describe pod <pod-name> -n <namespace>

# Access minikube dashboard
minikube dashboard
```

## Performance Tuning

### Resource Allocation
```bash
# Increase Minikube resources if needed
minikube stop
minikube start --cpus=6 --memory=8192

# Enable more addons
minikube addons enable metrics-server
minikube addons enable ingress
```

### Optimize Applications
```bash
# Scale deployments
kubectl scale deployment frontend --replicas=3 -n capstone
kubectl scale deployment backend --replicas=3 -n capstone

# Enable autoscaling
kubectl autoscale deployment frontend --min=2 --max=10 --cpu-percent=80 -n capstone
```

## Security Considerations

### 1. Enable Network Policies
```yaml
# Already included in Terraform configuration
# Restricts pod-to-pod communication
```

### 2. Use Secrets for Sensitive Data
```bash
kubectl create secret generic app-secrets \
  --from-literal=mongodb-uri="mongodb://mongodb-service:27017/capstone" \
  -n capstone
```

### 3. Enable RBAC
```yaml
# Already configured in Helm charts
# Follows principle of least privilege
```

### 4. Container Security
```bash
# Run security scans
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image capstone/frontend:latest
```

## Cleanup

When you're finished with the project:

```bash
# Complete cleanup
./scripts/cleanup.sh

# Or manually clean specific components
helm uninstall prometheus -n monitoring
helm uninstall frontend backend -n capstone
kubectl delete namespace capstone monitoring argocd
```

## Next Steps and Enhancements

### 1. Advanced Monitoring
- Set up distributed tracing with Jaeger
- Add log aggregation with ELK stack
- Configure advanced alerting rules

### 2. Security Enhancements
- Implement HashiCorp Vault for secrets
- Add Pod Security Standards
- Enable admission controllers

### 3. Advanced Deployments
- Implement blue-green deployment
- Add canary releases
- Multi-environment setup (dev/staging/prod)

### 4. Performance Optimization
- Add CDN for frontend
- Implement caching strategies
- Database optimization

### 5. Compliance and Governance
- Add policy enforcement with Open Policy Agent
- Implement resource quotas and limits
- Add backup and disaster recovery

## Learning Resources

- **Kubernetes**: [Official Documentation](https://kubernetes.io/docs/)
- **Helm**: [Helm Documentation](https://helm.sh/docs/)
- **Prometheus**: [Prometheus Documentation](https://prometheus.io/docs/)
- **ArgoCD**: [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- **Jenkins**: [Jenkins Documentation](https://www.jenkins.io/doc/)
- **Terraform**: [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Run the health check script: `./scripts/health-check.sh`
3. Review logs: `kubectl logs -f deployment/<name> -n <namespace>`
4. Check GitHub issues or create a new one

---

**Congratulations!** You've successfully implemented a complete DevOps pipeline with microservices, containerization, orchestration, CI/CD, and monitoring. This project demonstrates real-world enterprise DevOps practices and provides a solid foundation for further learning and development.