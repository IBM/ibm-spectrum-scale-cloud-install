terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.84.3"
    }
  }
}

provider "ibm" {
  region = var.vpc_region
}
