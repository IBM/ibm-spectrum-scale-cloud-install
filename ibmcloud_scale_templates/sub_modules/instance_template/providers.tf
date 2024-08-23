terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.68.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.41.0"
    }
  }
}

provider "ibm" {
  region = var.vpc_region
}
