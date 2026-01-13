terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.87.1"
    }
  }
}

provider "ibm" {
  region = var.vpc_region
}
