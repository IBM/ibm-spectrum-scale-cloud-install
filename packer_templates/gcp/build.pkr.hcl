build {
  sources = ["source.googlecompute.itself"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo dnf makecache",
      "sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "sudo dnf install -y make gcc-c++ elfutils-libelf-devel numactl",
      "sudo sh -c \"echo '[ar-plugin]' >> /etc/yum.repos.d/artifact-registry-plugin.repo\"",
      "sudo sh -c \"echo 'name=Artifact Registry Plugin' >> /etc/yum.repos.d/artifact-registry-plugin.repo\"",
      "sudo sh -c \"echo 'baseurl=https://packages.cloud.google.com/yum/repos/dnf-plugin-artifact-registry-stable' >> /etc/yum.repos.d/artifact-registry-plugin.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/artifact-registry-plugin.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/artifact-registry-plugin.repo\"",
      "sudo sh -c \"echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/artifact-registry-plugin.repo\"",
      "sudo sh -c \"echo 'gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg' >> /etc/yum.repos.d/artifact-registry-plugin.repo\"",
      "sudo dnf install -y dnf-plugin-artifact-registry",
      "sudo mkdir -p /root/.ssh/",
      "sudo sh -c \"echo 'StrictHostKeyChecking no' >> ~/.ssh/config\"",
      "sudo sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config",
      "sudo sh -c \"echo '[GPFSRepository]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Repository' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=https://\"${var.vpc_region}\"-yum.pkg.dev/projects/\"${var.project_id}\"/\"${var.artifact_id}\"' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=0' >> /etc/yum.repos.d/scale.repo\"",
      "sudo dnf install -y gpfs*",
      "sudo /usr/lpp/mmfs/bin/mmbuildgpl",
      "sudo sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\"",
      "sudo rm -rf /etc/yum.repos.d/scale.repo",
      "sudo rm -rf /root/.bash_history",
      "sudo rm -rf /home/${var.ssh_username}/.bash_history"
    ]
  }

  post-processor "manifest" {
    output     = "${local.manifest_path}/manifest.json"
    strip_path = true
  }
}
