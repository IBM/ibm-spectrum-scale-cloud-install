build {
  sources = ["source.amazon-ebs.itself"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo dnf install -y unzip @python36",
      "sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "sudo dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils",
      "sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
      "sudo unzip awscliv2.zip",
      "sudo ./aws/install",
      "sudo rm -rf aws awscliv2.zip",
      "sudo /usr/local/bin/aws s3 sync s3://\"${var.s3_spectrumscale_bucket}\" .",
      "sudo dnf install *.rpm -y",
      "sudo rm -rf *.rpm",
      "sudo /usr/lpp/mmfs/bin/mmbuildgpl",
      "sudo sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\"",
      "sudo systemctl stop syslog",
      "sudo rm -rf /var/log/messages",
      "sudo rm -rf /root/.bash_history",
      "sudo rm -rf /home/ec2-user/.bash_history"
    ]
  }
}
