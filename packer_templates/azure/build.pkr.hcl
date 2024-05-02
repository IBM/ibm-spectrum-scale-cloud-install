build {
  sources = ["source.azure-arm.itself"]

  provisioner "shell" {
    script           = "${path.root}/install.sh"
    environment_vars = ["STORAGE_ACCOUNT_URL=${var.storage_account_url}", "SCALE_VERSION=${var.scale_version}", "INSTALL_PROTOCOLS=${var.install_protocols}"]
  }

  post-processor "manifest" {
    output     = "${local.manifest_path}/manifest.json"
    strip_path = true
  }
}
