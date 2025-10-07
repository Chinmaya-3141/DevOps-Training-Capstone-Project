# Namespace Outputs
output "app_namespace" {
  description = "Application namespace name"
  value       = kubernetes_namespace.capstone.metadata[0].name
}

output "monitoring_namespace" {
  description = "Monitoring namespace name"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "argocd_namespace" {
  description = "ArgoCD namespace name"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

# Configuration Outputs
output "config_map_name" {
  description = "Application ConfigMap name"
  value       = kubernetes_config_map.app_config.metadata[0].name
}

output "secrets_name" {
  description = "Application Secrets name"
  value       = kubernetes_secret.app_secrets.metadata[0].name
}

# Resource Management Outputs
output "resource_quota_name" {
  description = "Resource quota name"
  value       = kubernetes_resource_quota.capstone_quota.metadata[0].name
}

output "limit_range_name" {
  description = "Limit range name"
  value       = kubernetes_limit_range.capstone_limits.metadata[0].name
}

output "network_policy_name" {
  description = "Network policy name"
  value       = kubernetes_network_policy.capstone_network_policy.metadata[0].name
}

# Environment Information
output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "ingress_domain" {
  description = "Ingress domain"
  value       = var.ingress_domain
}

# Useful kubectl commands
output "kubectl_commands" {
  description = "Useful kubectl commands for this deployment"
  value = {
    "get_pods"        = "kubectl get pods -n ${kubernetes_namespace.capstone.metadata[0].name}"
    "get_services"    = "kubectl get services -n ${kubernetes_namespace.capstone.metadata[0].name}"
    "get_configmap"   = "kubectl get configmap -n ${kubernetes_namespace.capstone.metadata[0].name}"
    "get_secrets"     = "kubectl get secrets -n ${kubernetes_namespace.capstone.metadata[0].name}"
    "describe_quota"  = "kubectl describe quota -n ${kubernetes_namespace.capstone.metadata[0].name}"
    "port_forward"    = "kubectl port-forward -n ${kubernetes_namespace.capstone.metadata[0].name} service/frontend-service 8080:80"
  }
}