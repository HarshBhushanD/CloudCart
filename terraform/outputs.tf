output "cloudcart_namespace" {
  description = "CloudCart Kubernetes namespace"
  value       = kubernetes_namespace.cloudcart.metadata[0].name
}

output "auth_service_name" {
  description = "CloudCart Auth Kubernetes service"
  value       = kubernetes_service.auth_service.metadata[0].name
}

output "product_service_name" {
  description = "CloudCart Product Kubernetes service"
  value       = kubernetes_service.product_service.metadata[0].name
}

output "auth_service_port" {
  description = "CloudCart Auth service port"
  value       = kubernetes_service.auth_service.spec[0].port[0].port
}

output "product_service_port" {
  description = "CloudCart Product service port"
  value       = kubernetes_service.product_service.spec[0].port[0].port
}