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
  ibmcloud_api_key = var.ibmcloud_api_key
}
