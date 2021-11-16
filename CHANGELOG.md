# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [3.4.0] - 2021-11-16
### Removed
- Remove provider proxy as it not compatible with module count.

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
