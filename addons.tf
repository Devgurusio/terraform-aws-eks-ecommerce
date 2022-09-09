#
# The cluster autoscaler will:
#   1) Check the cluster every 10s to find unschedulable pods, and if required, it'll contact AWS to scale up the cluster
#   2) Check if there is any underused node, and if possible, will reschedule all pods to another nodes and remove the node
# 
#   We're using all autoscaler defaults, but they can be overriden using the Helm extraArgs parameter:
#     --scan-interval controls how often the autoscaler checks for unschedulable resources (default 10)
#     --scale-down-utilization-threshold how low the usage has to be to consider node removal (default 50%)
#     --new-pod-scale-up-delay how old the pods have to be in order to be taken into account for the autoschedule algorithm (default 10s)
#   More information here https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md
resource "helm_release" "cluster_autoscaler" {
  depends_on = [
    module.eks_cluster
  ]

  count = var.enable_cluster_autoscaler == true ? 1 : 0

  name             = "cluster-autoscaler"
  namespace        = "cluster-autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  version          = "9.21.0"
  create_namespace = true

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.eks_cluster_autoscaler_role[0].arn
    type  = "string"
  }
  set {
    name  = "autoDiscovery.clusterName"
    value = local.cluster_name
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
}

resource "helm_release" "metrics_server" {
  depends_on = [
    module.eks_cluster
  ]

  # count = var.enable_cluster_autoscaler == true ? 1 : 0

  name             = "metrics-server"
  namespace        = "metrics-server"
  version          = "3.8.2"
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  chart            = "metrics-server"
  create_namespace = true

  set {
    name  = "replicas"
    value = 2
  }

}
