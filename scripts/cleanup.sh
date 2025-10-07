#!/bin/bash

# DevOps Capstone Project - Cleanup Script
# This script removes all resources created by the capstone project

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_header "🧹 DevOps Capstone Project Cleanup"

# Ask for confirmation
echo -e "${YELLOW}This will remove all capstone project resources including:${NC}"
echo "  - All Kubernetes namespaces (capstone, monitoring, argocd)"
echo "  - All Helm releases"
echo "  - Terraform state"
echo "  - Docker images"
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Step 1: Stop any running port-forwards
print_header "🔌 Stopping Port Forwards"
print_status "Killing any running kubectl port-forward processes..."
pkill -f "kubectl port-forward" || true
print_success "Port forwards stopped!"

# Step 2: Remove Helm releases
print_header "📦 Removing Helm Releases"

# Get list of releases in capstone namespace
if kubectl get namespace capstone &> /dev/null; then
    print_status "Removing Helm releases in capstone namespace..."
    helm list -n capstone -q | xargs -r helm uninstall -n capstone || true
fi

# Get list of releases in monitoring namespace
if kubectl get namespace monitoring &> /dev/null; then
    print_status "Removing Helm releases in monitoring namespace..."
    helm list -n monitoring -q | xargs -r helm uninstall -n monitoring || true
fi

# Get list of releases in argocd namespace
if kubectl get namespace argocd &> /dev/null; then
    print_status "Removing Helm releases in argocd namespace..."
    helm list -n argocd -q | xargs -r helm uninstall -n argocd || true
fi

print_success "Helm releases removed!"

# Step 3: Remove Kubernetes namespaces
print_header "🗂️ Removing Kubernetes Namespaces"

namespaces=("capstone" "monitoring" "argocd")

for namespace in "${namespaces[@]}"; do
    if kubectl get namespace $namespace &> /dev/null; then
        print_status "Deleting namespace: $namespace"
        kubectl delete namespace $namespace --ignore-not-found=true &
    fi
done

print_status "Waiting for namespaces to be fully deleted..."
wait

print_success "Namespaces removed!"

# Step 4: Remove custom resources
print_header "🔧 Removing Custom Resources"

print_status "Removing ArgoCD applications..."
kubectl delete applications --all -n argocd --ignore-not-found=true || true

print_status "Removing persistent volumes..."
kubectl delete pv --all --ignore-not-found=true || true

print_status "Removing ingress resources..."
kubectl delete ingress --all --all-namespaces --ignore-not-found=true || true

print_success "Custom resources removed!"

# Step 5: Clean up Docker images
print_header "🐳 Cleaning up Docker Images"

# Set Minikube Docker environment
eval $(minikube docker-env) 2>/dev/null || true

print_status "Removing capstone Docker images..."
docker images | grep capstone | awk '{print $3}' | xargs -r docker rmi -f || true

print_status "Cleaning up unused Docker resources..."
docker system prune -f || true

print_success "Docker cleanup completed!"

# Step 6: Terraform cleanup
print_header "🏗️ Terraform Cleanup"

if [ -d "infrastructure/terraform" ]; then
    cd infrastructure/terraform
    
    if [ -f "terraform.tfstate" ] || [ -f "terraform.tfstate.backup" ]; then
        print_status "Destroying Terraform resources..."
        terraform destroy -auto-approve || {
            print_warning "Terraform destroy failed. Forcing state cleanup..."
            rm -f terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
            rm -rf .terraform/
        }
    else
        print_status "No Terraform state found, skipping destroy."
    fi
    
    cd ../..
fi

print_success "Terraform cleanup completed!"

# Step 7: Clean up local files
print_header "📁 Cleaning up Local Files"

print_status "Removing temporary files..."

# Remove log files
find . -name "*.log" -type f -delete || true
find . -name "ansible.log" -type f -delete || true

# Remove build artifacts
rm -rf build-logs/ test-results/ security-reports/ || true
rm -rf services/frontend/node_modules/ || true
rm -rf services/backend/node_modules/ || true
rm -rf services/frontend/build/ || true
rm -rf services/frontend/coverage/ || true
rm -rf services/backend/coverage/ || true

# Remove Ansible generated files
rm -f infrastructure/ansible/setup-info.md || true

print_success "Local files cleaned up!"

# Step 8: Reset Minikube (optional)
print_header "🔄 Minikube Reset (Optional)"

echo -e "${YELLOW}Do you want to completely reset Minikube? This will delete the entire cluster.${NC}"
read -p "Reset Minikube cluster? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Stopping Minikube..."
    minikube stop || true
    
    print_status "Deleting Minikube cluster..."
    minikube delete || true
    
    print_status "Starting fresh Minikube cluster..."
    minikube start --driver=docker --cpus=4 --memory=6144 || {
        print_error "Failed to start Minikube. Please start it manually later."
    }
    
    print_success "Minikube reset completed!"
else
    print_status "Keeping existing Minikube cluster."
fi

# Step 9: Final verification
print_header "✅ Final Verification"

print_status "Checking remaining resources..."

# Check for remaining namespaces
remaining_namespaces=$(kubectl get namespaces -o name | grep -E "(capstone|monitoring|argocd)" || true)
if [ -n "$remaining_namespaces" ]; then
    print_warning "Some namespaces are still terminating:"
    echo "$remaining_namespaces"
else
    print_success "All capstone namespaces removed!"
fi

# Check for remaining pods
remaining_pods=$(kubectl get pods --all-namespaces | grep -E "(capstone|monitoring|argocd)" || true)
if [ -n "$remaining_pods" ]; then
    print_warning "Some pods are still running:"
    echo "$remaining_pods"
else
    print_success "All capstone pods removed!"
fi

# Check Docker images
remaining_images=$(docker images | grep capstone || true)
if [ -n "$remaining_images" ]; then
    print_warning "Some capstone Docker images still exist:"
    echo "$remaining_images"
else
    print_success "All capstone Docker images removed!"
fi

print_header "🎉 Cleanup Completed!"

cat << EOF

==============================================================
✨ DevOps Capstone Project Cleanup Summary ✨
==============================================================

✅ Completed Tasks:
──────────────────
• Stopped all port-forward processes
• Removed Helm releases from all namespaces
• Deleted Kubernetes namespaces (capstone, monitoring, argocd)
• Cleaned up custom resources and persistent volumes
• Removed Docker images and performed system cleanup
• Destroyed Terraform infrastructure
• Cleaned up local temporary files and build artifacts

🧹 What was removed:
──────────────────
• Application deployments (frontend, backend, MongoDB)
• Monitoring stack (Prometheus, Grafana, AlertManager)
• GitOps tools (ArgoCD)
• Ingress controllers and network policies
• Persistent volumes and storage claims
• Docker images and containers
• Terraform state and resources

🔍 Verification:
──────────────
$(if [ -n "$remaining_namespaces" ] || [ -n "$remaining_pods" ] || [ -n "$remaining_images" ]; then
    echo "⚠️  Some resources may still be terminating"
    echo "   Run 'kubectl get all --all-namespaces' to check"
else
    echo "✅ All capstone resources have been successfully removed"
fi)

==============================================================
📝 Post-Cleanup Notes:
─────────────────────

• Minikube cluster is still running (unless you chose to reset it)
• You can redeploy the project anytime with: ./scripts/deploy-all.sh
• Your source code and configuration files are preserved
• Docker and Kubernetes tools are still available

==============================================================
🚀 To redeploy the project:
─────────────────────────

1. Run: ./scripts/deploy-all.sh
2. Wait for deployment to complete
3. Access applications via the provided URLs

==============================================================

Thank you for using the DevOps Capstone Project! 🙏

EOF

print_success "Cleanup completed successfully! 🎉"