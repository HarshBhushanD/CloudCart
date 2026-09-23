resource "kubernetes_service" "auth_service" {
  metadata {
    name      = "auth-service"
    namespace = kubernetes_namespace.cloudcart.metadata[0].name
  }

  lifecycle {
    ignore_changes = [
      wait_for_load_balancer
    ]
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "auth-service"
    }

    port {
      port        = 5001
      target_port = 5001
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service" "product_service" {
  metadata {
    name      = "product-service"
    namespace = kubernetes_namespace.cloudcart.metadata[0].name
  }

  lifecycle {
    ignore_changes = [
      wait_for_load_balancer
    ]
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "product-service"
    }

    port {
      port        = 5002
      target_port = 5002
      protocol    = "TCP"
    }
  }
}