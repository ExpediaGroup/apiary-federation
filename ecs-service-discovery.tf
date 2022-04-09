/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_service_discovery_private_dns_namespace" "waggledance" {
  count = var.wd_instance_type == "ecs" && var.enable_autoscaling == false ? 1 : 0
  name  = "${local.instance_alias}-${var.aws_region}.${var.domain_extension}"
  vpc   = var.vpc_id
}

resource "aws_service_discovery_service" "metastore_proxy" {
  count = var.wd_instance_type == "ecs" ? 1 : 0
  name  = "metastore-proxy"

  dns_config {
    # This line does not work if we have autoscaling enabled.
    namespace_id = var.enable_autoscaling ? aws_route53_zone.waggledance[0].id : aws_service_discovery_private_dns_namespace.waggledance[0].id

    # We always want SRV records, but we only want A records if we are not auto-scaling.
    # If we are auto-scaling, we have an ELB that manages the instances.
    dns_records {
      ttl  = 10
      type = "SRV"
    }
    dynamic "dns_records" {
      for_each = var.enable_autoscaling ? [] : ["1"]
      content {
        ttl  = 10
        type = "A"
      }
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_route53_zone_association" "secondary" {
  count      = var.wd_instance_type == "ecs" && var.enable_autoscaling == false ? length(var.secondary_vpcs) : 0
  zone_id    = aws_service_discovery_private_dns_namespace.waggledance[0].hosted_zone
  vpc_id     = var.secondary_vpcs[count.index]
  vpc_region = var.aws_region
}
