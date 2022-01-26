/*
    Creates specified number of AWS EC2 instance(s).
    Note: Don't covert below element syntax to HCL2,
         since element could only avoid index overflow.
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
variable "root_volume_type" {}
variable "enable_delete_on_termination" {}
variable "enable_instance_termination_protection" {}
variable "private_key_ssm_name" {}
variable "public_key_ssm_name" {}
variable "instance_tags" {}
variable "ebs_volume_type" {}
variable "ebs_volume_iops" {}
variable "ebs_volume_size" {}
variable "total_ebs_volumes" {}
variable "device_names" {}


data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash

exec > >(tee /var/log/ibm_spectrumscale_user-data.log)
if grep -q "Red Hat" /etc/os-release
then
    REQ_PKG_INSTALLED=0
    if grep -q "platform:el8" /etc/os-release
    then
        PACKAGE_MGR=dnf
    else
        PACKAGE_MGR=yum
    fi

    RETRY_LIMIT=5
    retry_count=0
    pkg_installed=1

    while [[ $pkg_installed -ne 0 && $retry_count -lt $RETRY_LIMIT ]]
    do
        # Install all required packages
        echo "INFO: Attempting to install packages"
        $PACKAGE_MGR install -y python3 unzip kernel-devel-$(uname -r) kernel-headers-$(uname -r)

        # Check to ensure packages are installed
        pkg_query=$($PACKAGE_MGR list installed unzip)
        pkg_installed=$?

        if [[ $pkg_installed -ne 0 ]]
        then
            # The minimum required packages have not been installed.
            echo "WARN: Required packages not installed. Sleeping for 60 seconds and retrying..."
            sleep 60
            touch /var/log/scale-rerun-package-install

            if [ -f /usr/sbin/choose_repo.py ]
            then
                echo "INFO: Executing /usr/sbin/choose_repo.py to resetup the package repositories"
                /usr/sbin/choose_repo.py
            fi

            echo "INFO: Cleaning and repopulating repository data"
            $PACKAGE_MGR clean all
            $PACKAGE_MGR makecache
        fi

        retry_count=$(( $retry_count+1 ))
    done

elif grep -q "Ubuntu" /etc/os-release
then
    apt update
    apt-get install -y python3 wget unzip python3-pip
elif grep -q "SLES" /etc/os-release
then
    zypper install -y python3 wget unzip
fi

if [ ! -f /usr/local/bin/aws ]
then
    echo "INFO: Installing AWS CLI"
    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    cd aws/
    bash install
    cd -
else
    echo "INFO: AWS CLI already installed"
fi

SSM_RETRY_LIMIT=6
priv_retry_count=0
get_priv_key_status=1
while [[ $get_priv_key_status -ne 0 && $priv_retry_count -lt $SSM_RETRY_LIMIT ]]
do
    sleep 20
    echo "INFO: Retrieving instance keys (1)"
    private_key=$(/usr/local/bin/aws ssm get-parameter --name "${var.private_key_ssm_name}" --region "${var.region}" --with-decryption --query 'Parameter.{Value:Value}' --output text)
    get_priv_key_status=$?
    if [[ $get_priv_key_status -eq 0 ]]
    then
        echo "Installing key (1)"
        echo "$private_key" > ~/.ssh/id_rsa
    fi
    if [[ $priv_retry_count -gt 0 ]]
    then
        touch /var/log/scale-rerun-ssm-priv
    fi
    priv_retry_count=$(( $priv_retry_count+1 ))
done

pub_retry_count=0
get_pub_key_status=1
while [[ $get_pub_key_status -ne 0 && $pub_retry_count -lt $SSM_RETRY_LIMIT ]]
do
    sleep 20
    echo "INFO: Retrieving instance keys (2)"
    public_key=$(/usr/local/bin/aws ssm get-parameter --name "${var.public_key_ssm_name}" --region "${var.region}" --with-decryption --query 'Parameter.{Value:Value}' --output text)
    get_pub_key_status=$?
    if [[ $get_pub_key_status -eq 0 ]]
    then
        echo "Installing key (2)"
        echo "$public_key" > ~/.ssh/id_rsa.pub
    fi
    if [[ $pub_retry_count -gt 0 ]]
    then
        touch /var/log/scale-rerun-ssm-pub
    fi
    pub_retry_count=$(( $pub_retry_count+1 ))
done


cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
chmod 600 ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
pip3 install -U boto3 PyYAML
if [[ ! "$PATH" =~ "/usr/local/bin" ]]
then
    echo 'export PATH=$PATH:$HOME/bin:/usr/local/bin' >> ~/.bash_profile
fi
EOF
}

data "template_file" "nvme_alias" {
  template = file("${path.module}/scripts/nvme_alias.sh.tpl")
}

data "template_cloudinit_config" "user_data64" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.nvme_alias.rendered
  }
}

resource "aws_instance" "main_with_0_data" {
  count                   = tonumber(var.total_ebs_volumes) == 0 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_1_data" {
  count                   = tonumber(var.total_ebs_volumes) == 1 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_2_data" {
  count                   = tonumber(var.total_ebs_volumes) == 2 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_3_data" {
  count                   = tonumber(var.total_ebs_volumes) == 3 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_type : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_4_data" {
  count                   = tonumber(var.total_ebs_volumes) == 4 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_5_data" {
  count                   = tonumber(var.total_ebs_volumes) == 5 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_6_data" {
  count                   = tonumber(var.total_ebs_volumes) == 6 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_7_data" {
  count                   = tonumber(var.total_ebs_volumes) == 7 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_8_data" {
  count                   = tonumber(var.total_ebs_volumes) == 8 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_9_data" {
  count                   = tonumber(var.total_ebs_volumes) == 9 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_10_data" {
  count                   = tonumber(var.total_ebs_volumes) == 10 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_11_data" {
  count                   = tonumber(var.total_ebs_volumes) == 11 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_12_data" {
  count                   = tonumber(var.total_ebs_volumes) == 12 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[11]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_13_data" {
  count                   = tonumber(var.total_ebs_volumes) == 13 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[11]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[12]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_14_data" {
  count                   = tonumber(var.total_ebs_volumes) == 14 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[11]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[12]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[13]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
  }
}

resource "aws_instance" "main_with_15_data" {
  count                   = tonumber(var.total_ebs_volumes) == 15 ? var.total_ec2_count : 0
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = var.enable_instance_termination_protection
  security_groups         = var.instance_security_groups
  subnet_id               = element(var.instance_subnet_ids, count.index)
  iam_instance_profile    = var.instance_iam_instance_profile
  placement_group         = var.instance_placement_group

  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = var.enable_delete_on_termination
  }

  ebs_block_device {
    device_name = var.device_names[0]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[1]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[2]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[3]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[4]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[5]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[6]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[7]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[8]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[9]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[10]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[11]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[12]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[13]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  ebs_block_device {
    device_name = var.device_names[14]
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_volume_type == "io1" ? var.ebs_volume_iops : null
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered
  tags             = var.instance_tags

  lifecycle {
    ignore_changes = [user_data_base64, security_groups, subnet_id]
  }

  timeouts {
    create = "15m"
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

