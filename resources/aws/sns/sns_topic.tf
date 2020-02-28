/*
    Creates new AWS SNS topic.
*/

variable "region" {}
variable "operator_email" {
    type = string
    description = "Operator email address."
}
variable "sns_topic_name" {
    type = string
    description = "SNS topic name"
}

resource "aws_sns_topic" "email_topic" {
    name = var.sns_topic_name
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command     = "aws sns subscribe --topic-arn ${aws_sns_topic.email_topic.arn} --protocol email --notification-endpoint ${var.operator_email} --region ${var.region}"
    }
}

output "sns_topic_arn" {
    value = aws_sns_topic.email_topic.arn
}
