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


data "aws_iam_policy_document" "waggle_dance_glue_policy" {
  count = length(var.glue_metastores) > 0 ? 1 : 0
  statement {
    sid = "WaggledanceGluePolicy"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetTableVersions",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:GetUserDefinedFunction",
      "glue:GetUserDefinedFunctions"
    ]
    resources = [
      for glue_metastore in var.glue_metastores:
        format("arn:aws:glue:%s:%s:*", var.aws_region, glue_metastore["glue-account-id"])
    ]
  }
}

data "aws_secretsmanager_secret" "datadog_key" {
  count  = var.include_datadog_agent ? 1 : 0
  name  = var.datadog_key_secret_name
}

data "aws_secretsmanager_secret_version" "datadog_key" {
  count  = var.include_datadog_agent ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.datadog_key[0].id
}

provider "datadog" {
  api_key  = var.include_datadog_agent ? jsondecode(data.aws_secretsmanager_secret_version.datadog_key.secret_string).api_key : null
  app_key  = var.include_datadog_agent ? jsondecode(data.aws_secretsmanager_secret_version.datadog_key.secret_string).app_key : null
}
