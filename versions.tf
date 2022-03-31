terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.9.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5.0"
    }
  }
}
