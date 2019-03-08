#!/bin/sh
dns_name=`aws ec2 describe-vpc-endpoints --vpc-endpoint-ids $1|jq -r ".VpcEndpoints[].DnsEntries[0].DnsName"`
if [ "$dns_name" = "null" ]; then
  echo dns_name is null, you may need to update your aws cli 1>&2
  exit 1
fi
jq -n --arg dnsname "$dns_name" '{"dnsname":$dnsname}'
