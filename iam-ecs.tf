/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_iam_role" "waggledance_task_exec" {
  name = "${local.instance_alias}-ecs-task-exec-${var.aws_region}"

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
  role       = aws_iam_role.waggledance_task_exec.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "secretsmanager_for_ecs_task_exec" {
  count = var.docker_registry_auth_secret_name == "" ? 0 : 1
  name  = "secretsmanager-exec"
  role  = aws_iam_role.waggledance_task_exec.id

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
  name = "${local.instance_alias}-ecs-task-${var.aws_region}"

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

  tags = "${var.tags}"
}

resource "aws_iam_role_policy" "secretsmanager_for_waggledance_task" {
  count = var.bastion_ssh_key_secret_name == "" ? 0 : 1
  name  = "secretsmanager"
  role  = aws_iam_role.waggledance_task.id

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

resource "aws_iam_role_policy_attachment" "waggledance_ssm_policy" {
  count      = var.wd_instance_type == "ecs" ? 0 : 1
  role       = aws_iam_role.waggledance_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "waggledance" {
  count = var.wd_instance_type == "ecs" ? 0 : 1
  name  = aws_iam_role.waggledance_task.name
  role  = aws_iam_role.waggledance_task.name
}
