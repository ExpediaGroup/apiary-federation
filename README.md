
# Overview

For more information please refer to the main [Apiary](https://github.com/ExpediaInc/apiary) project page.

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alerting_email | Email to receive alerts | string | - | yes |
| cpu | The number of cpu units to reserve for waggledance container | string | `1024` | no |
| docker_image | waggledance docker image | string | - | yes |
| docker_version | waggledance docker image version | string | - | yes |
| graphite_host | graphite server configured in waggledance to send metrics | string | `localhost` | no |
| graphite_port | graphite server port | string | `2003` | no |
| graphite_prefix | prefix addded to all metrics sent to graphite from this waggledance instance. | string | `waggle-dance` | no |
| ingress_cidr | Generally allowed ingress cidr list | list | - | yes |
| instance_count | Number of EC2 instance to create | string | `1` | no |
| instance_name | waggledance instance name to identify resources in multi instance deployments | string | `` | no |
| local_metastores | federated metastores in current account | list | `<list>` | no |
| memory | The amount of memory (in MiB) used by waggledance task. | string | `4096` | no |
| primary_metastore_host | primary metastore hostname configured in waggledance | string | `localhost` | no |
| primary_metastore_port | primary metastore port | string | `9083` | no |
| primary_metastore_whitelist |  | list | `<list>` | no |
| region | AWS region to use for resources | string | - | yes |
| remote_metastores | vpc endpoint services to federate metastores in other accounts | list | `<list>` | no |
| subnets | ECS container subnets | list | - | yes |
| tags | A map of tags to apply to resources | map | `<map>` | no |
| vpc_id | VPC id | string | - | yes |

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
