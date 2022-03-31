/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

 locals {
 //avoiding name clash with LB entry when autoscaling
 //need both names for prometheus scraping
   dns_name = var.enable_autoscaling ? "${local.instance_alias}-${var.aws_region}.${var.domain_extension}-sd" : "${local.instance_alias}-${var.aws_region}.${var.domain_extension}"
 }

resource "aws_service_discovery_private_dns_namespace" "waggledance" {
  count = var.wd_instance_type == "ecs" ? 1 : 0
  name  = local.dns_name
  vpc   = var.vpc_id
}

resource "aws_service_discovery_service" "metastore_proxy" {
  count = var.wd_instance_type == "ecs" ? 1 : 0
  name  = "metastore-proxy"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.waggledance[0].id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_route53_zone_association" "secondary" {
  count      = var.wd_instance_type == "ecs" ? length(var.secondary_vpcs) : 0
  zone_id    = aws_service_discovery_private_dns_namespace.waggledance[0].hosted_zone
  vpc_id     = var.secondary_vpcs[count.index]
  vpc_region = var.aws_region
}
