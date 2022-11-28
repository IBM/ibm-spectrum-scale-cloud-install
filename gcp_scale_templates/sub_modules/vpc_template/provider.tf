terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0.0"
    }
  }
  required_version = "~> 1.0"
}
provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.gcp_project_id
  region      = var.vpc_region
}
