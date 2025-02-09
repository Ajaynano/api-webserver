provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
  }
}

resource "kubernetes_secret" "test" {
  metadata {
    name      = "test"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  data = {
    username = "<username>"
    password = "<password>"
  }
}

resource "kubernetes_config_map" "test" {
  metadata {
    name      = "test"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  data = {
    MAX_UPTIME_MINS = "60"
  }
}

resource "kubernetes_deployment" "test" {
  metadata {
    name      = "test"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "test"
      }
    }

    template {
      metadata {
        labels = {
          app = "test"
        }
      }

      spec {
        container {
          name  = "test"
          image = "dummyjson-restapi-app:v2"
          image_pull_policy = "IfNotPresent"

          env {
            name = "DUMMY_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.test.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "DUMMY_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.test.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name = "MAX_UPTIME_MINS"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.test.metadata[0].name
                key  = "MAX_UPTIME_MINS"
              }
            }
          }

          port {
            container_port = 5000
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 5000
            }
            initial_delay_seconds = 3
            period_seconds = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "test" {
  metadata {
    name      = "test-service"
    namespace = kubernetes_namespace.test.metadata[0].name
  }

  spec {
    selector = {
      app = "test"
    }

    port {
      port        = 80
      target_port = 5000
    }

    type = "NodePort"
  }
}