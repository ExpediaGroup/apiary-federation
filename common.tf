/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias               = "${ var.instance_name == "" ? "waggledance" : format("waggledance-%s",var.instance_name) }"
  remote_metastore_zone_prefix = "${ var.instance_name == "" ? "remote-metastore" : format("remote-metastore-%s",var.instance_name) }"
}

data "aws_vpc" "waggledance_vpc" {
  id = "${var.vpc_id}"
}
