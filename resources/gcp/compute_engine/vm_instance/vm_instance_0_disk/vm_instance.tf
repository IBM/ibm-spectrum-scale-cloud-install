/*
  Creates specified number of GCP VM instance(s).
*/

variable "zone" {}
variable "total_instances" {}
variable "machine_type" {}
variable "subnet_name" {}
variable "instance_name_prefix" {}
variable "boot_disk_size" {}
variable "boot_disk_type" {}
variable "boot_image" {}
variable "network_tier" {}
variable "ssh_user_name" {}
variable "ssh_key_path" {}
variable "private_key_path" {}
variable "public_key_path" {}
variable "vm_instance_tags" {}
variable "operator_email" {}
variable "scopes" {}


data local_file "id_rsa_template" {
  filename   = pathexpand(var.private_key_path)
  depends_on = [var.private_key_path]
}

data local_file "id_rsa_pub_template" {
  filename   = pathexpand(var.public_key_path)
  depends_on = [var.public_key_path]
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash
mkdir -p ~/.ssh/
echo "${data.local_file.id_rsa_template.content}" > ~/.ssh/id_rsa
echo "${data.local_file.id_rsa_pub_template.content}" > ~/.ssh/id_rsa.pub
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

resource "google_compute_instance" "instance_per_zone" {
  count        = var.total_instances
  name         = format("%s-%s-%s", var.instance_name_prefix, "instance", count.index + 1)
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true
  tags                      = var.vm_instance_tags

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
    ssh-keys = format("%s:%s", var.ssh_user_name, file(var.ssh_key_path))
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


output "instance_ids" {
  value = google_compute_instance.instance_per_zone.*.id
}

output "instance_uris" {
  value = google_compute_instance.instance_per_zone.*.self_link
}

output "instance_ips" {
  value = google_compute_instance.instance_per_zone.*.network_interface.0.network_ip
}
