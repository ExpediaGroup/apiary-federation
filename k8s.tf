resource "kubernetes_deployment" "waggle_dance" {
  metadata {
    name      = "waggle-dance"
    namespace = "metastore"

    labels = {
      name = "waggle-dance"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        name = "waggle-dance"
      }
    }

    template {
      metadata {
        labels = {
          name = "waggle-dance"
        }
      }

      spec {
        container {
          image = "${var.docker_image}:${var.docker_version}"
          name  = "waggle-dance"
          env {
            name  = "HEAPSIZE"
            value = var.memory
          }
          env {
            name  = "SERVER_YAML"
            value = base64encode(data.template_file.server_yaml.rendered)
          }
          env {
            name  = "FEDERATION_YAML"
            value = base64encode(data.template_file.federation_yaml.rendered)
          }
          resources {
            limits {
              memory = "${var.memory}Mi"
            }
            requests {
              memory = "${var.memory}Mi"
            }
          }
        }
        image_pull_secrets {
          name = var.k8s_docker_registry_secret
        }
      }
    }
  }
}

resource "kubernetes_service" "waggle_dance" {
  metadata {
    name      = "waggle-dance"
    namespace = "metastore"
  }
  spec {
    selector = {
      name = "waggle-dance"
    }
    session_affinity = "ClientIP"
    port {
      port        = 48869
      target_port = 48869
    }
    type = "NodePort"
  }
}
