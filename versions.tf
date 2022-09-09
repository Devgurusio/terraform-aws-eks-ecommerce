terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.3"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
  }
}
