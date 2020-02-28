/*
    Sets VPC DHCP options.
*/

variable "domain_name" {}
variable "vpc_dhcp_options_name_tag" {}

resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
    domain_name          = var.domain_name
    domain_name_servers  = ["AmazonProvidedDNS"]

    tags = {
        Name = var.vpc_dhcp_options_name_tag
    }
}

output "vpc_dhcp_options_id" {
    value = aws_vpc_dhcp_options.vpc_dhcp_options.id
}
