/*
    Validates if results obtained from data sources are valid or not.
*/

variable "resource_map" {}

locals {
  scripts_path            = replace(path.module, "resource_check", "scripts")
  state_check_script_path = "${local.scripts_path}/state_check.py"
}

resource "null_resource" "check_resource_existance" {
  for_each = var.resource_map

  triggers = {
    resource_name = each.key
    resource_id   = each.value
  }
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.state_check_script_path} --resource_name ${each.key} --resource_id ${each.value}"
  }
}

output "instance_ssh_key_id" {
  value      = lookup(var.resource_map, "instance_ssh_key")
  depends_on = [null_resource.check_resource_existance]
}

output "compute_vsi_osimage_id" {
  value      = lookup(var.resource_map, "compute_vsi_osimage_name")
  depends_on = [null_resource.check_resource_existance]
}

output "storage_vsi_osimage_id" {
  value      = lookup(var.resource_map, "storage_vsi_osimage_name")
  depends_on = [null_resource.check_resource_existance]
}
