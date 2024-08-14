/*
    Creates AWS Managed SimpleAD.
*/

variable "ad_password" {}
variable "directory_dns_name" {}
variable "directory_size" {}
variable "subnet_ids" {}
variable "turn_on" {}
variable "vpc_ref" {}

resource "aws_directory_service_directory" "itself" {
  count    = var.turn_on ? 1 : 0
  name     = var.directory_dns_name
  password = var.ad_password
  edition  = "Standard"
  type     = "MicrosoftAD"
  size     = var.directory_size

  vpc_settings {
    vpc_id     = var.vpc_ref
    subnet_ids = var.subnet_ids
  }
}

output "ad_access_url" {
  value = aws_directory_service_directory.itself[0].access_url
}

output "ad_security_group_id" {
  value = aws_directory_service_directory.itself[0].security_group_id
}

output "ad_dns_ip_addresses" {
  value = aws_directory_service_directory.itself[0].dns_ip_addresses
}
