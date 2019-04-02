/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_cloudwatch_log_group" "waggledance_ecs" {
  name = "${local.instance_alias}"
  tags = "${var.tags}"
}
