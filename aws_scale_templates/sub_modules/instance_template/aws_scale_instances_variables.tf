variable "generate_jumphost_ssh_config" {
  type        = bool
  default     = false
  description = "Flag to represent whether to generate jump host SSH config or not."
}

variable "region" {
  /* Keep it empty, it will be propagated via command line or via ".tfvars"
       or ".tfvars.json"
    */
  type        = string
  description = "AWS region where the resources will be created."
}

variable "tf_data_path" {
  type        = string
  default     = "~/tf_data_path"
  description = "Data path to be used by terraform for storing ssh keys."
}

variable "tf_input_json_root_path" {
  type        = string
  default     = null
  description = "Terraform module absolute path."
}

variable "tf_input_json_file_name" {
  type        = string
  default     = null
  description = "Terraform module input variable defintion/json file name."
}

variable "bucket_name" {
  type        = string
  description = "s3 bucket name to be used for backing up ansible inventory file."
}

variable "scale_infra_repo_clone_path" {
  type        = string
  default     = "/opt/IBM/ibm-spectrumscale-cloud-deploy"
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "vpc_id" {
  type        = string
  description = "AWS VPC id."
}

variable "stack_name" {
  type        = string
  default     = "Spectrum-Scale"
  description = "AWS Stack name."
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones."
}

variable "egress_access_cidr" {
  description = "List of egress CIDRs. Default : 0.0.0.0/0"
  type        = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "key_name" {
  type        = string
  description = "Name for the AWS key pair."
}

variable "root_volume_enable_delete_on_termination" {
  type        = bool
  default     = true
  description = "Whether the root volume should be destroyed on instance termination."
}

variable "compute_ami_id" {
  type        = string
  description = "AMI ID of provisioning compute instances."
}

variable "compute_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to use for the compute instances."
}

variable "tiebreaker_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to use for the tie breaker instance."
}

variable "total_compute_instances" {
  type        = string
  default     = "2"
  description = "Number of EC2 instances to be launched for compute instances."
}

variable "compute_root_volume_size" {
  type        = string
  default     = 100
  description = "Size of root volume in gibibytes (GiB)."
}

variable "compute_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: io1, gp2, st1 and sc1."
}

variable "storage_ami_id" {
  type        = string
  description = "AMI ID of provisioning storage instances."
}

variable "storage_instance_type" {
  type        = string
  default     = "t2.medium"
  description = "Instance type to use for the storage instances."
}

variable "total_storage_instances" {
  type        = string
  default     = "2"
  description = "Number of EC2 instances to be launched for storage instances."
}

variable "storage_root_volume_size" {
  type        = string
  default     = 100
  description = "Size of root volume in gibibytes (GiB)."
}

variable "storage_root_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: io1, gp2, st1 and sc1."
}

variable "ebs_volumes_per_instance" {
  type        = string
  default     = 1
  description = "Number of disks to be attached to each storage instance."
}

variable "ebs_enable_delete_on_termination" {
  type        = bool
  default     = false
  description = "Whether EBS volume to be deleted on instance termination."
}

variable "enable_instance_termination_protection" {
  type        = bool
  default     = false
  description = "If true, enables EC2 Instance Termination Protection."
}

variable "ebs_volume_device_names" {
  type = list(string)
  default = ["/dev/xvdf", "/dev/xvdg", "/dev/xvdh", "/dev/xvdi", "/dev/xvdj",
    "/dev/xvdk", "/dev/xvdl", "/dev/xvdm", "/dev/xvdn", "/dev/xvdo",
  "/dev/xvdp", "/dev/xvdq", "/dev/xvdr", "/dev/xvds", "/dev/xvdt"]
  description = "Name of the block device to mount on the instance"
}

variable "ebs_volume_iops" {
  type        = string
  default     = null
  description = "Provisioned IOPS (input/output operations per second) per volume."
}

variable "ebs_volume_size" {
  type        = string
  default     = 500
  description = "EBS/Disk size in GiB"
}

variable "ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS volume types: io1, gp2, st1 and sc1."
}

variable "bastion_sec_group_id" {
  type        = string
  description = "AWS Bastion security group id."
}

variable "deploy_container_sec_group_id" {
  type        = string
  default     = null
  description = "Deployment container (ECS-FARGATE) security group id. Default: null"
}

variable "private_instance_subnet_ids" {
  type        = list(string)
  description = "List of instances private security subnet ids."
}

variable "operator_email" {
  type        = string
  description = "SNS notifications will be sent to provided email id."
}

variable "create_scale_cluster" {
  type        = bool
  default     = false
  description = "Flag to represent whether to create scale cluster or not."
}

variable "generate_ansible_inv" {
  type        = bool
  default     = true
  description = "Flag to represent whether to generate ansible inventory JSON or not."
}

variable "filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "Filesystem block size."
}

variable "bastion_public_ip" {
  type        = string
  description = "Bastion public ip."
}

variable "scale_version" {
  type        = string
  default     = "5.0.5.0"
  description = "IBM Spectrum Scale version."
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/19"
  description = "Range of internal addresses."
}

variable "instances_ssh_private_key_path" {
  type        = string
  description = "SSH private key local path, which will be used to login to bastion host."
}

variable "instances_ssh_user_name" {
  type        = string
  default     = "ec2-user"
  description = "Name of the administrator to access the bastion instance."
}
