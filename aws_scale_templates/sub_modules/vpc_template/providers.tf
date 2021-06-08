terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = "~> 0.15"
}

provider "aws" {
  region = var.vpc_region
}
