resource "aws_sns_topic" "apiary_federation_ops_sns" {
  name = "${local.instance_alias}-operational-events"
}
