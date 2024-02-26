build {
  sources = ["source.amazon-ebs.itself"]

  provisioner "shell" {
    script           = "./install.sh"
    environment_vars = ["PACKAGE_REPOSITORY=${var.package_repository}", "VPC_REGION=${var.vpc_region}", "SCALE_VERSION=${var.scale_version}", "INSTALL_PROTOCOLS=${var.install_protocols}"]
  }

  post-processor "manifest" {
    output     = "${local.manifest_path}/manifest.json"
    strip_path = true
  }
}
