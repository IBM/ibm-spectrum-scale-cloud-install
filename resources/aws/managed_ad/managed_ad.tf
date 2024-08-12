/*
    Creates AWS Managed SimpleAD.
*/

variable "ad_password" {}
variable "directory_dns_name" {}
variable "directory_size" {}
variable "subnet_ids" {}
variable "vpc_ref" {}

resource "aws_directory_service_directory" "itself" {
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
  value = aws_directory_service_directory.itself.access_url
}

output "ad_security_group_id" {
  value = aws_directory_service_directory.itself.security_group_id
}

output "ad_dns_ip_addresses" {
  value = aws_directory_service_directory.itself.dns_ip_addresses
}
