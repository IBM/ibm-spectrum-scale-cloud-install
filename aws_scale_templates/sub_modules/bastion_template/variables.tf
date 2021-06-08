variable "vpc_region" {
  type        = string
  description = "The region where AWS operations will take place. Examples are us-east-1, us-west-2, etc."
}

variable "vpc_id" {
  type        = string
  description = "VPC id were to deploy the bastion."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "bastion_public_ssh_port" {
  type        = string
  default     = 22
  description = "Set the SSH port to use from desktop to the bastion."
}

variable "remote_cidr_blocks" {
  type = list(string)
  default = [
    "0.0.0.0/0",
  ]
  description = "List of CIDRs that can access to the bastion. Default : 0.0.0.0/0"
}

variable "aws_linux_image_map_codes" {
  # Ref: https://github.com/aws-quickstart/quickstart-linux-bastion/blob/master/templates/linux-bastion.template
  description = "AWS Linux images vs. search code names"
  type        = map(map(string))
  default = {
    ap-northeast-1 = {
      Amazon-Linux2-HVM          = "ami-0cc75a8978fbbc969"
      Ubuntu-Server-20-04LTS-HVM = "ami-0461b11e2fad8c14a"
      CentOS-7-HVM               = "ami-06a46da680048c8ae"
      SUSE-SLES-15-HVM           = "ami-056ac8ad44e6a7e1f"
    }
    ap-northeast-2 = {
      Amazon-Linux2-HVM          = "ami-0bd7691bf6470fe9c"
      Ubuntu-Server-20-04LTS-HVM = "ami-0dbad3c7f731477cb"
      CentOS-7-HVM               = "ami-06e83aceba2cb0907"
      SUSE-SLES-15-HVM           = "ami-0f81fff879bafe6b8"
    }
    ap-south-1 = {
      Amazon-Linux2-HVM          = "ami-0ebc1ac48dfd14136"
      Ubuntu-Server-20-04LTS-HVM = "ami-0ebd654017556e025"
      CentOS-7-HVM               = "ami-026f33d38b6410e30"
      SUSE-SLES-15-HVM           = "ami-01be89269d32f2a16"
    }
    ap-southeast-1 = {
      Amazon-Linux2-HVM          = "ami-0cd31be676780afa7"
      Ubuntu-Server-20-04LTS-HVM = "ami-0ba1d1f3433cd4c68"
      CentOS-7-HVM               = "ami-07f65177cb990d65b"
      SUSE-SLES-15-HVM           = "ami-070356c21596ddc67"
    }
    ap-southeast-2 = {
      Amazon-Linux2-HVM          = "ami-0ded330691a314693"
      Ubuntu-Server-20-04LTS-HVM = "ami-02be36619a83e9a16"
      CentOS-7-HVM               = "ami-0b2045146eb00b617"
      SUSE-SLES-15-HVM           = "ami-0c4245381c67efb39"
    }
    ca-central-1 = {
      Amazon-Linux2-HVM          = "ami-013d1df4bcea6ba95"
      Ubuntu-Server-20-04LTS-HVM = "ami-071c33c681c9d4a00"
      CentOS-7-HVM               = "ami-04a25c39dc7a8aebb"
      SUSE-SLES-15-HVM           = "ami-0c97d9b588207dad6"
    }
    eu-central-1 = {
      Amazon-Linux2-HVM          = "ami-0c115dbd34c69a004"
      Ubuntu-Server-20-04LTS-HVM = "ami-0c2b1c303a2e4cb49"
      CentOS-7-HVM               = "ami-0e8286b71b81c3cc1"
      SUSE-SLES-15-HVM           = "ami-05dfd265ea534a3e9"
    }
    me-south-1 = {
      Amazon-Linux2-HVM          = "ami-01f41d49c363da2ad"
      Ubuntu-Server-20-04LTS-HVM = "ami-07f9fe3f7a8c82448"
      CentOS-7-HVM               = "ami-011c71a894b10f35b"
      SUSE-SLES-15-HVM           = "ami-0252c6d3a59c7473b"
    }
    ap-east-1 = {
      Amazon-Linux2-HVM          = "ami-47317236"
      Ubuntu-Server-20-04LTS-HVM = "ami-545b1825"
      CentOS-7-HVM               = "ami-0e5c29e6c87a9644f"
      SUSE-SLES-15-HVM           = "ami-0ad6e15bcbb2dbe38"
    }
    eu-north-1 = {
      Amazon-Linux2-HVM          = "ami-039609244d2810a6b"
      Ubuntu-Server-20-04LTS-HVM = "ami-08baf9e3c347b7092"
      CentOS-7-HVM               = "ami-05788af9005ef9a93"
      SUSE-SLES-15-HVM           = "ami-0741fa1a008af40ad"
    }
    eu-south-1 = {
      Amazon-Linux2-HVM          = "ami-08a2aed6e0a6f9c7d"
      Ubuntu-Server-20-04LTS-HVM = "ami-01eec6bdfa20f008e"
      CENTOS-7-HVM               = "ami-0a84267606bcea16b"
      SUSE-SLES-15-HVM           = "ami-051cbea0e7660063d"
    }
    eu-west-1 = {
      Amazon-Linux2-HVM          = "ami-07d9160fa81ccffb5"
      Ubuntu-Server-20-04LTS-HVM = "ami-0f1d11c92a9467c07"
      CENTOS-7-HVM               = "ami-0b850cf02cc00fdc8"
      SUSE-SLES-15-HVM           = "ami-0a58a1b152ba55f1d"
    }
    eu-west-2 = {
      Amazon-Linux2-HVM          = "ami-0a13d44dccf1f5cf6"
      Ubuntu-Server-20-04LTS-HVM = "ami-082335b69bcfdb15b"
      CENTOS-7-HVM               = "ami-09e5afc68eed60ef4"
      SUSE-SLES-15-HVM           = "ami-01497522185aaa4ee"
    }
    eu-west-3 = {
      Amazon-Linux2-HVM          = "ami-093fa4c538885becf"
      Ubuntu-Server-20-04LTS-HVM = "ami-00f6fb16625871821"
      CENTOS-7-HVM               = "ami-0cb72d2e599cffbf9"
      SUSE-SLES-15-HVM           = "ami-0f238bd4c6fdbefb0"
    }
    sa-east-1 = {
      Amazon-Linux2-HVM          = "ami-018ccfb6b4745882a"
      Ubuntu-Server-20-04LTS-HVM = "ami-083aa2af86ff2bd11"
      CENTOS-7-HVM               = "ami-0b30f38d939dd4b54"
      SUSE-SLES-15-HVM           = "ami-0772af912976aa692"
    }
    us-east-1 = {
      Amazon-Linux2-HVM          = "ami-02354e95b39ca8dec"
      Ubuntu-Server-20-04LTS-HVM = "ami-0758470213bdd23b1"
      CENTOS-7-HVM               = "ami-0affd4508a5d2481b"
      SUSE-SLES-15-HVM           = "ami-0b1764f3d7d2e2316"
    }
    us-gov-west-1 = {
      Amazon-Linux2-HVM = "ami-74c4f215"
      SUSE-SLES-15-HVM  = "ami-57c0ba36"
    }
    us-gov-east-1 = {
      Amazon-Linux2-HVM = "ami-30e00c41"
      SUSE-SLES-15-HVM  = "ami-05e4bedfad53425e9"
    }
    us-east-2 = {
      Amazon-Linux2-HVM          = "ami-07c8bc5c1ce9598c3"
      Ubuntu-Server-20-04LTS-HVM = "ami-07fb7bd53bacdfc16"
      CENTOS-7-HVM               = "ami-01e36b7901e884a10"
      SUSE-SLES-15-HVM           = "ami-05ea824317ffc0c20"
    }
    us-west-1 = {
      AMZNLINUX2       = "ami-05655c267c89566dd"
      US2004HVM        = "ami-0cd230f950c3de5d8"
      CentOS-7-HVM     = "ami-098f55b4287a885ba"
      SUSE-SLES-15-HVM = "ami-00e34a7624e5a7107"
    }
    us-west-2 = {
      Amazon-Linux2-HVM = "ami-0873b46c45c11058d"
      US2004HVM         = "ami-056cb9ae6e2df09e8"
      CentOS-7-HVM      = "ami-0bc06212a56393ee1"
      SLES15HVM         = "ami-0f1e3b3fb0fec0361"
    }
    cn-north-1 = {
      Amazon-Linux2-HVM = "ami-010e92a33d9d1fc40"
      CentOS-7-HVM      = "ami-0e02aaefeb74c3373"
      SUSE-SLES-15-HVM  = "ami-021392849b6221a81"
    }
    cn-northwest-1 = {
      Amazon-Linux2-HVM = "ami-0959f8e18a2aac0fb"
      CentOS-7-HVM      = "ami-07183a7702633260b"
      SUSE-SLES-15-HVM  = "ami-00e1de3ee6d0d28ea"
    }
  }
}

variable "bastion_ami_name" {
  type        = string
  description = "Bastion AMI Image name."
}

variable "bastion_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type to use for the bastion instance."
}

variable "bastion_key_pair" {
  type        = string
  description = "The key pair to use to launch the bastion host."
}

variable "vpc_auto_scaling_group_subnets" {
  type        = list(string)
  description = "List of subnet were the Auto Scalling Group will deploy the instances."
}
