resource "aws_iam_role" "waggle_dance_k8s_role_iam" {
  count = var.wd_instance_type == "k8s" ? 1 : 0

  name = "waggle-dance-k8s-role-iam-${data.aws_region.current.name}"
  tags = module.tags.tags

  description = "Role to allow AWS Glue access from WaggleDance"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.kiam_role}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy" "waggle_dance_glue_policy" {
  count = var.waggle_dance_glue_policy != "" ? 1 : 0
  role = aws_iam_role.waggle-dance-k8s-role-iam.name
  name = "glue-readonly"

  policy = var.waggle_dance_glue_policy
}
