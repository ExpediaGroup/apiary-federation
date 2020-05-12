
# Overview

For more information please refer to the main [Apiary](https://github.com/ExpediaGroup/apiary) project page.

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_region | AWS region to use for resources. | string | - | yes |
| bastion_ssh_key_secret_name | Secret name in AWS Secrets Manager which stores the private key used to log in to bastions. The secret's key should be `private_key` and the value should be stored as a base64 encoded string. Max character limit for a secret's value is 4096. | string | `` | no |
| cpu | The number of CPU units to reserve for the Waggle Dance container. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `1024` | no |
| docker_image | Full path Waggle Dance Docker image. | string | - | yes |
| docker_registry_auth_secret_name | Docker Registry authentication SecretManager secret name. | string | `` | no |
| docker_version | Waggle Dance Docker image version. | string | - | yes |
| domain_extension | Domain name to use for Route 53 entry and service discovery. | string | `lcl` | no |
| enable_remote_metastore_dns | Option to enable creating DNS records for remote metastores. | string | `` | no |
| graphite_host | Graphite server configured in Waggle Dance to send metrics to. | string | `localhost` | no |
| graphite_port | Graphite server port. | string | `2003` | no |
| graphite_prefix | Prefix addded to all metrics sent to Graphite from this Waggle Dance instance. | string | `waggle-dance` | no |
| ingress_cidr | Generally allowed ingress CIDR list. | list | - | yes |
| instance_name | Waggle Dance instance name to identify resources in multi-instance deployments. | string | `` | no |
| k8s_namespace | K8s namespace to create waggle-dance deployment.| string | ``| no |
| k8s_docker_registry_secret | Docker Registry authentication K8s secret name.| string | ``| no |
| local_metastores | List of federated Metastore endpoints directly accessible on the local network. | list | `<list>` | no |
| memory | The amount of memory (in MiB) used to allocate for the Waggle Dance container. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `4096` | no |
| primary_metastore_host | Primary Hive Metastore hostname configured in Waggle Dance. | string | `localhost` | no |
| primary_metastore_port | Primary Hive Metastore port | string | `9083` | no |
| primary_metastore_whitelist | List of Hive databases to whitelist on primary Metastore. | list | `<list>` | no |
| remote_metastores | List of VPC endpoint services to federate Metastores in other accounts. | list | `<list>` | no |
| secondary_vpcs | List of VPCs to associate with Service Discovery namespace. | list | `<list>` | no |
| ssh_metastores | List of federated Metastores to connect to over SSH via bastion. | list | `<list>` | no |
| subnets | ECS container subnets. | list | - | yes |
| tags | A map of tags to apply to resources. | map | `<map>` | no |
| vpc_id | VPC ID. | string | - | yes |
| wd_ecs_task_count | Number of ECS tasks to create. | string | `1` | no |
| wd_instance_type | Waggle Dance instance type, possible values: `ecs`,`k8s`. | string | `ecs` | no |
| waggledance_version | Waggle Dance version to install on EC2 nodes. | string | `3.3.2` | no |
| waggledance_logs_retention_days | Log retention in days for the Waggle Dance Cloudwatch log group. | string | `30` | no |
| root_vol_type | Waggle Dance EC2 root volume type. | string | `gp2` | no |
| root_vol_size | Waggle Dance EC2 root volume size. | string | `10` | no |

## Usage

Example module invocation:
```
module "apiary-waggledance" {
  source            = "git::https://github.com/ExpediaGroup/apiary-federation.git?ref=master"
  instance_name     = "waggledance-test"
  wd_ecs_task_count = "1"
  aws_region        = "us-west-2"
  vpc_id            = "vpc-1"
  subnets           = ["subnet-1", "subnet-2"]

  tags = {
    Name = "Apiary-WaggleDance"
    Team = "Operations"
  }

  ingress_cidr                = ["10.0.0.0/8", "172.16.0.0/12"]
  docker_image                = "your.docker.repo/apiary-waggledance"
  docker_version              = "latest"
  primary_metastore_host      = "primary-metastore.yourdomain.com"
  primary_metastore_whitelist = ["test_.*", "team_.*"]

  remote_metastores = [{
    endpoint         = "com.amazonaws.vpce.us-west-2.vpce-svc-1"
    port             = "9083"
    prefix           = "metastore1"
    mapped-databases = "default,test"
  },
    {
      endpoint         = "com.amazonaws.vpce.us-east-1.vpce-svc-2"
      port             = "9083"
      prefix           = "metastore2"
      subnets          = "subnet-3"
      mapped-databases = "test"
    },
  ]
}
```

# Contact

## Mailing List
If you would like to ask any questions about or discuss Apiary please join our mailing list at

  [https://groups.google.com/forum/#!forum/apiary-user](https://groups.google.com/forum/#!forum/apiary-user)

# Legal
This project is available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).

Copyright 2018-2019 Expedia, Inc.
