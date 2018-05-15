/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

variable "profile" {
  description = "AWS CLI profile name"
  type        = "string"
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

variable "ami_id" {
  description = "AWS AMI id"
  type        = "string"
}

variable "instance_type" {
  description = "Instance type to use"
  type        = "string"
  default     = "m4.large"
}

variable "subnet_id" {
  description = "Subnet ID for host"
  type        = "list"
}

variable "security_groups" {
  description = "List of Security Group IDs to attach"
  type        = "list"
}

variable "public_ip_address" {
  description = "Associate public IP address with AWS EC2 instance? Set true for 'yes' else false"
  type        = "string"
  default     = "no"
}

variable "enable_termination_protection" {
  description = "Flag to enable Termination Protection. Defaults to true. Set to false to disable protection"
  type        = "string"
  default     = "true"
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = "string"
  default     = "false"
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = "string"
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = "string"
  default     = "true"
}

variable "user_data_base64" {
  description = "base64-encoded binary data"
  type        = "string"
  default     = ""
}

variable "root_block_device_volume_size" {
  description = "Root OS disk volume size"
  type        = "string"
  default     = "8"
}

variable "root_block_device_volume_type" {
  description = "Root OS disk volume type"
  type        = "string"
  default     = "standard"
}

variable "root_block_device_delete_on_termination" {
  description = "Root OS disk delete_on_termination action"
  type        = "string"
  default     = "true"
}

variable "root_block_device_iops" {
  description = "Root OS disk IOPS. Only applicable when volume type is io1"
  type        = "string"
  default     = "0"
}

variable "elb_access_logs_bucket" {
  description = "S3 bucket to store ELB access logs"
  type        = "string"
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

variable "name" {
  description = "Name of the instance to provide under 'Name' tag"
  type        = "string"
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
