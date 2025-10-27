resource "aws_iam_role" "waggle_dance_k8s_role_iam" {
  count = var.wd_instance_type == "k8s" && var.oidc_provider != "" ? 1 : 0

  name = "${local.instance_alias}-k8s-${var.aws_region}"
  tags = var.tags

  description = "Role to allow AWS Glue access from WaggleDance"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
       "StringEquals": {
         "${var.oidc_provider}:sub": "system:serviceaccount:${var.k8s_namespace}:${local.instance_alias}",
         "${var.oidc_provider}:aud": "sts.amazonaws.com"
       }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "waggle_dance_remote_glue_federations_policy" {
  count = var.wd_instance_type == "k8s" && var.oidc_provider != "" && local.glue_enabled ? 1 : 0
  role  = aws_iam_role.waggle_dance_k8s_role_iam[0].name
  name  = "waggle-dance-remote-metastores-glue-readonly"

  policy = data.aws_iam_policy_document.waggle_dance_remote_glue_federations_policy[0].json
}

resource "aws_iam_role_policy" "waggle_dance_remote_glue_federations_policy_write" {
  count = var.wd_instance_type == "k8s" && var.oidc_provider != "" && local.glue_enabled ? 1 : 0
  role  = aws_iam_role.waggle_dance_k8s_role_iam[0].name
  name  = "waggle-dance-remote-metastores-glue-write"

  policy = data.aws_iam_policy_document.waggle_dance_remote_glue_federations_policy_write[0].json
}

#Glue client creates folders on s3 for create tables. This policy gives that access.
resource "aws_iam_role_policy" "waggle_dance_remote_glue_federations_policy_s3_write" {
  count = var.wd_instance_type == "k8s" && var.oidc_provider != "" && local.glue_enabled ? 1 : 0
  role  = aws_iam_role.waggle_dance_k8s_role_iam[0].name
  name  = "waggle-dance-remote-metastores-glue-s3-write"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.s3_glue_tables_bucket}/",
        "arn:aws:s3:::${var.s3_glue_tables_bucket}/*"
      ]
    }
  ]
}
EOF
}



