/*
    Copy specified source file to remote destination location.
*/

variable "target_ips" {}
variable "target_user" {}
variable "ssh_private_key" {}
variable "bastion_ip" {}
variable "bastion_user" {}
variable "bastion_private_key" {}

resource "null_resource" "remote_copy" {
  count = length(var.target_ips)
  connection {
    type                = "ssh"
    host                = element(var.target_ips, count.index)
    user                = var.target_user
    private_key         = var.ssh_private_key
    bastion_host        = var.bastion_ip
    bastion_user        = var.bastion_user
    bastion_private_key = var.bastion_private_key
  }

  provisioner "file" {
    source      = "/opt/IBM/gpfs_cloud_rpms/"
    destination = "/opt"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
#!/usr/bin/env bash
if grep -q "Red Hat" /etc/os-release
 then
     USER=vpcuser
     if grep -q "platform:el8" /etc/os-release
     then
         dnf install -y /opt/*.rpm
         dnf install -y /opt/rhel8/*.rpm
         dnf install -y /opt/gui/*.rpm
         dnf install -y make cpp gcc gcc-c++
     else
         yum install -y /opt/*.rpm
         yum install -y /opt/rhel7/*.rpm
         yum install -y /opt/gui/*.rpm
         yum install -y make cpp gcc gcc-c++
     fi
fi
/usr/lpp/mmfs/bin/mmbuildgpl
echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc
    EOF
    ]
  }
}
