resource "aws_iam_role" "waggle_dance_k8s_role_iam" {
  count = var.waggle_dance_glue_assume_role_policy != "" ? 1 : 0

  name = "${local.instance_alias}-k8s-${var.aws_region}"
  tags = var.tags

  description = "Role to allow AWS Glue access from WaggleDance"

  assume_role_policy = var.waggle_dance_glue_assume_role_policy

}

resource "aws_iam_role_policy" "waggle_dance_glue_k8s_policy" {
  count = var.waggle_dance_glue_policy != "" ? 1 : 0
  role = aws_iam_role.waggle_dance_k8s_role_iam[0].name
  name = "waggle-dance-glue-readonly"

  policy = var.waggle_dance_glue_policy
}
