/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_service_discovery_private_dns_namespace" "waggledance" {
  name = "${local.instance_alias}-${var.aws_region}.${var.domain_extension}"
  vpc  = "${var.vpc_id}"
}

resource "aws_service_discovery_service" "metastore_proxy" {
  name = "metastore-proxy"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.waggledance.id}"

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
  count      = "${length(var.secondary_vpcs)}"
  zone_id    = "${aws_service_discovery_private_dns_namespace.waggledance.hosted_zone}"
  vpc_id     = "${element(var.secondary_vpcs,count.index)}"
  vpc_region = "${var.aws_region}"
}
