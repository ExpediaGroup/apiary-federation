/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_route53_zone" "waggledance" {
  count = var.wd_instance_type == "k8s" || var.enable_autoscaling ? 1 : 0
  name  = "${local.instance_alias}-${var.aws_region}.${var.domain_extension}"

  vpc {
    vpc_id = var.vpc_id
  }
  
  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "metastore_proxy" {
  count = var.wd_instance_type == "k8s" || var.enable_autoscaling ? 1 : 0
  name  = "metastore-proxy"

  zone_id = aws_route53_zone.waggledance[0].id
  type    = "CNAME"
  ttl     = "300"
  records = var.wd_instance_type == "k8s" ? kubernetes_service.waggle_dance[0].status.0.load_balancer.0.ingress.0.hostname : [aws_lb.waggledance[0].dns_name]
}

resource "aws_route53_zone_association" "waggledance_secondary_vpc" {
  count      = var.enable_autoscaling ? length(var.secondary_vpcs) : 0
  
  zone_id    = aws_route53_zone.waggledance[0].id
  vpc_id     = var.secondary_vpcs[count.index]
  vpc_region = var.aws_region
}
