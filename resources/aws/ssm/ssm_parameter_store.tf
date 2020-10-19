/*
    Creates AWS SSM parameter.
*/

variable "parameter_name" {}
variable "parameter_value" {}
variable "parameter_type" {}
variable "region" {}

locals {
  ssm_put_param_script_path = "${path.module}/ssm_putparams.py"
}

resource "null_resource" "put_ssm_parameter" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "python3 ${local.ssm_put_param_script_path} --param_name ${var.parameter_name} --param_type ${var.parameter_type} --local_file_path ${var.parameter_value} --region_name ${var.region} --cloud_platform AWS"
  }
}


output "ssm_parameter_name" {
  value      = var.parameter_name
  depends_on = [null_resource.put_ssm_parameter]
}
