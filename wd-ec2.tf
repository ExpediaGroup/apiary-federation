/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_instance" "waggle_dance_instance" {
  count                       = "${var.instance_count}"
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(var.subnet_id,count.index)}"
  associate_public_ip_address = "${var.public_ip_address == "yes" ? 1 : 0}"
  disable_api_termination     = "${var.enable_termination_protection}"
  ebs_optimized               = "${var.ebs_optimized}"
  key_name                    = "${var.key_name}"
  monitoring                  = "${var.monitoring}"
  user_data_base64            = "${var.user_data_base64}"

  root_block_device {
    volume_type           = "${var.root_block_device_volume_type}"
    volume_size           = "${var.root_block_device_volume_size}"
    iops                  = "${var.root_block_device_iops}"
    delete_on_termination = "${var.root_block_device_delete_on_termination}"
  }

  tags = "${merge(var.tags,
          map("Name", "${var.name}-${count.index}"))}"

  volume_tags = "${merge(var.tags,
        map("Name", "${var.name}-${count.index}"))}"

  vpc_security_group_ids = "${var.security_groups}"

  lifecycle {
    create_before_destroy = "true"
  }
}
