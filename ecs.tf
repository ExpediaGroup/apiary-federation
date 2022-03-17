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

  dynamic "service_registries" {
    for_each = var.enable_autoscaling ? [] : ["1"]
    content {
      registry_arn = var.enable_autoscaling ? null : aws_service_discovery_service.metastore_proxy[0].arn
    }
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

resource "aws_appautoscaling_target" "waggledance" {
  count = var.wd_instance_type == "ecs" && var.enable_autoscaling ? 1 : 0

  max_capacity       = var.wd_ecs_max_task_count
  min_capacity       = var.wd_ecs_task_count
  resource_id        = "service/${local.instance_alias}/${local.instance_alias}-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    aws_ecs_service.waggledance_service,
  ]
}

resource "aws_appautoscaling_policy" "waggledance" {
  count = var.wd_instance_type == "ecs" && var.enable_autoscaling ? 1 : 0

  name               = "cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.waggledance[0].resource_id
  scalable_dimension = aws_appautoscaling_target.waggledance[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.waggledance[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.wd_target_cpu_percentage
    scale_in_cooldown  = var.cpu_scale_in_cooldown
    scale_out_cooldown = var.cpu_scale_out_cooldown
  }

  depends_on = [aws_appautoscaling_target.waggledance]
}

