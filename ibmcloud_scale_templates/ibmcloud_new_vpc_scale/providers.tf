terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.0.2"
    }
  }
}

provider "ibm" {
  region = var.vpc_region
}
