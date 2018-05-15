/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "template_file" "wd_ansible_hosts" {
  template = "${file("${path.cwd}/templates/wd-ansible-host.tmpl")}"
  count    = "${var.instance_count}"

  vars {
    waggle_dance_ip = "${element(aws_instance.waggle_dance_instance.*.private_ip,count.index)}"
  }
}

resource "null_resource" "wd_ansible_hosts" {
  triggers {
    waggle_dance_ids = "${join(",", aws_instance.waggle_dance_instance.*.id)}"
  }

  count = "${var.instance_count}"

  provisioner "local-exec" {
    command = "echo '${data.template_file.wd_ansible_hosts.*.rendered[count.index]}' >  ${path.cwd}/${var.tags["Environment"]}-wd-hosts.${count.index}"
  }
}

resource "null_resource" "wd_final_ansible_hosts" {
  triggers {
    waggle_dance_ids = "${join(",", aws_instance.waggle_dance_instance.*.id)}"
  }

  depends_on = ["null_resource.wd_ansible_hosts"]

  provisioner "local-exec" {
    command = <<EOF
echo [wd] > ${path.cwd}/${var.tags["Environment"]}-wd-hosts-final && \
cat ${path.cwd}/${var.tags["Environment"]}-wd-hosts.* >> ${path.cwd}/${var.tags["Environment"]}-wd-hosts-final && \
grep -Ev '^$' ${path.cwd}/${var.tags["Environment"]}-wd-hosts-final > ${path.cwd}/../ansible/${var.tags["Environment"]}-wd-hosts && \
rm ${path.cwd}/${var.tags["Environment"]}-wd-hosts.* && \
rm ${path.cwd}/${var.tags["Environment"]}-wd-hosts-final
EOF
  }
}
