terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.61.0"
    }
  }
  required_version = "~> 1.0"
}
provider "google" {
  credentials = file(var.credential_json_path)
  project     = var.project_id
  region      = var.vpc_region
}
