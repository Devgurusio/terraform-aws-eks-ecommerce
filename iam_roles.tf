/*
 * Here, we define the Policy Document that will be used by all EKS-Based IAM Roles
 *  This document has to be attached to all aws_iam_role objects that will be annotated to a Kubernetes SA 
 */
data "aws_iam_policy_document" "eks_oidc_assume_policy_document" {
  statement {

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test = "StringEquals"
      # We need to trim the schema part from the URI because the policy condition expect it to be absent
      variable = replace("${module.eks_cluster.cluster_oidc_issuer_url}:aud", "https://", "")
      values = [
        "sts.amazonaws.com"
      ]
    }

    principals {
      type        = "Federated"
      identifiers = [module.eks_cluster.oidc_provider_arn]
    }
  }
}


resource "aws_iam_role" "eks_cluster_autoscaler_role" {
  name  = "ClusterAutoscalerRole-${var.environment}"
  count = var.enable_cluster_autoscaler == true ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.eks_oidc_assume_policy_document.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_role_attachment" {
  count      = var.enable_cluster_autoscaler == true ? 1 : 0
  role       = aws_iam_role.eks_cluster_autoscaler_role[0].name
  policy_arn = aws_iam_policy.autoscaler_modify_asg[0].arn
}
