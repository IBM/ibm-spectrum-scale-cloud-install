/*
    GIT operations to clone specific branch, tag.
*/

variable "branch" {}
variable "tag" { default = null }
variable "clone_path" {}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~>4.9.2"
    }
  }
}

data "github_repository" "ansible_repo" {
  full_name = "IBM/ibm-spectrum-scale-install-infra"
}

resource "null_resource" "create_clone_path" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "mkdir -p ${var.clone_path}"
  }
}

resource "null_resource" "clone_repo_branch" {
  count = var.tag == null ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "if [ -z \"$(ls -A ${var.clone_path})\" ]; then git -C ${var.clone_path} clone -b ${var.branch} ${data.github_repository.ansible_repo.http_clone_url}; fi"
  }
  depends_on = [null_resource.create_clone_path]
}

resource "null_resource" "clone_repo_tag" {
  count = var.tag != null ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "if [ -z \"$(ls -A ${var.clone_path})\" ]; then git -C ${var.clone_path} clone --branch ${var.tag} ${data.github_repository.ansible_repo.http_clone_url}; fi"
  }
  depends_on = [null_resource.create_clone_path]
}

output "clone_complete" {
  value      = true
  depends_on = [null_resource.clone_repo_branch, null_resource.clone_repo_tag]
}
