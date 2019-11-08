output "waggle_dance_dns" {
  value = aws_route53_record.metastore_proxy.*.fqdn
}
