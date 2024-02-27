build {
  sources = ["source.googlecompute.itself"]

  provisioner "shell" {
    script           = "${path.root}/install.sh"
    environment_vars = ["VPC_REGION=${var.vpc_region}", "PROJECT_ID=${var.project_id}", "ARTIFACT_ID=${var.artifact_id}", "SSH_USERNAME=${var.ssh_username}"]
  }

  post-processor "manifest" {
    output     = "${local.manifest_path}/manifest.json"
    strip_path = true
  }
}
