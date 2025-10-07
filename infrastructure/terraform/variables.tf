# Environment Configuration
variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

# Namespace Variables
variable "app_namespace" {
  description = "Kubernetes namespace for the capstone application"
  type        = string
  default     = "capstone"
}

variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "argocd_namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

# Application Configuration
variable "mongodb_uri" {
  description = "MongoDB connection URI"
  type        = string
  default     = "mongodb://mongodb-service:27017/capstone"
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret for authentication"
  type        = string
  default     = "your-super-secret-jwt-key-change-in-production"
  sensitive   = true
}

variable "session_secret" {
  description = "Session secret for cookie signing"
  type        = string
  default     = "your-super-secret-session-key-change-in-production"
  sensitive   = true
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"
  
  validation {
    condition     = contains(["error", "warn", "info", "debug"], var.log_level)
    error_message = "Log level must be one of: error, warn, info, debug."
  }
}

# Resource Quota Configuration
variable "resource_quota" {
  description = "Resource quota limits for the capstone namespace"
  type = object({
    requests_cpu    = string
    requests_memory = string
    limits_cpu      = string
    limits_memory   = string
    pvc_count       = number
    services_count  = number
    pods_count      = number
  })
  
  default = {
    requests_cpu    = "2000m"
    requests_memory = "4Gi"
    limits_cpu      = "4000m"
    limits_memory   = "8Gi"
    pvc_count       = 5
    services_count  = 10
    pods_count      = 20
  }
}

# Ingress Configuration
variable "ingress_domain" {
  description = "Domain for ingress resources"
  type        = string
  default     = "capstone.local"
}

variable "enable_ssl" {
  description = "Enable SSL/TLS for ingress"
  type        = bool
  default     = false
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable monitoring stack (Prometheus, Grafana)"
  type        = bool
  default     = true
}

variable "monitoring_retention_days" {
  description = "Prometheus data retention in days"
  type        = number
  default     = 15
}

# ArgoCD Configuration
variable "enable_argocd" {
  description = "Enable ArgoCD for GitOps"
  type        = bool
  default     = true
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password (bcrypt hashed)"
  type        = string
  default     = "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/XhfIBB97T3nKNa" # "password"
  sensitive   = true
}

# Application Images
variable "frontend_image" {
  description = "Frontend Docker image"
  type        = string
  default     = "capstone/frontend:latest"
}

variable "backend_image" {
  description = "Backend Docker image"
  type        = string
  default     = "capstone/backend:latest"
}

variable "mongodb_image" {
  description = "MongoDB Docker image"
  type        = string
  default     = "mongo:6.0"
}