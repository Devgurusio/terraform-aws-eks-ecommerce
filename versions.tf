terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.7.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }


    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4.1"
    }
  }
}
