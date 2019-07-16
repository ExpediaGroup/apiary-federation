/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_route53_zone" "waggledance" {
  count = "${var.wd_instance_type == "ecs" ? 0 : 1}"
  name  = "${local.instance_alias}-${var.aws_region}.${var.domain_extension}"

  vpc {
    vpc_id = "${var.vpc_id}"
  }
}

resource "aws_route53_record" "metastore_proxy" {
  count = "${var.wd_instance_type == "ecs" ? 0 : 1}"
  name  = "metastore-proxy"

  zone_id = "${aws_route53_zone.waggledance[0].id}"
  type    = "A"
  ttl     = "300"
  records = aws_instance.waggledance.*.private_ip
}
