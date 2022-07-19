build {
  sources = ["source.googlecompute.itself"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "sudo dnf install -y make gcc-c++ elfutils-libelf-devel",
      "sudo mkdir -p /root/.ssh/",
      "sudo sh -c \"echo 'StrictHostKeyChecking no' >> ~/.ssh/config\"",
      "sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config",
      "sudo gsutil -m cp -r gs://\"${var.gcs_spectrumscale_bucket}\" .",
      "sudo yum install -y \"${var.gcs_spectrumscale_bucket}\"/*.rpm",
      "sudo rm -rf \"${var.gcs_spectrumscale_bucket}\"",
      "sudo /usr/lpp/mmfs/bin/mmbuildgpl",
      "sudo sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\""]
  }
}
