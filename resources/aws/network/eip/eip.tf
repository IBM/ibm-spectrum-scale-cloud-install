/*
    Creates new EIP.
*/

variable "total_eips" {}

resource "aws_eip" "eip" {
    count = var.total_eips
    vpc   = true
}

output "eip_id" {
    value = aws_eip.eip.*.id
}
