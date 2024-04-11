/*
     Associate vpc with the specified route53 domain
*/

variable "turn_on" {}
variable "zone_id" {}
variable "vpc_id" {}

resource "aws_route53_zone_association" "itself" {
  count   = var.turn_on ? 1 : 0
  zone_id = var.zone_id
  vpc_id  = var.vpc_id
}

output "association_id" {
  value = try(aws_route53_zone_association.itself[0].id, null)
}
