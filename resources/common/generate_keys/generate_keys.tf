/*
    Creates new SSH key pair to enable passwordless SSH between scale nodes.
*/

variable "number_key_pairs" {}

resource "tls_private_key" "itself" {
  count     = var.number_key_pairs
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "public_key_content" {
  value = tls_private_key.itself[*].public_key_openssh
}

output "private_key_content" {
  value = tls_private_key.itself[*].private_key_pem
}
