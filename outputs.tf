/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */
#output "instance_ids" {
#  value = "${aws_instance.waggle_dance_instance.*.id}"
#}
#output "public_dns" {
#  value = "${aws_instance.waggle_dance_instance.*.public_dns}"
#}
#output "public_ips" {
#  value = "${aws_instance.waggle_dance_instance.*.public_ip}"
#}
#output "private_dns" {
#  value = "${aws_instance.waggle_dance_instance.*.private_dns}"
#}
#output "private_ips" {
#  value = "${aws_instance.waggle_dance_instance.*.private_ip}"
#}

