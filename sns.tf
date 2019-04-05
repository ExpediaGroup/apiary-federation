resource "aws_sns_topic" "apiary_ops_sns" {
  name = "${local.instance_alias}-operational-events"
}
