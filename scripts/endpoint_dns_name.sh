#!/bin/sh
dns_name=`aws ec2 describe-vpc-endpoints --vpc-endpoint-ids $1|jq -r ".VpcEndpoints[].DnsEntries[0].DnsName"`
jq -n --arg dnsname "$dns_name" '{"dnsname":$dnsname}'
