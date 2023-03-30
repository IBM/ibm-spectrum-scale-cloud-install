variable "launch_template_name_prefix" {}
variable "image_id" {}
variable "boot_disk_type" {}
variable "boot_disk_size" {}
variable "instance_type" {}
variable "subnetwork_name" {}
variable "network_tier" {}
variable "ssh_user_name" {}
variable "ssh_key_path" {}

resource "google_compute_instance_template" "itself" {
  name_prefix  = var.launch_template_name_prefix
  machine_type = var.instance_type
  disk {
    source_image = var.image_id
    disk_type    = var.boot_disk_type
    disk_size_gb = var.boot_disk_size
    auto_delete  = true
  }
  network_interface {
    subnetwork = var.subnetwork_name
    access_config {
      network_tier = var.network_tier
    }
  }
  metadata = {
    ssh-keys               = format("%s:%s", var.ssh_user_name, file(var.ssh_key_path))
    block-project-ssh-keys = true
  }
  tags = [var.launch_template_name_prefix]
}

output "asg_launch_template_self_link" {
  value = google_compute_instance_template.itself.self_link
}
