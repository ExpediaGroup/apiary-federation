/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  heapsize     = ceil((var.memory * 85) / 100)
  memory_limit = ceil((var.memory * 120) / 100)
}
resource "kubernetes_deployment" "waggle_dance" {
  count = var.wd_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = local.instance_alias
    namespace = var.k8s_namespace
    labels = {
      name = local.instance_alias
    }
  }

  spec {
    replicas = var.k8s_replica_count
    selector {
      match_labels = {
        name = local.instance_alias
      }
    }

    template {
      metadata {
        labels = {
          name = local.instance_alias
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
          name  = local.instance_alias
          env {
            name  = "HEAPSIZE"
            value = local.heapsize
          }
          env {
            name  = "LOGLEVEL"
            value = var.wd_log_level
          }
          env {
            name  = "SERVER_YAML"
            value = base64encode(data.template_file.server_yaml.rendered)
          }
          env {
            name  = "FEDERATION_YAML"
            value = base64encode(data.template_file.federation_yaml.rendered)
          }
          env {
            name  = "HIVE_SITE_XML"
            value = var.alluxio_endpoints == [] ? "" : base64encode(data.template_file.hive_site_xml.rendered)
          }
          env {
              name  = "LOG4J_FORMAT_MSG_NO_LOOKUPS"
              value = "true"
          }          
          resources {
            limits {
              memory = "${local.memory_limit}Mi"
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
    name      = local.instance_alias
    namespace = var.k8s_namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
    }
  }
  spec {
    selector = {
      name = local.instance_alias
    }
    port {
      port        = 48869
      target_port = 48869
    }
    type                        = "LoadBalancer"
    load_balancer_source_ranges = var.ingress_cidr
  }
}
