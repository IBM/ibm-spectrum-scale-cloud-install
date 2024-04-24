build {
  sources = ["source.azure-arm.itself"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "sleep 30",
      "dnf install -y unzip @python36",
      "dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils",
      "sudo sh -c \"echo '[GPFSRepository]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Repository' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=https://${var.storage_accountname}.blob.core.windows.net/${var.package_repository}/${var.scale_version}/gpfs_rpms/' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=https://${var.storage_accountname}.blob.core.windows.net/${var.package_repository}/${var.scale_version}/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo\"",
      "if sudo grep -q el8 /etc/os-release",
      "then",
      "sudo sh -c \"echo '[ZimonRepositoryRhel8]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Zimon Repository Rhel8' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=https://${var.storage_accountname}.blob.core.windows.net/${var.package_repository}/${var.scale_version}/zimon_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=https://${var.storage_accountname}.blob.core.windows.net/${var.package_repository}/${var.scale_version}/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo\"",
      "elif sudo grep -q el9 /etc/os-release",
      "then",
      "sudo sh -c \"echo '[ZimonRepositoryRhel9]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Zimon Repository Rhel9' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=https://${var.storage_accountname}.blob.core.windows.net/${var.package_repository}/${var.scale_version}/zimon_rpms/rhel9/'  >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=https://${var.storage_accountname}.blob.core.windows.net/${var.package_repository}/${var.scale_version}/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo\"",
      "fi",
      "sudo dnf install -y gpfs.base gpfs.docs gpfs.msg.en* gpfs.compression gpfs.ext gpfs.gpl gpfs.gskit gpfs.gui gpfs.java gpfs.gss.pmcollector gpfs.gss.pmsensors gpfs.afm.cos gpfs.compression gpfs.license*",
      "if sudo dnf search gpfs.adv | grep -q \"gpfs.adv\"",
      "then",
      "sudo dnf install -y gpfs.adv",
      "fi",
      "if sudo dnf search gpfs.crypto | grep -q \"gpfs.crypto\"",
      "then",
      "sudo dnf install -y gpfs.crypto",
      "fi",
      "sudo /usr/lpp/mmfs/bin/mmbuildgpl",
      "sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\"",
      "sudo rm -rf /etc/yum.repos.d/scale.repo",
      "sudo dnf clean all",
      "sudo rm -rf /var/cache/dnf",
      "systemctl stop syslog",
      "rm -rf /var/log/messages",
      "rm -rf /root/.bash_history",
      "rm -rf /root/.ssh/authorized_keys",
      "rm -rf /home/\"${var.ssh_username}\"/authorized_keys",
      "rm -rf /home/\"${var.ssh_username}\"/.bash_history",
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }

  post-processor "manifest" {
    output     = "${var.manifest_path}/manifest.json"
    strip_path = true
  }
}
