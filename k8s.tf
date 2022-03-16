/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  heapsize      = ceil((var.memory * 85) / 100)
  memory_limit  = ceil((var.memory * 120) / 100)
  actuator_port = 18000
  wd_port       = 48869
  k8s_cpu       = var.cpu / 1024
  k8s_cpu_limit = (var.cpu / 1024) * 1.25
}

resource "kubernetes_service_account" "waggle_dance" {
  count = var.wd_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = local.instance_alias
    namespace = var.k8s_namespace
  }
  automount_service_account_token = true
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
          "iam.amazonaws.com/role" = var.oidc_provider != "" ? aws_iam_role.waggle_dance_k8s_role_iam[0].arn : ""
          "prometheus.io/scrape" : var.prometheus_enabled
          "prometheus.io/port" : local.actuator_port
          "prometheus.io/path" : "/actuator/prometheus"
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.waggle_dance[0].metadata.0.name
        automount_service_account_token = true
        container {
          image = "${var.docker_image}:${var.docker_version}"
          name  = local.instance_alias
          port {
            container_port = local.wd_port
          }
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
              cpu    = local.k8s_cpu_limit
              memory = "${local.memory_limit}Mi"
            }
            requests {
              cpu    = local.k8s_cpu
              memory = "${var.memory}Mi"
            }
          }
          liveness_probe {
            http_get {
              path = "/actuator/health"
              port = local.actuator_port
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            failure_threshold     = 3
            success_threshold     = 1
          }
        }
        image_pull_secrets {
          name = var.k8s_docker_registry_secret
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "waggle_dance" {
  count = var.wd_instance_type == "k8s" && var.enable_autoscaling ? 1 : 0

  metadata {
    name      = local.instance_alias
    namespace = var.k8s_namespace
  }

  spec {
    min_replicas = var.k8s_replica_count
    max_replicas = var.k8s_max_replica_count

    target_cpu_utilization_percentage = var.wd_target_cpu_percentage

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.waggle_dance[0].metadata[0].name
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
      port        = local.wd_port
      target_port = local.wd_port
    }
    type                        = "LoadBalancer"
    load_balancer_source_ranges = var.ingress_cidr
  }
}

resource "kubernetes_service" "waggle_dance_internal" {
  count = var.wd_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.instance_alias}-internal"
    namespace = var.k8s_namespace
  }
  spec {
    selector = {
      name = local.instance_alias
    }
    session_affinity = "ClientIP"
    port {
      port        = local.wd_port
      target_port = local.wd_port
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "waggle_dance_headless" {
  count = var.wd_instance_type == "k8s" ? 1 : 0
  metadata {
    name      = "${local.instance_alias}-headless"
    namespace = var.k8s_namespace
  }
  spec {
    selector = {
      name = local.instance_alias
    }
    port {
      port        = local.wd_port
      target_port = local.wd_port
    }
    type       = "ClusterIP"
    cluster_ip = "None"
  }
}
