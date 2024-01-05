/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  default_exposed_endpoints = "health,info,metrics"
  exposed_endpoints         = var.prometheus_enabled ? join(",", [local.default_exposed_endpoints, "prometheus"]) : local.default_exposed_endpoints
}

data "template_file" "endpoints_server_yaml" {
  template = file("${path.module}/templates/waggle-dance-server-endpoints.yml.tmpl")

  vars = {
    exposed_endpoints = local.exposed_endpoints
  }
}

data "template_file" "graphite_server_yaml" {
  count    = var.graphite_host == "localhost" ? 0 : 1
  template = file("${path.module}/templates/waggle-dance-server-graphite.yml.tmpl")

  vars = {
    graphite_host   = var.graphite_host
    graphite_port   = var.graphite_port
    graphite_prefix = var.graphite_prefix
  }
}

data "template_file" "server_yaml" {
  template = file("${path.module}/templates/waggle-dance-server.yml.tmpl")

  vars = {
    enable_query_functions_across_all_metastores = var.enable_query_functions_across_all_metastores
    graphite                                     = join("", data.template_file.graphite_server_yaml.*.rendered)
    exposed_endpoints                            = data.template_file.endpoints_server_yaml.rendered
  }
}

data "template_file" "primary_metastore_whitelist" {
  count = length(var.primary_metastore_whitelist)

  template = <<EOF
  - ${var.primary_metastore_whitelist[count.index]}
EOF
}

data "template_file" "primary_metastore_mapped_databases" {
  count = length(var.primary_metastore_mapped_databases)

  template = <<EOF
  - ${var.primary_metastore_mapped_databases[count.index]}
EOF
}

data "template_file" "local_metastores_yaml" {
  count    = length(var.local_metastores)
  template = file("${path.module}/templates/waggle-dance-federation-local.yml.tmpl")

  vars = {
    prefix                 = var.local_metastores[count.index].prefix
    metastore_host         = var.local_metastores[count.index].host
    metastore_port         = lookup(var.local_metastores[count.index], "port", "9083")
    mapped_databases       = lookup(var.local_metastores[count.index], "mapped-databases", "")
    mapped_tables          = lookup(var.local_metastores[count.index], "mapped-tables", "")
    database_name_mapping  = lookup(var.local_metastores[count.index], "database-name-mapping", "")
    writable_whitelist     = lookup(var.local_metastores[count.index], "writable-whitelist", "")
    enable_path_conversion = lookup(var.local_metastores[count.index], "enable_path_conversion", false)
    metastore_enabled      = lookup(var.local_metastores[count.index], "enabled", true)
    latency                = lookup(var.local_metastores[count.index], "latency", var.default_latency)
  }
}

data "template_file" "remote_metastores_yaml" {
  count    = length(var.remote_metastores)
  template = file("${path.module}/templates/waggle-dance-federation-remote.yml.tmpl")

  vars = {
    prefix                 = var.remote_metastores[count.index].prefix
    metastore_host         = aws_vpc_endpoint.remote_metastores[count.index].dns_entry[0].dns_name
    metastore_port         = lookup(var.remote_metastores[count.index], "port", "9083")
    mapped_databases       = lookup(var.remote_metastores[count.index], "mapped-databases", "")
    mapped_tables          = lookup(var.remote_metastores[count.index], "mapped-tables", "")
    database_name_mapping  = lookup(var.remote_metastores[count.index], "database-name-mapping", "")
    writable_whitelist     = lookup(var.remote_metastores[count.index], "writable-whitelist", "")
    enable_path_conversion = lookup(var.remote_metastores[count.index], "enable_path_conversion", false)
    metastore_enabled      = lookup(var.remote_metastores[count.index], "enabled", true)
    latency                = lookup(var.remote_metastores[count.index], "latency", var.default_latency)
  }
}

data "template_file" "remote_region_metastores_yaml" {
  count    = length(var.remote_region_metastores)
  template = file("${path.module}/templates/waggle-dance-federation-remote.yml.tmpl")

  vars = {
    prefix                 = var.remote_region_metastores[count.index].prefix
    metastore_host         = aws_vpc_endpoint.remote_region_metastores[var.remote_region_metastores[count.index]["endpoint"]].dns_entry[0].dns_name
    metastore_port         = lookup(var.remote_region_metastores[count.index], "port", "9083")
    mapped_databases       = lookup(var.remote_region_metastores[count.index], "mapped-databases", "")
    mapped_tables          = lookup(var.remote_region_metastores[count.index], "mapped-tables", "")
    database_name_mapping  = lookup(var.remote_region_metastores[count.index], "database-name-mapping", "")
    writable_whitelist     = lookup(var.remote_region_metastores[count.index], "writable-whitelist", "")
    enable_path_conversion = lookup(var.remote_region_metastores[count.index], "enable_path_conversion", true)
    metastore_enabled      = lookup(var.remote_region_metastores[count.index], "enabled", true)
    latency                = lookup(var.remote_region_metastores[count.index], "latency", var.default_latency)
  }
}


data "template_file" "ssh_metastores_yaml" {
  count    = length(var.ssh_metastores)
  template = file("${path.module}/templates/waggle-dance-federation-ssh.yml.tmpl")

  vars = {
    prefix                = lookup(var.ssh_metastores[count.index], "prefix")
    bastion_host          = lookup(var.ssh_metastores[count.index], "bastion-host")
    metastore_host        = lookup(var.ssh_metastores[count.index], "metastore-host")
    metastore_port        = lookup(var.ssh_metastores[count.index], "port")
    user                  = lookup(var.ssh_metastores[count.index], "user")
    timeout               = lookup(var.ssh_metastores[count.index], "timeout", "60000")
    mapped_databases      = lookup(var.ssh_metastores[count.index], "mapped-databases", "")
    mapped_tables         = lookup(var.ssh_metastores[count.index], "mapped-tables", "")
    database_name_mapping = lookup(var.ssh_metastores[count.index], "database-name-mapping", "")
    writable_whitelist    = lookup(var.ssh_metastores[count.index], "writable-whitelist", "")
    metastore_enabled     = lookup(var.ssh_metastores[count.index], "enabled", true)
    latency               = lookup(var.ssh_metastores[count.index], "latency", var.default_latency)
  }
}

data "template_file" "glue_metastores_yaml" {
  count    = length(var.glue_metastores)
  template = file("${path.module}/templates/waggle-dance-federation-glue.yml.tmpl")

  vars = {
    prefix                 = lookup(var.glue_metastores[count.index], "prefix")
    glue_account_id        = lookup(var.glue_metastores[count.index], "glue-account-id")
    glue_endpoint          = lookup(var.glue_metastores[count.index], "glue-endpoint")
    mapped_databases       = lookup(var.glue_metastores[count.index], "mapped-databases", "")
    mapped_tables          = lookup(var.glue_metastores[count.index], "mapped-tables", "")
    database_name_mapping  = lookup(var.glue_metastores[count.index], "database-name-mapping", "")
    writable_whitelist     = lookup(var.glue_metastores[count.index], "writable-whitelist", "")
    enable_path_conversion = lookup(var.glue_metastores[count.index], "enable_path_conversion", false)
    metastore_enabled      = lookup(var.glue_metastores[count.index], "enabled", true)
    latency                = lookup(var.glue_metastores[count.index], "latency", var.default_latency)
  }
}

data "template_file" "federation_yaml" {
  template = file("${path.module}/templates/waggle-dance-federation.yml.tmpl")

  vars = {
    primary_metastore_host             = var.primary_metastore_host
    primary_metastore_port             = var.primary_metastore_port
    primary_metastore_latency          = var.primary_metastore_latency
    primary_metastore_glue_account_id  = var.primary_metastore_glue_account_id
    primary_metastore_glue_endpoint    = var.primary_metastore_glue_endpoint
    primary_metastore_whitelist        = join("", data.template_file.primary_metastore_whitelist.*.rendered)
    primary_metastore_mapped_databases = join("", data.template_file.primary_metastore_mapped_databases.*.rendered)
    primary_metastore_access_type      = var.primary_metastore_access_type
    local_metastores                   = join("", data.template_file.local_metastores_yaml.*.rendered)
    remote_metastores                  = join("", data.template_file.remote_metastores_yaml.*.rendered)
    remote_region_metastores           = join("", data.template_file.remote_region_metastores_yaml.*.rendered)
    ssh_metastores                     = join("", data.template_file.ssh_metastores_yaml.*.rendered)
    glue_metastores                    = join("", data.template_file.glue_metastores_yaml.*.rendered)
  }
}

data "template_file" "waggledance" {
  template = file("${path.module}/templates/waggledance.json")

  vars = {
    heapsize            = var.memory
    docker_image        = var.docker_image
    docker_version      = var.docker_version
    region              = var.aws_region
    loggroup            = var.wd_instance_type == "ecs" ? join("", aws_cloudwatch_log_group.waggledance_ecs.*.name) : ""
    loglevel            = var.wd_log_level
    invocationloglevel  = var.enable_invocation_logs ? "debug" : "info"
    server_yaml         = base64encode(data.template_file.server_yaml.rendered)
    federation_yaml     = base64encode(data.template_file.federation_yaml.rendered)
    hive_site_xml       = var.alluxio_endpoints == [] ? "" : base64encode(data.template_file.hive_site_xml.rendered)
    bastion_ssh_key_arn = var.bastion_ssh_key_secret_name == "" ? "" : join("", data.aws_secretsmanager_secret.bastion_ssh_key.*.arn)
    docker_auth         = var.docker_registry_auth_secret_name == "" ? "" : format("\"repositoryCredentials\" :{\n \"credentialsParameter\":\"%s\"\n},", join("\",\"", concat(data.aws_secretsmanager_secret.docker_registry.*.arn)))
    tcp_keepalive_time  = var.tcp_keepalive_time
    tcp_keepalive_intvl = var.tcp_keepalive_intvl
    tcp_keepalive_probes = var.tcp_keepalive_probes
    wd_instance_type = var.wd_instance_type
    metrics_port = var.metrics_port
    datadog_agent_version = var.datadog_agent_version
    include_datadog_agent = var.include_datadog_agent
    dd_use_dogstatsd = var.dd_use_dogstatsd
  }
}

data "template_file" "datadog-agent" {
  template = file("${path.module}/templates/datadog-agent.json")

  vars = {
    region              = var.aws_region
    loggroup            = var.wd_instance_type == "ecs" ? join("", aws_cloudwatch_log_group.waggledance_ecs.*.name) : ""
    datadog_secret_key = jsondecode(data.aws_secretsmanager_secret_version.datadog_key[0].secret_string).api_key
    wd_instance_type = var.wd_instance_type
    metrics_port = var.metrics_port
    datadog_agent_version = var.datadog_agent_version
  }
}
