#!/bin/sh -x
dns_name=`aws ec2 describe-vpc-endpoints --vpc-endpoint-ids $1|jq -r ".VpcEndpoints[].DnsEntries[0].DnsName"`
if [ "$dns_name" = "null" ]; then
  echo "dns_name for VPC endpoint is null, one issue which may cause this is an older version of the AWS CLI on the machine you run Terraform from." 1>&2
  exit 1
fi
jq -n --arg dnsname "$dns_name" '{"dnsname":$dnsname}'
