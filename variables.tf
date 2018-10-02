/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

variable "instance_name" {
  description = "Waggle Dance instance name to identify resources in multi-instance deployments."
  type        = "string"
  default     = ""
}

variable "region" {
  description = "AWS region to use for resources."
  type        = "string"
}

variable "instance_count" {
  description = "Number of ECS tasks to create."
  type        = "string"
  default     = "1"
}

variable "vpc_id" {
  description = "VPC ID."
  type        = "string"
}

variable "subnets" {
  description = "ECS container subnets."
  type        = "list"
}

# Tags
variable "tags" {
  description = "A map of tags to apply to resources."
  type        = "map"

  default = {
    Environment = ""
    Application = ""
    Team        = ""
  }
}

# Monitoring and alerting
variable "alerting_email" {
  description = "Email address to send alerts to."
  type        = "string"
}

variable "memory" {
  description = <<EOF
The amount of memory (in MiB) used to allocate for the Waggle Dance container.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = "string"
  default = "4096"
}

variable "cpu" {
  description = <<EOF
The number of CPU units to reserve for the Waggle Dance container.
Valid values can be 256, 512, 1024, 2048 and 4096.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = "string"
  default = "1024"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress CIDR list."
  type        = "list"
}

variable "docker_image" {
  description = "Full path Waggle Dance Docker image."
  type        = "string"
}

variable "docker_version" {
  description = "Waggle Dance Docker image version."
  type        = "string"
}

variable "graphite_host" {
  description = "Graphite server configured in Waggle Dance to send metrics to."
  type        = "string"
  default     = "localhost"
}

variable "graphite_port" {
  description = "Graphite server port."
  type        = "string"
  default     = "2003"
}

variable "graphite_prefix" {
  description = "Prefix addded to all metrics sent to Graphite from this Waggle Dance instance."
  type        = "string"
  default     = "waggle-dance"
}

variable "primary_metastore_host" {
  description = "Primary Hive Metastore hostname configured in Waggle Dance."
  type        = "string"
  default     = "localhost"
}

variable "primary_metastore_port" {
  description = "Primary Hive Metastore port"
  type        = "string"
  default     = "9083"
}

variable "primary_metastore_whitelist" {
  description = "List of Hive databases to whitelist on primary Metastore."
  type        = "list"
  default     = ["default"]
}

#list of maps, example: [ {host="metastore1", port="9083", prefix="pre1" }, {host="metastore2", port="9083", prefix="pre2", mapped-databases="dm,test" } ]
variable "local_metastores" {
  description = "List of federated Metastores in current account."
  type        = "list"
  default     = []
}

#list of maps, example: [ {endpoint="vpce1", port="9083", prefix="pre1" }, {endpoint="vpce2", port="9083", prefix="pre2", mapped-databases="dm,test", subnets="subnet1,subnet2" } ]
variable "remote_metastores" {
  description = "List of VPC endpoint services to federate Metastores in other accounts."
  type        = "list"
  default     = []
}

variable "enable_remote_metastore_dns" {
  description = "Option to enable creating DNS records for remote metastores."
  type        = "string"
  default     = ""
}

variable "domain_extension" {
  description = "Domain name to use for Route 53 entry and service discovery."
  type        = "string"
  default     = "lcl"
}

variable "secondary_vpcs" {
  description = "List of VPCs to associate with Service Discovery namespace"
  type        = "list"
  default     = []
}
