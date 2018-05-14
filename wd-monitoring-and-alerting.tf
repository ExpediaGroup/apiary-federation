/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

# Topic
resource "aws_sns_topic" "waggle_dance_user_updates" {
  name         = "waggle-dance-alerts"
  display_name = "Notifications for Waggle Dance Service"
}

# E-mail subscription
# aws_sns_topic_subscription does not support email protocol.
# for further information check: https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html
# workaround: manual cli calls
# Taint this resource to re-run subscription
resource "null_resource" "wd_subscribe_email" {
  depends_on = ["aws_sns_topic.waggle_dance_user_updates"]

  provisioner "local-exec" {
    command = "aws --region ${var.region} --output json sns subscribe --topic-arn ${aws_sns_topic.waggle_dance_user_updates.arn} --protocol email --notification-endpoint ${var.alerting_email}"
  }
}

# ALARM: Service is down
resource "aws_cloudwatch_metric_alarm" "waggle_dance_elb_no_healthy_hosts" {
  alarm_name        = "${var.tags["Environment"]}-${var.region}-waggle-dance-elb-no-healthy-hosts"
  alarm_description = "No healthy hosts --> Service is down."
  actions_enabled   = "true"
  alarm_actions     = ["${aws_sns_topic.waggle_dance_user_updates.arn}"]
  ok_actions        = ["${aws_sns_topic.waggle_dance_user_updates.arn}"]
  metric_name       = "HealthyHostCount"
  namespace         = "AWS/ELB"
  statistic         = "Average"

  dimensions {
    LoadBalancerName = "${aws_elb.waggle_dance_loadbalancer.id}"
  }

  period              = "60"
  unit                = "Count"
  evaluation_periods  = "1"
  threshold           = "0"
  comparison_operator = "LessThanOrEqualToThreshold"
}

# ALARM: At least one instance is down
resource "aws_cloudwatch_metric_alarm" "waggle_dance_elb_unhealthy_hosts" {
  # Dependency on other alarm is needed to avoid parallel request which are not handled well by AWS
  depends_on = ["aws_elb.waggle_dance_loadbalancer", "aws_cloudwatch_metric_alarm.waggle_dance_elb_no_healthy_hosts"]

  alarm_name        = "${var.tags["Environment"]}-${var.region}-waggle-dance-elb-unhealthy-hosts"
  alarm_description = "At least one unhealthy host."
  actions_enabled   = "true"
  alarm_actions     = ["${aws_sns_topic.waggle_dance_user_updates.arn}"]
  ok_actions        = ["${aws_sns_topic.waggle_dance_user_updates.arn}"]
  metric_name       = "UnHealthyHostCount"
  namespace         = "AWS/ELB"
  statistic         = "Average"

  dimensions {
    LoadBalancerName = "${var.wd_loadbalancer_name}"
  }

  period              = "60"
  unit                = "Count"
  evaluation_periods  = "1"
  threshold           = "0"
  comparison_operator = "GreaterThanThreshold"
}
