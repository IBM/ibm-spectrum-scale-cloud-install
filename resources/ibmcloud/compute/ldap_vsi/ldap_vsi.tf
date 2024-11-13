/*
    Creates a Bastion/Jump Host Instance.
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
variable "zones" {}
variable "vsi_subnet_id" {}
variable "vsi_security_group" {}
variable "vsi_profile" {}
variable "vsi_image_id" {}
variable "vsi_user_public_key" {}
variable "resource_group_id" {}
variable "resource_tags" {}
variable "vsi_meta_private_key" {}
variable "vsi_meta_public_key" {}
variable "ldap_basedns" {}
variable "ldap_admin_password" {}

data "template_file" "metadata_startup_script" {
  template = <<-EOF
#!/usr/bin/env bash

# USER=ubuntu
# basedns="${var.ldap_basedns}"
# logfile="/tmp/user_data.log"

# basedomain=$(echo "$basedns" | awk -F'.' '{print $1}')
# rootdomain=$(echo "$basedns" | awk -F'.' '{print $2}')

# # Install required software
# apt-get update -y
# apt-get install gnutls-bin ssl-cert nfs-common -y
# echo "Installed pre-reqiured softwares" >> $logfile

# # LDAP installation and configuration
# export DEBIAN_FRONTEND='non-interactive'
# echo -e "slapd slapd/root_password password ${var.ldap_admin_password}" |debconf-set-selections
# echo -e "slapd slapd/root_password_again password ${var.ldap_admin_password}" |debconf-set-selections
# apt-get install -y slapd ldap-utils
# echo "Installed OpenLDAP" >> $logfile

# echo -e "slapd slapd/internal/adminpw password ${var.ldap_admin_password}" |debconf-set-selections
# echo -e "slapd slapd/internal/generated_adminpw password ${var.ldap_admin_password}" |debconf-set-selections
# echo -e "slapd slapd/password2 password ${var.ldap_admin_password}" |debconf-set-selections
# echo -e "slapd slapd/password1 password ${var.ldap_admin_password}" |debconf-set-selections
# echo -e "slapd slapd/domain string ${var.ldap_basedns}" |debconf-set-selections
# echo -e "slapd shared/organization string ${var.ldap_basedns}" |debconf-set-selections
# echo -e "slapd slapd/purge_database boolean false" |debconf-set-selections
# echo -e "slapd slapd/move_old_database boolean true" |debconf-set-selections
# echo -e "slapd slapd/no_configuration boolean false" |debconf-set-selections
# dpkg-reconfigure slapd
# echo "BASE   dc=$basedomain,dc=$rootdomain" >> /etc/ldap/ldap.conf
# echo "URI    ldap://localhost" >> /etc/ldap/ldap.conf
# systemctl restart slapd
# echo "Started OpenLDAP service" >> $logfile

# # SSL certificate generation and OpenLDAP configuration
# echo "Creating SSL certificate" >> $logfile
# certtool --generate-privkey --sec-param High --outfile /etc/ssl/private/ldap_cakey.pem

# # Create CA template file
# cat <<-EOF_CA_INFO > /etc/ssl/ca.info
# cn = ${var.vsi_name_prefix}
# ca
# cert_signing_key
# expiration_days = 3650
# EOF_CA_INFO

# # Generate a self-signed CA certificate
# certtool --generate-self-signed \
#   --load-privkey /etc/ssl/private/ldap_cakey.pem \
#   --template /etc/ssl/ca.info \
#   --outfile /usr/local/share/ca-certificates/ldap_cacert.pem

# # Update CA certificates
# update-ca-certificates
# cp /usr/local/share/ca-certificates/ldap_cacert.pem /etc/ssl/certs/

# # Generate a private key and certificate for the LDAP server
# certtool --generate-privkey --sec-param High --outfile /etc/ssl/private/ldapserver_slapd_key.pem
# cat <<-EOF_LDAP_SERVER_INFO > /etc/ssl/ldapserver.info
# organization = ${var.vsi_name_prefix}
# cn = localhost
# tls_www_server
# encryption_key
# signing_key
# expiration_days = 3650
# EOF_LDAP_SERVER_INFO
# echo "Generated a private key and certificate for the LDAP server" >> $logfile

# # Generate a certificate for the LDAP server signed by the CA
# certtool --generate-certificate \
#   --load-privkey /etc/ssl/private/ldapserver_slapd_key.pem \
#   --load-ca-certificate /etc/ssl/certs/ldap_cacert.pem \
#   --load-ca-privkey /etc/ssl/private/ldap_cakey.pem \
#   --template /etc/ssl/ldapserver.info \
#   --outfile /etc/ssl/certs/ldapserver_slapd_cert.pem
# echo "Generated a certificate for the LDAP server signed by the CA" >> $logfile

# # Set proper permissions for the LDAP server private key
# chgrp openldap /etc/ssl/private/ldapserver_slapd_key.pem
# chmod 0640 /etc/ssl/private/ldapserver_slapd_key.pem
# gpasswd -a openldap ssl-cert
# echo "Applied TLS configuration" >> $logfile

# # Apply TLS configuration and restart slapd service
# systemctl restart slapd.service
# echo "Restarted the OpenLDAP service" >> $logfile


# # Configure OpenLDAP to use TLS
# cat <<-EOF_LDIF > /etc/ssl/certinfo.ldif
# dn: cn=config
# add: olcTLSCACertificateFile
# olcTLSCACertificateFile: /etc/ssl/certs/ldap_cacert.pem
# -
# add: olcTLSCertificateFile
# olcTLSCertificateFile: /etc/ssl/certs/ldapserver_slapd_cert.pem
# -
# add: olcTLSCertificateKeyFile
# olcTLSCertificateKeyFile: /etc/ssl/private/ldapserver_slapd_key.pem
# EOF_LDIF

# ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/ssl/certinfo.ldif
# sed -i 's|SLAPD_SERVICES="ldap:/// ldapi:///"|SLAPD_SERVICES="ldap:/// ldapi:/// ldaps:///"|g' /etc/default/slapd
# echo "Configured OpenLDAP to use TLS" >> $logfile

# # Update LDAP client configuration
# cat <<-EOF_LDAP_CONF >> /etc/ldap/ldap.conf
# TLS_CACERT /etc/ssl/certs/ldap_cacert.pem
# TLS_REQCERT allow
# EOF_LDAP_CONF

# # Restart the OpenLDAP service
# systemctl restart slapd.service
# echo "SSL creation completed" >> $logfile

# Configure SSH settings
sed -i -e "s/^/no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo 'Please login as the user \\\\\"$USER\\\\\" rather than the user \\\\\"root\\\\\".';echo;sleep 10; exit 142\" /" /root/.ssh/authorized_keys
sed -i "s/#MaxSessions 10/MaxSessions 32/" /etc/ssh/sshd_config
sed -i "s/#MaxStartups 10:30:100/MaxStartups 30:30:100/" /etc/ssh/sshd_config
systemctl restart sshd.service
echo "Restarted SSHD service" >> $logfile

# Set up passwordless SSH authentication
echo "${var.vsi_meta_private_key}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "${var.vsi_meta_public_key}" >> ~/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> ~/.ssh/config
echo "Keys added to the server for passwordless authentication !!" >> $logfile
EOF
}

# Resource definition for the VSI instance
resource "ibm_is_instance" "itself" {
  name    = var.vsi_name_prefix
  image   = var.vsi_image_id
  profile = var.vsi_profile
  tags    = var.resource_tags

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
  value = ibm_is_instance.itself.primary_network_interface[0].primary_ip[0].address
}

output "vsi_nw_id" {
  value = ibm_is_instance.itself.primary_network_interface[0].id
}