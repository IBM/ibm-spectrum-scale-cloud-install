terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.78.2"
    }
  }
}

provider "ibm" {
  region = var.vpc_region
}
