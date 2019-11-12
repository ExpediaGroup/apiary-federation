resource "aws_sns_topic" "apiary_federation_ops_sns" {
  count = var.wd_instance_type == "ecs" ? 1 : 0
  name  = "${local.instance_alias}-operational-events"
}
