terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "minikube"
  }
}

# Create namespace for the capstone application
resource "kubernetes_namespace" "capstone" {
  metadata {
    name = var.app_namespace
    labels = {
      "app.kubernetes.io/name"       = "capstone"
      "app.kubernetes.io/component"  = "namespace"
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

# Create namespace for monitoring stack
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
    labels = {
      "app.kubernetes.io/name"       = "monitoring"
      "app.kubernetes.io/component"  = "namespace"
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

# Create namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      "app.kubernetes.io/name"       = "argocd"
      "app.kubernetes.io/component"  = "namespace"
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
  }
}

# Create ConfigMap for application configuration
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "capstone-config"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "capstone"
      "app.kubernetes.io/component"  = "config"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    "NODE_ENV"     = var.environment
    "FRONTEND_URL" = "http://frontend-service"
    "API_URL"      = "http://backend-service:3000"
    "LOG_LEVEL"    = var.log_level
  }
}

# Create Secret for sensitive configuration
resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "capstone-secrets"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "capstone"
      "app.kubernetes.io/component"  = "secrets"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  type = "Opaque"

  data = {
    "mongodb-uri"    = base64encode(var.mongodb_uri)
    "jwt-secret"     = base64encode(var.jwt_secret)
    "session-secret" = base64encode(var.session_secret)
  }
}

# Network Policy for enhanced security
resource "kubernetes_network_policy" "capstone_network_policy" {
  metadata {
    name      = "capstone-network-policy"
    namespace = kubernetes_namespace.capstone.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "capstone"
      "app.kubernetes.io/component"  = "network-policy"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "capstone"
      }
    }

    policy_types = ["Ingress", "Egress"]

    # Allow ingress from frontend to backend
    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/component" = "frontend"
          }
        }
      }
      ports {
        port     = "3000"
        protocol = "TCP"
      }
    }

    # Allow ingress from ingress controller
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "name" = "ingress-nginx"
          }
        }
      }
    }

    # Allow egress to DNS
    egress {
      to {}
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }

    # Allow egress to MongoDB
    egress {
      to {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/component" = "mongodb"
          }
        }
      }
      ports {
        port     = "27017"
        protocol = "TCP"
      }
    }
  }
}

# Resource Quota for the namespace
resource "kubernetes_resource_quota" "capstone_quota" {
  metadata {
    name      = "capstone-quota"
    namespace = kubernetes_namespace.capstone.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"       = var.resource_quota.requests_cpu
      "requests.memory"    = var.resource_quota.requests_memory
      "limits.cpu"         = var.resource_quota.limits_cpu
      "limits.memory"      = var.resource_quota.limits_memory
      "persistentvolumeclaims" = var.resource_quota.pvc_count
      "services"           = var.resource_quota.services_count
      "pods"               = var.resource_quota.pods_count
    }
  }
}

# Limit Range for pod resource constraints
resource "kubernetes_limit_range" "capstone_limits" {
  metadata {
    name      = "capstone-limits"
    namespace = kubernetes_namespace.capstone.metadata[0].name
  }

  spec {
    limit {
      type = "Pod"
      max = {
        cpu    = "1000m"
        memory = "1Gi"
      }
      min = {
        cpu    = "100m"
        memory = "64Mi"
      }
    }

    limit {
      type = "Container"
      default = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "250m"
        memory = "256Mi"
      }
    }
  }
}