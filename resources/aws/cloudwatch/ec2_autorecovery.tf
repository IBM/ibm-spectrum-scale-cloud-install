/*
    Creates specified number of Auto-recovery alarms to AWS EC2 instance(s).
*/


variable "region" {}
variable "stack_name" {}
variable "sns_topic_arn" {}
variable "total_instance_count" {}
variable "all_instance_ids" {}

resource "aws_cloudwatch_metric_alarm" "autorecovery" {
  count               = var.total_instance_count
  alarm_name          = format("%s-AutoRecoveryAlarm-%s", var.stack_name, element(var.all_instance_ids, count.index))
  alarm_description   = "Auto recover if EC2 status checks fail for 5 minutes"
  alarm_actions       = ["arn:aws:automate:${var.region}:ec2:recover", var.sns_topic_arn]
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  period              = "60"
  threshold           = "1"
  statistic           = "Minimum"
  dimensions = {
    InstanceId = element(var.all_instance_ids, count.index)
  }

  depends_on = [var.all_instance_ids]
}

