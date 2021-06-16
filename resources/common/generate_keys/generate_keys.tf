/*
    Creates new SSH key pair to enable passwordless SSH between scale nodes.
*/

variable "turn_on" {}

resource "tls_private_key" "itself" {
  count     = tobool(var.turn_on) == true ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "public_key_content" {
  value     = try(tls_private_key.itself[0].public_key_openssh, "")
  sensitive = true
}

output "private_key_content" {
  value     = try(tls_private_key.itself[0].private_key_pem, "")
  sensitive = true
}
