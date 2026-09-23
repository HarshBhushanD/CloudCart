resource "kubernetes_namespace" "cloudcart" {
  metadata {
    name = "cloudcart"
  }
}

resource "kubernetes_config_map" "cloudcart_config" {
  metadata {
    name      = "cloudcart-config"
    namespace = kubernetes_namespace.cloudcart.metadata[0].name
  }

  data = {
    NODE_ENV = "production"

    AUTH_DB_HOST = "postgres-auth"
    AUTH_DB_NAME = "cloudcart_auth"
    AUTH_PORT    = "5001"

    DB_PORT = "5432"
    DB_USER = "postgres"

    PRODUCT_DB_HOST = "postgres-products"
    PRODUCT_DB_NAME = "cloudcart_products"
    PRODUCT_PORT    = "5002"
  }
}