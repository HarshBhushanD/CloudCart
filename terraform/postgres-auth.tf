resource "kubernetes_config_map" "auth_db_init" {
  metadata {
    name      = "auth-db-init"
    namespace = kubernetes_namespace.cloudcart.metadata[0].name
  }

  lifecycle {
    ignore_changes = [data]
  }

  data = {
    "init.sql" = <<-SQL
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SQL
  }
}

resource "kubernetes_persistent_volume_claim" "postgres_auth_pvc" {
  metadata {
    name      = "postgres-auth-pvc"
    namespace = kubernetes_namespace.cloudcart.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "postgres_auth" {
  wait_for_rollout = false

  metadata {
    name      = "postgres-auth"
    namespace = kubernetes_namespace.cloudcart.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres-auth"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres-auth"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false

        container {
          name  = "postgres"
          image = "postgres:16-alpine"

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_USER"

            value_from {
              config_map_key_ref {
                name = "cloudcart-config"
                key  = "DB_USER"
              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"

            value_from {
              secret_key_ref {
                name = "cloudcart-secrets"
                key  = "POSTGRES_PASSWORD"
              }
            }
          }

          env {
            name  = "POSTGRES_DB"
            value = "cloudcart_auth"
          }

          readiness_probe {
            exec {
              command = [
                "sh",
                "-c",
                "pg_isready -U postgres -d cloudcart_auth"
              ]
            }

            initial_delay_seconds = 5
            period_seconds        = 5
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "init-script"
            mount_path = "/docker-entrypoint-initdb.d/init.sql"
            sub_path   = "init.sql"
          }
        }

        volume {
          name = "postgres-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_auth_pvc.metadata[0].name
          }
        }

        volume {
          name = "init-script"

          config_map {
            name = kubernetes_config_map.auth_db_init.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres_auth" {
  wait_for_load_balancer = false

  metadata {
    name      = "postgres-auth"
    namespace = kubernetes_namespace.cloudcart.metadata[0].name
  }

  spec {
    selector = {
      app = "postgres-auth"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}