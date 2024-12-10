# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [4.5.6] - 2024-12-10
### Added
- Added waggledance VPC endpoint service
- Added following new variables to support waggledance VPC endpint service:
  - `enable_vpc_endpoint_services`
  - `waggledance_customer_accounts`

## [4.5.5] - 2024-10-04
### Added
- Added variables to control Waggledance deployment dns policy and config.

## [4.5.4] - 2024-10-03
### Added
- Added variables to control Waggledance k8s Service and NLB configuration

## [4.5.3] - 2024-07-01
### Added
- Added support for setting the TCP keepalive settings of Waggledance.

## [4.5.2] - 2024-06-04
### Updated
- Changed Service account creation to make it work with eks 1.24 and later.

## [4.5.1] - 2024-05-08
### Added
- Adding tags to the Datadog agent

## [4.5.0] - 2024-04-25
### Added
- Added optional `extended_server_config`. For instance to configure Waggle Dance Rate limiting configuration.

## [4.4.0] - 2024-04-18
### Added
- Add new variable `cpu_limit` and `memory_limit` to support set pod resource guaranteed.
    
## [4.3.2] - 2024-03-26
### Updated
- Removed the datadog explicit provider configuration as suggested here: https://developer.hashicorp.com/terraform/language/modules/develop/providers#legacy-shared-modules-with-provider-configurations

## [4.3.1] - 2024-02-22
### Updated
- Updated eks to use instance name instead of hard coding.

## [4.3.0] - 2024-02-08
### Added
- Variable to add a readonly primary optional host/port. Waggle Dance will redirect get calls automatically to those.

## [4.2.2] - 2024-01-05
### Fixed
- Conditional reading of Secrets from SecretManager fix.

## [4.2.1] - 2024-01-05
### Added
- Added ECR permission to ECS tasks IAM role to support using ECR images.
### Fixed
- Changed `HIVE_SITE_XML` condition expression from `var.alluxio_endpoints == []` to `length(var.alluxio_endpoints) == 0`, the previously expression does not work when `var.alluxio_endpoints` is empty.
- 
## [4.2.0] - 2024-01-05
### Added
- Added datadog to ECS clusters.

## [4.1.5] - 2023-11-30
### Fixed
- Issue where requests can hit 10min connection timeout, TCP keepalive prevents NLB closing idle connections. Similar to the issue explained here: https://paramount.tech/blog/2021/07/26/mitigation-of-connection-reset-in-aws.html

## [4.1.4] - 2023-11-08
### Fixed
- Added tags to ECS service and tasks.

## [4.1.3] - 2023-11-08
### Fixed
- ECS healtcheck endpoints, switched back to `/actuator/health`

## [4.1.2] - 2023-09-06
### Added
- Metrics have been incorporated into Waggle Dance with the inclusion of tags, which will facilitate filtering within Datadog.

## [4.1.1] - 2023-06-20
### Added
- Added JVM, System and Timer metrics in WaggleDance Datadog annotations.

## [4.1.0] - 2023-05-23
### Added
- Added the annotations to push waggle dance metrics to Datadog UI.

## [4.0.7] - 2023-05-12
### Changed
- Changed `/actuator/health` to `/actuator/health/liveness` due to WD spring boot upgrade. 

## [4.0.6] - 2023-05-05
### Changed
- Changed kubernetes deployment to support eks version 1.22+.
- Fix kubernetes service attribute refereing with v2.x.

## [4.0.5] - 2022-12-09
### Added
- Variable `primary_metastore_access_type` for enabling customized primary hive metastore access control type. See README for more info on this variable.

## [4.0.4] - 2022-09-14
### Changed
- Enable cross zone load balancing so that usage is spread evenly.

## [4.0.3] - 2022-09-01
### Changed
- Preserve ip in ECS LB to enforce security group rules.

## [4.0.2] - 2022-08-15
### Changed
- Add secondary vpc support for waggledance route53 zone with autoscaling.

## [4.0.1] - 2022-07-20
### Changed
- Add waggle-dance load balancer output when using ECS and autoscaling.

## [4.0.0] - 2022-05-23
### Added
- Variable `enable_query_functions_across_all_metastores` for disabling potential slow and cross metastore function lookup. Disabled by default which break backward compatibility. See README for more info on this variable.

## [3.6.1] - 2022-04-06
- Added support for enabling invocation logs separately from other `log4j` loggers.

## [3.6.0] - 2022-03-22
- Added support for AWS Glue metastore federation.

## [3.5.1] - 2022-03-17
- Update waggle-dance security group ingress to fix healthcheck.

## [3.5.0] - 2022-03-17
- Variable to enable autoscaling in ECS deployments.

## [3.4.2] - 2022-03-16
- Configure ECS task file limits.

## [3.4.1] - 2022-01-11
- Add k8s internal service with client affinity, for usecases than cannot use headless service and seamlessly failover to new waggle-dance instances.

## [3.4.0] - 2022-01-11
- Variable to enable waggle-dance autoscaling on k8s.

## [3.3.15] - 2022-01-06
- Add k8s headless service, so that clients running in k8s cluster can connect to a WD container instead of virtual ip.

## [3.3.14] - 2021-12-16
- Set env var `LOG4J_FORMAT_MSG_NO_LOOKUPS=”true”` for WD containers for log4j-shell bug.

## [3.3.13] - 2021-11-18
### Added
- Added suppport for Waggledance `mapped-tables` [configuration](https://github.com/ExpediaGroup/waggle-dance#mapped-tables).  

## [3.3.12] - 2021-11-16
### Fixed
- Replace aws.remote provider proxy with configuration_aliases as provider proxy is not compatible with module count.

## [3.3.11] - 2021-11-03
### Added
- Added `primary_metastore_latency` variable.

## [3.3.10] - 2021-11-01
### Changed
- Variable to configure pimary metastore mapped databases.

## [3.3.9] - 2021-10-27
### Fixed
- Fix to create ECS aws_iam_role_policy only when deploying on ECS.

## [3.3.8] - 2021-10-18
### Fixed
- Fix kubernetes serviceaccount reference.

## [3.3.7] - 2021-10-18
### Fixed
- Disable kubernetes serviceaccount creation when running on ecs.

## [3.3.6] - 2021-10-18
### Added
- Support Waggledance `latency` parameter

## [3.3.5] - 2021-09-21
### Changed
- Fixes to deploy on k8s clusters requiring serviceaccount for all deployments.

## [3.3.4] - 2021-08-13
### Changed
- Enable health check in k8s deployment.

## [3.3.3] - 2021-04-06
### Added
- Variable to configure k8s pod replicas.

## [3.3.2] - 2021-03-30
### Added
- Fix alluxio path replacement regex to handle s3a:// and s3n:// urls.

## [3.3.1] - 2021-03-30
### Added
- Variable to configure waggle-dance log level.

## [3.3.0] - 2021-03-18
### Added
- Add support for remote region metastores and alluxio cache. Access to tables in remote region s3 can be transparently redirected to alluxio using waggle-dance and hive hook.

## [3.2.3] - 2021-03-15
### Changed
- Option to disable metastore to mitigate issues.

## [3.2.2] - 2021-01-27
### Changed
- Update k8s memory limit to 120% memory request to prevent k8s from killing waggle-dance containers.

## [3.2.1] - 2021-01-27
### Changed
- Update terraform required version to include 0.13.x.

## [3.2.0] - 2021-01-19
### Added
- Added ability to pass `database-name-mapping` key/value pairs for each federated metastore.  See [Waggle Dance Database Name Mapping](https://github.com/HotelsDotCom/waggle-dance#database-name-mapping) for more information. Requires docker image version `1.6.0` or greater.

## [3.1.1] - 2020-08-04

### Changed
- Fix k8s multi instance deployment resource names.

## [3.1.0] - 2020-03-05

### Changed
- Fix waggle_dance_load_balancers output for ecs deployments.

### Added
- Prometheus support. Requires docker image version 1.5.0 or greater.

## [3.0.2] - 2019-11-21

### Changed
- Reduce k8s waggle-dance process heapsize from 90 to 85 percent of container memory limit.

## [3.0.1] - 2019-11-13

### Changed
- Configure k8s service load_balancer_source_ranges.

## [3.0.0] - 2019-11-12

### Added
- Support for running Waggle Dance on Kubernetes.
- Upgrade to Terraform version 0.12

### Changed
- Tag remote metastore VPC endpoints.

### Removed
- Support for running Waggle Dance on EC2 nodes.

## [2.0.1] - 2019-07-17

### Added
- Fixed problem adding new remote_metastores. - see [#36](https://github.com/ExpediaGroup/apiary-federation/issues/36)

## [2.0.0] - 2019-07-09

### Added
- Support for running Waggle Dance on EC2 nodes.

## [1.1.3] - 2019-06-27

### Changed
- Run `terraform fmt`.


## [1.1.2] - 2019-06-06

### Changed
- Fixes remote metastore CNAMEs when AWS_DEFAULT_REGION environment variable is not set - see[#59](https://github.com/ExpediaGroup/apiary-federation/issues/59)

## [1.1.1] - 2019-04-09

### Added
- Add CloudWatch and SNS - see [#57](https://github.com/ExpediaGroup/apiary-federation/pull/57).


## [1.1.0] - 2019-04-05

### Added
- Improved error handling in scripts/endpoint_dns_name.sh - see [#17](https://github.com/ExpediaGroup/apiary-federation/issues/17).
- Support for Docker private registry - see [#53](https://github.com/ExpediaGroup/apiary-federation/issues/53).

### Changed
- Refactor code to multiple `tf` files.


## [1.0.5] - 2019-03-12

### Added
- Pin module to use `terraform-aws-provider v1.60.0`


## [1.0.4] - 2019-02-22

### Added
- tag resources that were not yet applying tags - see [#49](https://github.com/ExpediaGroup/apiary-federation/issues/49).

## [1.0.3] - 2019-01-30

### Changed
- Set `server_yaml` to default content when `graphite_host` is not defined.


## [1.0.2] - 2019-01-07

### Changed
- Default access control for `local_metastores`.
- Description of `local_metastores` variable


## [1.0.1] - 2018-12-14

### Added
- Add health check for WaggleDance service.

### Changed
- Fix typo `ssh_metastores`.


## [1.0.0] - 2018-10-31

### Added
- Option to register route53 cnames for vpc endpoints - see [#20](https://github.com/ExpediaGroup/apiary-federation/issues/20).
- Option to associate multiple VPCs to Service Discovery namespace - see [#29](https://github.com/ExpediaGroup/apiary-federation/issues/29)
- Enable write support for federated metastores - see [#26](https://github.com/ExpediaGroup/apiary-federation/issues/26).
- Enable cross-region federated Metastore using Bastion and SSH tunnel - see
[#31](https://github.com/ExpediaGroup/apiary-federation/issues/31).

### Changed
- Renamed following variables:
  * `region` to `aws_region`
  * `instance_count` to `wd_ecs_task_count`

### Removed
- Remove `alerting_email` variable - see [#28](https://github.com/ExpediaGroup/apiary-federation/pull/28).
