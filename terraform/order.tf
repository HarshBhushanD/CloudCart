resource "kubernetes_deployment" "order_service" {
  metadata {
    name      = "order-service"
    namespace = kubernetes_namespace.cloudcart.metadata[0].name
  }

  lifecycle {
    ignore_changes = [
      spec[0].template[0].metadata[0].annotations
    ]
  }

  spec {
    replicas = 2

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "25%"
        max_unavailable = "25%"
      }
    }

    selector {
      match_labels = {
        app = "order-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "order-service"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name  = "order-service"
          image = "cloudcart-order-service:v2"

          port {
            container_port = 5003
          }

          env {
            name  = "PORT"
            value = "5003"
          }

          env {
            name  = "DB_USER"
            value = "postgres"
          }

          env {
            name  = "DB_HOST"
            value = "postgres-order"
          }

          env {
            name  = "DB_NAME"
            value = "cloudcart_orders"
          }

          env {
            name  = "DB_PASSWORD"
            value = "password"
          }

          env {
            name  = "DB_PORT"
            value = "5432"
          }

          env {
            name = "JWT_SECRET"

            value_from {
              secret_key_ref {
                name = "cloudcart-secrets"
                key  = "JWT_SECRET"
              }
            }
          }

          env {
            name  = "PRODUCT_SERVICE_URL"
            value = "http://product-service:5002"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5003
            }

            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5003
            }

            initial_delay_seconds = 5
            period_seconds        = 5
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}