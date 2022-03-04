data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.cluster_id
}

module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.8.1"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # # Enabling encryption on AWS EKS secrets using a customer-created key
  # cluster_encryption_config = [{
  #   provider_key_arn = aws_kms_key.eks_crypto_key.arn
  #   resources        = ["secrets"]
  # }]


  # Enabling this, we allow EKS to manage this components for us (upgrading and maintaining)
  cluster_addons = {

    # CoreDNS addon was removed from the module because it causes an execution loop
    #   This module requires the workers to be created, but the dependency is not set-up correctly
    #    For the time being, it would be advised to manage it outside of the module

    # coredns = {
    #   resolve_conflicts = "OVERWRITE"
    # }

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

    // This is a workaround that we need to apply in order to prevent the module from tagging all SG
    //  if more than 1 SG is tagged by the module, then, the Kubernetes Load Balancers won't work
    security_group_tags = {
      "kubernetes.io/cluster/${local.cluster_name}" = null
    }

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



# Extracted from the official AWS EKS module documentation, we need to patch the aws-auth configmap this way.
#   Doing it this way expects kubectl to be installed on the host running this command.
resource "null_resource" "apply" {
  triggers = {
    configmap_yaml = sha512(module.eks_cluster.aws_auth_configmap_yaml)
    cmd_patch      = <<-EOT
      kubectl create configmap aws-auth -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl patch configmap/aws-auth --patch "${module.eks_cluster.aws_auth_configmap_yaml}" -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }

  provisioner "local-exec" {
    interpreter = ["/bin/sh", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }
    command = self.triggers.cmd_patch
  }
}
