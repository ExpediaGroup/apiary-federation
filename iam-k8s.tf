resource "aws_iam_role" "waggle_dance_k8s_role_iam" {
  count = var.waggle_dance_glue_assume_role_policy != "" ? 1 : 0

  name = "waggle-dance-k8s-role-iam-${data.aws_region.current.name}"
  tags = module.tags.tags

  description = "Role to allow AWS Glue access from WaggleDance"

  assume_role_policy = var.waggle_dance_glue_assume_role_policy

}

resource "aws_iam_role_policy" "waggle_dance_glue_k8s_policy" {
  count = var.waggle_dance_glue_policy != "" ? 1 : 0
  role = aws_iam_role.waggle-dance-k8s-role-iam.name
  name = "glue-readonly"

  policy = var.waggle_dance_glue_policy
}
