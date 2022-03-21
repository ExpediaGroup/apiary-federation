
# Overview

For more information please refer to the main [Apiary](https://github.com/ExpediaGroup/apiary) project page.

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alluxio_endpoints | List of Alluxio endpoints(map of root url and s3 buckets) used to replace s3 paths with alluxio paths. See section [`Usage`](#Usage)| list | `<list>` | no |
| aws_region | AWS region to use for resources. | string | - | yes |
| bastion_ssh_key_secret_name | Secret name in AWS Secrets Manager which stores the private key used to log in to bastions. The secret's key should be `private_key` and the value should be stored as a base64 encoded string. Max character limit for a secret's value is 4096. | string | `` | no |
| cpu | The number of CPU units to reserve for the Waggle Dance container. Valid values can be 256, 512, 1024, 2048 and 4096. Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `1024` | no |
| cpu_scale_in_cooldown | Cool down time(seconds) of scale in task by cpu usage | number | 300 | no |
| cpu_scale_out_cooldown | Cool down time(seconds) of scale out task by cpu usage | number | 120 | no |
| default_latency | Latency used for other (not primary) metastores that don't override it in their own configurations. See `latency` parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. | number | `0` | no |
| primary_metastore_latency | Latency used for the primary metastores. See `latency` parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. | number | `0` | no |
| docker_image | Full path Waggle Dance Docker image. | string | - | yes |
| docker_registry_auth_secret_name | Docker Registry authentication SecretManager secret name. | string | `` | no |
| docker_version | Waggle Dance Docker image version. | string | - | yes |
| domain_extension | Domain name to use for Route 53 entry and service discovery. | string | `lcl` | no |
| enable_remote_metastore_dns | Option to enable creating DNS records for remote metastores. | string | `` | no |
| enable_autoscaling | Enable k8s horizontal pod autoscaling. | bool | `false` | no |
| graphite_host | Graphite server configured in Waggle Dance to send metrics to. | string | `localhost` | no |
| graphite_port | Graphite server port. | string | `2003` | no |
| graphite_prefix | Prefix addded to all metrics sent to Graphite from this Waggle Dance instance. | string | `waggle-dance` | no |
| ingress_cidr | Generally allowed ingress CIDR list. | list | - | yes |
| instance_name | Waggle Dance instance name to identify resources in multi-instance deployments. | string | `` | no |
| k8s_namespace | K8s namespace to create waggle-dance deployment.| string | ``| no |
| k8s_docker_registry_secret | Docker Registry authentication K8s secret name.| string | ``| no |
| k8s_replica_count | Initial Number of k8s pod replicas to create. | number | `3` | no |
| k8s_max_replica_count | Max Number of k8s pod replicas to create. | number | `10` | no |
| local_metastores | List of federated Metastore endpoints directly accessible on the local network. See section [`local_metastores`](#local_metastores) for more info.| list | `<list>` | no |
| memory | The amount of memory (in MiB) used to allocate for the Waggle Dance container. Valid values: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html | string | `4096` | no |
| primary_metastore_host | Primary Hive Metastore hostname configured in Waggle Dance. | string | `localhost` | no |
| primary_metastore_port | Primary Hive Metastore port | string | `9083` | no |
| primary_metastore_glue_account_id| Primary metastore Glue AWS account id, optional. Use with `primary_metastore_glue_endpoint` and instead of `primary_metastore_host/primary_metastore_port` | string | `` | no |
| primary_metastore_glue_endpoint | Primary metastore Glue endpoint `glue.us-east-1.amazonaws.com`, optional. Use with `primary_metastore_glue_account_id` and instead of `primary_metastore_host` and `primary_metastore_port` | string | `` | no |
| primary_metastore_whitelist | List of Hive databases to whitelist on primary Metastore. | list | `<list>` | no |
| primary_metastore_mapped_databases | List of Hive databases mapped from primary Metastore. | list | `<list>` | no |
| remote_metastores | List of VPC endpoint services to federate Metastores in other accounts. See section [`remote_metastores`](#remote_metastores) for more info.| list | `<list>` | no |
| remote_region_metastores | List of VPC endpoint services to federate Metastores in other region,other accounts. The actual data from tables in these metastores can be accessed using Alluxio caching instead of reading the data from S3 directly. See section [`remote_region_metastores`](#remote_region_metastores) for more info.| list | `<list>` | no |
| secondary_vpcs | List of VPCs to associate with Service Discovery namespace. | list | `<list>` | no |
| ssh_metastores | List of federated Metastores to connect to over SSH via bastion. See section [`ssh_metastores`](#ssh_metastores) for more info.| list | `<list>` | no |
| subnets | ECS container subnets. | list | - | yes |
| tags | A map of tags to apply to resources. | map | `<map>` | no |
| vpc_id | VPC ID. | string | - | yes |
| wd_ecs_task_count | Number of ECS tasks to create. | string | `1` | no |
| wd_ecs_max_task_count | Max Number of ECS tasks to create. | string | `10` | no |
| wd_instance_type | Waggle Dance instance type, possible values: `ecs`,`k8s`. | string | `ecs` | no |
| wd_target_cpu_percentage | Waggle Dance autoscaling threshold for CPU target usage. | number | `60` | no |
| waggledance_version | Waggle Dance version to install on EC2 nodes | string | `3.3.2` | no |
| root_vol_type | Waggle Dance EC2 root volume type. | string | `gp2` | no |
| root_vol_size | Waggle Dance EC2 root volume size. | string | `10` | no |

## Usage

Example module invocation:
```
module "apiary-waggledance" {
  source            = "git::https://github.com/ExpediaGroup/apiary-federation.git?ref=master"

  #required for creating VPC endpoints in remote region
  providers = {
    aws.remote = aws.remote
  }

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
  primary_metastore_latency   = 1000

  default_latency = 100

  remote_metastores = [
    {
      endpoint              = "com.amazonaws.vpce.us-west-2.vpce-svc-1"
      port                  = "9083"
      prefix                = "metastore1"
      mapped-databases      = "default,test"
      database-name-mapping = "test:test_alias,default:default_alias"
      writable-whitelist    = "test"
      latency               = 5000
    },
    {
      endpoint         = "com.amazonaws.vpce.us-east-1.vpce-svc-2"
      port             = "9083"
      prefix           = "metastore2"
      subnets          = "subnet-3"
      mapped-databases = "test"
      enabled          = false //option to enable/disable metastore in waggle-dance without removing vpc endpoint.
    },
  ]
  remote_region_metastores = [
    {
      endpoint              = "com.amazonaws.vpce.us-west-2.vpce-svc-1"
      port                  = "9083"
      prefix                = "metastore1"
      mapped-databases      = "default,test"
      database-name-mapping = "test:test_alias,default:default_alias"
      writable-whitelist    = "test"
      vpc_id                = "vpc-123456"
      subnets               = "subnet-1,subnet-2"
      security_group_id     = "sg1"
    },
  ]

  alluxio_endpoints = [
    {
      root_url   = "alluxio://alluxio1:19998/"
      s3_buckets = "bucket1,bucket2"
    }
    ,
    {
      root_url   = "alluxio://alluxio2:19998/"
      s3_buckets = "bucket3,bucket4"
    }
  ]

}
```

### local_metastores

A list of maps.  Each map entry describes a federated metastore server directly accessible on the local network.

An example entry looks like:
```
local_metastores = [
    {
      host                  = "hms-readonly.metastore.svc.cluster.local"
      latency               = 2000
      port                  = "9083"
      prefix                = "local1"
      mapped-databases      = "default,test"
      database-name-mapping = "test:test_alias,default:default_alias"
      mapped-tables         = "test:test_table1,test_table1;default:default_table1.*,default_table2"
      writable-whitelist    = "test"
    }
]
```
`local_metastores` map entry fields:

Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| host | Host name of the Hive metastore server on the local network. | string | - | yes |
| latency | Latency used for this metastore. See `latency` parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. | number | `var.default_latency` | no |
| port | IP port that the Thrift server of the Hive metastore listens on. | string | `"9083"` | no |
| prefix | Prefix added to the database names from this metastore. Must be unique among all local, remote, and SSH federated metastores in this Waggle Dance instance. | string | - | yes |
| mapped-databases | Comma-separated list of databases from this metastore to expose to federation. If not specified, *all* databases are exposed.| string | `""` | no |
| mapped-tables | Semicolon-separated/comma-separated list of databases and DB tables from this metastore to expose to federation. If not specified, *all* tables for each database are exposed. See [Waggle Dance Mapped Tables](https://github.com/ExpediaGroup/waggle-dance#mapped-tables) for more information.| string | `""` | no |
| database-name-mapping | Comma-separated list of `<database>:<alias>` key/value pairs to add aliases for the given databases. Default is no aliases. This is used primarily in migration scenarios where a database has been renamed/relocated. See [Waggle Dance Database Name Mapping](https://github.com/ExpediaGroup/waggle-dance#database-name-mapping) for more information.  | string | `""` | no |
| writable-whitelist | Comma-separated list of databases from this metastore that can be in read-write mode. If not specified, all databases are read-only. Use `.*` to allow all databases to be written to. | string | `""` | no |

See [Waggle Dance README](https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md) for more information on all these parameters.

### remote_metastores

A list of maps.  Each map entry describes a federated metastore endpoint accessible via an AWS VPC endpoint.

An example entry looks like:
```
remote_metastores = [
    {
      endpoint              = "com.amazonaws.vpce.us-west-2.vpce-svc-1"
      port                  = "9083"
      prefix                = "remote1"
      mapped-databases      = "default,test"
      database-name-mapping = "test:test_alias,default:default_alias"
      mapped-tables         = "test:test_table1,test_table1;default:default_table1.*,default_table2"
      writable-whitelist    = ".*"
    }
]
```
`remote_metastores` map entry fields:

Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| endpoint | AWS VPC endpoint name that is connected to the remote Hive metastore. | string | - | yes |
| latency | Latency used for this metastore. See `latency` parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. | number | `var.default_latency` | no |
| port | IP port that the Thrift server of the remote Hive metastore listens on. | string | `"9083"` | no |
| prefix | Prefix added to the database names from this metastore. Must be unique among all local, remote, and SSH federated metastores in this Waggle Dance instance. | string | - | yes |
| mapped-databases | Comma-separated list of databases from this metastore to expose to federation. If not specified, *all* databases are exposed.| string | `""` | no |
| mapped-tables | Semicolon-separated/comma-separated list of databases and DB tables from this metastore to expose to federation. If not specified, *all* tables for each database are exposed. See [Waggle Dance Mapped Tables](https://github.com/ExpediaGroup/waggle-dance#mapped-tables) for more information.| string | `""` | no |
| database-name-mapping | Comma-separated list of `<database>:<alias>` key/value pairs to add aliases for the given databases. Default is no aliases. This is used primarily in migration scenarios where a database has been renamed/relocated. See [Waggle Dance Database Name Mapping](https://github.com/ExpediaGroup/waggle-dance#database-name-mapping) for more information.  | string | `""` | no |
| writable-whitelist | Comma-separated list of databases from this metastore that can be in read-write mode. If not specified, all databases are read-only. Use `.*` to allow all databases to be written to. | string | `""` | no |

See [Waggle Dance README](https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md) for more information on all these parameters.

### remote_region_metastores

A list of maps.  Each map entry describes a federated metastore endpoint accessible via an AWS VPC endpoint. The actual data for these metastores will be accessed using Alluxio caching instead of reading the data from S3 directly.

An example entry looks like:
```
remote_region_metastores = [
    {
      endpoint              = "com.amazonaws.vpce.us-west-2.vpce-svc-1"
      port                  = "9083"
      prefix                = "remote1"
      mapped-databases      = "default,test"
      mapped-tables         = "test:test_table1,test_table1;default:default_table1.*,default_table2"
      database-name-mapping = "test:test_alias,default:default_alias"
      writable-whitelist    = ".*"
      vpc_id                = "vpc-123456"
      subnets               = "subnet-1,subnet-2"
      security_group_id     = "sg1
    }
]
```
`remote_region_metastores` map entry fields:

Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| endpoint | AWS VPC endpoint service name that is connected to the remote Hive metastore. | string | - | yes |
| latency | Latency used for this metastore. See `latency` parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. | number | `var.default_latency` | no |
| port | IP port that the Thrift server of the remote Hive metastore listens on. | string | `"9083"` | no |
| prefix | Prefix added to the database names from this metastore. Must be unique among all local, remote, and SSH federated metastores in this Waggle Dance instance. | string | - | yes |
| mapped-databases | Comma-separated list of databases from this metastore to expose to federation. If not specified, *all* databases are exposed.| string | `""` | no |
| mapped-tables | Semicolon-separated/comma-separated list of databases and DB tables from this metastore to expose to federation. If not specified, *all* tables for each database are exposed. See [Waggle Dance Mapped Tables](https://github.com/ExpediaGroup/waggle-dance#mapped-tables) for more information.| string | `""` | no |
| database-name-mapping | Comma-separated list of `<database>:<alias>` key/value pairs to add aliases for the given databases. Default is no aliases. This is used primarily in migration scenarios where a database has been renamed/relocated. See [Waggle Dance Database Name Mapping](https://github.com/ExpediaGroup/waggle-dance#database-name-mapping) for more information.  | string | `""` | no |
| writable-whitelist | Comma-separated list of databases from this metastore that can be in read-write mode. If not specified, all databases are read-only. Use `.*` to allow all databases to be written to. | string | `""` | no |
| vpc_id | Remote region AWS VPC id. | string | - | yes |
| subnets | AWS VPC subnets in remote region. | string | - | yes |
| security_group_id | AWS EC2 security group in remote region. | string | - | yes |

See [Waggle Dance README](https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md) for more information on all these parameters.

### ssh_metastores

A list of maps.  Each map entry describes a federated metastore endpoint connected via an SSH bastion host.

An example entry looks like:
```
ssh_metastores = [
    {
      metastore-host        = "com.amazonaws.vpce.us-west-2.vpce-svc-1"
      port                  = "9083"
      bastion-host          = "bastion.remote-account.com"
      user                  = "bastion-user"
      timeout               = "30000"
      prefix                = "ssh_metastore1"
      mapped-databases      = "default,test"
      database-name-mapping = "test:test_alias,default:default_alias"
      mapped-tables         = "test:test_table1,test_table1;default:default_table1.*,default_table2"
    }
]
```
`ssh_metastores` map entry fields:

Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| latency | Latency used for this metastore. See `latency` parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. | number | `var.default_latency` | no |
| metastore-host | Host name of the Hive metastore that can be resolved/reached from the bastion host. | string | - | yes |
| port | IP port that the Thrift server of the remote Hive metastore listens on. | string | `"9083"` | no |
| bastion-host | Host name of the bastion host. | string | - | yes |
| user | User name what will login to the bastion host. | string | - | yes |
| timeout | The SSH session timeout in milliseconds, 0 means no timeout. Default is 60000 milliseconds, i.e. 1 minute. | string | `"60000"` | no |
| prefix | Prefix added to the database names from this metastore. Must be unique among all local, remote, and SSH federated metastores in this Waggle Dance instance. | string | - | yes |
| mapped-databases | Comma-separated list of databases from this metastore to expose to federation. If not specified, *all* databases are exposed.| string | `""` | no |
| mapped-tables | Semicolon-separated/comma-separated list of databases and DB tables from this metastore to expose to federation. If not specified, *all* tables for each database are exposed. See [Waggle Dance Mapped Tables](https://github.com/ExpediaGroup/waggle-dance#mapped-tables) for more information.| string | `""` | no |
| database-name-mapping | Comma-separated list of `<database>:<alias>` key/value pairs to add aliases for the given databases. Default is no aliases. This is used primarily in migration scenarios where a database has been renamed/relocated. See [Waggle Dance Database Name Mapping](https://github.com/ExpediaGroup/waggle-dance#database-name-mapping) for more information.  | string | `""` | no |
| writable-whitelist | Comma-separated list of databases from this metastore that can be in read-write mode. If not specified, all databases are read-only. Use `.*` to allow all databases to be written to. | string | `""` | no |

See [Waggle Dance README](https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md) for more information on all these parameters.

### glue_metastores

A list of maps.  Each map entry describes a federated metastore endpoint connected to AWS Glue datacatalog.

An example entry looks like:
```
glue_metastores = [
    {
      glue-account-id       = "123456789012"
      glue-endpoint         = "glue.us-east-1.amazonaws.com"
      prefix                = "glue_metastore1"
      mapped-databases      = "default,test"
    }
]
```
`glue_metastores` map entry fields:

Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| latency | Latency used for this metastore. See `latency` parameter in https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md. | number | `var.default_latency` | no |
| glue-account-id | Glue AWS account id. | string | - | yes |
| glue-endpoint | Glue endpoint 'glue.us-east-1.amazonaws.com'. | string | - | yes |
| prefix | Prefix added to the database names from this metastore. Must be unique among all local, remote, and SSH federated metastores in this Waggle Dance instance. | string | - | yes |
| mapped-databases | Comma-separated list of databases from this metastore to expose to federation. If not specified, *all* databases are exposed.| string | `""` | no |
| mapped-tables | Semicolon-separated/comma-separated list of databases and DB tables from this metastore to expose to federation. If not specified, *all* tables for each database are exposed. See [Waggle Dance Mapped Tables](https://github.com/ExpediaGroup/waggle-dance#mapped-tables) for more information.| string | `""` | no |
| database-name-mapping | Comma-separated list of `<database>:<alias>` key/value pairs to add aliases for the given databases. Default is no aliases. This is used primarily in migration scenarios where a database has been renamed/relocated. See [Waggle Dance Database Name Mapping](https://github.com/ExpediaGroup/waggle-dance#database-name-mapping) for more information.  | string | `""` | no |
| writable-whitelist | Comma-separated list of databases from this metastore that can be in read-write mode. If not specified, all databases are read-only. Use `.*` to allow all databases to be written to. | string | `""` | no |

See [Waggle Dance README](https://github.com/ExpediaGroup/waggle-dance/blob/main/README.md) for more information on all these parameters.

# Contact

## Mailing List
If you would like to ask any questions about or discuss Apiary please join our mailing list at

  [https://groups.google.com/forum/#!forum/apiary-user](https://groups.google.com/forum/#!forum/apiary-user)

# Legal
This project is available under the [Apache 2.0 License](http://www.apache.org/licenses/LICENSE-2.0.html).

Copyright 2018-2019 Expedia, Inc.
