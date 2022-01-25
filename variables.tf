variable "environment" {
  type        = string
  description = "The environment name"
  default     = "devgurus-dev"
}
variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the Kubernetes control plane"
  default     = "1.21"
}

variable "self_managed_node_groups" {
  type        = any
  description = "Object that represents the Node configuration to apply. Taken from the parent module that bootstraps EKS https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest#input_self_managed_node_groups "
}

variable "vpc_cidr" {
  type        = string
  description = "VPC's CIDR to be created by the VPC module"
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "VPC's private subnets to be created by the VPC module"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "VPC's public subnets to be created by the VPC module"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "enable_cluster_autoscaler" {
  type        = bool
  description = "Whether to create a Helm release installing cluster-autoscaler resources or not"
  default     = false
}
