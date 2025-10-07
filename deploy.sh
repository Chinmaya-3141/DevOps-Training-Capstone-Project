#!/bin/bash

# 🚀 Quick Deployment Script for DevOps Capstone Project
# This script helps you get started quickly with the project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}🚀 DevOps Capstone Project - Quick Setup${NC}"
    echo "=================================================="
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Commands:
    local       Start local development environment
    docker      Deploy with Docker Compose
    k8s         Deploy to Kubernetes (requires Minikube)
    clean       Clean up all resources
    help        Show this help message

Examples:
    $0 local    # Start local development
    $0 docker   # Deploy with Docker
    $0 k8s      # Deploy to Kubernetes
    $0 clean    # Clean everything up

EOF
}

setup_local() {
    print_info "Setting up local development environment..."
    
    # Install dependencies
    print_info "Installing dependencies..."
    if command -v npm &> /dev/null; then
        npm run install:all
        print_success "Dependencies installed"
    else
        print_error "npm not found. Please install Node.js"
        exit 1
    fi
    
    # Check if MongoDB is running
    print_info "Checking MongoDB..."
    if ! pgrep mongod > /dev/null; then
        print_warning "MongoDB not running. Please start MongoDB:"
        echo "  - macOS: brew services start mongodb-community"
        echo "  - Ubuntu: sudo systemctl start mongod"
        echo "  - Windows: net start MongoDB"
        echo ""
        print_info "Or use Docker: docker run -d -p 27017:27017 --name mongodb mongo:7.0"
    fi
    
    print_success "Local environment ready!"
    print_info "Start services:"
    echo "  Backend:  npm run start:backend"
    echo "  Frontend: npm run start:frontend"
    echo ""
    echo "Access: http://localhost:3000"
}

setup_docker() {
    print_info "Deploying with Docker Compose..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found. Please install Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose not found. Please install Docker Compose"
        exit 1
    fi
    
    print_info "Building and starting containers..."
    docker-compose up --build -d
    
    print_info "Waiting for services to be ready..."
    sleep 10
    
    # Health check
    if curl -f http://localhost:5000/health > /dev/null 2>&1; then
        print_success "Backend is healthy"
    else
        print_warning "Backend health check failed"
    fi
    
    if curl -f http://localhost > /dev/null 2>&1; then
        print_success "Frontend is accessible"
    else
        print_warning "Frontend not accessible yet"
    fi
    
    print_success "Docker deployment complete!"
    print_info "Services:"
    echo "  Frontend: http://localhost"
    echo "  Backend:  http://localhost:5000"
    echo "  Health:   http://localhost:5000/health"
    echo ""
    echo "View logs: docker-compose logs -f"
}

setup_k8s() {
    print_info "Deploying to Kubernetes..."
    
    # Check prerequisites
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl not found. Please install kubectl"
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        print_error "helm not found. Please install Helm"
        exit 1
    fi
    
    if ! command -v minikube &> /dev/null; then
        print_warning "minikube not found. Assuming you have a Kubernetes cluster"
    else
        print_info "Starting Minikube..."
        minikube start --driver=docker --cpus=4 --memory=6144
        eval $(minikube docker-env)
    fi
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    print_info "Building Docker images..."
    docker build -t capstone-frontend:latest ./services/frontend
    docker build -t capstone-backend:latest ./services/backend
    
    print_info "Deploying to Kubernetes..."
    if [ -x "./ci-cd/scripts/deploy.sh" ]; then
        ./ci-cd/scripts/deploy.sh --environment staging
    else
        print_warning "Deploy script not found. Creating basic deployment..."
        
        # Create namespace
        kubectl create namespace capstone-staging --dry-run=client -o yaml | kubectl apply -f -
        
        # Deploy MongoDB
        kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
  namespace: capstone-staging
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:7.0
        ports:
        - containerPort: 27017
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
  namespace: capstone-staging
spec:
  selector:
    app: mongodb
  ports:
  - port: 27017
    targetPort: 27017
EOF
        
        print_success "Basic MongoDB deployment created"
    fi
    
    print_success "Kubernetes deployment initiated!"
    print_info "Check status:"
    echo "  kubectl get all -n capstone-staging"
    echo "  kubectl port-forward svc/frontend 8080:80 -n capstone-staging"
}

cleanup_all() {
    print_info "Cleaning up all resources..."
    
    # Docker cleanup
    if command -v docker-compose &> /dev/null; then
        print_info "Stopping Docker Compose..."
        docker-compose down -v --remove-orphans
    fi
    
    # Kubernetes cleanup
    if command -v kubectl &> /dev/null; then
        print_info "Cleaning up Kubernetes resources..."
        kubectl delete namespace capstone-staging --ignore-not-found=true
        kubectl delete namespace capstone-production --ignore-not-found=true
    fi
    
    # Local cleanup
    print_info "Cleaning build artifacts..."
    find . -name "node_modules" -type d -prune -exec rm -rf {} + 2>/dev/null || true
    find . -name "dist" -type d -prune -exec rm -rf {} + 2>/dev/null || true
    find . -name "build" -type d -prune -exec rm -rf {} + 2>/dev/null || true
    
    print_success "Cleanup complete!"
}

main() {
    print_header
    
    case "${1:-help}" in
        local)
            setup_local
            ;;
        docker)
            setup_docker
            ;;
        k8s|kubernetes)
            setup_k8s
            ;;
        clean|cleanup)
            cleanup_all
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"