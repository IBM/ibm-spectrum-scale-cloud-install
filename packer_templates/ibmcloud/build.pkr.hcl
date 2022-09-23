build {
  sources = ["source.ibmcloud-vpc.itself"]

  provisioner "file" {
    source      = "/opt/IBM/5.1.1/rpms.zip"
    destination = "/home/vpcuser/rpms.zip"
  }

  provisioner "shell" {
    execute_command = "{{.Vars}} bash '{{.Path}}'"
    inline = [
      "sleep 30",
      "sudo dnf install -y unzip @python36 tar wget git rsync jq",
      "curl -fsSL https://clis.cloud.ibm.com/install/linux | sh",
      "ibmcloud plugin install schematics",
      "sudo wget https://releases.hashicorp.com/terraform/1.0.6/terraform_1.0.6_linux_amd64.zip",
      "sudo unzip terraform_1.0.6_linux_amd64.zip",
      "sudo mv terraform /usr/bin",
      "sudo -u vpcuser pip3 install ansible==2.9 --user",
      "sudo -u vpcuser mkdir -p /home/vpcuser/IBM/gpfs_cloud_rpms /home/vpcuser/IBM/ibm-spectrumscale-cloud-deploy",
      "sudo chown vpcuser /home/vpcuser/rpms.zip",
      "sudo chgrp vpcuser /home/vpcuser/rpms.zip",
      "sudo -u vpcuser unzip /home/vpcuser/rpms.zip -d /home/vpcuser/IBM/gpfs_cloud_rpms",
      "sudo -u vpcuser git clone --branch=next_gen https://github.com/IBM/ibm-spectrum-scale-cloud-install.git /home/vpcuser/IBM/ibm-spectrumscale-cloud-deploy/ibm-spectrum-scale-cloud-install",
      "sudo -u vpcuser git clone --branch scale_cloud https://github.com/IBM/ibm-spectrum-scale-install-infra.git /home/vpcuser/IBM/ibm-spectrumscale-cloud-deploy/ibm-spectrum-scale-install-infra",
      "sudo sh -c \"echo 'export PATH=$PATH:/usr/local/bin' >> /root/.bashrc\"",
      "sudo systemctl stop syslog",
      "sudo rm -rf /home/vpcuser/rpms.zip",
      "sudo rm -rf /var/log/messages",
      "sudo rm -rf /root/.bash_history",
      "sudo rm -rf /home/vpcuser/.bash_history"
    ]
  }
}
