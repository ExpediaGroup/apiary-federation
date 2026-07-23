/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias               = var.instance_name == "" ? "waggledance" : format("waggledance-%s", var.instance_name)
  remote_metastore_zone_prefix = var.instance_name == "" ? "remote-metastore" : format("remote-metastore-%s", var.instance_name)
  glue_account_ids = tolist(
    toset(
      concat(
        # Extract glue-account-id from each object in var.glue_metastores
        [for m in var.glue_metastores : m["glue-account-id"]],

        # Optionally add the primary metastore account id if not empty
        var.primary_metastore_glue_account_id != "" ?
          [var.primary_metastore_glue_account_id] :
          [],

        # Optionally add the read-only primary metastore account id if not empty
        var.primary_metastore_read_only_glue_account_id != "" ?
          [var.primary_metastore_read_only_glue_account_id] :
          []
      )
    )
  )

   glue_enabled = length(local.glue_account_ids) > 0
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

data "aws_iam_policy_document" "waggle_dance_remote_glue_federations_policy_read" {
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
      "glue:GetUserDefinedFunctions",
      "glue:GetColumnStatisticsForTable",
      "glue:GetColumnStatisticsForPartition"
    ]
    resources = [
      for glue_account_id in local.glue_account_ids:
        format("arn:aws:glue:%s:%s:*", var.aws_region, glue_account_id)
    ]
  }
}

data "aws_iam_policy_document" "waggle_dance_remote_glue_federations_policy_write" {
  count = local.glue_enabled ? 1 : 0
  statement {
    sid = "WaggledanceRemoteGlueFederationsPolicy"
    actions = [
      "glue:CreatePartition",
      "glue:CreateTable",
      "glue:DeletePartition",
      "glue:DeleteTable",
      "glue:UpdatePartition",
      "glue:UpdateTable",
      "glue:BatchUpdatePartition",
      "glue:BatchDeletePartition",
      "glue:BatchCreatePartition",
      "glue:UpdateColumnStatisticsForTable",
      "glue:DeleteColumnStatisticsForTable",
      "glue:UpdateColumnStatisticsForPartition",
      "glue:DeleteColumnStatisticsForPartition"
    ]
    resources = [
      for glue_account_id in local.glue_account_ids:
        format("arn:aws:glue:%s:%s:*", var.aws_region, glue_account_id)
    ]
  }
}

#Glue client creates folders on s3 for create tables. This policy gives that access.
data "aws_iam_policy_document" "waggle_dance_remote_glue_federations_policy_s3_write" {
  count = local.glue_enabled ? 1 : 0
  statement {
    sid = "WaggledanceRemoteGlueFederationsPolicy"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:Get*",
      "s3:List*",
      "s3:PutBucketLogging",
      "s3:PutBucketNotification",
      "s3:PutBucketVersioning",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging"
    ]
    resources = [
        "arn:aws:s3:::${var.s3_glue_tables_bucket}",
        "arn:aws:s3:::${var.s3_glue_tables_bucket}/*"
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
