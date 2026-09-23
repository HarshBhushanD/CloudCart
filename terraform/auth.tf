resource "kubernetes_deployment" "auth_service" {
  metadata {
    name      = "auth-service"
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
        app = "auth-service"
      }
    }

    template {
      metadata {
        labels = {
          app = "auth-service"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name  = "auth-service"
          image = "harshbhushandixit/cloudcart-auth:5"

          port {
            container_port = 5001
          }

          env {
            name = "PORT"

            value_from {
              config_map_key_ref {
                name = "cloudcart-config"
                key  = "AUTH_PORT"
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
                key  = "AUTH_DB_HOST"
              }
            }
          }

          env {
            name = "DB_NAME"

            value_from {
              config_map_key_ref {
                name = "cloudcart-config"
                key  = "AUTH_DB_NAME"
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

          env {
            name = "JWT_SECRET"

            value_from {
              secret_key_ref {
                name = "cloudcart-secrets"
                key  = "JWT_SECRET"
              }
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 5001
            }

            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 5001
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