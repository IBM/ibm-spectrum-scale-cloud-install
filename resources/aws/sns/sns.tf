/*
    Creates new AWS SNS topic.
*/

variable "turn_on" {}
variable "operator_email" {}
variable "topic_name" {}

#tfsec:ignore:aws-sns-enable-topic-encryption
resource "aws_sns_topic" "itself" {
  count = var.turn_on ? 1 : 0
  name  = var.topic_name
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
  count     = var.turn_on ? 1 : 0
  topic_arn = element(aws_sns_topic.itself[*].arn, count.index)
  protocol  = "email"
  endpoint  = var.operator_email
}

output "topic_arn" {
  value = aws_sns_topic_subscription.itself[*].arn
}
