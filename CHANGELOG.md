# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [2.0.0] - TBD

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
