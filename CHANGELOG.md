# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Option to register route53 cnames for vpc endpoints - see [#20](https://github.com/ExpediaInc/apiary-waggledance/issues/20).
- Option to associate multiple VPCs to Service Discovery namespace - see [#29](https://github.com/ExpediaInc/apiary-waggledance/issues/29)
- Enable write support for federated metastores - see [#26](https://github.com/ExpediaInc/apiary-waggledance/issues/26).
- Enable cross-region federated Metastore using Bastion and SSH tunnel - see
[#31](https://github.com/ExpediaInc/apiary-waggledance/issues/31).

### Changed
- Renamed following variables:
  * `region` to `aws_region`
  * `instance_count` to `wd_ecs_task_count`

### Removed
- Remove `alerting_email` variable - see [#28](https://github.com/ExpediaInc/apiary-waggledance/pull/28).
