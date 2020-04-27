/*
    Creates specified number of AWS EC2 instance(s).
*/

variable "region" {}
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
variable "ebs_volume_type" {}
variable "ebs_volume_size" {}
variable "total_ebs_volumes" {}
variable "device_names" {}


data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
yum install -y python3 git wget unzip
pip3 install awscli ansible boto3
wget https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
unzip terraform_0.12.24_linux_amd64.zip
rm -rf terraform_0.12.24_linux_amd64.zip
mv terraform /usr/bin
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

resource "aws_instance" "main_with_0_data" {
  count                   = tonumber(var.total_ebs_volumes) == 0 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_1_data" {
  count                   = tonumber(var.total_ebs_volumes) == 1 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_2_data" {
  count                   = tonumber(var.total_ebs_volumes) == 2 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_3_data" {
  count                   = tonumber(var.total_ebs_volumes) == 3 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_4_data" {
  count                   = tonumber(var.total_ebs_volumes) == 4 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_5_data" {
  count                   = tonumber(var.total_ebs_volumes) == 5 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_6_data" {
  count                   = tonumber(var.total_ebs_volumes) == 6 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_7_data" {
  count                   = tonumber(var.total_ebs_volumes) == 7 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_8_data" {
  count                   = tonumber(var.total_ebs_volumes) == 8 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }


  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_9_data" {
  count                   = tonumber(var.total_ebs_volumes) == 9 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_10_data" {
  count                   = tonumber(var.total_ebs_volumes) == 10 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_11_data" {
  count                   = tonumber(var.total_ebs_volumes) == 11 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_12_data" {
  count                   = tonumber(var.total_ebs_volumes) == 12 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[11]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_13_data" {
  count                   = tonumber(var.total_ebs_volumes) == 13 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }
  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[11]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[12]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }


  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_14_data" {
  count                   = tonumber(var.total_ebs_volumes) == 14 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }
  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }
  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[11]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[12]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[13]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}

resource "aws_instance" "main_with_15_data" {
  count                   = tonumber(var.total_ebs_volumes) == 15 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  /*
        Don't covert below element syntax to HCL2, since element could only
        avoid index overflow.
    */
  subnet_id            = element(var.instance_subnet_ids, count.index)
  iam_instance_profile = var.instance_iam_instance_profile
  placement_group      = var.instance_placement_group

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[11]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[12]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[13]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  ebs_block_device {
    device_name = var.device_names[14]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups]
  }
}


output "instance_ids_with_0_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 0 ? aws_instance.main_with_0_data.*.id : null
}

output "instance_ids_with_1_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 1 ? aws_instance.main_with_1_data.*.id : null
}

output "instance_ids_with_2_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 2 ? aws_instance.main_with_2_data.*.id : null
}

output "instance_ids_with_3_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 3 ? aws_instance.main_with_3_data.*.id : null
}

output "instance_ids_with_4_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 4 ? aws_instance.main_with_4_data.*.id : null
}

output "instance_ids_with_5_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 5 ? aws_instance.main_with_5_data.*.id : null
}

output "instance_ids_with_6_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 6 ? aws_instance.main_with_6_data.*.id : null
}

output "instance_ids_with_7_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 7 ? aws_instance.main_with_7_data.*.id : null
}

output "instance_ids_with_8_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 8 ? aws_instance.main_with_8_data.*.id : null
}

output "instance_ids_with_9_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 9 ? aws_instance.main_with_9_data.*.id : null
}

output "instance_ids_with_10_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 10 ? aws_instance.main_with_10_data.*.id : null
}

output "instance_ids_with_11_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 11 ? aws_instance.main_with_11_data.*.id : null
}

output "instance_ids_with_12_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 12 ? aws_instance.main_with_12_data.*.id : null
}

output "instance_ids_with_13_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 13 ? aws_instance.main_with_13_data.*.id : null
}

output "instance_ids_with_14_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 14 ? aws_instance.main_with_14_data.*.id : null
}

output "instance_ids_with_15_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 15 ? aws_instance.main_with_15_data.*.id : null
}

output "instance_ips_with_0_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 0 ? aws_instance.main_with_0_data.*.private_ip : null
}

output "instance_ips_with_1_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 1 ? aws_instance.main_with_1_data.*.private_ip : null
}

output "instance_ips_with_2_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 2 ? aws_instance.main_with_2_data.*.private_ip : null
}

output "instance_ips_with_3_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 3 ? aws_instance.main_with_3_data.*.private_ip : null
}

output "instance_ips_with_4_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 4 ? aws_instance.main_with_4_data.*.private_ip : null
}

output "instance_ips_with_5_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 5 ? aws_instance.main_with_5_data.*.private_ip : null
}

output "instance_ips_with_6_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 6 ? aws_instance.main_with_6_data.*.private_ip : null
}

output "instance_ips_with_7_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 7 ? aws_instance.main_with_7_data.*.private_ip : null
}

output "instance_ips_with_8_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 8 ? aws_instance.main_with_8_data.*.private_ip : null
}

output "instance_ips_with_9_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 9 ? aws_instance.main_with_9_data.*.private_ip : null
}

output "instance_ips_with_10_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 10 ? aws_instance.main_with_10_data.*.private_ip : null
}

output "instance_ips_with_11_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 11 ? aws_instance.main_with_11_data.*.private_ip : null
}

output "instance_ips_with_12_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 12 ? aws_instance.main_with_12_data.*.private_ip : null
}

output "instance_ips_with_13_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 13 ? aws_instance.main_with_13_data.*.private_ip : null
}

output "instance_ips_with_14_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 14 ? aws_instance.main_with_14_data.*.private_ip : null
}

output "instance_ips_with_15_datadisks" {
  value = tonumber(var.total_ebs_volumes) == 15 ? aws_instance.main_with_15_data.*.private_ip : null
}

output "instance_ip_by_id_with_0_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 0 ? {
    for instance in aws_instance.main_with_0_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_1_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 1 ? {
    for instance in aws_instance.main_with_1_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_2_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 2 ? {
    for instance in aws_instance.main_with_2_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_3_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 3 ? {
    for instance in aws_instance.main_with_3_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_4_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 4 ? {
    for instance in aws_instance.main_with_4_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_5_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 5 ? {
    for instance in aws_instance.main_with_5_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_6_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 6 ? {
    for instance in aws_instance.main_with_6_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_7_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 7 ? {
    for instance in aws_instance.main_with_7_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_8_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 8 ? {
    for instance in aws_instance.main_with_8_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_9_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 9 ? {
    for instance in aws_instance.main_with_9_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_10_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 10 ? {
    for instance in aws_instance.main_with_10_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_11_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 11 ? {
    for instance in aws_instance.main_with_11_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_12_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 12 ? {
    for instance in aws_instance.main_with_12_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_13_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 13 ? {
    for instance in aws_instance.main_with_13_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_14_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 14 ? {
    for instance in aws_instance.main_with_14_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ip_by_id_with_15_datadisks" {
  # Result is a map from instance id to private IP address, such as:
  #  {"i-1234" = "192.168.1.2", "i-5678" = "192.168.1.5"}
  value = tonumber(var.total_ebs_volumes) == 15 ? {
    for instance in aws_instance.main_with_15_data :
    instance.id => instance.private_ip
  } : null
}

output "instance_ids_by_availability_zone_with_0_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 0 ? {
    for instance in aws_instance.main_with_0_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_1_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 1 ? {
    for instance in aws_instance.main_with_1_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_2_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 2 ? {
    for instance in aws_instance.main_with_2_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_3_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 3 ? {
    for instance in aws_instance.main_with_3_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_4_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 4 ? {
    for instance in aws_instance.main_with_4_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_5_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 5 ? {
    for instance in aws_instance.main_with_5_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_6_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 6 ? {
    for instance in aws_instance.main_with_6_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_7_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 7 ? {
    for instance in aws_instance.main_with_7_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_8_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 8 ? {
    for instance in aws_instance.main_with_8_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_9_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 9 ? {
    for instance in aws_instance.main_with_9_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_10_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 10 ? {
    for instance in aws_instance.main_with_10_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_11_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 11 ? {
    for instance in aws_instance.main_with_11_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_12_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 12 ? {
    for instance in aws_instance.main_with_12_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_13_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 13 ? {
    for instance in aws_instance.main_with_13_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_14_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 14 ? {
    for instance in aws_instance.main_with_14_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

output "instance_ids_by_availability_zone_with_15_datadisks" {
  # Result is a map from availability zone to instance ids, such as:
  # {"us-east-1a": ["i-1234", "i-5678"], "us-east-1b": ["i-1234", "i-5678"]}
  value = tonumber(var.total_ebs_volumes) == 15 ? {
    for instance in aws_instance.main_with_15_data :
    # Use the ellipsis (...) after the value expression to enable
    # grouping by key.
    instance.availability_zone => instance.id...
  } : null
}

