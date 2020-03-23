/*
    Creates specified number of AWS EC2 instance(s).
*/

variable "region" {}
variable "stack_name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "instance_security_groups" {}
variable "instance_subnet_id" {}
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

data "template_cloudinit_config" "user_data64" {
    gzip          = true
    base64_encode = true
    part {
       content_type = "text/x-shellscript"
       content      = data.template_file.user_data.rendered
    }
}

resource "aws_instance" "main" {
    ami                       = var.ami_id
    instance_type             = var.instance_type
    key_name                  = var.key_name
    disable_api_termination   = var.enable_instance_termination_protection
    security_groups           = var.instance_security_groups
    /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
    subnet_id                 = var.instance_subnet_id
    iam_instance_profile      = var.instance_iam_instance_profile
    placement_group           = var.instance_placement_group

    root_block_device {
        volume_size           = var.root_volume_size
        volume_type           = var.root_volume_type
        delete_on_termination = var.enable_delete_on_termination
    }
    user_data_base64          = data.template_cloudinit_config.user_data64.rendered
    tags                      = var.instance_tags

    ebs_block_device {
        device_name = "/dev/xvdh"
        volume_size = 5
        volume_type = "gp2"
        delete_on_termination = var.enable_delete_on_termination
    }

    # Refer to https://github.com/terraform-providers/terraform-provider-aws/issues/4954
    lifecycle {
        ignore_changes = [user_data_base64, security_groups]
    }
}

resource "aws_cloudwatch_metric_alarm" "autorecovery" {
    alarm_name          = format("%s-AutoRecoveryAlarm-%s", var.stack_name, aws_instance.main.id)
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
        InstanceId = aws_instance.main.id
    }
}


output "instance_id" {
    value = aws_instance.main.id
}

output "instance_ip" {
    value = aws_instance.main.private_ip
}

output "instance_private_ip_address" {
    #  {"i-1234" = "192.168.1.2"}
    value = {"${aws_instance.main.id}" = "${aws_instance.main.private_ip}"}
}
