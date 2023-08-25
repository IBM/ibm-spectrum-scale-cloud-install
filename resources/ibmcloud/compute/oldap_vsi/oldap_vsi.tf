/*
    Creates a OLDAP Instance.
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
variable "oldap_domain_controller" {}
variable "admingroup" {}
variable "usergroup" {}
variable "resource_tags" {}
variable "oldap_image_name" {}



data "ibm_is_image" "oldap_image" {
  name = var.oldap_image_name
}

data "template_file" "metadata_startup_script" {
  template = <<EOF
#!/usr/bin/env bash

yum -y install openldap-servers openldap-clients

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG

chown ldap. /var/lib/ldap/DB_CONFIG

systemctl start slapd
systemctl enable slapd

manager_password_hash=`slappasswd -s ${var.managerpassword}`
defaultuser_password_hash=`slappasswd -s ${var.defaultuserpassword}`

cat << EOS > /opt/chrootpw.ldif
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $manager_password_hash
EOS

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

cat << EOS > /opt/chdomain.ldif
# DC should be your domain
# specify the password generated above for "olcRootPW" section

dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=Manager,dc=${var.oldap_domain_controller},dc=com" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=${var.oldap_domain_controller},dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=${var.oldap_domain_controller},dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $manager_password_hash

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=${var.oldap_domain_controller},dc=com" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=${var.oldap_domain_controller},dc=com" write by * read
EOS

ldapmodify -Y EXTERNAL -H ldapi:/// -f /opt/chdomain.ldif

cat << EOS > /opt/basedomain.ldif
# replace to your own domain name for "dc=***,dc=***" section

dn: dc=${var.oldap_domain_controller},dc=com
objectClass: top
objectClass: dcObject
objectclass: organization
o: WES Migration
dc: ${var.oldap_domain_controller}

dn: cn=Manager,dc=${var.oldap_domain_controller},dc=com
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=${var.oldap_domain_controller},dc=com
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=${var.oldap_domain_controller},dc=com
objectClass: organizationalUnit
ou: Group
EOS

ldapadd -x -D cn=Manager,dc=${var.oldap_domain_controller},dc=com -w ${var.managerpassword} -f /opt/basedomain.ldif

cat << EOS > /opt/ldapuser.ldif
dn: uid=${var.defaultuser},ou=People,dc=${var.oldap_domain_controller},dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: ${var.defaultuser}
sn: Linux
userPassword: $defaultuser_password_hash
loginShell: /bin/bash
uidNumber: 1003
gidNumber: 1003
homeDirectory: /home/${var.defaultuser}

dn: cn=${var.defaultuser},ou=Group,dc=${var.oldap_domain_controller},dc=com
objectClass: posixGroup
cn: ${var.defaultuser}
gidNumber: 1001
memberUid: ${var.defaultuser}
EOS

ldapadd -x -D cn=Manager,dc=${var.oldap_domain_controller},dc=com -w ${var.managerpassword} -f /opt/ldapuser.ldif

if ldapsearch -x -LLL -b "ou=People,dc=${var.oldap_domain_controller},dc=com" "(objectClass=posixAccount)" uid cn | grep ${var.defaultuser};then
  echo "user created"
else
  echo "user not created"
fi


cat << EOS > /opt/ldapgroup.ldif
# create an organizational unit for groups
dn: ou=groups,dc=${var.oldap_domain_controller},dc=com
objectClass: organizationalUnit
ou: groups

# create a group called "${var.admingroup}"
dn: cn=${var.admingroup},ou=groups,dc=${var.oldap_domain_controller},dc=com
objectClass: top
objectClass: posixGroup
gidNumber: 1001
cn: ${var.admingroup}
description: ${var.admingroup} group

# create a group called "${var.usergroup}"
dn: cn=${var.usergroup},ou=groups,dc=${var.oldap_domain_controller},dc=com
objectClass: top
objectClass: posixGroup
gidNumber: 1002
cn: ${var.usergroup}
description: ${var.usergroup} group 
EOS

ldapadd -x -D cn=Manager,dc=${var.oldap_domain_controller},dc=com -w ${var.managerpassword} -f /opt/ldapgroup.ldif

if ldapsearch -x -D cn=Manager,dc=${var.oldap_domain_controller},dc=com -w ${var.managerpassword} -b "ou=groups,dc=${var.oldap_domain_controller},dc=com" "(objectClass=posixGroup)" | grep ${var.admingroup};then
  echo "${var.admingroup} group created"
else
  echo "${var.admingroup} group not created"
fi

if ldapsearch -x -D cn=Manager,dc=${var.oldap_domain_controller},dc=com -w ${var.managerpassword} -b "ou=groups,dc=${var.oldap_domain_controller},dc=com" "(objectClass=posixGroup)" | grep ${var.usergroup};then
  echo "${var.usergroup} group  created"
else
  echo "${var.usergroup} group not created"
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
  image   = data.ibm_is_image.oldap_image.id
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
