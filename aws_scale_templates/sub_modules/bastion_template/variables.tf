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
  type        = number
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
    af-south-1 = {
      Amazon-Linux2-HVM          = "ami-0adee70ff4394e3d5"
      Ubuntu-Server-20-04LTS-HVM = "ami-0f5298ccab965edeb"
      CentOS-7-HVM               = "ami-0a2be7731769e6cc1"
      SUSE-SLES-15-HVM           = "ami-0b182a175a9344329"
    }
    ap-northeast-2 = {

      Amazon-Linux2-HVM          = "ami-0e1d09d8b7c751816"
      Ubuntu-Server-20-04LTS-HVM = "ami-0565d651769eb3de5"
      CentOS-7-HVM               = "ami-06e83aceba2cb0907"
      SUSE-SLES-15-HVM           = "ami-0fe8ef15442bbbacb"
    }
    ap-northeast-3 = {

      Amazon-Linux2-HVM          = "ami-0253beba286f3e848"
      Ubuntu-Server-20-04LTS-HVM = "ami-0e6078093a109801c"
      CentOS-7-HVM               = "ami-02d6b455335e3af14"
      SUSE-SLES-15-HVM           = "ami-0bb84400e7507097c"
    }
    ap-southeast-3 = {

      Amazon-Linux2-HVM          = "ami-0483d92a8124da6c9"
      Ubuntu-Server-20-04LTS-HVM = "ami-09915141a4f1dafdd"
      CentOS-7-HVM               = "ami-0c654ac429998fb1c"
      SUSE-SLES-15-HVM           = "ami-005899737135b4201"
    }
    us-gov-west-1 = {

      Amazon-Linux2-HVM          = "ami-0456d1223a9a0764a"
      Ubuntu-Server-20-04LTS-HVM = "ami-84556de5"
      CentOS-7-HVM               = "ami-bbba86da"
      SUSE-SLES-15-HVM           = "ami-0602869f1391f1ba3"
    }
    ap-northeast-1 = {
      Amazon-Linux2-HVM          = "ami-06ce6680729711877"
      Ubuntu-Server-20-04LTS-HVM = "ami-0986c991cc80c6ad9"
      CentOS-7-HVM               = "ami-06a46da680048c8ae"
      SUSE-SLES-15-HVM           = "ami-08d5afff14b78a281"
    }
    ap-northeast-2 = {
      Amazon-Linux2-HVM          = "ami-0e1d09d8b7c751816"
      Ubuntu-Server-20-04LTS-HVM = "ami-0565d651769eb3de5"
      CentOS-7-HVM               = "ami-06e83aceba2cb0907"
      SUSE-SLES-15-HVM           = "ami-0fe8ef15442bbbacb"
    }
    ap-south-1 = {
      Amazon-Linux2-HVM          = "ami-09de362f44ba0a166"
      Ubuntu-Server-20-04LTS-HVM = "ami-0325e3016099f9112"
      CentOS-7-HVM               = "ami-026f33d38b6410e30"
      SUSE-SLES-15-HVM           = "ami-0931494f2532d950d"
    }
    ap-southeast-1 = {
      Amazon-Linux2-HVM          = "ami-0adf622550366ea53"
      Ubuntu-Server-20-04LTS-HVM = "ami-0eaf04122a1ae7b3b"
      CentOS-7-HVM               = "ami-054bf1c1a522aa6e8"
      SUSE-SLES-15-HVM           = "ami-0cc06d620beca2a35"
    }
    ap-southeast-2 = {
      Amazon-Linux2-HVM          = "ami-03b836d87d294e89e"
      Ubuntu-Server-20-04LTS-HVM = "ami-048a2d001938101dd"
      CentOS-7-HVM               = "ami-0d1eb46a368923d43"
      SUSE-SLES-15-HVM           = "ami-03790de3a37ba87cc"
    }
    ca-central-1 = {
      Amazon-Linux2-HVM          = "ami-04c12937e87474def"
      Ubuntu-Server-20-04LTS-HVM = "ami-04a579d2f00bb4001"
      CentOS-7-HVM               = "ami-04a25c39dc7a8aebb"
      SUSE-SLES-15-HVM           = "ami-054bc3c58e249d26f"
    }
    eu-central-1 = {
      Amazon-Linux2-HVM          = "ami-094c442a8e9a67935"
      Ubuntu-Server-20-04LTS-HVM = "ami-06cac34c3836ff90b"
      CentOS-7-HVM               = "ami-0e8286b71b81c3cc1"
      SUSE-SLES-15-HVM           = "ami-00c80956d89173342"
    }
    me-south-1 = {
      Amazon-Linux2-HVM          = "ami-07a68e42e669daed0"
      Ubuntu-Server-20-04LTS-HVM = "ami-0c769d841005394ee"
      CentOS-7-HVM               = "ami-011c71a894b10f35b"
      SUSE-SLES-15-HVM           = "ami-01517fccda7ee908a"
    }
    ap-east-1 = {
      Amazon-Linux2-HVM          = "ami-0b751f901b93720a5"
      Ubuntu-Server-20-04LTS-HVM = "ami-0dfad1f1f65cd083b"
      CentOS-7-HVM               = "ami-0e5c29e6c87a9644f"
      SUSE-SLES-15-HVM           = "ami-0ca7ed1fd25821f56"
    }
    eu-north-1 = {
      Amazon-Linux2-HVM          = "ami-04e8b0e36ed3403dc"
      Ubuntu-Server-20-04LTS-HVM = "ami-0ede84a5f28ec932a"
      CentOS-7-HVM               = "ami-05788af9005ef9a93"
      SUSE-SLES-15-HVM           = "ami-0c61d9bf4e84dd26a"
    }
    eu-south-1 = {
      Amazon-Linux2-HVM          = "ami-0432f14b68c3e0273"
      Ubuntu-Server-20-04LTS-HVM = "ami-0a39f417b8836bc59"
      CENTOS-7-HVM               = "ami-03014b98e9665115a"
      SUSE-SLES-15-HVM           = "ami-0324f5c2cb963f12b"
    }
    eu-west-1 = {
      Amazon-Linux2-HVM          = "ami-0bba0a4cb75835f71"
      Ubuntu-Server-20-04LTS-HVM = "ami-0141514361b6a3c1b"
      CENTOS-7-HVM               = "ami-0fc585b7cdf48bbb0"
      SUSE-SLES-15-HVM           = "ami-0688ec3cb81e58545"
    }
    eu-west-2 = {
      Amazon-Linux2-HVM          = "ami-030770b178fa9d374"
      Ubuntu-Server-20-04LTS-HVM = "ami-014b642f603e350c3"
      CENTOS-7-HVM               = "ami-09e5afc68eed60ef4"
      SUSE-SLES-15-HVM           = "ami-09dc0d3735677ec06"
    }
    eu-west-3 = {
      Amazon-Linux2-HVM          = "ami-0614433a16ab15878"
      Ubuntu-Server-20-04LTS-HVM = "ami-0d0b8d91779dec1e5"
      CENTOS-7-HVM               = "ami-0cb72d2e599cffbf9"
      SUSE-SLES-15-HVM           = "ami-055d9fcbed9687d9f"
    }
    sa-east-1 = {
      Amazon-Linux2-HVM          = "ami-0656df2cc0dfd150a"
      Ubuntu-Server-20-04LTS-HVM = "ami-088afbba294231fe0"
      CENTOS-7-HVM               = "ami-0b30f38d939dd4b54"
      SUSE-SLES-15-HVM           = "ami-0964ddd286e7d4a4f"
    }
    us-east-1 = {
      Amazon-Linux2-HVM          = "ami-065efef2c739d613b"
      Ubuntu-Server-20-04LTS-HVM = "ami-0070c5311b7677678"
      CENTOS-7-HVM               = "ami-0810ddd646a26b133"
      SUSE-SLES-15-HVM           = "ami-08199c714a509d3bc"
    }
    us-gov-west-1 = {
      Amazon-Linux2-HVM          = "ami-0456d1223a9a0764a"
      Ubuntu-Server-20-04LTS-HVM = "ami-84556de5"
      CENTOS-7-HVM               = "ami-bbba86da"
      SUSE-SLES-15-HVM           = "ami-0602869f1391f1ba3"
    }
    us-gov-east-1 = {
      Amazon-Linux2-HVM          = "ami-0c371616b3ca56690"
      Ubuntu-Server-20-04LTS-HVM = "ami-dee008af"
      CENTOS-7-HVM               = "ami-00e30c71"
      SUSE-SLES-15-HVM           = "ami-0c49e39cbc98483b4"
    }
    us-east-2 = {
      Amazon-Linux2-HVM          = "ami-07251f912d2a831a3"
      Ubuntu-Server-20-04LTS-HVM = "ami-07f84a50d2dec2fa4"
      CENTOS-7-HVM               = "ami-01e36b7901e884a10"
      SUSE-SLES-15-HVM           = "ami-013d257c3198b3759"
    }
    us-west-1 = {
      AMZNLINUX2       = "ami-09b2f6d85764ec71b"
      US2004HVM        = "ami-040a251ee9d7d1a9b"
      CentOS-7-HVM     = "ami-0a2e84f9f7388300f"
      SUSE-SLES-15-HVM = "ami-0d36c27f11154fad6"
    }
    us-west-2 = {
      Amazon-Linux2-HVM = "ami-0d08ef957f0e4722b"
      US2004HVM         = "ami-0aab355e1bfa1e72e"
      CentOS-7-HVM      = "ami-0bc06212a56393ee1"
      SLES15HVM         = "ami-0bfb58754b8025d15"
    }
    cn-north-1 = {
      Amazon-Linux2-HVM = "ami-06b608ec1cc843660"
      US2004HVM         = "ami-0ee7de898385f3816"
      CentOS-7-HVM      = "ami-08c16f7e830c0e393"
      SUSE-SLES-15-HVM  = "ami-07563af55cf2eb31d"
    }
    cn-northwest-1 = {
      Amazon-Linux2-HVM = "ami-0f0625eb0f9444fd7"
      US2004HVM         = "ami-08e0c0a54f075c9bc"
      CentOS-7-HVM      = "ami-0f21aa96a61df8c44"
      SUSE-SLES-15-HVM  = "ami-019b04518c072a050"
    }
  }
}

variable "bastion_ami_name" {
  type        = string
  default     = "Amazon-Linux2-HVM"
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
