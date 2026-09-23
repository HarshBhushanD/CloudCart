resource "kubernetes_deployment" "product_service" {
  metadata {
    name      = "product-service"
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
        max_surge       = 1
        max_unavailable = 0
      }
    }

    selector {
      match_labels = {
        app = "product-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "product-service"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name  = "product-service"
          image = "harshbhushandixit/cloudcart-product:5"

          port {
            container_port = 5002
          }

          env {
            name = "PORT"

            value_from {
              config_map_key_ref {
                name = "cloudcart-config"
                key  = "PRODUCT_PORT"
              }
            }
          }

          env {
            name = "DB_USER"

            value_from {
              config_map_key_ref {
                name = "cloudcart-config"
                key  = "DB_USER"
              }
            }
          }

          env {
            name = "DB_HOST"

            value_from {
              config_map_key_ref {
                name = "cloudcart-config"
                key  = "PRODUCT_DB_HOST"
              }
            }
          }

          env {
            name = "DB_NAME"

            value_from {
              config_map_key_ref {
                name = "cloudcart-config"
                key  = "PRODUCT_DB_NAME"
              }
            }
          }

          env {
            name = "DB_PORT"

            value_from {
              config_map_key_ref {
                name = "cloudcart-config"
                key  = "DB_PORT"
              }
            }
          }

          env {
            name = "DB_PASSWORD"

            value_from {
              secret_key_ref {
                name = "cloudcart-secrets"
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5002
            }

            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5002
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