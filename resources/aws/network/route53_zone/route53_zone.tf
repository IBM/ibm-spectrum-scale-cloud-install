/*
     Creates new AWS route53 domain
*/

variable "turn_on" {}
variable "zone_name" {}
variable "description" {}
variable "vpc_id" {}
variable "vpc_region" {}
variable "vpc_dns_tags" {}

resource "aws_route53_zone" "itself" {
  count         = var.turn_on ? 1 : 0
  name          = var.zone_name
  comment       = var.description
  force_destroy = false # Don't destroy records if created outside of terraform during zone destroy.
  vpc {
    vpc_id     = var.vpc_id
    vpc_region = var.vpc_region
  }
  tags = merge(
    {
      "Name" = format("%s", var.zone_name)
    },
    var.vpc_dns_tags,
  )
}

output "zone_id" {
  value = try(aws_route53_zone.itself[0].zone_id, null)
}
