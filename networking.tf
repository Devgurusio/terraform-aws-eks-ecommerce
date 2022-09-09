module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14.0"

  name            = "${var.environment}-eks-vpc"
  cidr            = var.vpc_cidr
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets
  # One NAT Gateway per Subnet to increase reliability
  enable_nat_gateway   = true
  enable_dns_hostnames = false # We don't need DNS entries for the VPC hostnames


  # We need to add this tags to allow the AWS Load Balancer Controller to detect which subnets are public
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  # We need to add this tags to allow the AWS Load Balancer Controller to detect which subnets are private
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
