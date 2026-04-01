terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.0.0"
    }
  }
}

provider "ibm" {
  region           = var.vpc_region
  ibmcloud_api_key = var.ibmcloud_api_key
}
