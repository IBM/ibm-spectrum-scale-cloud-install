/*
  Creates GCP VM instance with specified number of persistent disk
*/

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "GCP zone that the instances should be created."
}

variable "subnet_name" {
  type        = string
  nullable    = true
  description = "Instance subnet name."
}

variable "operator_email" {
  type        = string
  description = "GCP service account e-mail address."
}

variable "scopes" {
  type        = list(string)
  default     = ["cloud-platform"]
  description = "List of service scopes."
}

variable "instance_name" {
  type        = string
  default     = "compute-0"
  description = "Instance name prefix (Rules: 1-63 characters long, comply with RFC1035 and match regex [a-z]([-a-z0-9]*[a-z0-9])?"
}

variable "ssh_key_path" {
  type        = string
  description = "SSH public key local path."
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-1"
  description = "GCP instance machine type to create Spectrum Scale compute instances."
}

variable "boot_disk_size" {
  type        = number
  default     = 100
  description = "Compute instances boot disk size in gigabytes."
}
variable "boot_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "boot_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-1804-lts"
  description = "Image from which to initialize compute instances."
}

variable "ssh_user_name" {
  type        = string
  default     = "gcpadmin"
  description = "Name of the administrator to access the instance."
}

variable "vm_instance_tags" {
  type        = list(string)
  default     = []
  description = "List of tags to attach to the compute instance."
}

#Disk variables
variable "total_data_disks" {
  type        = number
  default     = 0
  description = "Number of data disks that needs to be attached to compute instance."
}

variable "data_disk_name_prefix" {
  type        = string
  default     = "scale-disk"
  description = "Persistent data disk name prefix."
}

variable "data_disk_description" {
  type        = string
  default     = "SSD scale-disk"
  description = "Persistent data disk description."
}

variable "physical_block_size_bytes" {
  type        = number
  default     = 4096
  description = "Physical block size of the persistent disk, in bytes (valid: 4096, 16384)."
}

variable "data_disk_type" {
  type        = string
  default     = "pd-standard"
  description = "GCE disk type (valid: pd-standard, pd-ssd)."
}

variable "data_disk_size" {
  type        = string
  default     = 500
  description = "Data disk size in gigabytes."
}

variable "private_key_content" {
  type        = string
  description = "SSH private key content."
}

variable "public_key_content" {
  type        = string
  description = "SSH public key content."
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
mkdir -p ~/.ssh/
echo "${var.private_key_content}" > ~/.ssh/id_rsa
echo "${var.public_key_content}" > ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
if grep -q "Red Hat" /etc/os-release
then
    if grep -q "platform:el8" /etc/os-release
    then
        dnf install -y python3 git wget unzip kernel-devel-$(uname -r) kernel-headers-$(uname -r)
    else
        yum install -y python3 git wget unzip kernel-devel-$(uname -r) kernel-headers-$(uname -r)
    fi
    echo "exclude=kernel* redhat-release*" >> /etc/yum.conf
elif grep -q "Ubuntu" /etc/os-release
then
    apt update
    apt-get install -y python3 git wget unzip python3-pip
elif grep -q "SLES" /etc/os-release
then
    zypper install -y python3 git wget unzip
fi
pip3 install -U ansible PyYAML
if [[ ! "$PATH" =~ "/usr/local/bin" ]]
then
    echo 'export PATH=$PATH:$HOME/bin:/usr/local/bin' >> ~/.bash_profile
fi
EOF
}

#Create scale instance
#tfsec:ignore:google-compute-enable-shielded-vm-im
#tfsec:ignore:google-compute-enable-shielded-vm-vtpm
resource "google_compute_instance" "scale_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true
  tags                      = var.vm_instance_tags

  #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
  boot_disk {
    auto_delete = true
    mode        = "READ_WRITE"

    initialize_params {
      size  = var.boot_disk_size
      type  = var.boot_disk_type
      image = var.boot_image
    }
  }

  network_interface {
    subnetwork = var.subnet_name
    network_ip = null
  }

  metadata = {
    ssh-keys               = format("%s:%s", var.ssh_user_name, file(var.ssh_key_path))
    block-project-ssh-keys = true
  }

  metadata_startup_script = data.template_file.metadata_startup_script.rendered

  service_account {
    email  = var.operator_email
    scopes = var.scopes
  }

  lifecycle {
    ignore_changes = [attached_disk, metadata_startup_script]
  }
}

#tfsec:ignore:google-compute-disk-encryption-customer-key
resource "google_compute_disk" "data_disk" {
  count                     = var.total_data_disks
  zone                      = var.zone
  name                      = format("%s-%s-%s", var.data_disk_name_prefix, google_compute_instance.scale_instance.instance_id, count.index + 1)
  description               = var.data_disk_description
  physical_block_size_bytes = var.physical_block_size_bytes
  type                      = var.data_disk_type
  size                      = var.data_disk_size
  depends_on                = [google_compute_instance.scale_instance]
}

resource "google_compute_attached_disk" "attach_data_disk" {
  count      = length(google_compute_disk.data_disk)
  disk       = google_compute_disk.data_disk[count.index].id
  instance   = google_compute_instance.scale_instance.id
  depends_on = [google_compute_disk.data_disk]
}

#Instance details
output "scale_instance_ids" {
  value = google_compute_instance.scale_instance.id
}

output "scale_instance_uris" {
  value = google_compute_instance.scale_instance.self_link
}

output "scale_instance_ips" {
  value = google_compute_instance.scale_instance.network_interface[0].network_ip
}

#Disk details
output "data_disk_id" {
  value = google_compute_disk.data_disk[*].id
}

output "data_disk_uri" {
  value = google_compute_disk.data_disk[*].self_link
}

output "data_disk_attachment_id" {
  value = google_compute_attached_disk.attach_data_disk[*].id
}
