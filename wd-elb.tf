/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_elb" "waggle_dance_loadbalancer" {
  name = "${var.wd_loadbalancer_name}"

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 60
  idle_timeout                = 4000
  internal                    = "true"
  subnets                     = "${var.subnet_id}"

  security_groups = "${var.security_groups}"

  access_logs {
    bucket        = "${var.elb_access_logs_bucket}"
    bucket_prefix = "${var.tags["Environment"]}/${var.wd_loadbalancer_name}"
    interval      = 60
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:${var.wd_port}"
    interval            = 30
  }

  listener {
    instance_port     = "${var.wd_port}"
    instance_protocol = "tcp"
    lb_port           = "${var.wd_port}"
    lb_protocol       = "tcp"
  }

  tags = "${merge(var.tags,
          map("Name", "${var.wd_loadbalancer_name}"))}"
}

resource "aws_elb_attachment" "waggle_dance_elb_attachment" {
  count    = "${var.instance_count}"
  elb      = "${aws_elb.waggle_dance_loadbalancer.id}"
  instance = "${element(aws_instance.waggle_dance_instance.*.id,count.index)}"
}
