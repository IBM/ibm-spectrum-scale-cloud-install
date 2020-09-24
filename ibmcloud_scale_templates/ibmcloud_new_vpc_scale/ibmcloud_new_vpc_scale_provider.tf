terraform {
  required_version = ">= 0.12"
}

provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
  generation       = var.compute_generation
}
