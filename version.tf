/**
 * Copyright (C) 2018-2019 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

terraform {
  experiments = [module_variable_optional_attrs]
  required_version = "> 0.15.0, < 1.0.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 2.13.0"
      configuration_aliases = [aws.remote]
    }
    datadog = {
      source = "DataDog/datadog"
      version = "3.25.0"
    }
  }
}
