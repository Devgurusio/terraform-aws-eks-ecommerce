data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.cluster_id
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.29.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  create_aws_auth_configmap = var.create_aws_auth_configmap

  aws_auth_roles = var.map_roles
  aws_auth_users = var.map_users

  # # Enabling encryption on AWS EKS secrets using a customer-created key
  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks_kms_key.arn
    resources        = ["secrets"]
  }]


  # Enabling this, we allow EKS to manage this components for us (upgrading and maintaining)
  cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # IRSA enabled to create an OpenID trust between our cluster and IAM, in order to map AWS Roles to Kubernetes SA's
  enable_irsa = true

  self_managed_node_group_defaults = {
    update_launch_template_default_version = true
    iam_role_additional_policies           = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  }


  self_managed_node_groups = var.self_managed_node_groups

  node_security_group_additional_rules = {
    ms_4443_ing = {
      description                   = "Cluster API to metrics server 4443 ingress port"
      protocol                      = "tcp"
      from_port                     = 4443
      to_port                       = 4443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ms_443_ing = {
      description                   = "Cluster API to metrics server 15017 ingress port"
      protocol                      = "tcp"
      from_port                     = 15017
      to_port                       = 15017
      type                          = "ingress"
      source_cluster_security_group = true
    }
    node_to_node_ig = {
      description = "Node to node ingress traffic"
      from_port   = 1
      to_port     = 65535
      protocol    = "all"
      type        = "ingress"
      self        = true
    }
    node_to_node_eg = {
      description = "Node to node egress traffic"
      from_port   = 1
      to_port     = 65535
      protocol    = "all"
      type        = "egress"
      self        = true
    }
  }

}
