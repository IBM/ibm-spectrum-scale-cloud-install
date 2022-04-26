terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
  required_version = "1.40.1"
}

provider "ibm" {
  region = var.vpc_region
}
