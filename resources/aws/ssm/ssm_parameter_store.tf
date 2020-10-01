/*
    Creates AWS SSM parameter.
*/

variable "parameter_name" {}
variable "parameter_value" {}
variable "parameter_type" {}
variable "region" {}


resource "null_resource" "put_ssm_parameter" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "aws ssm put-parameter --name ${var.parameter_name} --value \"`cat ${var.parameter_value}`\" --type ${var.parameter_type} --overwrite --region ${var.region}"
  }
}


output "ssm_parameter_name" {
  value      = var.parameter_name
  depends_on = [null_resource.put_ssm_parameter]
}
