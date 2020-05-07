/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  heapsize = ceil((var.memory * 85) / 100)
}
resource "kubernetes_deployment" "waggle_dance" {
  count = var.wd_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "waggle-dance"
    namespace = var.k8s_namespace
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
        annotations = {
          "prometheus.io/scrape" : var.prometheus_enabled
          "prometheus.io/port" : 18000
          "prometheus.io/path" : "/actuator/prometheus"
        }
      }

      spec {
        container {
          image = "${var.docker_image}:${var.docker_version}"
          name  = "waggle-dance"
          env {
            name  = "HEAPSIZE"
            value = local.heapsize
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
  count = var.wd_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "waggle-dance"
    namespace = var.k8s_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
    }
  }
  spec {
    selector = {
      name = "waggle-dance"
    }
    port {
      port        = 48869
      target_port = 48869
    }
    type                        = "LoadBalancer"
    load_balancer_source_ranges = var.ingress_cidr
  }
}
