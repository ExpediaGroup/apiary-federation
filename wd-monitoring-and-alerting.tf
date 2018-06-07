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
