/*
    Creates new AWS SNS topic.
*/

variable "turn_on" {}
variable "vpc_region" {}
variable "operator_email" {}
variable "topic_name" {}

#tfsec:ignore:AWS016
resource "aws_sns_topic" "itself" {
  count = var.turn_on
  name = var.topic_name
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "aws sns subscribe --topic-arn ${aws_sns_topic.itself[0].arn} --protocol email --notification-endpoint ${var.operator_email} --region ${var.vpc_region}"
  }
}

output "topic_arn" {
  value = try(aws_sns_topic.itself[0].arn, null)
}
