/*
    Creates new EIP.
*/

variable "total_eips" {}

resource "aws_eip" "itself" {
  count = var.total_eips
  vpc   = true
}

output "eip_id" {
  value = aws_eip.itself.*.id
}
