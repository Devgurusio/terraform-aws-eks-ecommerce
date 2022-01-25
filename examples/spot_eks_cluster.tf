module "eks-cluster" {
  source             = "../."
  environment        = "eks-spot-demo"
  kubernetes_version = "1.21"

  enable_cluster_autoscaler = true

  # Networking configuration 
  vpc_cidr            = "10.0.0.0/16"
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]


  # Here, we define all node pools that we want to create

  self_managed_node_groups = {
    spot_pool = {
      name = "spool-node-pool"

      instance_type = "t2.medium"

      max_size     = 6
      desired_size = 2

      # If we want to run the whole pool with spot instances we create this block
      instance_market_options = {
        market_type = "spot"
      }

      # Dockershim is the default runtime. Here, we switch it with containerd
      bootstrap_extra_args = "--container-runtime containerd"


      # SSM Agent installation. Extracted from the AWS EKS module documentation
      post_bootstrap_user_data = <<-EOT
      cd /tmp
      sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
      sudo systemctl enable amazon-ssm-agent
      sudo systemctl start amazon-ssm-agent
      EOT


      # We add this tags into the AutoScaling Group to enable the cluster-autoscaler discovery
      propagate_tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/eks-spot-demo-eks-cluster"
          "propagate_at_launch" = "false"
          "value"               = "owned"
        }
      ]

    }
  }

}
