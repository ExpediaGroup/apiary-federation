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
  tags               = merge(map("Name", "${var.remote_metastores[count.index].prefix}_metastore"), var.tags)
}

resource "aws_vpc_endpoint" "remote_region_metastores" {
  for_each = {
    for metastore in var.remote_region_metastores : metastore["endpoint"] => metastore
  }

  provider           = "aws.${each.value["region"]}"
  vpc_id             = each.value["vpc_id"]
  vpc_endpoint_type  = "Interface"
  service_name       = each.value["endpoint"]
  subnet_ids         = split(",", each.value["subnets"])
  security_group_ids = each.value["security_group_id"]
  tags               = merge(map("Name", "${each.value["prefix"]}_metastore"), var.tags)
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
