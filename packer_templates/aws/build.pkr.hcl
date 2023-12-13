build {
  sources = ["source.amazon-ebs.itself"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "if [ -f /etc/os-release ] && grep -qiE 'Ubuntu' /etc/os-release;",
      "then",
      "sudo apt install unzip",
      "sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
      "sudo unzip awscliv2.zip",
      "sudo ./aws/install",
      "sudo rm -rf awscliv2.zip",
      "curl -sS http://\"${var.package_repository}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/Public_Keys/                        Storage_Scale_public_key.pgp | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/scale.gpg",
      "sudo ua detach --assume-yes",
      "sudo rm -rf /var/log/ubuntu-advantage.log",
      "sudo cloud-init clean --machine-id",
      "elif [ -f /etc/os-release ] && grep -qiE 'redhat' /etc/os-release;",
      "then",
      "sudo dnf install -y unzip python3 python3-pip jq numactl",
      "sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "sudo dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils nftables iptables nvme-cli",
      "sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip",
      "sudo unzip awscliv2.zip",
      "sudo ./aws/install",
      "sudo rm -rf awscliv2.zip",
      "sudo sh -c \"echo '[GPFSRepository]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Repository' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=http://\"${var.package_repository}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/gpfs_rpms/' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=http://\"${var.package_repository}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/Public_Keys/Storage_Scale_public_key.pgp\n' >> /etc/yum.repos.d/scale.repo\"",
      "if sudo grep -q el8 /etc/os-release",
      "then",
      "sudo sh -c \"echo '[ZimonRepositoryRhel8]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Zimon Repository Rhel8' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=http://\"${var.package_repository}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/zimon_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=http://\"${var.package_repository}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/Public_Keys/Storage_Scale_public_key.pgp\n' >> /etc/yum.repos.d/scale.repo\"",
      "elif sudo grep -q el9 /etc/os-release",
      "then",
      "sudo sh -c \"echo '[ZimonRepositoryRhel9]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Zimon Repository Rhel9' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=http://\"${var.package_repository}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/zimon_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=http://\"${var.package_repository}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/Public_Keys/Storage_Scale_public_key.pgp' >> /etc/yum.repos.d/scale.repo\"",
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
      "sudo sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\"",
      "sudo rm -rf /etc/yum.repos.d/scale.repo",
      "sudo dnf clean all",
      "sudo rm -rf /var/cache/dnf",
      "sudo rm -rf /root/.bash_history",
      "sudo rm -rf /home/ec2-user/.bash_history",
      "fi"
    ]
  }

  post-processor "manifest" {
    output     = "${local.manifest_path}/manifest.json"
    strip_path = true
  }
}
