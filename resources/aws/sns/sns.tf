/*
    Creates new AWS SNS topic.
*/

variable "vpc_region" {}
variable "operator_email" {}
variable "topic_name" {}

#tfsec:ignore:AWS016
resource "aws_sns_topic" "itself" {
  name = var.topic_name
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "aws sns subscribe --topic-arn ${aws_sns_topic.itself.arn} --protocol email --notification-endpoint ${var.operator_email} --region ${var.vpc_region}"
  }
}

output "topic_arn" {
  value = aws_sns_topic.itself.arn
}
