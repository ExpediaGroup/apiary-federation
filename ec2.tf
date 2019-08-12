/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "aws_ami" "amzn" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-ebs"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "waggledance_userdata" {
  template = file("${path.module}/templates/waggledance_userdata.sh")
}

resource "aws_instance" "waggledance" {
  count         = var.wd_instance_type == "ecs" ? 0 : length(var.subnets)
  ami           = var.ami_id == "" ? data.aws_ami.amzn.id : var.ami_id
  instance_type = var.ec2_instance_type
  key_name      = var.key_name
  ebs_optimized = true

  subnet_id              = var.subnets[count.index]
  iam_instance_profile   = aws_iam_instance_profile.waggledance[0].id
  vpc_security_group_ids = [aws_security_group.wd_sg.id]

  user_data_base64 = base64encode(data.template_file.waggledance_userdata.rendered)

  root_block_device {
    volume_type = var.root_vol_type
    volume_size = var.root_vol_size
  }

  tags = merge(map("Name", "${local.instance_alias}-${count.index + 1}"), var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "waggledance" {
  count = var.wd_instance_type == "ecs" ? 0 : length(var.subnets)

  alarm_name = "Auto Reboot - ${aws_instance.waggledance.*.id[count.index]}"

  dimensions = {
    InstanceId = aws_instance.waggledance.*.id[count.index]
  }

  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"

  alarm_description = "This will restart ${local.instance_alias}-${count.index + 1} if the status check fails"

  alarm_actions = [local.cw_arn]
}
