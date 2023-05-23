/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

variable "instance_name" {
  description = "Waggle Dance instance name to identify resources in multi-instance deployments."
  type        = string
  default     = ""
}

variable "wd_instance_type" {
  description = "Waggle Dance instance type, possible values: ecs,k8s."
  type        = string
  default     = "ecs"
}

variable "waggledance_version" {
  description = "Waggle Dance version to install on EC2 nodes."
  type        = string
  default     = "3.3.2"
}

variable "wd_log_level" {
  description = "Log level for WaggleDance."
  type        = string
  default     = "info"
}

variable "enable_invocation_logs" {
  description = "Turns on Waggledance invocation logs in log4j, by default only slow (1 minute+) invocations are logged."
  type        = bool
  default     = false
}

variable "enable_autoscaling" {
  description = "Enable k8s horizontal pod autoscaling"
  type        = bool
  default     = false
}

variable "wd_target_cpu_percentage" {
  description = "waggle-dance autoscaling threshold for CPU target usage."
  type        = number
  default     = 60
}

variable "cpu_scale_in_cooldown" {
  type        = number
  default     = 300
  description = "cool down time(seconds) of scale in task by cpu usage"
}

variable "cpu_scale_out_cooldown" {
  type        = number
  default     = 120
  description = "cool down time(seconds) of scale out task by cpu usage"
}

variable "root_vol_type" {
  description = "Waggle Dance EC2 root volume type."
  type        = string
  default     = "gp2"
}

variable "root_vol_size" {
  description = "Waggle Dance EC2 root volume size."
  type        = string
  default     = "10"
}

variable "k8s_namespace" {
  description = "K8s namespace to create waggle-dance deployment."
  type        = string
  default     = "metastore"
}

variable "aws_region" {
  description = "AWS region to use for resources."
  type        = string
}

variable "wd_ecs_task_count" {
  description = "Number of ECS tasks to create."
  type        = string
  default     = "1"
}

variable "wd_ecs_max_task_count" {
  description = "Max Number of ECS tasks to create."
  type        = string
  default     = "10"
}

variable "k8s_replica_count" {
  description = "Initial Number of k8s pod replicas to create."
  type        = number
  default     = 3
}

variable "k8s_max_replica_count" {
  description = "Max Number of k8s pod replicas to create."
  type        = number
  default     = 10
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnets" {
  description = "ECS container subnets."
  type        = list(string)
}

# Tags
variable "tags" {
  description = "A map of tags to apply to resources."
  type        = map(string)

  default = {
    Environment = ""
    Application = ""
    Team        = ""
  }
}

variable "memory" {
  description = <<EOF
The amount of memory (in MiB) used to allocate for the Waggle Dance container.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = string
  default = "4096"
}

variable "cpu" {
  description = <<EOF
The number of CPU units to reserve for the Waggle Dance container.
Valid values can be 256, 512, 1024, 2048 and 4096.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = string
  default = "1024"
}

variable "ingress_cidr" {
  description = "Generally allowed ingress CIDR list."
  type        = list(string)
}

variable "docker_image" {
  description = "Full path Waggle Dance Docker image."
  type        = string
}

variable "docker_version" {
  description = "Waggle Dance Docker image version."
  type        = string
}

variable "k8s_docker_registry_secret" {
  description = "Docker Registry authentication K8s secret name."
  type        = string
  default     = ""
}

variable "graphite_host" {
  description = "Graphite server configured in Waggle Dance to send metrics to."
  type        = string
  default     = "localhost"
}

variable "graphite_port" {
  description = "Graphite server port."
  type        = string
  default     = "2003"
}

variable "graphite_prefix" {
  description = "Prefix addded to all metrics sent to Graphite from this Waggle Dance instance."
  type        = string
  default     = "waggle-dance"
}

variable "primary_metastore_host" {
  description = "Primary Hive Metastore hostname configured in Waggle Dance."
  type        = string
  default     = "localhost"
}

variable "primary_metastore_port" {
  description = "Primary Hive Metastore port"
  type        = string
  default     = "9083"
}

variable "primary_metastore_glue_account_id" {
  description = "Primary metastore Glue AWS account id, optional. Use with 'primary_metastore_glue_endpoint' and instead of 'primary_metastore_host/primary_metastore_port'"
  type        = string
  default     = ""
}

variable "primary_metastore_glue_endpoint" {
  description = "Primary metastore Glue endpoint 'glue.us-east-1.amazonaws.com', optional. Use with 'primary_metastore_glue_account_id' and instead of 'primary_metastore_host/primary_metastore_port'"
  type        = string
  default     = ""
}

variable "primary_metastore_whitelist" {
  description = "List of Hive databases to whitelist on primary Metastore."
  type        = list(string)
  default     = ["default"]
}

variable "primary_metastore_mapped_databases" {
  description = "List of Hive databases mapped from primary Metastore."
  type        = list(string)
  default     = []
}

#list of maps, example: [ {host="metastore1", port="9083", prefix="pre1", writable-whitelist="db1,test" }, {host="metastore2", port="9083", prefix="pre2", mapped-databases="dm,test" } ]
variable "local_metastores" {
  description = "List of federated Metastore endpoints directly accessible on the local network."
  type        = list(map(string))
  default     = []
}

#list of maps, example: [ {endpoint="vpce1", port="9083", prefix="pre1", writable-whitelist="db1,test" }, {endpoint="vpce2", port="9083", prefix="pre2", mapped-databases="dm,test", subnets="subnet1,subnet2" } ]
variable "remote_metastores" {
  description = "List of VPC endpoint services to federate Metastores in other accounts."
  type        = list(map(string))
  default     = []
}

#list of maps, example: [ {endpoint="vpce1", port="9083", prefix="pre1", writable-whitelist="db1,test", vpc_id = "vpc-123456", subnets = "subnet1,subnet2", security_group_id="sg1"  } ]
variable "remote_region_metastores" {
  description = "List of VPC endpoint services to federate Metastores in other region,other accounts. The actual data from tables in these metastores can be accessed using Alluxio caching instead of reading the data from S3 directly."
  type        = list(map(string))
  default     = []
}

#list of maps, example: [ {bastion-host="10.x.x.x", metastore-host="10.x.x.x", port="9083", prefix="pre1", user="my-unix-user", mapped-databases="test1,test2"}, {bastion-host="10.x.x.x", metastore-host="10.x.x.x", port="9083", prefix="pre2", user="my-unix-user", writable-whitelist="db1,test", mapped-databases="test1,test2"} ]
variable "ssh_metastores" {
  description = "List of federated Metastores to connect to over SSH via bastion."
  type        = list(map(string))
  default     = []
}

#list of maps, example: [ {glue-account-id="123456789012", glue-endpoint="glue.us-east-1.amazonaws.com", prefix="pre1", mapped-databases="test1,test2"}, {glue-account-id="111111111112", glue-endpoint="glue.us-east-1.amazonaws.com", prefix="pre2", mapped-databases="test1,test2"} ]
variable "glue_metastores" {
  description = "List of federated AWS Glue Data Catalogs."
  type        = list(map(string))
  default     = []
}

variable "bastion_ssh_key_secret_name" {
  description = <<EOF
Secret name in AWS Secrets Manager which stores the private key used to log in to bastions.
The secret's key should be `private_key` and the value should be stored as a base64 encoded string.
Max character limit for a secret's value is 4096.
EOF

  type    = string
  default = ""
}

variable "enable_remote_metastore_dns" {
  description = "Option to enable creating DNS records for remote metastores."
  type        = string
  default     = ""
}

variable "domain_extension" {
  description = "Domain name to use for Route 53 entry and service discovery."
  type        = string
  default     = "lcl"
}

variable "secondary_vpcs" {
  description = "List of VPCs to associate with Service Discovery namespace."
  type        = list(string)
  default     = []
}

variable "docker_registry_auth_secret_name" {
  description = "Docker Registry authentication SecretManager secret name."
  type        = string
  default     = ""
}

variable "prometheus_enabled" {
  description = "Enable to expose the Prometheus endpoint. Also enables Prometheus metrics scraping from k8s pods - true or false."
  default     = false
  type        = bool
}

//[ { root_url = "alluxio://alluxio1:19998/", s3_buckets = "bucket1,bucket2" }, { root_url = "alluxio://alluxio2:19998/", s3_buckets = "bucket3,bucket4" } ]
//it is important that root_url contains / at the end for hive hook to create valid url after replacement
variable "alluxio_endpoints" {
  type    = list(map(string))
  default = []
}

variable "default_latency" {
  type        = number
  default     = 0
  description = "HMS latency (in ms.) that Waggledance will tolerate.  See \"latency\" parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. This sets the default for all metastores except the primary metastore."
}

variable "primary_metastore_latency" {
  type        = number
  default     = 0
  description = "HMS latency (in ms.) that Waggledance will tolerate.  See \"latency\" parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. This sets the latency for the primary metastore only."
}

variable "oidc_provider" {
  description = "EKS cluster OIDC provider name, required for configuring IAM using IRSA."
  type        = string
  default     = ""
}

variable "enable_query_functions_across_all_metastores" {
  default     = false
  type        = bool
  description = "See `queryFunctionsAcrossAllMetastores` in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md, overriding the WaggleDance default as we will get better performance"
}

variable "primary_metastore_access_type" {
  description = "Primary metastore access control type."
  type        = string
  default     = "READ_AND_WRITE_ON_DATABASE_WHITELIST"
}

variable "datadog_metrics_waggledance" {
  description = "WaggleDance metrics to be sent to Datadog."
  type        = list(string)
  default = [
    "metastore_status_total*",
    "counter_com_hotels_bdp_waggledance_server*"
  ]
}

variable "metrics_port" {
  description = "Port in which metrics will be send for Datadog"
  type        = string
  default     = "18000"
}

variable "datadog_metrics_enabled" {
  description = "Enable Datadog metrics for HMS"
  type        = bool
  default     = false
}
