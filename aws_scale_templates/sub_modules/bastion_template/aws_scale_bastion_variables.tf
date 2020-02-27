variable "region" {
    /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
    type = string
    description = "AWS region where the resources will be created."
}

variable "vpc_id" {
    type = string
    description = "VPC id."
}

variable "stack_name" {
    type = string
    default = "Spectrum-Scale"
    description = "AWS stack name, will be used for tagging resources."
}

variable "bastion_public_ssh_start_port" {
    type = string
    default = 22
    description = "The start port."

}
variable "bastion_public_ssh_end_port" {
    type = string
    default = 22
    description = "The end range port."
}

variable "bastion_traffic_protocol" {
    type = string
    default = "TCP"
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
    type = map(map(string))
    default = {
        ap-northeast-1 = {
            Amazon-Linux2-HVM           = "ami-0af1df87db7b650f4"
            Amazon-Linux-HVM            = "ami-02ddf94e5edc8e904"
            CentOS-7-HVM                = "ami-045f38c93733dd48d"
            Ubuntu-Server-16-04-LTS-HVM = "ami-03344c819e1ac354d"
            Ubuntu-Server-18-04-LTS-HVM = "ami-01f90b0460589991e"
            SUSE-SLES-15-HVM            = "ami-056ac8ad44e6a7e1f"
        }
        ap-northeast-2 = {
            Amazon-Linux2-HVM           = "ami-0a93a08544874b3b7"
            Amazon-Linux-HVM            = "ami-0ecd78c22823e02ef"
            CentOS-7-HVM                = "ami-06cf2a72dadf92410"
            Ubuntu-Server-16-04-LTS-HVM = "ami-0c5a717974f63b04c"
            Ubuntu-Server-18-04-LTS-HVM = "ami-096e3ded41e3bda6a"
            SUSE-SLES-15-HVM            = "ami-0f81fff879bafe6b8"
        }
        ap-south-1 = {
            Amazon-Linux2-HVM           = "ami-0d9462a653c34dab7"
            Amazon-Linux-HVM            = "ami-05695932c5299858a"
            CentOS-7-HVM                = "ami-02e60be79e78fef21"
            Ubuntu-Server-16-04-LTS-HVM = "ami-0c28d7c6dd94fb3a7"
            Ubuntu-Server-18-04-LTS-HVM = "ami-0d11056c10bfdde69"
            SUSE-SLES-15-HVM            = "ami-01be89269d32f2a16"
        }
        ap-southeast-1 = {
            Amazon-Linux2-HVM           = "ami-0f02b24005e4aec36"
            Amazon-Linux-HVM            = "ami-043afc2b8b6cfba5c"
            CentOS-7-HVM                = "ami-0b4dd9d65556cac22"
            Ubuntu-Server-16-04-LTS-HVM = "ami-0ca13b3dabeb6c66d"
            Ubuntu-Server-18-04-LTS-HVM = "ami-07ce5f60a39f1790e"
            SUSE-SLES-15-HVM            = "ami-070356c21596ddc67"
        }
        ap-southeast-2 = {
            Amazon-Linux2-HVM           = "ami-0f767afb799f45102"
            Amazon-Linux-HVM            = "ami-01393ce9a3ca55d67"
            CentOS-7-HVM                = "ami-08bd00d7713a39e7d"
            Ubuntu-Server-16-04-LTS-HVM = "ami-02d7e25c1cfdd5695"
            Ubuntu-Server-18-04-LTS-HVM = "ami-04c7af7de7ad468f0"
            SUSE-SLES-15-HVM            = "ami-0c4245381c67efb39"
        }
        ca-central-1 = {
            Amazon-Linux2-HVM           = "ami-00db12b46ef5ebc36"
            Amazon-Linux-HVM            = "ami-0fa94ecf2fef3420b"
            CentOS-7-HVM                = "ami-033e6106180a626d0"
            Ubuntu-Server-16-04-LTS-HVM = "ami-0f06e521718460abf"
            Ubuntu-Server-18-04-LTS-HVM = "ami-064efdb82ae15e93f"
            SUSE-SLES-15-HVM            = "ami-0c97d9b588207dad6"
        }
        eu-central-1 = {
            Amazon-Linux2-HVM           = "ami-0df0e7600ad0913a9"
            Amazon-Linux-HVM            = "ami-0ba441bdd9e494102"
            CentOS-7-HVM                = "ami-04cf43aca3e6f3de3"
            Ubuntu-Server-16-04-LTS-HVM = "ami-03d8059563982d7b0"
            Ubuntu-Server-18-04-LTS-HVM = "ami-0718a1ae90971ce4d"
            SUSE-SLES-15-HVM            = "ami-05dfd265ea534a3e9"
        }
        eu-north-1 = {
            Amazon-Linux2-HVM           = "ami-074a0e4318181e9d9"
            Amazon-Linux-HVM            = "ami-01a7a49829bda9d79"
            CentOS-7-HVM                = "ami-5ee66f20"
            Ubuntu-Server-16-04-LTS-HVM = "ami-017ad30b324faed9b"
            Ubuntu-Server-18-04-LTS-HVM = "ami-0e850e0e9c20d9deb"
            SUSE-SLES-15-HVM            = "ami-0741fa1a008af40ad"
        }
        eu-west-1 = {
            Amazon-Linux2-HVM           = "ami-099a8245f5daa82bf"
            Amazon-Linux-HVM            = "ami-0e61341fa75fcaa18"
            CentOS-7-HVM                = "ami-0ff760d16d9497662"
            Ubuntu-Server-16-04-LTS-HVM = "ami-0f630a3f40b1eb0b8"
            Ubuntu-Server-18-04-LTS-HVM = "ami-07042e91d04b1c30d"
            SUSE-SLES-15-HVM            = "ami-0a58a1b152ba55f1d"
        }
        eu-west-2 = {
            Amazon-Linux2-HVM           = "ami-0389b2a3c4948b1a0"
            Amazon-Linux-HVM            = "ami-050b8344d77081f4b"
            CentOS-7-HVM                = "ami-0eab3a90fc693af19"
            Ubuntu-Server-16-04-LTS-HVM = "ami-0a590332f9f499197"
            Ubuntu-Server-18-04-LTS-HVM = "ami-04cc79dd5df3bffca"
            SUSE-SLES-15-HVM            = "ami-01497522185aaa4ee"
        }
        eu-west-3 = {
            Amazon-Linux2-HVM           = "ami-0fd9bce3a3384b635"
            Amazon-Linux-HVM            = "ami-053418e626d0549fc"
            CentOS-7-HVM                = "ami-0e1ab783dc9489f34"
            Ubuntu-Server-16-04-LTS-HVM = "ami-051ebe9615b416c15"
            Ubuntu-Server-18-04-LTS-HVM = "ami-0c367ebddcf279dc6"
            SUSE-SLES-15-HVM            = "ami-0f238bd4c6fdbefb0"
        }
        sa-east-1 = {
            Amazon-Linux2-HVM           = "ami-080a223be3de0c3b8"
            Amazon-Linux-HVM            = "ami-05b7dbc290217250d"
            CentOS-7-HVM                = "ami-0b8d86d4bf91850af"
            Ubuntu-Server-16-04-LTS-HVM = "ami-0a16d0952a2a7b0ce"
            Ubuntu-Server-18-04-LTS-HVM = "ami-0cb1ddea3786f6c0d"
            SUSE-SLES-15-HVM            = "ami-0772af912976aa692"
        }
        us-east-1 = {
            Amazon-Linux2-HVM           = "ami-0a887e401f7654935"
            Amazon-Linux-HVM            = "ami-0e2ff28bfb72a4e45"
            CentOS-7-HVM                = "ami-02eac2c0129f6376b"
            Ubuntu-Server-16-04-LTS-HVM = "ami-08bc77a2c7eb2b1da"
            Ubuntu-Server-18-04-LTS-HVM = "ami-046842448f9e74e7d"
            SUSE-SLES-15-HVM            = "ami-0b1764f3d7d2e2316"
        }
        us-east-2 = {
            Amazon-Linux2-HVM           = "ami-0e38b48473ea57778"
            Amazon-Linux-HVM            = "ami-0998bf58313ab53da"
            CentOS-7-HVM                = "ami-0f2b4fc905b0bd1f1"
            Ubuntu-Server-16-04-LTS-HVM = "ami-08cec7c429219e339"
            Ubuntu-Server-18-04-LTS-HVM = "ami-0367b500fdcac0edc"
            SUSE-SLES-15-HVM            = "ami-05ea824317ffc0c20"
        }
        us-west-1 = {
            Amazon-Linux2-HVM           = "ami-01c94064639c71719"
            Amazon-Linux-HVM            = "ami-021bb9f371690f97a"
            CentOS-7-HVM                = "ami-074e2d6769f445be5"
            Ubuntu-Server-16-04-LTS-HVM = "ami-094f0176b0d009d9f"
            Ubuntu-Server-18-04-LTS-HVM = "ami-0d58800f291760030"
            SUSE-SLES-15-HVM            = "ami-00e34a7624e5a7107"
        }
        us-west-2 = {
            Amazon-Linux2-HVM           = "ami-0e8c04af2729ff1bb"
            Amazon-Linux-HVM            = "ami-079f731edfe27c29c"
            CentOS-7-HVM                = "ami-01ed306a12b7d1c96"
            Ubuntu-Server-16-04-LTS-HVM = "ami-02d0ea44ae3fe9561"
            Ubuntu-Server-18-04-LTS-HVM = "ami-0edf3b95e26a682df"
            SUSE-SLES-15-HVM            = "ami-0f1e3b3fb0fec0361"
        }
        us-gov-west-1 = {
            Amazon-Linux2-HVM           = "ami-a03768c1"
            Amazon-Linux-HVM            = "ami-6cfab40d"
            Ubuntu-Server-14-04-LTS-HVM = "ami-c5930ca4"
            Ubuntu-Server-16-04-LTS-HVM = "ami-9e7d22ff"
            SUSE-SLES-15-HVM            = "ami-a61b4fc7"
        }
        us-gov-east-1 = {
            Amazon-Linux2-HVM           = "ami-7c2bc80d"
            Amazon-Linux-HVM            = "ami-28ed0d59"
            Ubuntu-Server-14-04-LTS-HVM = "ami-21a64050"
            Ubuntu-Server-16-04-LTS-HVM = "ami-a529cad4"
            SUSE-SLES-15-HVM            = "ami-0e85d9b9717e16d66"
        }
    }
}

variable "bastion_image_name" {
    type = string
    description = "Bastion AMI Image name."
}

variable "bastion_instance_type" {
    type = string
    default = "t2.micro"
    description = "Instance type to use for the bastion instance."
}

variable "key_name" {
    type = string
    description = "Name for the AWS key pair."
}

variable "auto_scaling_group_subnets" {
    type = list(string)
    description = "Autoscaling Public subnet list."
}
