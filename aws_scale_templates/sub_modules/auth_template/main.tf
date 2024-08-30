/*
    Creates auth service resources required for IBM Spectrum scale protocol configuration
*/

# Create cloud managed ad service
module "managed_ad" {
  source             = "../../../resources/aws/managed_ad"
  turn_on            = var.create_cloud_managed_auth ? true : false
  ad_password        = var.managed_ad_password
  directory_dns_name = var.managed_ad_dns_name
  directory_size     = var.managed_ad_size
  subnet_ids         = var.managed_ad_subnet_refs
  vpc_ref            = var.vpc_ref
}

# Create self-managed OpenLDAP security group
module "ldap_security_group" {
  source                = "../../../resources/aws/security/security_group"
  turn_on               = var.create_cloud_managed_auth == false ? true : false
  sec_group_name        = ["ldap-sec-group-"]
  sec_group_description = ["Open LDAP security group"]
  vpc_id                = var.vpc_ref
  sec_group_tag         = ["ldap-sec-group"]
}

# Create security rules to enable login to ldap instance.
module "bastion_security_rule" {
  source      = "../../../resources/aws/security/security_rule_cidr"
  total_rules = var.create_cloud_managed_auth == false ? 4 : 0
  security_group_id = [module.ldap_security_group.sec_group_id, module.ldap_security_group.sec_group_id,
  module.ldap_security_group.sec_group_id, module.ldap_security_group.sec_group_id]
  security_rule_description = ["Incoming SSH traffic to ldap instance", "Incoming LDAP unencrypted traffic to ldap instance",
  "Incoming LDAP encrypted traffic to ldap instance", "Incoming ICMP traffic to ldap instance"]
  security_rule_type       = ["ingress", "ingress", "ingress", "ingress"]
  traffic_protocol         = ["TCP", "TCP", "TCP", "icmp"]
  traffic_from_port        = [var.ldap_public_ssh_port, "389", "636", "-1"]
  traffic_to_port          = [var.ldap_public_ssh_port, "389", "636", "-1"]
  cidr_blocks              = var.remote_cidr_blocks
  security_prefix_list_ids = null
}

# Create security rule to enable ldap egress communication
module "ldap_egress_security_rule" {
  source                    = "../../../resources/aws/security/security_rule_cidr"
  total_rules               = var.create_cloud_managed_auth == false ? 1 : 0
  security_group_id         = [module.ldap_security_group.sec_group_id]
  security_rule_description = ["Outgoing traffic from ldap instances"]
  security_rule_type        = ["egress"]
  traffic_protocol          = ["-1"]
  traffic_from_port         = ["0"]
  traffic_to_port           = ["6335"]
  cidr_blocks               = ["0.0.0.0/0"]
  security_prefix_list_ids  = null
}

# Create self-managed OpenLDAP service
module "self_managed_ldap" {
  source               = "../../../resources/aws/compute/ec2_ldap"
  turn_on              = var.create_cloud_managed_auth == false ? true : false
  ami_id               = var.ldap_image_ref
  dns_domain           = var.vpc_dns_domain
  forward_dns_zone     = var.vpc_forward_dns_zone
  iam_instance_profile = null
  instance_type        = var.ldap_instance_type
  name_prefix          = var.resource_prefix
  reverse_dns_domain   = var.vpc_reverse_dns_domain
  reverse_dns_zone     = var.vpc_reverse_dns_zone
  root_volume_type     = var.ldap_instance_boot_disk_type
  security_groups      = [module.ldap_security_group.sec_group_id]
  subnet_id            = var.ldap_instance_private_subnet
  user_public_key      = var.ldap_instance_key_pair
}
