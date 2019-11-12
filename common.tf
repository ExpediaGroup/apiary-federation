/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias               = var.instance_name == "" ? "waggledance" : format("waggledance-%s", var.instance_name)
  remote_metastore_zone_prefix = var.instance_name == "" ? "remote-metastore" : format("remote-metastore-%s", var.instance_name)
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "waggledance_vpc" {
  id = var.vpc_id
}

data "aws_secretsmanager_secret" "bastion_ssh_key" {
  count = var.bastion_ssh_key_secret_name == "" ? 0 : 1
  name  = var.bastion_ssh_key_secret_name
}

data "aws_secretsmanager_secret" "docker_registry" {
  count = var.docker_registry_auth_secret_name == "" ? 0 : 1
  name  = var.docker_registry_auth_secret_name
}
