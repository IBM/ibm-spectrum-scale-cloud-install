/*
    Creates a ldap Instance.
*/

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

variable "vsi_name_prefix" {}
variable "vpc_id" {}
variable "vsi_subnet_id" {}
variable "zones" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "resource_group_id" {}
variable "vsi_user_public_key" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}
variable "managerpassword" {}
variable "defaultuser" {}
variable "defaultuserpassword" {}
variable "ldap_domain_controller" {}
variable "usergroup" {}
variable "resource_tags" {}
variable "ldap_image_name" {}



data "ibm_is_image" "ldap_image" {
  name = var.ldap_image_name
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash


#!/usr/bin/env bash

com=".com"
fulldc="${var.ldap_domain_controller}$com"

apt-get update -y
export DEBIAN_FRONTEND='non-interactive'
echo -e "slapd slapd/root_password password ${var.managerpassword}" |debconf-set-selections
echo -e "slapd slapd/root_password_again password ${var.managerpassword}" |debconf-set-selections
apt-get install -y slapd ldap-utils

echo -e "slapd slapd/internal/adminpw password ${var.managerpassword}" |debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password ${var.managerpassword}" |debconf-set-selections
echo -e "slapd slapd/password2 password ${var.managerpassword}" |debconf-set-selections
echo -e "slapd slapd/password1 password ${var.managerpassword}" |debconf-set-selections
echo -e "slapd slapd/domain string $fulldc" |debconf-set-selections
echo -e "slapd shared/organization string $fulldc" |debconf-set-selections
echo -e "slapd slapd/purge_database boolean false" |debconf-set-selections
echo -e "slapd slapd/move_old_database boolean true" |debconf-set-selections
echo -e "slapd slapd/no_configuration boolean false" |debconf-set-selections
dpkg-reconfigure slapd

echo "BASE   dc=${var.ldap_domain_controller},dc=com" >> /etc/ldap/ldap.conf
echo "URI    ldap://localhost" >> /etc/ldap/ldap.conf

     
systemctl restart slapd
systemctl status slapd
   
cat << EOS > /opt/base-ou-groups.ldif
dn: ou=People,dc=${var.ldap_domain_controller},dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Groups,dc=${var.ldap_domain_controller},dc=com
objectClass: organizationalUnit
ou: Groups
EOS

ldapadd -x -D cn=admin,dc=${var.ldap_domain_controller},dc=com -w ${var.managerpassword} -f /opt/base-ou-groups.ldif


cat << EOS > /opt/group.ldif
dn: cn=${var.usergroup},ou=Groups,dc=${var.ldap_domain_controller},dc=com
objectClass: posixGroup
cn: ${var.usergroup}
gidNumber: 5000
EOS

if ldapsearch -x -D cn=admin,dc=${var.ldap_domain_controller},dc=com -w ${var.managerpassword} -b "ou=groups,dc=${var.ldap_domain_controller},dc=com" "(objectClass=posixGroup)" | grep ${var.usergroup};then
  echo "user group created"
else
  echo "user group created"
fi

ldapadd -x -D cn=admin,dc=${var.ldap_domain_controller},dc=com -w ${var.managerpassword} -f /opt/group.ldif 
   
defaultuser_password_hash=`slappasswd -s ${var.defaultuserpassword}`

cat << EOS > /opt/user.ldif
dn: uid=${var.defaultuser},ou=People,dc=${var.ldap_domain_controller},dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: ${var.defaultuser}
sn: ${var.defaultuser}
givenName: ${var.defaultuser}
cn: ${var.defaultuser}
displayName: ${var.defaultuser}
uidNumber: 1100
gidNumber: 5000
userPassword: $defaultuser_password_hash
gecos: ${var.defaultuser}
loginShell: /bin/bash
homeDirectory: /home/${var.defaultuser}
EOS

ldapadd -x -D cn=admin,dc=${var.ldap_domain_controller},dc=com -w ${var.managerpassword} -f /opt/user.ldif 

if ldapsearch -x -LLL -b "ou=People,dc=${var.ldap_domain_controller},dc=com" "(objectClass=posixAccount)" uid cn | grep ${var.defaultuser};then
  echo "user created"
else
  echo "user not created"
fi


sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo \'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".\';echo;sleep 10; exit 142\" /" ~/.ssh/authorized_keys
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config

EOF
}

resource "ibm_is_instance" "itself" {
  name    = var.vsi_name_prefix
  image   = data.ibm_is_image.ldap_image.id
  profile = var.vsi_profile

  primary_network_interface {
    subnet          = var.vsi_subnet_id
    security_groups = var.vsi_security_group
  }

  vpc            = var.vpc_id
  zone           = var.zones
  resource_group = var.resource_group_id
  keys           = var.vsi_user_public_key
  user_data      = data.template_file.metadata_startup_script.rendered

  boot_volume {
    name = format("%s-boot-vol", var.vsi_name_prefix)
  }
}

output "vsi_id" {
  value = ibm_is_instance.itself.id
}

output "vsi_private_ip" {
  value = ibm_is_instance.itself.primary_network_interface[0].primary_ip.0.address
}

output "vsi_nw_id" {
  value = ibm_is_instance.itself.primary_network_interface[0].id
}
