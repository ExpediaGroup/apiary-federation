/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_security_group" "endpoint_sg" {
  name   = "${local.instance_alias}-endpoint"
  vpc_id = var.vpc_id
  tags   = var.tags

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.waggledance_vpc.cidr_block]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.wd_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "remote_metastores" {
  count              = length(var.remote_metastores)
  vpc_id             = var.vpc_id
  vpc_endpoint_type  = "Interface"
  service_name       = var.remote_metastores[count.index].endpoint
  subnet_ids         = split(",", lookup(var.remote_metastores[count.index], "subnets", join(",", var.subnets)))
  security_group_ids = [aws_security_group.endpoint_sg.id]
  tags               = merge(tomap({ "Name" = "${var.remote_metastores[count.index].prefix}_metastore" }), var.tags)
}

resource "aws_vpc_endpoint" "remote_region_metastores" {
  for_each = {
    for metastore in var.remote_region_metastores : "${metastore["endpoint"]}" => metastore
  }
  provider           = "aws.remote"
  vpc_id             = each.value["vpc_id"]
  vpc_endpoint_type  = "Interface"
  service_name       = each.value["endpoint"]
  subnet_ids         = split(",", each.value["subnets"])
  security_group_ids = [each.value["security_group_id"]]
  tags               = merge(tomap({ "Name" = "${each.value["prefix"]}_metastore" }), var.tags)
}

resource "aws_route53_zone" "remote_metastore" {
  count = var.enable_remote_metastore_dns == "" ? 0 : 1
  name  = "${local.remote_metastore_zone_prefix}-${var.aws_region}.${var.domain_extension}"
  tags  = var.tags

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "metastore_alias" {
  count   = var.enable_remote_metastore_dns == "" ? 0 : length(var.remote_metastores)
  zone_id = aws_route53_zone.remote_metastore[0].zone_id
  name    = var.remote_metastores[count.index].prefix
  type    = "CNAME"
  ttl     = "60"
  records = [aws_vpc_endpoint.remote_metastores[count.index].dns_entry[0].dns_name]
}


data "aws_lb" "waggledance_lb" {
  count = var.wd_instance_type == "k8s" && var.enable_vpc_endpoint_services ? 1 : 0
  name  = split("-", split(".", kubernetes_service.waggle_dance[0].status.0.load_balancer.0.ingress.0.hostname).0).0
}

resource "aws_vpc_endpoint_service" "waggledance" {
  count                      = var.enable_vpc_endpoint_services ? 1 : 0
  network_load_balancer_arns = var.wd_instance_type == "ecs" ? aws_lb.waggledance[0].*.arn : data.aws_lb.waggledance_lb[0].*.arn
  acceptance_required        = false
  allowed_principals         = formatlist("arn:aws:iam::%s:root", var.waggledance_customer_accounts)
  tags                       = merge(tomap({"Name"="${local.instance_alias}"}), var.tags)
}
