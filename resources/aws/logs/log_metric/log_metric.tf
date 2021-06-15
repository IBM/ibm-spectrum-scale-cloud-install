/*
    Creates AWS cloudwatch log metric filter.
*/

variable "log_group_name" {}

resource "aws_cloudwatch_log_metric_filter" "itself" {
  name           = "Bastion-SSH-filter"
  pattern        = "ON FROM USER PWD"
  log_group_name = var.log_group_name

  metric_transformation {
    name      = "SSHCommandCount"
    namespace = "BastionStack"
    value     = "1"
  }
}
