source "googlecompute" "itself" {
  credentials_file      = var.credential_json_path
  disk_size             = var.volume_size
  disk_type             = var.volume_type
  source_image          = var.source_image_reference
  image_name            = "${var.resource_prefix}-{{timestamp}}"
  image_description     = var.image_description
  machine_type          = var.instance_type
  project_id            = var.project_id
  region                = var.vpc_region
  source_image_family   = var.source_image_family
  ssh_username          = var.ssh_username
  zone                  = var.vpc_zone
  network               = var.vpc_ref
  subnetwork            = var.vpc_subnet_id
  service_account_email = var.service_account_email
  scopes                = ["https://www.googleapis.com/auth/cloud-platform"]
}
