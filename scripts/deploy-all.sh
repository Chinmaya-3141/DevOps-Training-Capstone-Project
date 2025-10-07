#!/bin/bash

# DevOps Capstone Project - Complete Deployment Script
# This script deploys the entire capstone project infrastructure and applications

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}"
    echo "=================================================="
    echo "$1"
    echo "=================================================="
    echo -e "${NC}"
}

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_error "$1 is not installed. Please install it first."
        exit 1
    fi
}

# Function to wait for pods to be ready
wait_for_pods() {
    local namespace=$1
    local timeout=${2:-300}
    
    print_status "Waiting for pods in namespace '$namespace' to be ready..."
    kubectl wait --for=condition=ready pod --all -n $namespace --timeout=${timeout}s || {
        print_warning "Some pods in '$namespace' are not ready yet. Continuing..."
    }
}

# Function to check if namespace exists
namespace_exists() {
    kubectl get namespace $1 &> /dev/null
}

print_header "🚀 DevOps Capstone Project Deployment"

# Step 1: Prerequisites Check
print_header "📋 Checking Prerequisites"

check_command "kubectl"
check_command "helm"
check_command "terraform"
check_command "ansible-playbook"
check_command "docker"
check_command "minikube"

print_status "Checking if Minikube is running..."
if ! minikube status &> /dev/null; then
    print_error "Minikube is not running. Please start it with: minikube start"
    exit 1
fi

print_success "All prerequisites are satisfied!"

# Step 2: Infrastructure Setup with Terraform
print_header "🏗️ Setting up Infrastructure with Terraform"

cd infrastructure/terraform

print_status "Initializing Terraform..."
terraform init

print_status "Planning Terraform deployment..."
terraform plan -out=tfplan

print_status "Applying Terraform configuration..."
terraform apply -auto-approve tfplan

print_success "Infrastructure setup completed!"
cd ../..

# Step 3: Cluster Configuration with Ansible
print_header "⚙️ Configuring Cluster with Ansible"

cd infrastructure/ansible

print_status "Running Ansible playbook..."
ansible-playbook setup.yml

print_success "Cluster configuration completed!"
cd ../..

# Step 4: Install Application Dependencies  
print_header "📦 Installing Application Dependencies"

print_status "Installing frontend dependencies..."
cd services/frontend
if [ ! -d "node_modules" ]; then
    npm install
fi
cd ../..

print_status "Installing backend dependencies..."
cd services/backend
if [ ! -d "node_modules" ]; then
    npm install
    mkdir -p logs
fi
cd ../..

print_success "Application dependencies installed!"

# Step 5: Build and Push Docker Images
print_header "🐳 Building and Pushing Docker Images"

# Configure Docker to use Minikube's Docker daemon
eval $(minikube docker-env)

print_status "Building frontend image..."
docker build -t capstone/frontend:latest services/frontend/

print_status "Building backend image..."
docker build -t capstone/backend:latest services/backend/

print_success "Docker images built successfully!"

# Step 6: Deploy Services with Helm
print_header "☸️ Deploying Services with Helm"

# Wait for namespaces to be ready
wait_for_pods "kube-system" 120

print_status "Installing MongoDB..."
helm upgrade --install mongodb \
    --repo https://charts.bitnami.com/bitnami mongodb \
    --namespace capstone \
    --create-namespace \
    --set auth.enabled=false \
    --set architecture=standalone \
    --set persistence.enabled=true \
    --set persistence.size=5Gi \
    --set service.nameOverride=mongodb-service \
    --wait

print_status "Installing backend service..."
helm upgrade --install backend helm-charts/backend \
    --namespace capstone \
    --wait

print_status "Installing frontend service..."
helm upgrade --install frontend helm-charts/frontend \
    --namespace capstone \
    --wait

print_success "Services deployed successfully!"

# Step 7: Setup Monitoring Stack
print_header "📊 Setting up Monitoring Stack"

print_status "Installing Prometheus and Grafana..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    -f monitoring/prometheus/values.yaml \
    --wait

wait_for_pods "monitoring" 300

print_success "Monitoring stack deployed successfully!"

# Step 8: Setup ArgoCD
print_header "🔄 Setting up ArgoCD for GitOps"

print_status "Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

print_status "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

print_status "Applying ArgoCD applications..."
kubectl apply -f ci-cd/argocd/application.yaml

print_success "ArgoCD setup completed!"

# Step 9: Configure Ingress
print_header "🌐 Configuring Ingress"

print_status "Enabling Minikube ingress addon..."
minikube addons enable ingress

print_status "Waiting for ingress controller to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/ingress-nginx-controller -n ingress-nginx

print_success "Ingress configured successfully!"

# Step 10: Health Checks
print_header "🔍 Running Health Checks"

print_status "Checking application health..."

# Check if all pods are running
kubectl get pods --all-namespaces

print_status "Checking services..."
kubectl get services -n capstone

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
print_status "Minikube IP: $MINIKUBE_IP"

# Test backend health (through port-forward)
print_status "Testing backend health endpoint..."
kubectl port-forward -n capstone service/backend-service 3000:3000 &
PORT_FORWARD_PID=$!
sleep 5

if curl -f http://localhost:3000/health &> /dev/null; then
    print_success "Backend health check passed!"
else
    print_warning "Backend health check failed. Check logs: kubectl logs -n capstone deployment/backend"
fi

# Clean up port-forward
kill $PORT_FORWARD_PID &> /dev/null || true

print_success "Health checks completed!"

# Step 11: Display Access Information
print_header "🎉 Deployment Completed Successfully!"

cat << EOF

==============================================================
🌟 DevOps Capstone Project is now running! 🌟
==============================================================

📍 Access Information:
──────────────────────

🌐 Frontend Application:
   http://$MINIKUBE_IP (or use port-forward)
   kubectl port-forward -n capstone service/frontend-service 8080:80

🔧 Backend API:
   http://$MINIKUBE_IP:30000 (or use port-forward)
   kubectl port-forward -n capstone service/backend-service 3000:3000

📊 Grafana Dashboard:
   kubectl port-forward -n monitoring service/prometheus-grafana 3000:80
   Access: http://localhost:3000
   Username: admin
   Password: admin123

🔄 ArgoCD UI:
   kubectl port-forward -n argocd service/argocd-server 8080:80
   Access: http://localhost:8080
   Username: admin
   Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

📈 Prometheus:
   kubectl port-forward -n monitoring service/prometheus-kube-prometheus-prometheus 9090:9090
   Access: http://localhost:9090

==============================================================
📝 Useful Commands:
──────────────────────

# Check all pods
kubectl get pods --all-namespaces

# View application logs
kubectl logs -n capstone deployment/frontend
kubectl logs -n capstone deployment/backend

# Access Minikube dashboard
minikube dashboard

# Enable tunnel for LoadBalancer services
minikube tunnel

# Scale services
kubectl scale deployment frontend --replicas=3 -n capstone
kubectl scale deployment backend --replicas=3 -n capstone

==============================================================
🔧 Troubleshooting:
──────────────────

# If pods are not starting:
kubectl describe pod <pod-name> -n <namespace>

# If images are not found:
eval \$(minikube docker-env)
docker images | grep capstone

# Restart deployment:
kubectl rollout restart deployment/<deployment-name> -n capstone

==============================================================
📚 Next Steps:
────────────

1. 🧪 Run tests: ./scripts/run-tests.sh
2. 📊 Set up monitoring dashboards in Grafana
3. 🔄 Configure ArgoCD applications for GitOps
4. 🔐 Implement security scanning with ./scripts/security-scan.sh
5. 🧹 Clean up when done: ./scripts/cleanup.sh

==============================================================

Happy DevOps-ing! 🚀

EOF

print_success "All deployment steps completed successfully!"
print_status "Check the above information for access details and next steps."