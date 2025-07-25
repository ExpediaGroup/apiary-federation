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
  default     = "3.11.4"
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

variable "k8s_dns_policy" {
  description = "DNS policy for the Waggledance Kubernetes deployment. Valid values are 'ClusterFirstWithHostNet', 'ClusterFirst', 'Default', or 'None'."
  type        = string
  default     = "ClusterFirst"

  validation {
    condition = can(regex("(ClusterFirstWithHostNet|ClusterFirst|Default|None)", var.k8s_dns_policy))
    error_message = "The dns_policy must be one of 'ClusterFirstWithHostNet', 'ClusterFirst', 'Default', or 'None'."
  }
}

variable "k8s_dns_config" {
  description = "DNS configuration for the Waggledance Kubernetes deployment."
  type = object({
    nameservers = optional(list(string))
    searches    = optional(list(string))
    options     = optional(list(object({
      name  = string
      value = optional(string)
    })))
  })
  default = {
    nameservers = []
    searches    = []
    options     = []
  }
}

variable "k8s_svc_spec" {
  description =<<EOF
Waggledance Kubernetes service settings. All fields are optional.
external_traffic_policy = "Denotes if this Service desires to route external traffic to node-local or cluster-wide endpoints. Local preserves the client source IP and avoids a second hop for LoadBalancer and Nodeport type services, but risks potentially imbalanced traffic spreading. Cluster obscures the client source IP and may cause a second hop to another node, but should have good overall load-spreading."
internal_traffic_policy = "Specifies if the cluster internal traffic should be routed to all endpoints or node-local endpoints only. Cluster routes internal traffic to a Service to all endpoints. Local routes traffic to node-local endpoints only, traffic is dropped if no node-local endpoints are ready. The default value is 'Cluster'"
allocate_load_balancer_node_ports = "Defines if NodePorts will be automatically allocated for services with type LoadBalancer. It may be set to false if the cluster load-balancer does not rely on NodePorts. If the caller requests specific NodePorts (by specifying a value), those requests will be respected, regardless of this field. This field may only be set for services with type LoadBalancer. Default is 'true'"
load_balancer_class = "The class of the load balancer implementation this Service belongs to. By default this service is handled by the built-in Cloud Controller Manager. To use AWS Load Balancer Controller, set this to 'service.k8s.aws/nlb'"
health_check_node_port = "Specifies the Healthcheck NodePort for the service. Only effects when service type is set to 'LoadBalancer' and k8s_svc_external_traffic_policy is set to 'Local'"
EOF

  type = object({
    external_traffic_policy           = optional(string)
    internal_traffic_policy           = optional(string)
    allocate_load_balancer_node_ports = optional(bool)
    load_balancer_class               = optional(string)
    health_check_node_port            = optional(string)
  })
  default = {}
}

variable "k8s_svc_annotations" {
  description =<<EOF
Custom annotations for the Waggledance Kubernetes service. You can use this variable to add extra annotations for configuring the AWS NLB for this service. If var.k8s_svc_lb_controller_type is "nlb-ip" or "external" it means you want to offload 
the NLB management to an external controller like AWS Load Balancer Controller. The annotations that are accepted are defined here - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/service/annotations/
If the var.k8s_svc_lb_controller_type is "nlb" or any other value, then you are using the Legacy AWS Cloud controller and you can see the accepted values here - https://github.com/kubernetes/cloud-provider-aws/blob/master/docs/service_controller.md
EOF

  type        = map(string)
  default     = {
    "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
    "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
  }
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

variable "memory_limit" {
  description = <<EOF
The amount of memory limit (in MiB) used to allocate for the Waggle Dance container. It will use memory * 1.25 
if this value is not specified.
Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = string
  default = ""
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

variable "cpu_limit" {
  description = <<EOF
The number of CPU units limit to reserve for the Waggle Dance container.
Valid values can be 256, 512, 1024, 2048 and 4096.It will use cpu * 1.25 if this value is not specified.
Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
EOF

  type    = string
  default = ""
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

variable "primary_metastore_database_prefix" {
  description = "Primary Hive Metastore database prefix configured in Waggle Dance."
  type        = string
  default     = ""
}

variable "primary_metastore_read_only_host" {
  description = "Primary Hive Metastore READ ONLY hostname configured in Waggle Dance. Optional."
  type        = string
  default     = ""
}

variable "primary_metastore_read_only_port" {
  description = "Primary Hive Metastore READ ONLY port configured in Waggle Dance. Optional."
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
    "counter_com_hotels_bdp_waggledance_server*",
    "jvm_*",
    "system_*",
    "timer_*"
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

variable "enable_tcp_keepalive" {
  description = "Enable tcp keepalive settings on the waggledance pods."
  type        = bool
  default     = false
}

variable "tcp_keepalive_time" {
  description = "Sets net.ipv4.tcp_keepalive_time (seconds)."
  type        = number
  default     = 200
}

variable "tcp_keepalive_intvl" {
  description = "Sets net.ipv4.tcp_keepalive_intvl (seconds)."
  type        = number
  default     = 30
}

variable "tcp_keepalive_probes" {
  description = "Sets net.ipv4.tcp_keepalive_probes (number)."
  type        = number
  default     = 2
}


variable "datadog_key_secret_name" {
  description = "Name of the secret containing the DataDog API key. This needs to be created manually in AWS secrets manager. This is only applicable to ECS deployments."
  type        = string
  default     = ""
}

variable "datadog_agent_version" {
  description = "Version of the Datadog Agent running in the ECS cluster. This is only applicable to ECS deployments."
  type        = string
  default     = "7.46.0-jmx"
}

variable "include_datadog_agent" {
  description = "Whether to include the datadog-agent container alongside waggledance. This is only applicable to ECS deployments."
  type        = bool
  default     = false
}

/*
Example:
extended_server_config = <<EOT
waggledance.extensions.ratelimit.enabled: true
waggledance.extensions.ratelimit.storage: redis
waggledance.extensions.ratelimit.capacity: 2000
waggledance.extensions.ratelimit.tokensPerMinute: 1000
waggledance.extensions.ratelimit.reddison.embedded.config: |
  replicatedServersConfig:
    idleConnectionTimeout: 10000
    connectTimeout: 3000
    timeout: 1000
    retryAttempts: 0
    retryInterval: 1500
    password: "<auth_token>"
    nodeAddresses:
    - "rediss://localhost1:62493"
    - "rediss://localhost2:62493"
EOT
*/
variable "extended_server_config" {
  description = "Extended waggle-dance-server.yml configuration for Waggle Dance. This is a YAML string."
  type        = string
  default     = ""
}

variable "enable_vpc_endpoint_services" {
  description = "Enable metastore NLB, Route53 entries VPC access and VPC endpoint services, for cross-account access."
  type        = bool
  default     = false
}

variable "waggledance_customer_accounts" {
  description = "Waggledance VPC Endpoint customer accounts"
  type        = list(string)
  default     = []
}

variable "enable_splunk_logging" {
  description = "Enable sending longs to Splunk. When enabling we also need splunk_hec_token, splunk_hec_host and splunk_index."
  type        = bool
  default     = false
}

variable "splunk_hec_token" {
  description = "The token used for authentication with the Splunk HTTP Event Collector (HEC). This is required for sending logs to Splunk. Compatible with both EC2 and FARGATE ECS task definitions."
  type        = string
  default     = ""
}

variable "splunk_hec_host" {
  description = "The hostname or URL of the Splunk HTTP Event Collector (HEC) endpoint to which logs will be sent."
  type        = string
  default     = ""
}

variable "splunk_hec_index" {
  description = "The index in Splunk where logs will be stored. This is used to organize and manage logs within Splunk."
  type        = string
  default     = ""
}
variable "splunk_insecureskipverify" {
  description = "Instructs the splunk lgging driver to skip cert validation."
  type        = string
  default     = "false"
}