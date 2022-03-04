/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role" "waggledance_task_exec" {
  count = var.wd_instance_type == "ecs" ? 1 : 0
  name  = "${local.instance_alias}-ecs-task-exec-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "task_exec_managed" {
  count      = var.wd_instance_type == "ecs" ? 1 : 0
  role       = aws_iam_role.waggledance_task_exec[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "secretsmanager_for_ecs_task_exec" {
  count = var.wd_instance_type == "ecs" && var.docker_registry_auth_secret_name != "" ? 1 : 0
  name  = "secretsmanager-exec"
  role  = aws_iam_role.waggledance_task_exec[0].id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": [ "${join("\",\"", concat(data.aws_secretsmanager_secret.docker_registry.*.arn))}" ]
    }
}
EOF
}

resource "aws_iam_role" "waggledance_task" {
  count = var.wd_instance_type == "ecs" ? 1 : 0
  name  = "${local.instance_alias}-ecs-task-${var.aws_region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy" "secretsmanager_for_waggledance_task" {
  count = var.wd_instance_type == "ecs" && var.bastion_ssh_key_secret_name != "" ? 1 : 0
  name  = "secretsmanager"
  role  = aws_iam_role.waggledance_task[0].id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "${data.aws_secretsmanager_secret.bastion_ssh_key[0].arn}"
    }
}
EOF
}

resource "aws_iam_role_policy" "waggle_dance_glue_policy" {
  count = var.waggle_dance_glue_policy != "" ? 1 : 0
  role = aws_iam_role.waggledance_task.name
  name = "waggle-dance-glue-policy"

  policy = var.waggle_dance_glue_policy
}
