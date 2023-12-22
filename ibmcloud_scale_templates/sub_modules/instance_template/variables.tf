variable "vpc_region" {
  type        = string
  description = "The region where IBM Cloud operations will take place. Examples are us-east, us-south, etc."
}

variable "vpc_availability_zones" {
  type        = list(string)
  description = "A list of availability zones names or ids in the region."
}

variable "resource_prefix" {
  type        = string
  default     = "spectrum-scale"
  description = "Prefix is added to all resources that are created."
}

variable "resource_group_id" {
  type        = string
  description = "IBM Cloud resource group id."
}

variable "vpc_id" {
  type        = string
  description = "VPC id were to deploy the bastion."
}

variable "vpc_compute_cluster_private_subnets" {
  type        = list(string)
  description = "List of IDs of compute cluster private subnets."
}

variable "vpc_storage_cluster_private_subnets" {
  type        = list(string)
  description = "List of IDs of storage cluster private subnets."
}

variable "total_compute_cluster_instances" {
  type        = number
  default     = 3
  description = "Number of instances to be launched for compute cluster."
}

variable "compute_cluster_key_pair" {
  type        = list(string)
  default     = null
  description = "The key pair to use to launch the compute cluster host."
}

variable "compute_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the compute cluster instances."
}

variable "compute_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for compute cluster virtual server instance."
}

variable "using_rest_api_remote_mount" {
  type        = string
  default     = true
  description = "If false, skips GUI initialization on compute cluster for remote mount configuration."
}

variable "compute_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on compute cluster."
}

variable "compute_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for compute cluster GUI"
}

variable "total_storage_cluster_instances" {
  type        = number
  default     = 4
  description = "Number of instances to be launched for storage cluster."
}

variable "storage_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the storage cluster instances."
}

variable "storage_vsi_profile" {
  type        = string
  default     = "bx2d-8x32"
  description = "Profile to be used for storage cluster virtual server instance."
}

variable "storage_cluster_key_pair" {
  type        = list(string)
  description = "The key pair to use to launch the storage cluster host."
}

variable "storage_cluster_gui_username" {
  type        = string
  sensitive   = true
  description = "GUI user to perform system management and monitoring tasks on storage cluster."
}

variable "storage_cluster_gui_password" {
  type        = string
  sensitive   = true
  description = "Password for storage cluster GUI"
}

variable "using_packer_image" {
  type        = bool
  default     = false
  description = "If true, gpfs rpm copy step will be skipped during the configuration."
}

variable "using_jumphost_connection" {
  type        = bool
  default     = false
  description = "If true, will skip the jump/bastion host configuration."
}

variable "vpc_compute_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS service resource id."
}

variable "vpc_storage_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud storage cluster DNS service resource id."
}

variable "vpc_compute_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS zone id."
}

variable "vpc_storage_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud storage cluster DNS zone id."
}

variable "vpc_compute_cluster_dns_domain" {
  type        = string
  default     = "compscale.com"
  description = "IBM Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_storage_cluster_dns_domain" {
  type        = string
  default     = "strgscale.com"
  description = "IBM Cloud DNS domain name to be used for storage cluster."
}

variable "vpc_custom_resolver_id" {
  type        = string
  description = "IBM Cloud DNS custom resolver id."
}

variable "scale_ansible_repo_clone_path" {
  type        = string
  default     = "/opt/IBM/ibm-spectrumscale-cloud-deploy"
  description = "Path to clone github.com/IBM/ibm-spectrum-scale-install-infra."
}

variable "spectrumscale_rpms_path" {
  type        = string
  default     = "/opt/IBM/gpfs_cloud_rpms"
  description = "Path that contains IBM Spectrum Scale product cloud rpms."
}

variable "storage_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Storage cluster (owningCluster) Filesystem mount point."
}

variable "compute_cluster_filesystem_mountpoint" {
  type        = string
  default     = "/gpfs/fs1"
  description = "Compute cluster (accessingCluster) Filesystem mount point."
}

variable "filesystem_block_size" {
  type        = string
  default     = "4M"
  description = "Filesystem block size."
}

variable "create_separate_namespaces" {
  type        = bool
  default     = true
  description = "Flag to select if separate namespace needs to be created for compute instances."
}

variable "bastion_instance_public_ip" {
  type        = string
  default     = null
  description = "Bastion instance public ip address."
}

variable "bastion_security_group_id" {
  type        = string
  default     = null
  description = "Bastion security group id."
}

variable "bastion_instance_id" {
  type        = string
  default     = null
  description = "Bastion instance id."
}

variable "bastion_ssh_private_key" {
  type        = string
  default     = null
  description = "Bastion SSH private key path, which will be used to login to bastion host."
}

variable "deploy_controller_sec_group_id" {
  type        = string
  default     = null
  description = "Deployment controller security group id. Default: null"
}

variable "vpc_create_activity_tracker" {
  type        = bool
  default     = true
  description = "Flag to select if IBM Cloud activity tracker to be created or not. Note: You can only provision 1 instance of this service per IBM Cloud region."
}

variable "activity_tracker_plan_type" {
  type        = string
  default     = "lite"
  description = "IBM Cloud activity tracker plan type (Valid: lite, 7-day, 14-day, 30-day, hipaa-30-day)."
}

variable "create_scale_cluster" {
  type        = bool
  default     = false
  description = "Flag to represent whether to create scale cluster or not."
}

variable "scale_cluster_resource_tags" {
  type        = list(string)
  default     = null
  description = "A list of tags for resources created for scale cluster."
}

variable "compute_vsi_osimage_id" {
  type        = string
  default     = ""
  description = "Image id to use for provisioning the compute cluster instances."
}

variable "storage_vsi_osimage_id" {
  type        = string
  default     = ""
  description = "Image id to use for provisioning the storage cluster instances."
}

variable "storage_bare_metal_server_profile" {
  type        = string
  default     = "cx2d-metal-96x192"
  description = "Specify the virtual server instance profile type name to be used to create the Baremetal Storage nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-bare-metal-servers-profile&interface=ui)."
}

variable "storage_bare_metal_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-3-minimal-amd64-3"
  description = "Image name to use for provisioning the storage Baremetal cluster."
}

variable "storage_bare_metal_osimage_id" {
  type        = string
  default     = ""
  description = "Image Id to use for provisioning the storage Baremetal cluster instances."
}

variable "storage_type" {
  type        = string
  default     = "scratch"
  description = "Select the required scale filesystem deployment method. Note: Choosing the scale scratch or evaluation type will deploy scale filesystem on VSI and scale persistent type will deploy scale filesystem on Baremetal server."
}

variable "inventory_format" {
  type        = string
  default     = "ini"
  description = "Specify inventory format suited for ansible playbooks."
}

variable "bastion_user" {
  type        = string
  default     = "ubuntu"
  description = "Provide the username for Bastion login."
}

#GKLM Variables

variable "scale_encryption_enabled" {
  type        = bool
  default     = false
  description = "To enable the encryption for the filesystem. Select true or false"
}

variable "gklm_vsi_osimage_id" {
  type        = string
  default     = null
  description = "Image id to use for provisioning the GKLM instances."
}

variable "total_gklm_instances" {
  type        = number
  default     = 2
  description = "Number of instances to be launched for GKLM."
}

variable "gklm_instance_key_pair" {
  type        = list(string)
  default     = null
  description = "The key pair to use to launch the GKLM host."
}

variable "gklm_vsi_osimage_name" {
  type        = string
  default     = null
  description = "Image name to use for provisioning the GKLM instances."
}

variable "gklm_vsi_profile" {
  type        = string
  default     = "bx2-2x8"
  description = "Profile to be used for GKLM virtual server instance."
}

variable "gklm_instance_dns_domain" {
  type        = string
  default     = "gklmscale.com"
  description = "IBM Cloud DNS domain name to be used for GKLM instances."
}

variable "gklm_instance_dns_service_id" {
  type        = string
  default     = null
  description = "IBM Cloud GKLM Instance DNS service resource id."
}

variable "gklm_instance_dns_zone_id" {
  type        = string
  default     = null
  description = "IBM GKLM Instance DNS zone id."
}

variable "scale_encryption_admin_default_password" {
  type        = string
  default     = "SKLM@dmin123"
  description = "The default administrator password used for resetting the admin password based on the user input. The password has to be updated which was configured during the GKLM installation."
}

variable "scale_encryption_admin_username" {
  type        = string
  default     = "SKLMAdmin"
  description = "The default Admin username for Security Key Lifecycle Manager(GKLM)."
}

variable "scale_encryption_admin_password" {
  type        = string
  default     = null
  description = "Password that is used for performing administrative operations for the GKLM.The password must contain at least 8 characters and at most 20 characters. For a strong password, at least three alphabetic characters are required, with at least one uppercase and one lowercase letter.  Two numbers, and at least one special character from this(~@_+:). Make sure that the password doesn't include the username. Visit this [page](https://www.ibm.com/docs/en/gklm/3.0.1?topic=roles-password-policy) to know more about password policy of GKLM. "
}

# CES Variables

variable "vpc_protocol_cluster_private_subnets" {
  type        = list(string)
  default     = ["10.241.2.0/24"]
  description = "List of IDs of protocol nodes private subnets."
}

variable "vpc_protocol_cluster_dns_domain" {
  type        = string
  default     = "cesscale.com"
  description = "IBM Cloud DNS domain name to be used for compute cluster."
}

variable "vpc_protocol_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS service resource id."
}

variable "vpc_protocol_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud compute cluster DNS zone id."
}

variable "protocol_vsi_profile" {
  type        = string
  default     = "cx2-32x64"
  description = "Profile to be used for compute cluster virtual server instance."
}

variable "total_protocol_cluster_instances" {
  type        = number
  default     = 2
  description = "Total number of protocol nodes that you need to provision. A minimum of 2 nodes and a maximum of 16 nodes are supported"
}

variable "filesets" {
  type = list(object({
    mount_path = string,
    size       = number
  }))
  default     = [{ mount_path = "/mnt/binaries", size = 0 }, { mount_path = "/mnt/data", size = 0 }]
  description = "Mount point(s) and size(s) in GB of file share(s) that can be used to customize shared file storage layout. Provide the details for up to 5 file shares."
}

# Client Cluster Variables

variable "total_client_cluster_instances" {
  type        = number
  default     = 2
  description = "Total number of client cluster instances that you need to provision. A minimum of 2 nodes and a maximum of 64 nodes are supported"
}

variable "client_vsi_osimage_name" {
  type        = string
  default     = "ibm-redhat-8-8-minimal-amd64-2"
  description = "Name of the image that you would like to use to create the client cluster nodes for the IBM Storage Scale cluster. The solution supports only stock images that use RHEL8.8 version."
}

variable "client_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Client nodes vis profile"
}

variable "vpc_client_cluster_dns_service_id" {
  type        = string
  description = "IBM Cloud client cluster DNS service resource id."
}

variable "vpc_client_cluster_dns_zone_id" {
  type        = string
  description = "IBM Cloud client cluster DNS zone id."
}

variable "vpc_client_cluster_dns_domain" {
  type        = string
  default     = "clntscale.com"
  description = "IBM Cloud DNS domain name to be used for client cluster."
}

variable "client_cluster_key_pair" {
  type        = list(string)
  default     = null
  description = "The key pair to use to launch the client cluster host."
}

variable "ldap_basedns" {
  type        = string
  default     = null
  description = "Base DNS of LDAP Server. If none given the LDAP feature will not be enabled."
}

variable "ldap_server" {
  type        = string
  default     = null
  description = "IP of existing LDAP server. If none given a new ldap server will be created"
}

variable "ldap_admin_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "Password that is used for performing administrative operations for LDAP.The password must contain at least 8 characters and at most 20 characters. For a strong password, at least three alphabetic characters are required, with at least one uppercase and one lowercase letter.  Two numbers, and at least one special character from this(~@_+:). Make sure that the password doesn't include the username. "
}

variable "ldap_user_name" {
  type        = string
  sensitive   = true
  default     = null
  description = "Custom LDAP User for performing cluster operations. Note: Username should be at least 4 characters, (any combination of lowercase and uppercase letters)."
  validation {
    condition     = var.ldap_user_name == null || (try(length(var.ldap_user_name), 0) >= 4 && try(length(var.ldap_user_name), 0) <= 32)
    error_message = "Specified input for \"ldap_user_name\" is not valid. username should be greater or equal to 4 letters."
  }
}

variable "ldap_user_password" {
  type        = string
  sensitive   = true
  default     = null
  description = "LDAP User Password that is used for performing operations on the cluster.The password must contain at least 8 characters and at most 20 characters. For a strong password, at least three alphabetic characters are required, with at least one uppercase and one lowercase letter.  Two numbers, and at least one special character from this(~@_+:). Make sure that the password doesn't include the username."
}

variable "ldap_instance_key_pair" {
  type        = list(string)
  default     = null
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the LDAP Server. Make sure that the SSH key is present in the same resource group and region where the LDAP Servers are provisioned. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions."
}

variable "ldap_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "Profile to be used for LDAP virtual server instance."
}

variable "ldap_vsi_osimage_name" {
  type        = string
  default     = "ibm-ubuntu-22-04-3-minimal-amd64-1"
  description = "Image name to be used for provisioning the LDAP instances."
}

variable "total_afm_cluster_instances" {
  type        = number
  default     = 1
  description = "Total number of afm nodes that you need to provision."
}

variable "afm_vsi_profile" {
  type        = string
  default     = "cx2-2x4"
  description = "The virtual server instance profile type name to be used to create the protocol cluster nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles&interface=ui)."
}

variable "afm_existing_cos_details" {
  type = list(object({
    bucket = string,
    akey   = string,
    skey   = string,
  }))
  description = "Existing Bucket name, access and secret key"
}

variable "afm_cos_config_details" {
  type = list(object({
    bucket     = string,
    filesystem = string,
    fileset    = string,
    endpoint   = string,
    mode       = string
  }))
  description = "Existing Bucket name and config details"
}


###################################################################################################
###################################################################################################
#####                This Terraform file defines the variables used in COS Module           #######
#####                                      COS Module                                        ######
###################################################################################################
###################################################################################################


/**
* Name: cos_bucket_plan
* Type: String
* Desc: List of available plan for the COS bucket.
* Exmp: Followings are the list of availabe
* 1. lite
* 2. standard
**/
variable "cos_bucket_plan" {
  description = "Please enter plan name for COS bucket. Possible value is \n1:lite\n2:standard"
  type        = string
}


/**
* Name: cross_region_location
* Type: String
* Desc: Cross Region service provides higher durability and availability than using a single region,
* at the cost of slightly higher latency. This service is available today in the U.S., E.U., and A.P. areas.
* Followings are the list of availabe cross_region_location as of now.
* 1. us
* 2. eu
* 3. ap
**/
# variable "cross_region_location" {
#   description = "Cross Region service provides higher durability and availability than using a single region, at the cost of slightly higher latency. This service is available today in the U.S., E.U., and A.P. areas."
#   type        = string
# }


/**
* Name: storage_class
* Type: String
* Desc: Storage class helps in choosing a right storage plan and location and helps in reducing the cost.
* Followings are the list of availabe storage_class as of now.
* 1. Smart Tier
* 2. Standard
* 3. Vault
* 4. Cold Vault
* Note: Flex has been replaced by Smart Tier for dynamic workloads.
* Flex users can continue to manage their data in existing Flex buckets, although no new Flex buckets may be created. Existing users can reference pricing information
**/
variable "storage_class" {
  description = "Storage class helps in choosing a right storage plan and location and helps in reducing the cost."
  type        = string
}

/**
* Name: bucket_location
* Type: String
* Desc: The location of the COS bucket.
**/
variable "bucket_location" {
  description = "The location of the COS bucket"
  type        = string
}

/**
* Name: obj_key
* Type: String
* Desc: The name of an object in the COS bucket. This is used to identify our object.
**/
variable "obj_key" {
  description = "The name of an object in the COS bucket. This is used to identify our object."
  type        = string
}

/**
* Name: obj_content
* Type: String
* Desc:  Literal string value to use as an object content, which will be uploaded as UTF-8 encoded text. Conflicts with content_base64 and content_file.
**/
variable "obj_content" {
  description = "Literal string value to use as an object content, which will be uploaded as UTF-8 encoded text. Conflicts with content_base64 and content_file"
  type        = string
}

/**
#################################################################################################################
*                                   End of the Variable Section
#################################################################################################################
**/
