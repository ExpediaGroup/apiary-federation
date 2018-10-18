
# Overview

For more information please refer to the main [Apiary](https://github.com/ExpediaInc/apiary) project page.

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bastion_ssh_key_secret_name | Secret name in AWS Secrets Manager which stores private key to login to Bastions. Secret's key should be `private_key` and value should be stored as base64 encoded string. Max character limit for a Secret's value is 4096. | string | `` | no |
| cpu | The number of CPU units to reserve for the Waggle Dance container. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `1024` | no |
| docker_image | Full path Waggle Dance Docker image. | string | - | yes |
| docker_version | Waggle Dance Docker image version. | string | - | yes |
| domain_extension | Domain name to use for Route 53 entry and service discovery. | string | `lcl` | no |
| enable_remote_metastore_dns | Option to enable creating DNS records for remote metastores. | string | `` | no |
| graphite_host | Graphite server configured in Waggle Dance to send metrics to. | string | `localhost` | no |
| graphite_port | Graphite server port. | string | `2003` | no |
| graphite_prefix | Prefix addded to all metrics sent to Graphite from this Waggle Dance instance. | string | `waggle-dance` | no |
| ingress_cidr | Generally allowed ingress CIDR list. | list | - | yes |
| instance_count | Number of ECS tasks to create. | string | `1` | no |
| instance_name | Waggle Dance instance name to identify resources in multi-instance deployments. | string | `` | no |
| local_metastores | List of federated Metastores in current account. | list | `<list>` | no |
| memory | The amount of memory (in MiB) used to allocate for the Waggle Dance container. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `4096` | no |
| primary_metastore_host | Primary Hive Metastore hostname configured in Waggle Dance. | string | `localhost` | no |
| primary_metastore_port | Primary Hive Metastore port | string | `9083` | no |
| primary_metastore_whitelist | List of Hive databases to whitelist on primary Metastore. | list | `<list>` | no |
| region | AWS region to use for resources. | string | - | yes |
| remote_metastores | List of VPC endpoint services to federate Metastores in other accounts. | list | `<list>` | no |
| secondary_vpcs | List of VPCs to associate with Service Discovery namespace | list | `<list>` | no |
| ssh_metastores | List of federated Metastores to connect over SSH via Bastion. | list | `<list>` | no |
| subnets | ECS container subnets. | list | - | yes |
| tags | A map of tags to apply to resources. | map | `<map>` | no |
| vpc_id | VPC ID. | string | - | yes |

## Usage

Example module invocation:
```
module "apiary-waggledance" {
  source         = "git::https://github.com/ExpediaInc/apiary-waggledance.git?ref=master"
  instance_name  = "waggledance-test"
  instance_count = "1"
  region         = "us-west-2"
  vpc_id         = "vpc-1"
  subnets        = ["subnet-1", "subnet-2"]

  tags = {
    Name = "Apiary-WaggleDance"
    Team = "Operations"
  }

  alerting_email              = "abc@yourdomain.com"
  ingress_cidr                = ["10.0.0.0/8", "172.16.0.0/12"]
  docker_image                = "your.docker.repo/apiary-waggledance"
  docker_version              = "latest"
  primary_metastore_host      = "primary-metastore.yourdomain.com"
  primary_metastore_whitelist = ["test_.*", "team_.*"]

  remote_metastores = [{
    endpoint = "com.amazonaws.vpce.us-west-2.vpce-svc-1"
    port = "9083"
    prefix = "metastore1"
    mapped-databases = "default,test"
  },
  {
    endpoint = "com.amazonaws.vpce.us-east-1.vpce-svc-2"
    port = "9083"
    prefix = "metastore2"
    subnets = "subnet-3"
    mapped-databases = "test"
  }]
}
```

# Contact

## Mailing List
If you would like to ask any questions about or discuss Apiary please join our mailing list at

  [https://groups.google.com/forum/#!forum/apiary-user](https://groups.google.com/forum/#!forum/apiary-user)

# Legal
This project is available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).

Copyright 2018 Expedia Inc.
