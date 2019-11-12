/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_ecs_cluster" "waggledance" {
  count = var.wd_instance_type == "ecs" ? 1 : 0
  name  = local.instance_alias
  tags  = var.tags
}

resource "aws_ecs_service" "waggledance_service" {
  count           = var.wd_instance_type == "ecs" ? 1 : 0
  name            = "${local.instance_alias}-service"
  launch_type     = "FARGATE"
  cluster         = aws_ecs_cluster.waggledance[0].id
  task_definition = aws_ecs_task_definition.waggledance[0].arn
  desired_count   = var.wd_ecs_task_count

  network_configuration {
    security_groups = [aws_security_group.wd_sg.id]
    subnets         = var.subnets
  }

  service_registries {
    registry_arn = aws_service_discovery_service.metastore_proxy[0].arn
  }
}

resource "aws_ecs_task_definition" "waggledance" {
  count                    = var.wd_instance_type == "ecs" ? 1 : 0
  family                   = local.instance_alias
  task_role_arn            = aws_iam_role.waggledance_task[0].arn
  execution_role_arn       = aws_iam_role.waggledance_task_exec[0].arn
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  requires_compatibilities = ["EC2", "FARGATE"]
  container_definitions    = data.template_file.waggledance.rendered
  tags                     = var.tags
}
