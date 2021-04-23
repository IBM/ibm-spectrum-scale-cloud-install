terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.23.0"
    }
  }
  required_version = "~> 0.14"
}

provider "ibm" {
  region = var.region
}
