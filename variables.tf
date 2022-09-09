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

variable "manage_aws_auth_configmap" {
  type        = bool
  description = "Choose whether the EKS module should manage your aws-auth configmap or not"
  default     = true
}

variable "create_aws_auth_configmap" {
  type        = bool
  description = "This option toogles aws-auth creation. It should only be enabled when using self-managed nodes"
  default     = false
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}
