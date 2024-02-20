/*
    Creates new EIP.
*/

variable "turn_on" {}
variable "total_eips" {}

resource "aws_eip" "itself" {
  count  = var.turn_on == true ? var.total_eips : 0
  domain = "vpc"
}

output "eip_id" {
  value = try(aws_eip.itself[*].id, null)
}
