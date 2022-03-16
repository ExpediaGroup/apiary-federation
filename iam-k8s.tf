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
           "${var.oidc_provider}:sub": "system:serviceaccount:${var.k8s_namespace}:${local.instance_alias}"
         }
        }
      }
    ]
  }
EOF
}

data "aws_iam_policy_document" "waggle_dance_glue_policy" {
  count = var.wd_instance_type == "k8s" && length(var.glue_metastores) > 0 ? 1 : 0
  sid = "Waggledance Glue Policy"
  statement {
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetTableVersions",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:GetUserDefinedFunction",
      "glue:GetUserDefinedFunctions"
    ]
    resources = [
      "${join("\",\"", formatlist("arn:aws:glue:%s:%s:*", var.aws_region, [for glue_metastore in var.glue_metastores: glue_metastore["glue-account-id"]]))}"
    ]
  }
}
resource "aws_iam_role_policy" "waggle_dance_glue_k8s_policy" {
  count = var.wd_instance_type == "k8s" && length(var.glue_metastores) > 0 ? 1 : 0
  role  = aws_iam_role.waggle_dance_k8s_role_iam[0].name
  name  = "waggle-dance-glue-readonly"

  policy = <<EOF
{
   "Version" : "2012-10-17",
   "Statement" :
   [
     {
       "Sid" : "Waggledance Glue Policy",
       "Effect" : "Allow",
       "Action" : [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetTableVersions",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchGetPartition",
          "glue:GetUserDefinedFunction",
          "glue:GetUserDefinedFunctions"
        ],
       "Resource" : [
          "${join("\",\"", formatlist("arn:aws:glue:%s:%s:*", var.aws_region, [for glue_metastore in var.glue_metastores: glue_metastore["glue-account-id"]]))}"
        ]
     }
   ]
}
EOF
}
