/*
     Creates AWS EC2 Open LDAP instance.
*/
variable "ami_id" {}
variable "instance_type" {}
variable "meta_private_key" {}
variable "meta_public_key" {}
variable "name_prefix" {}
variable "root_volume_type" {}
variable "subnet_id" {}
variable "user_public_key" {}
variable "dns_domain" {}
variable "manager_password" {}
variable "ldap_domain_controller" {}
variable "user_group" {}
variable "default_user_password" {}
variable "default_user" {}
variable "security_groups" {}
variable "forward_dns_zone" {}
variable "reverse_dns_zone" {}
variable "reverse_dns_domain" {}
variable "availability_zone" {}

data "template_file" "user_data" {
  template = <<EOF
#!/usr/bin/env bash
# Hostname settings
hostnamectl set-hostname --static "${var.name_prefix}.${var.dns_domain}"
echo 'preserve_hostname: True' > /etc/cloud/cloud.cfg.d/10_hostname.cfg
echo "${var.name_prefix}.${var.dns_domain}" > /etc/hostname
# LDAP install and configure
com=".com"
fulldc="${var.ldap_domain_controller}$com"
apt-get update -y
export DEBIAN_FRONTEND='non-interactive'
echo -e "slapd slapd/root_password password ${var.manager_password}" |debconf-set-selections
echo -e "slapd slapd/root_password_again password ${var.manager_password}" |debconf-set-selections
apt-get install -y slapd ldap-utils
echo -e "slapd slapd/internal/adminpw password ${var.manager_password}" |debconf-set-selections
echo -e "slapd slapd/internal/generated_adminpw password ${var.manager_password}" |debconf-set-selections
echo -e "slapd slapd/password2 password ${var.manager_password}" |debconf-set-selections
echo -e "slapd slapd/password1 password ${var.manager_password}" |debconf-set-selections
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
ldapadd -x -D cn=admin,dc=${var.ldap_domain_controller},dc=com -w ${var.manager_password} -f /opt/base-ou-groups.ldif
cat << EOS > /opt/group.ldif
dn: cn=${var.user_group},ou=Groups,dc=${var.ldap_domain_controller},dc=com
objectClass: posixGroup
cn: ${var.user_group}
gidNumber: 5000
EOS
if ldapsearch -x -D cn=admin,dc=${var.ldap_domain_controller},dc=com -w ${var.manager_password} -b "ou=groups,dc=${var.ldap_domain_controller},dc=com" "(objectClass=posixGroup)" | grep ${var.user_group};then
  echo "user group created"
else
  echo "user group created"
fi
ldapadd -x -D cn=admin,dc=${var.ldap_domain_controller},dc=com -w ${var.manager_password} -f /opt/group.ldif 
   
defaultuser_password_hash=`slappasswd -s ${var.default_user_password}`
cat << EOS > /opt/user.ldif
dn: uid=${var.default_user},ou=People,dc=${var.ldap_domain_controller},dc=com
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: ${var.default_user}
sn: ${var.default_user}
givenName: ${var.default_user}
cn: ${var.default_user}
displayName: ${var.default_user}
uidNumber: 1100
gidNumber: 5000
userPassword: $defaultuser_password_hash
gecos: ${var.default_user}
loginShell: /bin/bash
homeDirectory: /home/${var.default_user}
EOS
ldapadd -x -D cn=admin,dc=${var.ldap_domain_controller},dc=com -w ${var.manager_password} -f /opt/user.ldif 
if ldapsearch -x -LLL -b "ou=People,dc=${var.ldap_domain_controller},dc=com" "(objectClass=posixAccount)" uid cn | grep ${var.default_user};then
  echo "user created"
else
  echo "user not created"
fi
#Install samba
apt-get install -y samba
echo "${var.meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
EOF
}

data "template_cloudinit_config" "user_data64" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
  }
}

# Creates Open LDAP instance
resource "aws_instance" "itself" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.user_public_key
  subnet_id         = var.subnet_id
  security_groups   = var.security_groups
  availability_zone = var.availability_zone
  root_block_device {
    volume_type           = var.root_volume_type
    delete_on_termination = true
  }

  user_data_base64 = data.template_cloudinit_config.user_data64.rendered

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = var.name_prefix
  }

  lifecycle {
    ignore_changes = all
  }
}

# Create "A" (IPv4 Address) record to map IPv4 address as hostname along with domain
resource "aws_route53_record" "a_itself" {
  zone_id = var.forward_dns_zone
  type    = "A"
  name    = var.name_prefix
  records = [aws_instance.itself.private_ip]
  ttl     = 360
}

# Create "PTR" (Pointer) to enables reverse DNS lookup, from an IP address to a hostname
resource "aws_route53_record" "ptr_itself" {
  zone_id = var.reverse_dns_zone
  type    = "PTR"
  name    = format("%s.%s.%s.%s", split(".", aws_instance.itself.private_ip)[3], split(".", aws_instance.itself.private_ip)[2], split(".", aws_instance.itself.private_ip)[1], var.reverse_dns_domain)
  records = [format("%s.%s", var.name_prefix, var.dns_domain)]
  ttl     = 360
}

/*
 # Wait till cloudinit provision finish
 resource "null_resource" "waitcloudinit" {
   connection {
     type        = "ssh"
     user        = var.login_username
     private_key = file(var.user_private_key)
     host        = azurerm_linux_virtual_machine.itself.public_ip_address
     timeout     = 1200
   }

   #  Alternativly we can use #cloud-init status --wait , command instead of file /tmp/cloudinitdone creation wait
   provisioner "remote-exec" {
     inline = [
       "while [ ! -f /tmp/cloudinitdone ]; do echo 'waiting for cloudinit provision..' ;sleep 40; done",
       "touch /tmp/remoteexecdone",
       "sleep 20"
     ]
   }

   depends_on = [azurerm_linux_virtual_machine.itself]
 }
*/

output "instance_details" {
  value = {
    private_ip = aws_instance.itself.private_ip
    id         = aws_instance.itself.id
    dns        = format("%s-", var.name_prefix)
    zone       = aws_instance.itself.availability_zone
  }
}
