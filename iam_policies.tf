resource "aws_iam_policy" "autoscaler_modify_asg" {
  name        = "ClusterAutoscalerPolicy-${var.environment}"
  count       = var.enable_cluster_autoscaler == true ? 1 : 0
  description = "Policy created to allow the Cluster autoscaler service to access the underlying AWS ASG"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "autoscaling:UpdateAutoScalingGroup",
        ]
        Effect   = "Allow"
        Resource = "*"

        Condition = {
          "StringEquals" = {
            "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${local.cluster_name}" = ["owned"],
            "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"               = ["true"]
          }
        }
      }

    ]
  })
}
