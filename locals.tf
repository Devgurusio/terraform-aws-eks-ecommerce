locals {
  cluster_name = "${var.environment}-eks-cluster"

  base_auth_configmap = yamldecode(module.eks_cluster.aws_auth_configmap_yaml)

  updated_auth_configmap_data = {
    data = {
      mapRoles = yamlencode(
        distinct(concat(
          yamldecode(local.base_auth_configmap.data.mapRoles), var.map_roles, )
      ))
      mapUsers = yamlencode(var.map_users)
    }
  }


  // We need to autogenerate a valid kubeconfig to be used by the null_resource to update the aws-auth configmap
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks_cluster.cluster_id
      cluster = {
        certificate-authority-data = module.eks_cluster.cluster_certificate_authority_data
        server                     = module.eks_cluster.cluster_endpoint
      }
    }]

    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks_cluster.cluster_id
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })

}
