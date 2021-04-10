terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.23.0"
    }
  }
}

provider "ibm" {
  region = var.region
}
