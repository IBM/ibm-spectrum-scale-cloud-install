build {
  sources = ["source.azure-arm.itself"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "sleep 30",
      "dnf install -y unzip @python36",
      "dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils",
      "rpm --import https://packages.microsoft.com/keys/microsoft.asc",
      "sh -c \"echo '[azure-cli]' >> /etc/yum.repos.d/azure-cli.repo\"",
      "sh -c \"echo 'name=Azure CLI' >> /etc/yum.repos.d/azure-cli.repo\"",
      "sh -c \"echo 'baseurl=https://packages.microsoft.com/yumrepos/azure-cli' >> /etc/yum.repos.d/azure-cli.repo\"",
      "sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/azure-cli.repo\"",
      "sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/azure-cli.repo\"",
      "sh -c \"echo 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' >> /etc/yum.repos.d/azure-cli.repo\"",
      "dnf install -y azure-cli",
      "az login --identity",
      "az storage blob download-batch --source \"${var.spectrumscale_container}\" --destination . --account-name \"${var.storage_accountname}\" --auth-mode login",
      "dnf install *.rpm -y",
      "rm -rf *.rpm *.gpg",
      "/usr/lpp/mmfs/bin/mmbuildgpl",
      "sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\"",
      "rm -rf /root/.ssh/authorized_keys",
      "rm -rf /home/\"${var.ssh_username}\"/authorized_keys",
      "systemctl stop syslog",
      "rm -rf /var/log/messages",
      "rm -rf /root/.bash_history",
      "rm -rf /home/\"${var.ssh_username}\"/.bash_history",
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }
}
