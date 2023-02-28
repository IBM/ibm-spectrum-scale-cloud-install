build {
  sources = ["source.googlecompute.itself"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo dnf makecache",
      "sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "sudo dnf install -y make gcc-c++ elfutils-libelf-devel",
      "sudo dnf install -y dnf-plugin-artifact-registry",
      "sudo mkdir -p /root/.ssh/",
      "sudo sh -c \"echo 'StrictHostKeyChecking no' >> ~/.ssh/config\"",
      "sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config",
      "if sudo grep -q el8 /etc/os-release",
      "then",
      "sudo sh -c \"echo '[GPFSRepository]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Repository' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=https://\"${var.vpc_region}\"-yum.pkg.dev/projects/\"${var.project_id}\"/\"${var.artifact_id}\"' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=0' >> /etc/yum.repos.d/scale.repo\"",
      "elif sudo grep -q el9 /etc/os-release",
      "then",
      "sudo sh -c \"echo '[GPFSRepository]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Repository' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=https://\"${var.vpc_region}\"-yum.pkg.dev/projects/\"${var.project_id}\"/\"${var.artifact_id}\"' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=0' >> /etc/yum.repos.d/scale.repo\"",
      "fi",
      "sudo dnf install -y gpfs*",
      "sudo /usr/lpp/mmfs/bin/mmbuildgpl",
      "sudo sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\""
    ]
  }

  post-processor "manifest" {
    output     = "${local.manifest_path}/manifest.json"
    strip_path = true
  }
}
