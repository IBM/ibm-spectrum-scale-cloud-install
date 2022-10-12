/*
    Creates new AWS SNS topic.
*/

variable "vpc_region" {}
variable "operator_email" {}
variable "topic_name" {}

resource "aws_sns_topic" "itself" {
  name            = var.topic_name
  delivery_policy = jsonencode({
    "http" : {
      "defaultHealthyRetryPolicy" : {
        "minDelayTarget" : 20,
        "maxDelayTarget" : 20,
        "numRetries" : 3,
        "numMaxDelayRetries" : 0,
        "numNoDelayRetries" : 0,
        "numMinDelayRetries" : 0,
        "backoffFunction" : "linear"
      },
      "disableSubscriptionOverrides" : false,
      "defaultThrottlePolicy" : {
        "maxReceivesPerSecond" : 1
      }
    }
  })
}

resource "aws_sns_topic_subscription" "itself" {
  topic_arn = aws_sns_topic.itself.arn
  protocol  = "email"
  endpoint  = var.operator_email
}

output "topic_arn" {
  value = aws_sns_topic_subscription.itself.arn
}
