/*
    Creates new Elastic network interface (ENI).
*/

variable "subnet_id" {}
variable "private_ips" {}
variable "private_ips_count" {}
variable "security_groups" {}
variable "description" {}

resource "aws_network_interface" "itself" {
  subnet_id         = var.subnet_id
  private_ips       = length(coalesce(var.private_ips, [])) > 0 ? var.private_ips : null
  private_ips_count = var.private_ips_count
  security_groups   = var.security_groups
  description       = var.description
}

output "eni_id" {
  value = aws_network_interface.itself.id
}
