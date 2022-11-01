build {
  sources = ["source.amazon-ebs.itself"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo dnf install -y unzip python3",
      "sudo dnf install -y kernel-devel-`uname -r` kernel-headers-`uname -r`",
      "sudo dnf install -y make gcc-c++ elfutils-libelf-devel bind-utils iptables",
      "sudo sh -c \"echo '[GPFSRepository]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Repository' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=http://\"${var.s3_spectrumscale_bucket}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/gpfs_rpms/' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=http://\"${var.s3_spectrumscale_bucket}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/Public_Keys/SpectrumScale_public_key.pgp\n' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo '[ZimonRepositoryRhel8]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Zimon Repository Rhel8' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=http://\"${var.s3_spectrumscale_bucket}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/zimon_rpms/rhel8/' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=http://\"${var.s3_spectrumscale_bucket}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/Public_Keys/SpectrumScale_public_key.pgp\n' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo '[ZimonRepositoryRhel9]' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'name=Spectrum Scale Zimon Repository Rhel9' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'baseurl=http://\"${var.s3_spectrumscale_bucket}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/zimon_rpms/rhel9/' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'enabled=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgcheck=1' >> /etc/yum.repos.d/scale.repo\"",
      "sudo sh -c \"echo 'gpgkey=http://\"${var.s3_spectrumscale_bucket}\".s3-website.\"${var.vpc_region}\".amazonaws.com/\"${var.scale_version}\"/Public_Keys/SpectrumScale_public_key.pgp' >> /etc/yum.repos.d/scale.repo\"",
      "sudo dnf install gpfs* -y",
      "sudo /usr/lpp/mmfs/bin/mmbuildgpl",
      "sudo sh -c \"echo 'export PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin' >> /root/.bashrc\"",
      "sudo rm -rf /root/.bash_history",
      "sudo rm -rf /home/ec2-user/.bash_history"
    ]
  }

  post-processor "manifest" {
    output     = "${path.root}/manifest.json"
    strip_path = true
  }
}
