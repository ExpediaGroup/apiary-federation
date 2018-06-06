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

variable "security_groups" {
  description = "List of Security Group IDs to attach"
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

# Waggle Dance
variable "wd_loadbalancer_name" {
  description = "ELB name pointing to Waggle Dance"
  type        = "string"
  default     = "waggle-dance-elb"
}

variable "wd_port" {
  description = "Waggle Dance Port"
  type        = "string"
  default     = "48869"
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

variable "docker_image" {}

variable "docker_version" {}

variable "graphite_host" {
  default = "localhost"
}

variable "graphite_port" {
  default = "2003"
}

variable "graphite_prefix" {
  default = "waggle-dance"
}

variable "primary_metastore_host" {
  default = "localhost"
}

variable "primary_metastore_port" {
  default = "9083"
}

#list of maps, example: [ {'endpoint':'vpce1', 'port':'9083', 'prefix':'pre1' }, {'endpoint':'vpce2', 'port':'9083', 'prefix':'pre2' } ]
variable "remote_metastores" {
  type    = "list"
  default = []
}
