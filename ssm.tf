/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "template_file" "waggledance_playbook" {
  template = file("${path.module}/templates/waggledance_playbook.yml")

  vars = {
    aws_region          = var.aws_region
    waggledance_version = var.waggledance_version
    server_yaml         = base64encode(data.template_file.server_yaml.rendered)
    federation_yaml     = base64encode(data.template_file.federation_yaml.rendered)
  }
}

#to delay ssm assiociation till ansible is installed
resource "null_resource" "waggledance_delay" {
  count = var.wd_instance_type == "ecs" ? 0 : 1

  triggers = {
    waggledance_instance_ids = join(",", aws_instance.waggledance.*.id)
  }

  provisioner "local-exec" {
    command = "sleep 90"
  }
}

resource "aws_ssm_association" "waggledance_playbook" {
  count            = var.wd_instance_type == "ecs" ? 0 : 1
  name             = "AWS-RunAnsiblePlaybook"
  association_name = "${local.instance_alias}-playbook"

  schedule_expression = "rate(30 minutes)"

  targets {
    key    = "InstanceIds"
    values = aws_instance.waggledance.*.id
  }

  parameters = {
    playbook = data.template_file.waggledance_playbook.rendered
  }

  depends_on = [null_resource.waggledance_delay]
}
