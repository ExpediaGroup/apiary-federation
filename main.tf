/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_ecs_cluster" "waggledance" {
  name = "${local.instance_alias}"
}

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
}

resource "aws_iam_role_policy_attachment" "task_exec_managed" {
  role       = "${aws_iam_role.waggledance_task_exec.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
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
}

resource "aws_iam_role_policy" "secretsmanager_for_waggledance_task" {
  count = "${ var.bastion_ssh_key_secret_name == "" ? 0 : 1}"
  name  = "secretsmanager"
  role  = "${aws_iam_role.waggledance_task.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "secretsmanager:GetSecretValue",
        "Resource": "${data.aws_secretsmanager_secret.bastion_ssh_key.arn}"
    }
}
EOF
}

resource "aws_cloudwatch_log_group" "waggledance_ecs" {
  name = "${local.instance_alias}"
  tags = "${var.tags}"
}

data "template_file" "server_yaml" {
  template = "${file("${path.module}/templates/waggle-dance-server.yml.tmpl")}"

  vars {
    graphite_host   = "${var.graphite_host}"
    graphite_port   = "${var.graphite_port}"
    graphite_prefix = "${var.graphite_prefix}"
  }
}

data "template_file" "primary_metastore_whitelist" {
  count = "${length(var.primary_metastore_whitelist)}"

  template = <<EOF
  - ${var.primary_metastore_whitelist[count.index]}
EOF
}

data "template_file" "ssh_metastores_yaml" {
  count    = "${length(var.ssh_metastores)}"
  template = "${file("${path.module}/templates/waggle-dance-federation-ssh.yml.tmpl")}"

  vars {
    prefix             = "${lookup(var.ssh_metastores[count.index],"prefix")}"
    bastion_host       = "${lookup(var.ssh_metastores[count.index],"bastion-host")}"
    metastore_host     = "${lookup(var.ssh_metastores[count.index],"metastore-host")}"
    metastore_port     = "${lookup(var.ssh_metastores[count.index],"port")}"
    user               = "${lookup(var.ssh_metastores[count.index],"user")}"
    timeout            = "${lookup(var.ssh_metastores[count.index],"timeout", "60000")}"
    mapped_databases   = "${ lookup(var.ssh_metastores[count.index],"mapped-databases","") }"
    writable_whitelist = "${ lookup(var.ssh_metastores[count.index],"writable-whitelist","") }"
  }
}

data "template_file" "federation_yaml" {
  template = "${file("${path.module}/templates/waggle-dance-federation.yml.tmpl")}"

  vars {
    primary_metastore_host      = "${var.primary_metastore_host}"
    primary_metastore_port      = "${var.primary_metastore_port}"
    primary_metastore_whitelist = "${join("",data.template_file.primary_metastore_whitelist.*.rendered)}"
    local_metastores            = "${join("",data.template_file.local_metastores_yaml.*.rendered)}"
    remote_metastores           = "${join("",data.template_file.remote_metastores_yaml.*.rendered)}"
    ssh_metatstores             = "${join("",data.template_file.ssh_metastores_yaml.*.rendered)}"
  }
}

data "template_file" "waggledance" {
  template = "${file("${path.module}/templates/waggledance.json")}"

  vars {
    heapsize            = "${var.memory}"
    docker_image        = "${var.docker_image}"
    docker_version      = "${var.docker_version}"
    region              = "${var.aws_region}"
    loggroup            = "${aws_cloudwatch_log_group.waggledance_ecs.name}"
    server_yaml         = "${ var.graphite_host == "localhost" ? "" : base64encode(data.template_file.server_yaml.rendered) }"
    federation_yaml     = "${base64encode(data.template_file.federation_yaml.rendered)}"
    bastion_ssh_key_arn = "${var.bastion_ssh_key_secret_name == "" ? "" : join("",data.aws_secretsmanager_secret.bastion_ssh_key.*.arn)}"
  }
}

resource "aws_ecs_task_definition" "waggledance" {
  family                   = "${local.instance_alias}"
  task_role_arn            = "${aws_iam_role.waggledance_task.arn}"
  execution_role_arn       = "${aws_iam_role.waggledance_task_exec.arn}"
  network_mode             = "awsvpc"
  memory                   = "${var.memory}"
  cpu                      = "${var.cpu}"
  requires_compatibilities = ["EC2", "FARGATE"]
  container_definitions    = "${data.template_file.waggledance.rendered}"
}

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

resource "aws_ecs_service" "waggledance_service" {
  name            = "${local.instance_alias}-service"
  launch_type     = "FARGATE"
  cluster         = "${aws_ecs_cluster.waggledance.id}"
  task_definition = "${aws_ecs_task_definition.waggledance.arn}"
  desired_count   = "${var.wd_ecs_task_count}"

  network_configuration {
    security_groups = ["${aws_security_group.wd_sg.id}"]
    subnets         = ["${var.subnets}"]
  }

  service_registries {
    registry_arn = "${aws_service_discovery_service.metastore_proxy.arn}"
  }
}

resource "aws_service_discovery_private_dns_namespace" "waggledance" {
  name = "${local.instance_alias}-${var.aws_region}.${var.domain_extension}"
  vpc  = "${var.vpc_id}"
}

resource "aws_service_discovery_service" "metastore_proxy" {
  name = "metastore-proxy"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.waggledance.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_route53_zone_association" "secondary" {
  count      = "${length(var.secondary_vpcs)}"
  zone_id    = "${aws_service_discovery_private_dns_namespace.waggledance.hosted_zone}"
  vpc_id     = "${element(var.secondary_vpcs,count.index)}"
  vpc_region = "${var.aws_region}"
}
