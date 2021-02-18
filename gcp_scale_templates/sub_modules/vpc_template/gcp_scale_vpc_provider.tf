terraform {
  required_version = ">= 0.12"
}

provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.gcp_project_id
  region      = var.region
}
