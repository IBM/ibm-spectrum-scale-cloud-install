variable "launch_template_name_prefix" {}
variable "image_id" {}
variable "boot_disk_type" {}
variable "boot_disk_size" {}
variable "instance_type" {}
variable "subnetwork_name" {}
variable "network_tier" {}
variable "ssh_user_name" {}
variable "ssh_key_path" {}
variable "network_tags" {}

data "local_sensitive_file" "itself" {
  filename = var.ssh_key_path
}

resource "google_compute_instance_template" "itself" {
  name_prefix    = var.launch_template_name_prefix
  machine_type   = var.instance_type
  can_ip_forward = false
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
  tags = var.network_tags
  metadata = {
    ssh-keys               = format("%s:%s", var.ssh_user_name, data.local_sensitive_file.itself.content)
    block-project-ssh-keys = true
  }
}

output "asg_launch_template_self_link" {
  value = google_compute_instance_template.itself.self_link
}
