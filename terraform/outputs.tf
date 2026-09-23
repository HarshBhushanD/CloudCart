output "cloudcart_namespace" {
  value = kubernetes_namespace.cloudcart.metadata[0].name
}