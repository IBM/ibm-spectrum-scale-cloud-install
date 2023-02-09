source "googlecompute" "itself" {
  account_file          = var.service_account_json
  disk_size             = var.disk_size
  disk_type             = var.disk_type
  image_name            = "${var.image_name}-{{timestamp}}"
  image_description     = var.image_description
  machine_type          = var.machine_type
  project_id            = var.project_id
  region                = var.vpc_region
  source_image_family   = var.source_image_reference
  ssh_username          = var.user_account
  zone                  = var.vpc_zone
  tags                  = var.tags
  network               = var.vpc_id
  subnetwork            = var.vpc_subnet_id
  service_account_email = var.service_account_email
  scopes                = ["https://www.googleapis.com/auth/cloud-platform"]
}
