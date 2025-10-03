/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias               = var.instance_name == "" ? "waggledance" : format("waggledance-%s", var.instance_name)
  remote_metastore_zone_prefix = var.instance_name == "" ? "remote-metastore" : format("remote-metastore-%s", var.instance_name)
  glue_account_ids = tolist(toset(concat(
     [for m in var.glue_metastores : m["glue-account-id"]],
     var.primary_metastore_glue_account_id != "" ? [var.primary_metastore_glue_account_id] : [],
     var.primary_metastore_read_only_glue_account_id != "" ? [var.primary_metastore_read_only_glue_account_id] : []
   )))
   glue_enabled = length(var.glue_account_ids) > 0
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

data "aws_iam_policy_document" "waggle_dance_remote_glue_federations_policy" {
  count = local.glue_enabled ? 1 : 0
  statement {
    sid = "WaggledanceRemoteGlueFederationsPolicy"
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
      for glue_account_id in local.glue_account_ids:
        format("arn:aws:glue:%s:%s:*", var.aws_region, glue-account-id)
    ]
  }
}


data "aws_secretsmanager_secret" "datadog_key" {
  count = length(var.datadog_key_secret_name) > 0 ? 1 : 0
  name  = var.datadog_key_secret_name
}

data "aws_secretsmanager_secret_version" "datadog_key" {
  count = length(var.datadog_key_secret_name) > 0 ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.datadog_key[0].id
}

data "external" "datadog_key" {
  count = length(var.datadog_key_secret_name) > 0 ? 1 : 0
  program = ["echo", "${data.aws_secretsmanager_secret_version.datadog_key[0].secret_string}"]
}
