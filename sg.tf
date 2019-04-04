/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_security_group" "wd_sg" {
  name   = "${local.instance_alias}"
  vpc_id = "${var.vpc_id}"
  tags   = "${var.tags}"

  ingress {
    from_port   = 48869
    to_port     = 48869
    protocol    = "tcp"
    cidr_blocks = "${var.ingress_cidr}"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.waggledance_vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
