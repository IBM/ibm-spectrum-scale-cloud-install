variable "region" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "AWS region where the resources will be created."
}

variable "vpc_id" {
  type        = string
  description = "VPC id."
}

variable "stack_name" {
  type        = string
  default     = "Spectrum-Scale"
  description = "AWS stack name, will be used for tagging resources."
}

variable "bastion_public_ssh_start_port" {
  type        = string
  default     = 22
  description = "The start port."

}
variable "bastion_public_ssh_end_port" {
  type        = string
  default     = 22
  description = "The end range port."
}

variable "bastion_traffic_protocol" {
  type        = string
  default     = "TCP"
  description = "The traffic protocol."
}

variable "cidr_blocks" {
  description = "List of CIDRs than can access to the bastion. Default : 0.0.0.0/0"
  type        = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "aws_linux_image_map_codes" {
  # Ref: https://github.com/aws-quickstart/quickstart-linux-bastion/blob/master/templates/linux-bastion.template
  description = "AWS Linux images vs. search code names"
  type        = map(map(string))
  default = {
    ap-northeast-1 = {
      Amazon-Linux2-HVM           = "ami-0f310fced6141e627"
      Amazon-Linux-HVM            = "ami-0318ecd6d05daa212"
      CentOS-7-HVM                = "ami-06a46da680048c8ae"
      Ubuntu-Server-16-04-LTS-HVM = "ami-0196a6e6d6129f2c8"
      Ubuntu-Server-18-04-LTS-HVM = "ami-0278fe6949f6b1a06"
      SUSE-SLES-15-HVM            = "ami-056ac8ad44e6a7e1f"
    }
    ap-northeast-2 = {
      Amazon-Linux2-HVM           = "ami-01288945bd24ed49a"
      Amazon-Linux-HVM            = "ami-09391a0ad9f9243b6"
      CentOS-7-HVM                = "ami-06e83aceba2cb0907"
      Ubuntu-Server-16-04-LTS-HVM = "ami-04e5ceec6723d7ec5"
      Ubuntu-Server-18-04-LTS-HVM = "ami-00edfb46b107f643c"
      SUSE-SLES-15-HVM            = "ami-0f81fff879bafe6b8"
    }
    ap-south-1 = {
      Amazon-Linux2-HVM           = "ami-0470e33cd681b2476"
      Amazon-Linux-HVM            = "ami-04b2519c83e2a7ea5"
      CentOS-7-HVM                = "ami-026f33d38b6410e30"
      Ubuntu-Server-16-04-LTS-HVM = "ami-01b8d0884f38e37b4"
      Ubuntu-Server-18-04-LTS-HVM = "ami-0b44050b2d893d5f7"
      SUSE-SLES-15-HVM            = "ami-01be89269d32f2a16"
    }
    ap-southeast-1 = {
      Amazon-Linux2-HVM           = "ami-0ec225b5e01ccb706"
      Amazon-Linux-HVM            = "ami-0dff4318d85149d5d"
      CentOS-7-HVM                = "ami-07f65177cb990d65b"
      Ubuntu-Server-16-04-LTS-HVM = "ami-01c54eee4ab8725c0"
      Ubuntu-Server-18-04-LTS-HVM = "ami-0f7719e8b7ba25c61"
      SUSE-SLES-15-HVM            = "ami-070356c21596ddc67"
    }
    ap-southeast-2 = {
      Amazon-Linux2-HVM           = "ami-0970010f37c4f9c8d"
      Amazon-Linux-HVM            = "ami-050e1ec030abb8dde"
      CentOS-7-HVM                = "ami-0b2045146eb00b617"
      Ubuntu-Server-16-04-LTS-HVM = "ami-07e22925f7bf77a0c"
      Ubuntu-Server-18-04-LTS-HVM = "ami-04fcc97b5f6edcd89"
      SUSE-SLES-15-HVM            = "ami-0c4245381c67efb39"
    }
    ca-central-1 = {
      Amazon-Linux2-HVM           = "ami-054362537f5132ce2"
      Amazon-Linux-HVM            = "ami-021321e9bc16d5186"
      CentOS-7-HVM                = "ami-04a25c39dc7a8aebb"
      Ubuntu-Server-16-04-LTS-HVM = "ami-03785c71db4b1f73a"
      Ubuntu-Server-18-04-LTS-HVM = "ami-0edd51cc29813e254"
      SUSE-SLES-15-HVM            = "ami-0c97d9b588207dad6"
    }
    eu-central-1 = {
      Amazon-Linux2-HVM           = "ami-076431be05aaf8080"
      Amazon-Linux-HVM            = "ami-03ab4e8f1d88ce614"
      CentOS-7-HVM                = "ami-0e8286b71b81c3cc1"
      Ubuntu-Server-16-04-LTS-HVM = "ami-0bad2b43a871348da"
      Ubuntu-Server-18-04-LTS-HVM = "ami-0e342d72b12109f91"
      SUSE-SLES-15-HVM            = "ami-05dfd265ea534a3e9"
    }
    eu-north-1 = {
      Amazon-Linux2-HVM           = "ami-0b7a46b4bd694e8a6"
      Amazon-Linux-HVM            = "ami-0c5254b956817b326"
      CentOS-7-HVM                = "ami-05788af9005ef9a93"
      Ubuntu-Server-16-04-LTS-HVM = "ami-0caae0b310f01ff33"
      Ubuntu-Server-18-04-LTS-HVM = "ami-050981837962d44ac"
      SUSE-SLES-15-HVM            = "ami-0741fa1a008af40ad"
    }
    eu-west-1 = {
      Amazon-Linux2-HVM           = "ami-06ce3edf0cff21f07"
      Amazon-Linux-HVM            = "ami-00890f614e48ce866"
      CentOS-7-HVM                = "ami-0b850cf02cc00fdc8"
      Ubuntu-Server-16-04-LTS-HVM = "ami-0f2ed58082cb08a4d"
      Ubuntu-Server-18-04-LTS-HVM = "ami-0701e7be9b2a77600"
      SUSE-SLES-15-HVM            = "ami-0a58a1b152ba55f1d"
    }
    eu-west-2 = {
      Amazon-Linux2-HVM           = "ami-01a6e31ac994bbc09"
      Amazon-Linux-HVM            = "ami-0596aab74a1ce3983"
      CentOS-7-HVM                = "ami-09e5afc68eed60ef4"
      Ubuntu-Server-16-04-LTS-HVM = "ami-0b1912235a9e70540"
      Ubuntu-Server-18-04-LTS-HVM = "ami-0eb89db7593b5d434"
      SUSE-SLES-15-HVM            = "ami-01497522185aaa4ee"
    }
    eu-west-3 = {
      Amazon-Linux2-HVM           = "ami-00077e3fed5089981"
      Amazon-Linux-HVM            = "ami-06cba15121418cdcb"
      CentOS-7-HVM                = "ami-0cb72d2e599cffbf9"
      Ubuntu-Server-16-04-LTS-HVM = "ami-0b92a0ac418c64fb1"
      Ubuntu-Server-18-04-LTS-HVM = "ami-08c757228751c5335"
      SUSE-SLES-15-HVM            = "ami-0f238bd4c6fdbefb0"
    }
    sa-east-1 = {
      Amazon-Linux2-HVM           = "ami-003449ffb2605a74c"
      Amazon-Linux-HVM            = "ami-03e1e4abf50e14ded"
      CentOS-7-HVM                = "ami-0b30f38d939dd4b54"
      Ubuntu-Server-16-04-LTS-HVM = "ami-0bb677666cd3fd188"
      Ubuntu-Server-18-04-LTS-HVM = "ami-077d5d3682940b34a"
      SUSE-SLES-15-HVM            = "ami-0772af912976aa692"
    }
    us-east-1 = {
      Amazon-Linux2-HVM           = "ami-0323c3dd2da7fb37d"
      Amazon-Linux-HVM            = "ami-0915e09cc7ceee3ab"
      CentOS-7-HVM                = "ami-0affd4508a5d2481b"
      Ubuntu-Server-16-04-LTS-HVM = "ami-039a49e70ea773ffc"
      Ubuntu-Server-18-04-LTS-HVM = "ami-085925f297f89fce1"
      SUSE-SLES-15-HVM            = "ami-0b1764f3d7d2e2316"
    }
    us-east-2 = {
      Amazon-Linux2-HVM           = "ami-0f7919c33c90f5b58"
      Amazon-Linux-HVM            = "ami-097834fcb3081f51a"
      CentOS-7-HVM                = "ami-01e36b7901e884a10"
      Ubuntu-Server-16-04-LTS-HVM = "ami-03ffa9b61e8d2cfda"
      Ubuntu-Server-18-04-LTS-HVM = "ami-07c1207a9d40bc3bd"
      SUSE-SLES-15-HVM            = "ami-05ea824317ffc0c20"
    }
    us-west-1 = {
      Amazon-Linux2-HVM           = "ami-06fcc1f0bc2c8943f"
      Amazon-Linux-HVM            = "ami-0027eed75be6f3bf4"
      CentOS-7-HVM                = "ami-098f55b4287a885ba"
      Ubuntu-Server-16-04-LTS-HVM = "ami-00e3060e4cb84a493"
      Ubuntu-Server-18-04-LTS-HVM = "ami-0f56279347d2fa43e"
      SUSE-SLES-15-HVM            = "ami-00e34a7624e5a7107"
    }
    us-west-2 = {
      Amazon-Linux2-HVM           = "ami-0d6621c01e8c2de2c"
      Amazon-Linux-HVM            = "ami-01f08ef3e76b957e5"
      CentOS-7-HVM                = "ami-0bc06212a56393ee1"
      Ubuntu-Server-16-04-LTS-HVM = "ami-008c6427c8facbe08"
      Ubuntu-Server-18-04-LTS-HVM = "ami-003634241a8fcdec0"
      SUSE-SLES-15-HVM            = "ami-0f1e3b3fb0fec0361"
    }
    us-gov-west-1 = {
      Amazon-Linux2-HVM           = "ami-f5e4d294"
      Amazon-Linux-HVM            = "ami-74c4f215"
      Ubuntu-Server-14-04-LTS-HVM = "ami-adecdbcc"
      Ubuntu-Server-16-04-LTS-HVM = "ami-3a61505b"
      SUSE-SLES-15-HVM            = "ami-57c0ba36"
    }
    us-gov-east-1 = {
      Amazon-Linux2-HVM           = "ami-51ef0320"
      Amazon-Linux-HVM            = "ami-30e00c41"
      Ubuntu-Server-14-04-LTS-HVM = "ami-c29975b3"
      Ubuntu-Server-16-04-LTS-HVM = "ami-7df4180c"
      SUSE-SLES-15-HVM            = "ami-05e4bedfad53425e9"
    }
  }
}

variable "bastion_image_name" {
  type        = string
  description = "Bastion AMI Image name."
}

variable "bastion_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type to use for the bastion instance."
}

variable "key_name" {
  type        = string
  description = "Name for the AWS key pair."
}

variable "auto_scaling_group_subnets" {
  type        = list(string)
  description = "Autoscaling Public subnet list."
}
