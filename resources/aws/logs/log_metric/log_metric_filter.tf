/*
    Creates AWS cloudwatch log metric filter.
*/

variable "group_name" {}

resource "aws_cloudwatch_log_metric_filter" "log_metric_filter" {
  name           = "Bastion-SSH-filter"
  pattern        = "ON FROM USER PWD"
  log_group_name = var.group_name

  metric_transformation {
    name      = "SSHCommandCount"
    namespace = "BastionStack"
    value     = "1"
  }
}
