#!/bin/bash

# DevOps Capstone Project - Health Check Script
# This script performs comprehensive health checks on all components

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
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
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
    if command -v $1 &> /dev/null; then
        print_success "$1 is installed"
        return 0
    else
        print_error "$1 is not installed"
        return 1
    fi
}

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local timeout=${3:-10}
    
    if curl -f -s --max-time $timeout "$url" > /dev/null 2>&1; then
        print_success "$description: $url"
        return 0
    else
        print_error "$description: $url (timeout: ${timeout}s)"
        return 1
    fi
}

# Function to check pod status
check_pod_status() {
    local namespace=$1
    local label_selector=${2:-""}
    
    if [ -n "$label_selector" ]; then
        pods=$(kubectl get pods -n $namespace -l $label_selector -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
    else
        pods=$(kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || echo "")
    fi
    
    if [ -z "$pods" ]; then
        print_warning "No pods found in namespace $namespace"
        return 1
    fi
    
    local all_ready=true
    for pod in $pods; do
        status=$(kubectl get pod $pod -n $namespace -o jsonpath='{.status.phase}' 2>/dev/null || echo "Unknown")
        ready=$(kubectl get pod $pod -n $namespace -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null || echo "false")
        
        if [ "$status" = "Running" ] && [ "$ready" = "true" ]; then
            print_success "Pod $pod: Running and Ready"
        else
            print_error "Pod $pod: $status (Ready: $ready)"
            all_ready=false
        fi
    done
    
    return $([ "$all_ready" = true ] && echo 0 || echo 1)
}

# Initialize counters
total_checks=0
passed_checks=0

increment_check() {
    total_checks=$((total_checks + 1))
    if [ $1 -eq 0 ]; then
        passed_checks=$((passed_checks + 1))
    fi
}

print_header "🔍 DevOps Capstone Project - Health Check"

# Step 1: Check Prerequisites
print_header "📋 Prerequisites Check"

check_command "kubectl"
increment_check $?

check_command "helm"
increment_check $?

check_command "docker"
increment_check $?

check_command "minikube"
increment_check $?

# Check Minikube status
print_status "Checking Minikube status..."
if minikube status &> /dev/null; then
    print_success "Minikube is running"
    increment_check 0
    MINIKUBE_IP=$(minikube ip)
    print_status "Minikube IP: $MINIKUBE_IP"
else
    print_error "Minikube is not running"
    increment_check 1
fi

# Step 2: Check Cluster Status
print_header "☸️ Kubernetes Cluster Status"

print_status "Checking cluster connectivity..."
if kubectl cluster-info &> /dev/null; then
    print_success "Cluster is accessible"
    increment_check 0
else
    print_error "Cannot connect to cluster"
    increment_check 1
fi

# Check nodes
print_status "Checking node status..."
node_status=$(kubectl get nodes --no-headers | awk '{print $2}' | head -1)
if [ "$node_status" = "Ready" ]; then
    print_success "Node is Ready"
    increment_check 0
else
    print_error "Node status: $node_status"
    increment_check 1
fi

# Step 3: Check Namespaces
print_header "🗂️ Namespace Status"

namespaces=("capstone" "monitoring" "argocd")

for namespace in "${namespaces[@]}"; do
    print_status "Checking namespace: $namespace"
    if kubectl get namespace $namespace &> /dev/null; then
        print_success "Namespace $namespace exists"
        increment_check 0
    else
        print_error "Namespace $namespace does not exist"
        increment_check 1
    fi
done

# Step 4: Check Application Pods
print_header "📦 Application Pod Status"

print_status "Checking capstone application pods..."
if kubectl get namespace capstone &> /dev/null; then
    check_pod_status "capstone"
    increment_check $?
else
    print_error "Capstone namespace not found"
    increment_check 1
fi

# Step 5: Check Monitoring Stack
print_header "📊 Monitoring Stack Status"

print_status "Checking monitoring pods..."
if kubectl get namespace monitoring &> /dev/null; then
    check_pod_status "monitoring"
    increment_check $?
else
    print_error "Monitoring namespace not found"
    increment_check 1
fi

# Step 6: Check ArgoCD
print_header "🔄 ArgoCD Status"

print_status "Checking ArgoCD pods..."
if kubectl get namespace argocd &> /dev/null; then
    check_pod_status "argocd"
    increment_check $?
else
    print_error "ArgoCD namespace not found"
    increment_check 1
fi

# Step 7: Check Services
print_header "🌐 Service Status"

services=(
    "capstone:frontend-service"
    "capstone:backend-service"
    "capstone:mongodb-service"
    "monitoring:prometheus-grafana"
    "argocd:argocd-server"
)

for service_info in "${services[@]}"; do
    IFS=':' read -r namespace service <<< "$service_info"
    print_status "Checking service: $service in $namespace"
    
    if kubectl get service $service -n $namespace &> /dev/null; then
        cluster_ip=$(kubectl get service $service -n $namespace -o jsonpath='{.spec.clusterIP}')
        port=$(kubectl get service $service -n $namespace -o jsonpath='{.spec.ports[0].port}')
        print_success "Service $service: $cluster_ip:$port"
        increment_check 0
    else
        print_error "Service $service not found in namespace $namespace"
        increment_check 1
    fi
done

# Step 8: Check Ingress
print_header "🚪 Ingress Status"

print_status "Checking ingress resources..."
ingresses=$(kubectl get ingress --all-namespaces --no-headers 2>/dev/null | wc -l)
if [ $ingresses -gt 0 ]; then
    print_success "Found $ingresses ingress resource(s)"
    kubectl get ingress --all-namespaces
    increment_check 0
else
    print_warning "No ingress resources found"
    increment_check 1
fi

# Step 9: Application Health Checks
print_header "🏥 Application Health Checks"

# Test backend health endpoint through port-forward
print_status "Testing backend health endpoint..."
if kubectl get service backend-service -n capstone &> /dev/null; then
    kubectl port-forward -n capstone service/backend-service 3001:3000 &
    PORT_FORWARD_PID=$!
    sleep 3
    
    if test_endpoint "http://localhost:3001/health" "Backend Health"; then
        increment_check 0
    else
        increment_check 1
    fi
    
    kill $PORT_FORWARD_PID &> /dev/null || true
else
    print_error "Backend service not found"
    increment_check 1
fi

# Test frontend through port-forward
print_status "Testing frontend accessibility..."
if kubectl get service frontend-service -n capstone &> /dev/null; then
    kubectl port-forward -n capstone service/frontend-service 8081:80 &
    PORT_FORWARD_PID=$!
    sleep 3
    
    if test_endpoint "http://localhost:8081" "Frontend"; then
        increment_check 0
    else
        increment_check 1
    fi
    
    kill $PORT_FORWARD_PID &> /dev/null || true
else
    print_error "Frontend service not found"
    increment_check 1
fi

# Step 10: Resource Usage
print_header "📈 Resource Usage"

print_status "Checking node resource usage..."
kubectl top nodes 2>/dev/null || print_warning "Metrics server may not be available"

print_status "Checking pod resource usage..."
kubectl top pods --all-namespaces 2>/dev/null || print_warning "Metrics server may not be available"

# Step 11: Storage Status
print_header "💾 Storage Status"

print_status "Checking persistent volumes..."
pvs=$(kubectl get pv --no-headers 2>/dev/null | wc -l)
if [ $pvs -gt 0 ]; then
    print_success "Found $pvs persistent volume(s)"
    kubectl get pv
    increment_check 0
else
    print_warning "No persistent volumes found"
    increment_check 1
fi

print_status "Checking persistent volume claims..."
pvcs=$(kubectl get pvc --all-namespaces --no-headers 2>/dev/null | wc -l)
if [ $pvcs -gt 0 ]; then
    print_success "Found $pvcs persistent volume claim(s)"
    kubectl get pvc --all-namespaces
    increment_check 0
else
    print_warning "No persistent volume claims found"
    increment_check 1
fi

# Step 12: Final Summary
print_header "📋 Health Check Summary"

# Calculate percentage
if [ $total_checks -gt 0 ]; then
    percentage=$((passed_checks * 100 / total_checks))
else
    percentage=0
fi

cat << EOF

==============================================================
🏥 Health Check Results
==============================================================

📊 Overall Status: $passed_checks/$total_checks checks passed ($percentage%)

$(if [ $percentage -ge 90 ]; then
    echo -e "${GREEN}🎉 Excellent! System is healthy${NC}"
elif [ $percentage -ge 75 ]; then
    echo -e "${YELLOW}⚠️  Good, but some issues detected${NC}"
elif [ $percentage -ge 50 ]; then
    echo -e "${YELLOW}⚠️  System partially functional${NC}"
else
    echo -e "${RED}🚨 Critical issues detected${NC}"
fi)

==============================================================
🔗 Quick Access Commands:
──────────────────────────

# Access frontend
kubectl port-forward -n capstone service/frontend-service 8080:80
# Then open: http://localhost:8080

# Access Grafana
kubectl port-forward -n monitoring service/prometheus-grafana 3000:80
# Then open: http://localhost:3000 (admin/admin123)

# Access ArgoCD
kubectl port-forward -n argocd service/argocd-server 8080:80
# Then open: http://localhost:8080 (admin/password)

# Check logs
kubectl logs -n capstone deployment/frontend
kubectl logs -n capstone deployment/backend

# Scale applications
kubectl scale deployment frontend --replicas=3 -n capstone
kubectl scale deployment backend --replicas=3 -n capstone

==============================================================
🛠️  Troubleshooting:
───────────────────

$(if [ $percentage -lt 100 ]; then
cat << 'TROUBLESHOOT'
If issues were detected:

1. Check pod logs:
   kubectl logs -f deployment/<deployment-name> -n <namespace>

2. Describe problematic resources:
   kubectl describe pod <pod-name> -n <namespace>

3. Check events:
   kubectl get events --sort-by='.lastTimestamp' -n <namespace>

4. Restart deployments:
   kubectl rollout restart deployment/<deployment-name> -n <namespace>

5. Re-run deployment:
   ./scripts/deploy-all.sh

TROUBLESHOOT
else
    echo "✅ No issues detected. System is operating normally!"
fi)

==============================================================

Health check completed at $(date)

EOF

# Exit with appropriate code
if [ $percentage -ge 75 ]; then
    print_success "Health check completed successfully!"
    exit 0
else
    print_warning "Health check completed with issues detected."
    exit 1
fi