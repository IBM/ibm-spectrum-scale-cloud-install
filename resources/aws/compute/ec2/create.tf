/*
    Creates specified number of AWS EC2 instance(s).
*/

variable "region" {}
variable "stack_name" {}
variable "total_ec2_count" {}
variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "instance_security_groups" {}
variable "instance_subnet_ids" {}
variable "instance_iam_instance_profile" {}
variable "instance_placement_group" {}
variable "root_volume_size" {}
variable "root_volume_type" {}
variable "enable_delete_on_termination" {}
variable "enable_instance_termination_protection" {}
variable "vault_private_key" {}
variable "vault_public_key" {}
variable "instance_tags" {}
variable "sns_topic_arn" {}

data "template_file" "user_data" {
    template = <<EOF
#!/usr/bin/env bash
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py
pip install awscli ansible
echo "${var.vault_private_key}" > ~/.ssh/id_rsa
echo "${var.vault_public_key}"  > ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
EOF
}

resource "aws_instance" "main" {
    count                     = var.total_ec2_count
    ami                       = var.ami_id
    instance_type             = var.instance_type
    key_name                  = var.key_name
    disable_api_termination   = var.enable_instance_termination_protection
    security_groups           = var.instance_security_groups
    /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
    subnet_id                 = element(var.instance_subnet_ids, count.index)
    iam_instance_profile      = var.instance_iam_instance_profile
    placement_group           = var.instance_placement_group

    root_block_device {
        volume_size           = var.root_volume_size
        volume_type           = var.root_volume_type
        delete_on_termination = var.enable_delete_on_termination
    }
    user_data_base64          = base64encode(data.template_file.user_data.rendered)
    tags                      = var.instance_tags

    lifecycle {
        ignore_changes = [user_data_base64, security_groups]
    }
}

resource "aws_cloudwatch_metric_alarm" "autorecovery" {
    count               = length(aws_instance.main.*.id)
    alarm_name          = format("%s-AutoRecoveryAlarm-%s", var.stack_name, element(aws_instance.main.*.id, count.index))
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
        InstanceId = element(aws_instance.main.*.id, count.index)
    }
}

output "instance_ids" {
    value = aws_instance.main.*.id
}

output "instance_ips" {
    value = aws_instance.main.*.private_ip
}

output "instances_private_ip_addresses" {
    # Result is a map from instance id to private IP address, such as:
    #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
    value = {
        for instance in aws_instance.main:
            instance.id => instance.private_ip
    }
}

output "instances_by_availability_zone" {
    # Result is a map from availability zone to instance ids, such as:
    # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
    value = {
        for instance in aws_instance.main:
            # Use the ellipsis (...) after the value expression to enable
            # grouping by key.
            instance.availability_zone => instance.id...
    }
}
