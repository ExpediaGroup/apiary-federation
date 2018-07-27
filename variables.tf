/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

variable "instance_name" {
  description = "waggledance instance name to identify resources in multi instance deployments"
  type        = "string"
  default     = ""
}

variable "region" {
  description = "AWS region to use for resources"
  type        = "string"
}

variable "instance_count" {
  description = "Number of EC2 instance to create"
  type        = "string"
  default     = "1"
}

variable "vpc_id" {
  description = "VPC id"
  type        = "string"
}

variable "subnets" {
  description = "ECS container subnets"
  type        = "list"
}

# Tags
variable "tags" {
  description = "A map of tags to apply to resources"
  type        = "map"

  default = {
    Environment = ""
    Application = ""
    Team        = ""
  }
}

# Monitoring and alerting
variable "alerting_email" {
  description = "Email to receive alerts"
  type        = "string"
}

variable "memory" {
  description = "The amount of memory (in MiB) used by waggledance task."
  type        = "string"
  default     = "4096"
}

variable "cpu" {
  description = "The number of cpu units to reserve for waggledance container"
  type        = "string"
  default     = "1024"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress cidr list"
  type        = "list"
}

variable "docker_image" {
  description = "waggledance docker image"
  type        = "string"
}

variable "docker_version" {
  description = "waggledance docker image version"
  type        = "string"
}

variable "graphite_host" {
  description = "graphite server configured in waggledance to send metrics"
  type        = "string"
  default     = "localhost"
}

variable "graphite_port" {
  description = "graphite server port"
  type        = "string"
  default     = "2003"
}

variable "graphite_prefix" {
  description = "prefix addded to all metrics sent to graphite from this waggledance instance."
  type        = "string"
  default     = "waggle-dance"
}

variable "primary_metastore_host" {
  description = "primary metastore hostname configured in waggledance"
  type        = "string"
  default     = "localhost"
}

variable "primary_metastore_port" {
  description = "primary metastore port"
  type        = "string"
  default     = "9083"
}

variable "primary_metastore_whitelist" {
  type        = "list"
  default     = [ "default" ]
}

#list of maps, example: [ {host="metastore1", port="9083", prefix="pre1" }, {host="metastore2", port="9083", prefix="pre2", mapped-databases="dm,test" } ]
variable "local_metastores" {
  description = "federated metastores in current account"
  type        = "list"
  default     = []
}

#list of maps, example: [ {endpoint="vpce1", port="9083", prefix="pre1" }, {endpoint="vpce2", port="9083", prefix="pre2", mapped-databases="dm,test", subnets="subnet1,subnet2" } ]
variable "remote_metastores" {
  description = "vpc endpoint services to federate metastores in other accounts"
  type        = "list"
  default     = []
}
