module "eks-cluster" {
  source             = "../."
  environment        = "eks-spot-demo"
  kubernetes_version = "1.23"

  enable_cluster_autoscaler = true

  # Networking configuration 
  vpc_cidr            = "10.0.0.0/16"
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]


  create_aws_auth_configmap = true

  map_users = [
    {
      userarn  = "arn:aws:iam::xxxxxxxx:user/youremail@yourdomain.com"
      username = "youremail@yourdomain"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::xxxxxxxx:user/youremail2@yourdomain.com"
      username = "youremail2@yourdomain.com"
      groups   = ["system:masters"]
    }
  ]

  map_roles = [
    {
      rolearn  = "arn:aws:iam::xxxxxxxx:role/YourRoleARN"
      username = "yourroleusername"
      groups   = ["system:masters"]
    }
  ]

  # Here, we define all node pools that we want to create

  self_managed_node_groups = {
    spot_pool = {
      name = "spool-node-pool"

      instance_type = "t3.medium"

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

      autoscaling_group_tags = {
        "k8s.io/cluster-autoscaler/eks-spot-demo-eks-cluster" = "owned"
        "k8s.io/cluster-autoscaler/enabled"                   = "true"
      }
    }
  }
}
