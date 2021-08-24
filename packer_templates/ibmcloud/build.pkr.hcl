build {
  sources = ["source.ibmcloud-vpc.itself"]

  provisioner "shell" {
    execute_command = "{{.Vars}} bash '{{.Path}}'"
    inline = [
      "sleep 30",
      "sudo dnf install -y unzip @python36",
      "sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "sudo dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils iptables",
      "sudo sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\"",
      "sudo systemctl stop syslog",
      "sudo rm -rf /var/log/messages",
      "sudo rm -rf /root/.bash_history",
      "sudo rm -rf /home/ec2-user/.bash_history"
    ]
  }
}
